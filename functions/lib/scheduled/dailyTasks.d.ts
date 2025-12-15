/**
 * Daily Scheduled Tasks
 *
 * Runs every day at midnight (or configured time) to:
 * - Distribute weekly bonuses
 * - Cleanup old data
 */
/**
 * Weekly Bonus Distribution (Runs every Sunday at 00:00 UTC)
 * Note: While we have a manual claim button, this can enable auto-distribution
 * or just notifications. For now, it logs eligibility.
 */
export declare const weeklyTasks: import("firebase-functions/v2/scheduler").ScheduleFunction;
/**
 * Daily Cleanup (Runs every day at 04:00 UTC)
 */
export declare const dailyCleanup: import("firebase-functions/v2/scheduler").ScheduleFunction;
//# sourceMappingURL=dailyTasks.d.ts.map