"use strict";
/**
 * Scheduled Economy Jobs
 *
 * 1. Automatic Tier Upgrades (Verified -> Trusted)
 * 2. Supply Monitoring (Daily Audit)
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.monitorDiamondSupply = exports.checkTierUpgrade = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = __importStar(require("firebase-admin"));
const utils_1 = require("./utils");
// Lazy initialization
const getDb = () => admin.firestore();
// ============ AUTOMATIC TIER UPGRADE CHECK ============
// Runs every hour to promote eligible users
exports.checkTierUpgrade = (0, scheduler_1.onSchedule)({
    schedule: '0 * * * *', // Every hour
    timeZone: 'Asia/Kolkata',
}, async (event) => {
    // Check 'verified' users for promotion to 'trusted'
    const verifiedUsersSnapshot = await getDb()
        .collection('users')
        .where('tier', '==', 'verified')
        .get();
    const batch = getDb().batch();
    let upgradeCount = 0;
    for (const doc of verifiedUsersSnapshot.docs) {
        const user = doc.data();
        // Trusted requirements:
        // 1. 100+ games played
        // 2. Account age >= 60 days
        // 3. No violations
        const accountAgeDays = (0, utils_1.daysSince)(user.createdAt?.toDate ? user.createdAt.toDate() : new Date(user.createdAt));
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
exports.monitorDiamondSupply = (0, scheduler_1.onSchedule)({
    schedule: '0 0 * * *', // Daily at midnight
    timeZone: 'Asia/Kolkata',
}, async (event) => {
    try {
        // 1. Calculate Circulating Supply
        // NOTE: In a massive app, scanning all users is expensive. 
        const aggregateSnapshot = await getDb().collection('users').count().get();
        const userCount = aggregateSnapshot.data().count;
        const sumSnapshot = await getDb().collection('users').aggregate({
            totalBalance: admin.firestore.AggregateField.sum('diamondBalance')
        }).get();
        const totalSupply = sumSnapshot.data().totalBalance || 0;
        // 2. Get yesterday's supply to calc inflation
        const metricsRef = getDb().collection('supply_metrics');
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
            await (0, utils_1.sendAdminAlert)({
                type: 'HIGH_INFLATION',
                message: `Daily inflation at ${dailyInflation.toFixed(2)}%`,
                data: { totalSupply, dailyChange }
            });
        }
        // 5. Reset Daily Limits for all users
        await (0, utils_1.resetDailyLimits)();
        console.log('Daily supply monitoring and limit reset completed.');
    }
    catch (e) {
        console.error('Error in monitorDiamondSupply:', e);
    }
});
//# sourceMappingURL=scheduled.js.map