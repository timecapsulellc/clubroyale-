/**
 * Social Diamond Rewards Cloud Functions
 *
 * Part of Diamond Revenue Model V5 - Social Enhancements
 * Handles server-side validation and scheduled engagement tier calculations.
 */
/**
 * Generic social reward granting function
 * Called by client after completing a social action
 */
export declare const grantSocialRewardFunction: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    reason: string;
    amount?: undefined;
} | {
    success: boolean;
    amount: number;
    reason?: undefined;
}>, unknown>;
/**
 * Process voice room tip with 5% platform fee
 */
export declare const processVoiceRoomTip: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    reason: string;
    grossAmount?: undefined;
    fee?: undefined;
    netAmount?: undefined;
    showAnimation?: undefined;
    isSuperTip?: undefined;
} | {
    success: boolean;
    grossAmount: any;
    fee: number;
    netAmount: number;
    showAnimation: boolean;
    isSuperTip: boolean;
    reason?: undefined;
}>, unknown>;
/**
 * Weekly engagement tier calculation
 * Runs every Sunday at 23:00 UTC
 */
export declare const calculateWeeklyEngagement: import("firebase-functions/v2/scheduler").ScheduleFunction;
/**
 * Monthly milestone calculation
 * Runs on the 1st of each month at 00:30 UTC
 */
export declare const calculateMonthlyMilestones: import("firebase-functions/v2/scheduler").ScheduleFunction;
//# sourceMappingURL=social.d.ts.map