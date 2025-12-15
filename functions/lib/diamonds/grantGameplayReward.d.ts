/**
 * Gameplay Reward Granting
 *
 * Securely grants diamonds for gameplay wins.
 * - Anti-cheat verification
 * - Tier-based daily earning caps
 * - Origin tracking (weighted higher for governance)
 */
interface GameplayRewardResponse {
    success: boolean;
    earned: number;
    message?: string;
    dailyTotal?: number;
    dailyCap?: number;
}
export declare const grantGameplayReward: import("firebase-functions/v2/https").CallableFunction<any, Promise<GameplayRewardResponse>, unknown>;
export {};
//# sourceMappingURL=grantGameplayReward.d.ts.map