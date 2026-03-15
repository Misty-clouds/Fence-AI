import { NextRequest, NextResponse } from "next/server";
import { buildInterswitchCheckoutPayload } from "@/lib/interswitch";

type InitializeRequestBody = {
  amount?: number;
  serviceId?: string;
  customerEmail?: string;
  customerName?: string;
  currency?: number;
  redirectUrl?: string;
  transactionReference?: string;
  metadata?: Record<string, unknown>;
};

export async function POST(request: NextRequest) {
  try {
    const body = (await request.json()) as InitializeRequestBody;

    if (!body.amount || body.amount <= 0) {
      return NextResponse.json(
        { error: "`amount` is required and must be greater than 0." },
        { status: 400 },
      );
    }

    if (!body.serviceId?.trim()) {
      return NextResponse.json(
        { error: "`serviceId` is required." },
        { status: 400 },
      );
    }

    const checkout = buildInterswitchCheckoutPayload({
      amount: body.amount,
      serviceId: body.serviceId.trim(),
      customerEmail: body.customerEmail?.trim(),
      customerName: body.customerName?.trim(),
      currency: body.currency,
      redirectUrl: body.redirectUrl?.trim(),
      transactionReference: body.transactionReference?.trim(),
      metadata: body.metadata,
    });

    return NextResponse.json({
      success: true,
      data: checkout,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to initialize InterSwitch checkout.";

    return NextResponse.json(
      {
        success: false,
        error: message,
      },
      { status: 500 },
    );
  }
}
