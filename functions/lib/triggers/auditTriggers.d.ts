/**
 * Trigger: Audit Game Updates
 *
 * Listens for changes in the 'games' collection.
 * Detects moves, calculates latency, and logs to the audit system.
 */
export declare const auditGameUpdate: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").Change<import("firebase-functions/v2/firestore").QueryDocumentSnapshot> | undefined, {
    gameId: string;
}>>;
//# sourceMappingURL=auditTriggers.d.ts.map