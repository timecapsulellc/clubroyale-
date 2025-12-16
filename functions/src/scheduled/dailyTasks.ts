/**
 * Daily Scheduled Tasks
 * 
 * Runs every day at midnight (or configured time) to:
 * - Distribute weekly bonuses
 * - Cleanup old data
 */

import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

// Lazy initialization
const db = () => getFirestore();

/**
 * Weekly Bonus Distribution (Runs every Sunday at 00:00 UTC)
 * Note: While we have a manual claim button, this can enable auto-distribution
 * or just notifications. For now, it logs eligibility.
 */
export const weeklyTasks = onSchedule({
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
export const dailyCleanup = onSchedule({
    schedule: '0 4 * * *',
    timeZone: 'UTC',
}, async () => {
    console.log('Running daily cleanup...');

    // Cleanup expired transfer records older than 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const oldTransfers = await db().collection('diamond_transfers')
        .where('status', 'in', ['completed', 'cancelled', 'expired'])
        .where('createdAt', '<', Timestamp.fromDate(thirtyDaysAgo))
        .limit(500)
        .get();

    if (!oldTransfers.empty) {
        const batch = db().batch();
        oldTransfers.docs.forEach(doc => batch.delete(doc.ref));
        await batch.commit();
        console.log(`Cleaned up ${oldTransfers.size} old transfer records`);
    }

    // Cleanup claimed reward logs older than 60 days
    const sixtyDaysAgo = new Date();
    sixtyDaysAgo.setDate(sixtyDaysAgo.getDate() - 60);

    const oldRewards = await db().collection('diamond_rewards')
        .where('claimedAt', '<', Timestamp.fromDate(sixtyDaysAgo))
        .limit(500)
        .get();

    if (!oldRewards.empty) {
        const batch = db().batch();
        oldRewards.docs.forEach(doc => batch.delete(doc.ref));
        await batch.commit();
        console.log(`Cleaned up ${oldRewards.size} old reward logs`);
    }
});

import { Timestamp } from 'firebase-admin/firestore';
