/**
 * Diamond Transfer Validation & Execution
 *
 * P2P diamond transfers with:
 * - Tier-based limits
 * - 5% burn fee
 * - Full audit trail
 */
interface TransferResult {
    success: boolean;
    sent: number;
    received: number;
    feeBurned: number;
}
/**
 * Validate and execute P2P diamond transfer
 */
export declare const validateTransfer: import("firebase-functions/v2/https").CallableFunction<any, Promise<TransferResult>, unknown>;
export {};
//# sourceMappingURL=validateTransfer.d.ts.map