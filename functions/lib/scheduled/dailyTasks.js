"use strict";
/**
 * Daily Scheduled Tasks
 *
 * Runs every day at midnight (or configured time) to:
 * - Distribute weekly bonuses
 * - Cleanup old data
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.dailyCleanup = exports.weeklyTasks = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestore_1 = require("firebase-admin/firestore");
const db = (0, firestore_1.getFirestore)();
/**
 * Weekly Bonus Distribution (Runs every Sunday at 00:00 UTC)
 * Note: While we have a manual claim button, this can enable auto-distribution
 * or just notifications. For now, it logs eligibility.
 */
exports.weeklyTasks = (0, scheduler_1.onSchedule)({
    schedule: '0 0 * * 0', // Every Sunday at midnight
    timeZone: 'UTC',
}, async () => {
    console.log('Running weekly tasks...');
    // Potentially cleanup old notifications or logs here
    // Or identify top players for leaderboard snapshots
});
/**
 * Daily Cleanup (Runs every day at 04:00 UTC)
 */
exports.dailyCleanup = (0, scheduler_1.onSchedule)({
    schedule: '0 4 * * *',
    timeZone: 'UTC',
}, async () => {
    console.log('Running daily cleanup...');
    // Cleanup expired transfer records older than 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const oldTransfers = await db.collection('diamond_transfers')
        .where('status', 'in', ['completed', 'cancelled', 'expired'])
        .where('createdAt', '<', firestore_2.Timestamp.fromDate(thirtyDaysAgo))
        .limit(500)
        .get();
    if (!oldTransfers.empty) {
        const batch = db.batch();
        oldTransfers.docs.forEach(doc => batch.delete(doc.ref));
        await batch.commit();
        console.log(`Cleaned up ${oldTransfers.size} old transfer records`);
    }
    // Cleanup claimed reward logs older than 60 days
    const sixtyDaysAgo = new Date();
    sixtyDaysAgo.setDate(sixtyDaysAgo.getDate() - 60);
    const oldRewards = await db.collection('diamond_rewards')
        .where('claimedAt', '<', firestore_2.Timestamp.fromDate(sixtyDaysAgo))
        .limit(500)
        .get();
    if (!oldRewards.empty) {
        const batch = db.batch();
        oldRewards.docs.forEach(doc => batch.delete(doc.ref));
        await batch.commit();
        console.log(`Cleaned up ${oldRewards.size} old reward logs`);
    }
});
const firestore_2 = require("firebase-admin/firestore");
//# sourceMappingURL=dailyTasks.js.map