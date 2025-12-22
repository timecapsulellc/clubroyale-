import { Timestamp } from "firebase-admin/firestore";
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
export declare const recordAgentMetric: import("firebase-functions/v2/https").CallableFunction<{
    agentName: string;
    action: string;
    durationMs: number;
    success: boolean;
    error?: string;
    metadata?: Record<string, unknown>;
}, any, unknown>;
/**
 * Get Agent Metrics Summary
 *
 * Returns aggregated agent metrics for the specified period.
 */
export declare const getAgentMetricsSummary: import("firebase-functions/v2/https").CallableFunction<{
    days?: number;
}, Promise<AgentMetricsSummary>, unknown>;
/**
 * Get Recent Agent Errors
 *
 * Returns recent agent errors for debugging.
 */
export declare const getRecentAgentErrors: import("firebase-functions/v2/https").CallableFunction<{
    limit?: number;
}, Promise<AgentMetric[]>, unknown>;
export {};
//# sourceMappingURL=agentMetrics.d.ts.map