"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRecentAgentErrors = exports.getAgentMetricsSummary = exports.recordAgentMetric = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const db = (0, firestore_1.getFirestore)();
/**
 * Record Agent Metric
 *
 * Logs agent invocations for performance tracking and debugging.
 * Call this from each agent after completing an action.
 */
exports.recordAgentMetric = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    const { agentName, action, durationMs, success, error, metadata } = request.data;
    const metric = {
        agentName,
        action,
        durationMs,
        success,
        error,
        userId: request.auth?.uid,
        metadata,
        timestamp: firestore_1.Timestamp.now(),
    };
    await db.collection("agent_metrics").add(metric);
    // Update daily aggregates
    const today = new Date().toISOString().split("T")[0];
    const aggRef = db.collection("agent_metrics_daily").doc(today);
    await db.runTransaction(async (tx) => {
        const doc = await tx.get(aggRef);
        if (doc.exists) {
            const data = doc.data();
            tx.update(aggRef, {
                totalCalls: firestore_1.FieldValue.increment(1),
                successCount: success ? firestore_1.FieldValue.increment(1) : firestore_1.FieldValue.increment(0),
                errorCount: success ? firestore_1.FieldValue.increment(0) : firestore_1.FieldValue.increment(1),
                totalDurationMs: firestore_1.FieldValue.increment(durationMs),
                [`agents.${agentName}`]: firestore_1.FieldValue.increment(1),
                [`actions.${action}`]: firestore_1.FieldValue.increment(1),
                lastUpdated: firestore_1.FieldValue.serverTimestamp(),
            });
        }
        else {
            tx.set(aggRef, {
                date: today,
                totalCalls: 1,
                successCount: success ? 1 : 0,
                errorCount: success ? 0 : 1,
                totalDurationMs: durationMs,
                agents: { [agentName]: 1 },
                actions: { [action]: 1 },
                createdAt: firestore_1.FieldValue.serverTimestamp(),
                lastUpdated: firestore_1.FieldValue.serverTimestamp(),
            });
        }
    });
    return { success: true };
});
/**
 * Get Agent Metrics Summary
 *
 * Returns aggregated agent metrics for the specified period.
 */
exports.getAgentMetricsSummary = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    const days = request.data.days || 7;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    const startDateStr = startDate.toISOString().split("T")[0];
    const dailySnap = await db
        .collection("agent_metrics_daily")
        .where("date", ">=", startDateStr)
        .get();
    let totalCalls = 0;
    let successCount = 0;
    let errorCount = 0;
    let totalDurationMs = 0;
    const callsByAgent = {};
    const callsByAction = {};
    for (const doc of dailySnap.docs) {
        const data = doc.data();
        totalCalls += data.totalCalls || 0;
        successCount += data.successCount || 0;
        errorCount += data.errorCount || 0;
        totalDurationMs += data.totalDurationMs || 0;
        // Aggregate agent counts
        if (data.agents) {
            for (const [agent, count] of Object.entries(data.agents)) {
                callsByAgent[agent] = (callsByAgent[agent] || 0) + count;
            }
        }
        // Aggregate action counts
        if (data.actions) {
            for (const [action, count] of Object.entries(data.actions)) {
                callsByAction[action] = (callsByAction[action] || 0) + count;
            }
        }
    }
    return {
        totalCalls,
        successRate: totalCalls > 0 ? (successCount / totalCalls) * 100 : 0,
        avgDurationMs: totalCalls > 0 ? totalDurationMs / totalCalls : 0,
        errorCount,
        callsByAgent,
        callsByAction,
        period: `${days} days`,
    };
});
/**
 * Get Recent Agent Errors
 *
 * Returns recent agent errors for debugging.
 */
exports.getRecentAgentErrors = (0, https_1.onCall)({ region: "us-central1" }, async (request) => {
    const limit = request.data.limit || 50;
    const errorsSnap = await db
        .collection("agent_metrics")
        .where("success", "==", false)
        .orderBy("timestamp", "desc")
        .limit(limit)
        .get();
    return errorsSnap.docs.map(doc => ({
        ...doc.data(),
        id: doc.id,
    }));
});
//# sourceMappingURL=agentMetrics.js.map