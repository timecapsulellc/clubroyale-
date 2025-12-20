/**
 * Metrics Collection Utility
 * Performance and business metrics tracking
 */
interface MetricData {
    name: string;
    value: number;
    labels?: Record<string, string>;
    timestamp?: Date;
}
interface PerformanceMetric {
    functionName: string;
    duration: number;
    success: boolean;
    userId?: string;
    metadata?: Record<string, unknown>;
}
/**
 * Record a custom metric
 */
export declare function recordMetric(metric: MetricData): Promise<void>;
/**
 * Record function performance
 */
export declare function recordPerformance(perf: PerformanceMetric): Promise<void>;
/**
 * Record a counter metric
 */
export declare function incrementCounter(name: string, labels?: Record<string, string>): Promise<void>;
/**
 * Timer utility for measuring durations
 */
export declare class Timer {
    private startTime;
    private functionName;
    private userId?;
    constructor(functionName: string, userId?: string);
    stop(success?: boolean, metadata?: Record<string, unknown>): Promise<number>;
}
/**
 * Performance-tracked function wrapper
 */
export declare function withMetrics<T extends (...args: any[]) => Promise<any>>(fn: T, functionName: string): T;
/**
 * Business metrics helpers
 */
export declare const BusinessMetrics: {
    gameStarted(gameType: string, playerCount: number): Promise<void>;
    gameCompleted(gameType: string, duration: number): Promise<void>;
    userSignedIn(method: string): Promise<void>;
    botRoomJoined(gameType: string): Promise<void>;
    aiAgentAction(agentName: string, action: string, duration: number): Promise<void>;
    diamondTransaction(type: string, amount: number): Promise<void>;
};
export default recordMetric;
//# sourceMappingURL=metrics.d.ts.map