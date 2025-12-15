/**
 * Admin Diamond Cloud Functions
 *
 * Handles admin grant execution after cooling period
 */
/**
 * Execute grant when fully approved (no cooling period)
 */
export declare const onGrantApproved: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").Change<import("firebase-functions/v2/firestore").QueryDocumentSnapshot> | undefined, {
    requestId: string;
}>>;
/**
 * Execute grants that passed cooling period (runs every hour)
 */
export declare const executeCooledGrants: import("firebase-functions/v2/scheduler").ScheduleFunction;
/**
 * Send notification to admins for new chat messages
 */
export declare const notifyAdminNewChat: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").Change<import("firebase-functions/v2/firestore").QueryDocumentSnapshot> | undefined, {
    chatId: string;
}>>;
//# sourceMappingURL=diamondAdmin.d.ts.map