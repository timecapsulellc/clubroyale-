/**
 * Revenue Tracking Functions
 * 
 * Tracks all revenue events for analytics and reporting.
 */

import { onCall } from "firebase-functions/v2/https";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getFirestore, FieldValue, Timestamp, Transaction } from "firebase-admin/firestore";

const db = getFirestore();

interface RevenueEvent {
    type: 'purchase' | 'subscription' | 'ad_revenue';
    amount: number;
    currency: string;
    userId: string;
    productId?: string;
    source: string;
    timestamp: Timestamp;
    metadata?: Record<string, unknown>;
}

interface RevenueSnapshot {
    date: string;
    totalRevenue: number;
    purchaseRevenue: number;
    adRevenue: number;
    transactions: number;
    arpu: number; // Average Revenue Per User
    arppu: number; // Average Revenue Per Paying User
    payingUsers: number;
    currency: string;
}

/**
 * Track a revenue event
 */
export const trackRevenueEvent = onCall<{
    type: 'purchase' | 'subscription' | 'ad_revenue';
    amount: number;
    currency: string;
    productId?: string;
    source: string;
    metadata?: Record<string, unknown>;
}>(
    { region: "us-central1" },
    async (request) => {
        if (!request.auth) {
            return { success: false, error: "Unauthenticated" };
        }

        const { type, amount, currency, productId, source, metadata } = request.data;

        const event: RevenueEvent = {
            type,
            amount,
            currency,
            userId: request.auth.uid,
            productId,
            source,
            timestamp: Timestamp.now(),
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
                    totalRevenue: FieldValue.increment(amount),
                    [type === 'ad_revenue' ? 'adRevenue' : 'purchaseRevenue']: FieldValue.increment(amount),
                    transactions: FieldValue.increment(1),
                    [`users.${request.auth!.uid}`]: true,
                    lastUpdated: FieldValue.serverTimestamp(),
                });
            } else {
                tx.set(dailyRef, {
                    date: today,
                    totalRevenue: amount,
                    purchaseRevenue: type === 'purchase' || type === 'subscription' ? amount : 0,
                    adRevenue: type === 'ad_revenue' ? amount : 0,
                    transactions: 1,
                    users: { [request.auth!.uid]: true },
                    currency,
                    createdAt: FieldValue.serverTimestamp(),
                    lastUpdated: FieldValue.serverTimestamp(),
                });
            }
        });

        console.log(`[Revenue] ${type}: $${amount} ${currency} from ${request.auth.uid}`);
        return { success: true };
    }
);

/**
 * Track purchase completion automatically
 */
export const onPurchaseCompleted = onDocumentCreated(
    "purchases/{purchaseId}",
    async (event) => {
        const purchase = event.data?.data();
        if (!purchase) return;

        const revenueEvent: Omit<RevenueEvent, 'timestamp'> = {
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
            timestamp: FieldValue.serverTimestamp(),
        });

        // Update LTV for user
        const userRef = db.collection("users").doc(purchase.userId);
        await userRef.update({
            lifetimeValue: FieldValue.increment(purchase.price || 0),
            purchaseCount: FieldValue.increment(1),
            lastPurchaseAt: FieldValue.serverTimestamp(),
        });

        console.log(`[Revenue] Purchase tracked: ${purchase.productId} - $${purchase.price}`);
    }
);

/**
 * Get revenue dashboard data
 */
export const getRevenueDashboard = onCall<
    { days?: number },
    Promise<{ snapshots: RevenueSnapshot[]; summary: Record<string, number> }>
>(
    { region: "us-central1" },
    async (request) => {
        const days = request.data.days || 30;
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);
        const startDateStr = startDate.toISOString().split("T")[0];

        const dailySnap = await db
            .collection("revenue_daily")
            .where("date", ">=", startDateStr)
            .orderBy("date", "desc")
            .get();

        const snapshots: RevenueSnapshot[] = [];
        let totalRevenue = 0;
        let totalPurchaseRevenue = 0;
        let totalAdRevenue = 0;
        let totalTransactions = 0;
        const payingUserSet = new Set<string>();

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
    }
);

/**
 * Calculate monthly MRR (Monthly Recurring Revenue)
 */
export const calculateMrr = onCall<void, Promise<{
    mrr: number;
    subscribers: number;
    churnRate: number;
}>>(
    { region: "us-central1" },
    async () => {
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
            .where("cancelledAt", ">=", Timestamp.fromDate(thirtyDaysAgo))
            .count()
            .get();

        const startOfMonthSubs = await db
            .collection("subscriptions")
            .where("createdAt", "<", Timestamp.fromDate(thirtyDaysAgo))
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
    }
);
