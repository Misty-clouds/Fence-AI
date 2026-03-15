type InterswitchMode = "TEST" | "LIVE";

type InterswitchInitializeParams = {
  amount: number;
  serviceId: string;
  customerEmail?: string;
  customerName?: string;
  currency?: number;
  redirectUrl?: string;
  transactionReference?: string;
  metadata?: Record<string, unknown>;
};

type InterswitchVerifyParams = {
  amount: number;
  transactionReference: string;
};

const DEFAULT_CURRENCY = 566;

function getRequiredEnv(name: string): string {
  const value = process.env[name]?.trim();

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

export function getInterswitchConfig() {
  const merchantCode = getRequiredEnv("INTERSWITCH_MERCHANT_CODE");
  const payItemId = getRequiredEnv("INTERSWITCH_PAY_ITEM_ID");
  const redirectUrl = getRequiredEnv("INTERSWITCH_REDIRECT_URL");
  const mode = (process.env.INTERSWITCH_MODE?.trim().toUpperCase() || "TEST") as InterswitchMode;

  return {
    merchantCode,
    payItemId,
    redirectUrl,
    mode,
    checkoutUrl:
      mode === "LIVE"
        ? "https://newwebpay.interswitchng.com/collections/w/pay"
        : "https://newwebpay.qa.interswitchng.com/collections/w/pay",
    verificationBaseUrl:
      mode === "LIVE"
        ? "https://webpay.interswitchng.com"
        : "https://qa.interswitchng.com",
  };
}

export function generateTransactionReference(prefix = "fence") {
  const random = Math.random().toString(36).slice(2, 10);
  return `${prefix}_${Date.now()}_${random}`;
}

export function buildInterswitchCheckoutPayload(params: InterswitchInitializeParams) {
  const config = getInterswitchConfig();
  const transactionReference = params.transactionReference || generateTransactionReference();
  const amount = Math.round(params.amount);
  const currency = params.currency ?? DEFAULT_CURRENCY;
  const redirectUrl = params.redirectUrl || config.redirectUrl;

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Amount must be a positive integer in the smallest currency unit.");
  }

  const formFields: Record<string, string> = {
    merchant_code: config.merchantCode,
    pay_item_id: config.payItemId,
    site_redirect_url: redirectUrl,
    txn_ref: transactionReference,
    amount: String(amount),
    currency: String(currency),
  };

  if (params.customerEmail) {
    formFields.cust_email = params.customerEmail;
  }

  if (params.customerName) {
    formFields.cust_name = params.customerName;
  }

  if (params.serviceId) {
    formFields.payment_item = params.serviceId;
  }

  if (params.metadata && Object.keys(params.metadata).length > 0) {
    formFields.xml_data = JSON.stringify(params.metadata);
  }

  return {
    transactionReference,
    checkoutUrl: config.checkoutUrl,
    redirectUrl,
    mode: config.mode,
    formFields,
  };
}

export async function verifyInterswitchTransaction(params: InterswitchVerifyParams) {
  const config = getInterswitchConfig();
  const searchParams = new URLSearchParams({
    merchantcode: config.merchantCode,
    transactionreference: params.transactionReference,
    amount: String(Math.round(params.amount)),
  });

  const url = `${config.verificationBaseUrl}/collections/api/v1/gettransaction.json?${searchParams.toString()}`;

  const response = await fetch(url, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
    cache: "no-store",
  });

  const rawText = await response.text();
  let data: unknown = rawText;

  try {
    data = JSON.parse(rawText);
  } catch {}

  if (!response.ok) {
    throw new Error(`InterSwitch verification failed with status ${response.status}`);
  }

  return data;
}
