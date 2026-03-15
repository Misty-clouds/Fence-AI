import { NextRequest, NextResponse } from "next/server";
import { verifyInterswitchTransaction } from "@/lib/interswitch";

export async function GET(request: NextRequest) {
  try {
    const transactionReference = request.nextUrl.searchParams.get("transactionReference")?.trim();
    const amountParam = request.nextUrl.searchParams.get("amount")?.trim();
    const amount = amountParam ? Number(amountParam) : NaN;

    if (!transactionReference) {
      return NextResponse.json(
        { error: "`transactionReference` query param is required." },
        { status: 400 },
      );
    }

    if (!Number.isFinite(amount) || amount <= 0) {
      return NextResponse.json(
        { error: "`amount` query param is required and must be greater than 0." },
        { status: 400 },
      );
    }

    const verification = await verifyInterswitchTransaction({
      transactionReference,
      amount,
    });

    return NextResponse.json({
      success: true,
      data: verification,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Failed to verify InterSwitch transaction.";

    return NextResponse.json(
      {
        success: false,
        error: message,
      },
      { status: 500 },
    );
  }
}
