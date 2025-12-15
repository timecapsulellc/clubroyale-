/**
 * Diamond Rewards Cloud Functions
 *
 * Handles reward validation and granting for:
 * - Signup bonuses (triggered on user creation)
 * - Daily login claims
 * - Ad watch rewards
 * - Game completion rewards
 * - Referral bonuses
 */
/**
 * Grant signup bonus when a new user is created
 */
export declare const grantSignupBonus: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    userId: string;
}>>;
/**
 * Claim daily login bonus (callable)
 */
export declare const claimDailyLogin: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    reason: string;
    amount?: undefined;
} | {
    success: boolean;
    amount: number;
    reason?: undefined;
}>, unknown>;
/**
 * Claim ad watch reward (callable)
 */
export declare const claimAdReward: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    reason: string;
    amount?: undefined;
    remaining?: undefined;
} | {
    success: boolean;
    amount: number;
    remaining: number;
    reason?: undefined;
}>, unknown>;
/**
 * Grant game completion reward (triggered on game status change)
 */
export declare const grantGameReward: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").Change<import("firebase-functions/v2/firestore").QueryDocumentSnapshot> | undefined, {
    gameId: string;
}>>;
/**
 * Process referral bonus when new user joins with referral code
 */
export declare const processReferral: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    referralId: string;
}>>;
//# sourceMappingURL=diamondRewards.d.ts.map