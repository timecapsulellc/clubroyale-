/**
 * Diamond Transfer Cloud Functions
 *
 * Handles P2P transfer completion and expiry
 */
/**
 * Complete transfer when both parties confirm
 */
export declare const onTransferConfirmed: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").Change<import("firebase-functions/v2/firestore").QueryDocumentSnapshot> | undefined, {
    transferId: string;
}>>;
/**
 * Expire stale transfers (runs every hour)
 */
export declare const expireStaleTransfers: import("firebase-functions/v2/scheduler").ScheduleFunction;
//# sourceMappingURL=diamondTransfers.d.ts.map