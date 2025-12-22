"use strict";
/**
 * Revenue Tracking Functions
 *
 * Tracks all revenue events for analytics and reporting.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.calculateMrr = exports.getRevenueDashboard = exports.onPurchaseCompleted = exports.trackRevenueEvent = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const db = (0, firestore_2.getFirestore)();
/**
 * Track a revenue event
 */
exports.trackRevenueEvent = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    if (!request.auth) {
        return { success: false, error: "Unauthenticated" };
    }
    const { type, amount, currency, productId, source, metadata } = request.data;
    const event = {
        type,
        amount,
        currency,
        userId: request.auth.uid,
        productId,
        source,
        timestamp: firestore_2.Timestamp.now(),
        metadata,
    };
    // Store revenue event
    await db.collection("revenue_events").add(event);
    // Update daily aggregate
    const today = new Date().toISOString().split("T")[0];
    const dailyRef = db.collection("revenue_daily").doc(today);
    await db.runTransaction(async (tx) => {
        const doc = await tx.get(dailyRef);
        if (doc.exists) {
            tx.update(dailyRef, {
                totalRevenue: firestore_2.FieldValue.increment(amount),
                [type === 'ad_revenue' ? 'adRevenue' : 'purchaseRevenue']: firestore_2.FieldValue.increment(amount),
                transactions: firestore_2.FieldValue.increment(1),
                [`users.${request.auth.uid}`]: true,
                lastUpdated: firestore_2.FieldValue.serverTimestamp(),
            });
        }
        else {
            tx.set(dailyRef, {
                date: today,
                totalRevenue: amount,
                purchaseRevenue: type === 'purchase' || type === 'subscription' ? amount : 0,
                adRevenue: type === 'ad_revenue' ? amount : 0,
                transactions: 1,
                users: { [request.auth.uid]: true },
                currency,
                createdAt: firestore_2.FieldValue.serverTimestamp(),
                lastUpdated: firestore_2.FieldValue.serverTimestamp(),
            });
        }
    });
    console.log(`[Revenue] ${type}: $${amount} ${currency} from ${request.auth.uid}`);
    return { success: true };
});
/**
 * Track purchase completion automatically
 */
exports.onPurchaseCompleted = (0, firestore_1.onDocumentCreated)("purchases/{purchaseId}", async (event) => {
    const purchase = event.data?.data();
    if (!purchase)
        return;
    const revenueEvent = {
        type: 'purchase',
        amount: purchase.price || 0,
        currency: purchase.currency || 'USD',
        userId: purchase.userId,
        productId: purchase.productId,
        source: 'in_app_purchase',
        metadata: {
            purchaseId: event.params.purchaseId,
            store: purchase.store,
        },
    };
    await db.collection("revenue_events").add({
        ...revenueEvent,
        timestamp: firestore_2.FieldValue.serverTimestamp(),
    });
    // Update LTV for user
    const userRef = db.collection("users").doc(purchase.userId);
    await userRef.update({
        lifetimeValue: firestore_2.FieldValue.increment(purchase.price || 0),
        purchaseCount: firestore_2.FieldValue.increment(1),
        lastPurchaseAt: firestore_2.FieldValue.serverTimestamp(),
    });
    console.log(`[Revenue] Purchase tracked: ${purchase.productId} - $${purchase.price}`);
});
/**
 * Get revenue dashboard data
 */
exports.getRevenueDashboard = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    const days = request.data.days || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    const startDateStr = startDate.toISOString().split("T")[0];
    const dailySnap = await db
        .collection("revenue_daily")
        .where("date", ">=", startDateStr)
        .orderBy("date", "desc")
        .get();
    const snapshots = [];
    let totalRevenue = 0;
    let totalPurchaseRevenue = 0;
    let totalAdRevenue = 0;
    let totalTransactions = 0;
    const payingUserSet = new Set();
    for (const doc of dailySnap.docs) {
        const data = doc.data();
        // Count paying users
        if (data.users) {
            Object.keys(data.users).forEach(uid => payingUserSet.add(uid));
        }
        snapshots.push({
            date: data.date,
            totalRevenue: data.totalRevenue || 0,
            purchaseRevenue: data.purchaseRevenue || 0,
            adRevenue: data.adRevenue || 0,
            transactions: data.transactions || 0,
            arpu: 0, // Calculated later
            arppu: 0, // Calculated later
            payingUsers: data.users ? Object.keys(data.users).length : 0,
            currency: data.currency || 'USD',
        });
        totalRevenue += data.totalRevenue || 0;
        totalPurchaseRevenue += data.purchaseRevenue || 0;
        totalAdRevenue += data.adRevenue || 0;
        totalTransactions += data.transactions || 0;
    }
    // Get total DAU for ARPU calculation
    const dauSnap = await db
        .collection("kpi_snapshots")
        .where("date", ">=", startDateStr)
        .get();
    let totalDau = 0;
    for (const doc of dauSnap.docs) {
        totalDau += doc.data().dau || 0;
    }
    const avgDau = totalDau / (dauSnap.docs.length || 1);
    const summary = {
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        purchaseRevenue: Math.round(totalPurchaseRevenue * 100) / 100,
        adRevenue: Math.round(totalAdRevenue * 100) / 100,
        transactions: totalTransactions,
        payingUsers: payingUserSet.size,
        arpu: avgDau > 0 ? Math.round((totalRevenue / avgDau) * 100) / 100 : 0,
        arppu: payingUserSet.size > 0 ? Math.round((totalRevenue / payingUserSet.size) * 100) / 100 : 0,
    };
    return { snapshots, summary };
});
/**
 * Calculate monthly MRR (Monthly Recurring Revenue)
 */
exports.calculateMrr = (0, https_1.onCall)({ region: "us-central1" }, async () => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    // Count active subscriptions
    const subsSnap = await db
        .collection("subscriptions")
        .where("status", "==", "active")
        .get();
    let mrr = 0;
    for (const doc of subsSnap.docs) {
        const sub = doc.data();
        // Convert to monthly if different billing period
        const monthlyAmount = sub.billingPeriod === 'yearly'
            ? sub.price / 12
            : sub.price;
        mrr += monthlyAmount;
    }
    // Calculate churn
    const cancelledSnap = await db
        .collection("subscriptions")
        .where("cancelledAt", ">=", firestore_2.Timestamp.fromDate(thirtyDaysAgo))
        .count()
        .get();
    const startOfMonthSubs = await db
        .collection("subscriptions")
        .where("createdAt", "<", firestore_2.Timestamp.fromDate(thirtyDaysAgo))
        .where("status", "==", "active")
        .count()
        .get();
    const churnRate = startOfMonthSubs.data().count > 0
        ? (cancelledSnap.data().count / startOfMonthSubs.data().count) * 100
        : 0;
    return {
        mrr: Math.round(mrr * 100) / 100,
        subscribers: subsSnap.docs.length,
        churnRate: Math.round(churnRate * 100) / 100,
    };
});
//# sourceMappingURL=revenueTracking.js.map