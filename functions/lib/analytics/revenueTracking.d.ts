/**
 * Revenue Tracking Functions
 *
 * Tracks all revenue events for analytics and reporting.
 */
interface RevenueSnapshot {
    date: string;
    totalRevenue: number;
    purchaseRevenue: number;
    adRevenue: number;
    transactions: number;
    arpu: number;
    arppu: number;
    payingUsers: number;
    currency: string;
}
/**
 * Track a revenue event
 */
export declare const trackRevenueEvent: import("firebase-functions/v2/https").CallableFunction<{
    type: "purchase" | "subscription" | "ad_revenue";
    amount: number;
    currency: string;
    productId?: string;
    source: string;
    metadata?: Record<string, unknown>;
}, any, unknown>;
/**
 * Track purchase completion automatically
 */
export declare const onPurchaseCompleted: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    purchaseId: string;
}>>;
/**
 * Get revenue dashboard data
 */
export declare const getRevenueDashboard: import("firebase-functions/v2/https").CallableFunction<{
    days?: number;
}, Promise<{
    snapshots: RevenueSnapshot[];
    summary: Record<string, number>;
}>, unknown>;
/**
 * Calculate monthly MRR (Monthly Recurring Revenue)
 */
export declare const calculateMrr: import("firebase-functions/v2/https").CallableFunction<void, Promise<{
    mrr: number;
    subscribers: number;
    churnRate: number;
}>, unknown>;
export {};
//# sourceMappingURL=revenueTracking.d.ts.map