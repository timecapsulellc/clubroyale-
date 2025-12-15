/**
 * Scheduled Economy Jobs
 * 
 * 1. Automatic Tier Upgrades (Verified -> Trusted)
 * 2. Supply Monitoring (Daily Audit)
 */

import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';
import { daysSince, sendAdminAlert, resetDailyLimits } from './utils';

const firestore = admin.firestore();

// ============ AUTOMATIC TIER UPGRADE CHECK ============
// Runs every hour to promote eligible users
export const checkTierUpgrade = onSchedule({
    schedule: '0 * * * *', // Every hour
    timeZone: 'Asia/Kolkata',
}, async (event) => {
    // Check 'verified' users for promotion to 'trusted'
    const verifiedUsersSnapshot = await firestore
        .collection('users')
        .where('tier', '==', 'verified')
        .get();

    const batch = firestore.batch();
    let upgradeCount = 0;

    for (const doc of verifiedUsersSnapshot.docs) {
        const user = doc.data();

        // Trusted requirements:
        // 1. 100+ games played
        // 2. Account age >= 60 days
        // 3. No violations

        const accountAgeDays = daysSince(user.createdAt?.toDate ? user.createdAt.toDate() : new Date(user.createdAt));

        if ((user.gamesPlayed || 0) >= 100 &&
            accountAgeDays >= 60 &&
            !user.hasViolations) {

            batch.update(doc.ref, {
                tier: 'trusted',
                trustedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            upgradeCount++;
        }
    }

    if (upgradeCount > 0) {
        await batch.commit();
        console.log(`Upgraded ${upgradeCount} users to Trusted tier.`);
    }
});

// ============ SUPPLY MONITORING & MAINTENANCE ============
// Runs daily at midnight to record economy stats and reset limits
export const monitorDiamondSupply = onSchedule({
    schedule: '0 0 * * *', // Daily at midnight
    timeZone: 'Asia/Kolkata',
}, async (event) => {
    try {
        // 1. Calculate Circulating Supply
        // NOTE: In a massive app, scanning all users is expensive. 
        const aggregateSnapshot = await firestore.collection('users').count().get();
        const userCount = aggregateSnapshot.data().count;

        const sumSnapshot = await firestore.collection('users').aggregate({
            totalBalance: admin.firestore.AggregateField.sum('diamondBalance')
        }).get();

        const totalSupply = sumSnapshot.data().totalBalance || 0;

        // 2. Get yesterday's supply to calc inflation
        const metricsRef = firestore.collection('supply_metrics');
        const lastMetricQuery = await metricsRef.orderBy('timestamp', 'desc').limit(1).get();
        let yesterdaySupply = 0;
        if (!lastMetricQuery.empty) {
            yesterdaySupply = lastMetricQuery.docs[0].data().totalSupply || 0;
        }

        const dailyChange = totalSupply - yesterdaySupply;
        const dailyInflation = yesterdaySupply > 0 ? (dailyChange / yesterdaySupply) * 100 : 0;

        // 3. Record Metrics
        await metricsRef.add({
            date: new Date().toISOString().split('T')[0],
            totalSupply: totalSupply,
            userCount: userCount,
            dailyChange: dailyChange,
            dailyInflationPercent: dailyInflation,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 4. Alert on High Inflation
        if (dailyInflation > 0.5) { // > 0.5% daily is huge
            await sendAdminAlert({
                type: 'HIGH_INFLATION',
                message: `Daily inflation at ${dailyInflation.toFixed(2)}%`,
                data: { totalSupply, dailyChange }
            });
        }

        // 5. Reset Daily Limits for all users
        await resetDailyLimits();

        console.log('Daily supply monitoring and limit reset completed.');

    } catch (e) {
        console.error('Error in monitorDiamondSupply:', e);
    }
});
