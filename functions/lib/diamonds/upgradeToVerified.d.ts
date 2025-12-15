/**
 * User Verification Upgrade
 *
 * Upgrades a user from 'Basic' to 'Verified'.
 * - Costs 100 diamonds (one-time fee)
 * - Requires prerequisite checks (phone verification)
 * - Burns the fee
 */
export declare const upgradeToVerified: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    newTier: string;
    feePaid: number;
    newLimits: import("./config").TierLimits;
}>, unknown>;
//# sourceMappingURL=upgradeToVerified.d.ts.map