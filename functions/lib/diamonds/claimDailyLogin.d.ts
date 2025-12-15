/**
 * Daily Login Bonus
 *
 * Grants daily rewards with streak bonuses.
 * - Tracks consecutive login days
 * - Resets streak on missed days
 * - Awards milestone bonuses
 */
interface DailyLoginResponse {
    success: boolean;
    earned: number;
    baseReward: number;
    milestoneBonus: number;
    currentStreak: number;
    nextMilestone: number | null;
}
export declare const claimDailyLogin: import("firebase-functions/v2/https").CallableFunction<any, Promise<DailyLoginResponse>, unknown>;
export {};
//# sourceMappingURL=claimDailyLogin.d.ts.map