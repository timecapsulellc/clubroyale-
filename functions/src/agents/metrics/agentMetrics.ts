import { onCall } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";

const db = getFirestore();

interface AgentMetric {
    id?: string;
    agentName: string;
    action: string;
    durationMs: number;
    success: boolean;
    error?: string;
    userId?: string;
    metadata?: Record<string, unknown>;
    timestamp: Timestamp;
}

interface AgentMetricsSummary {
    totalCalls: number;
    successRate: number;
    avgDurationMs: number;
    errorCount: number;
    callsByAgent: Record<string, number>;
    callsByAction: Record<string, number>;
    period: string;
}

/**
 * Record Agent Metric
 * 
 * Logs agent invocations for performance tracking and debugging.
 * Call this from each agent after completing an action.
 */
export const recordAgentMetric = onCall<{
    agentName: string;
    action: string;
    durationMs: number;
    success: boolean;
    error?: string;
    metadata?: Record<string, unknown>;
}>(
    { region: "us-central1" },
    async (request) => {
        const { agentName, action, durationMs, success, error, metadata } = request.data;

        const metric: AgentMetric = {
            agentName,
            action,
            durationMs,
            success,
            error,
            userId: request.auth?.uid,
            metadata,
            timestamp: Timestamp.now(),
        };

        await db.collection("agent_metrics").add(metric);

        // Update daily aggregates
        const today = new Date().toISOString().split("T")[0];
        const aggRef = db.collection("agent_metrics_daily").doc(today);

        await db.runTransaction(async (tx) => {
            const doc = await tx.get(aggRef);

            if (doc.exists) {
                const data = doc.data()!;
                tx.update(aggRef, {
                    totalCalls: FieldValue.increment(1),
                    successCount: success ? FieldValue.increment(1) : FieldValue.increment(0),
                    errorCount: success ? FieldValue.increment(0) : FieldValue.increment(1),
                    totalDurationMs: FieldValue.increment(durationMs),
                    [`agents.${agentName}`]: FieldValue.increment(1),
                    [`actions.${action}`]: FieldValue.increment(1),
                    lastUpdated: FieldValue.serverTimestamp(),
                });
            } else {
                tx.set(aggRef, {
                    date: today,
                    totalCalls: 1,
                    successCount: success ? 1 : 0,
                    errorCount: success ? 0 : 1,
                    totalDurationMs: durationMs,
                    agents: { [agentName]: 1 },
                    actions: { [action]: 1 },
                    createdAt: FieldValue.serverTimestamp(),
                    lastUpdated: FieldValue.serverTimestamp(),
                });
            }
        });

        return { success: true };
    }
);

/**
 * Get Agent Metrics Summary
 * 
 * Returns aggregated agent metrics for the specified period.
 */
export const getAgentMetricsSummary = onCall<
    { days?: number },
    Promise<AgentMetricsSummary>
>(
    { region: "us-central1" },
    async (request) => {
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
        const callsByAgent: Record<string, number> = {};
        const callsByAction: Record<string, number> = {};

        for (const doc of dailySnap.docs) {
            const data = doc.data();
            totalCalls += data.totalCalls || 0;
            successCount += data.successCount || 0;
            errorCount += data.errorCount || 0;
            totalDurationMs += data.totalDurationMs || 0;

            // Aggregate agent counts
            if (data.agents) {
                for (const [agent, count] of Object.entries(data.agents)) {
                    callsByAgent[agent] = (callsByAgent[agent] || 0) + (count as number);
                }
            }

            // Aggregate action counts
            if (data.actions) {
                for (const [action, count] of Object.entries(data.actions)) {
                    callsByAction[action] = (callsByAction[action] || 0) + (count as number);
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
    }
);

/**
 * Get Recent Agent Errors
 * 
 * Returns recent agent errors for debugging.
 */
export const getRecentAgentErrors = onCall<
    { limit?: number },
    Promise<AgentMetric[]>
>(
    { region: "us-central1" },
    async (request) => {
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
        })) as AgentMetric[];
    }
);
