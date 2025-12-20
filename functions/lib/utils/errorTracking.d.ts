/**
 * Error Tracking Utility
 * Centralized error handling and reporting
 * Ready for Sentry integration
 */
interface ErrorContext {
    userId?: string;
    gameId?: string;
    functionName?: string;
    action?: string;
    metadata?: Record<string, unknown>;
}
/**
 * Capture and track an error
 */
export declare function captureError(error: Error, context?: ErrorContext, severity?: 'warning' | 'error' | 'critical'): Promise<string>;
/**
 * Wrap a function with error tracking
 */
export declare function withErrorTracking<T extends (...args: any[]) => Promise<any>>(fn: T, functionName: string): T;
/**
 * Create a monitored async operation
 */
export declare function monitored<T>(operation: () => Promise<T>, context: ErrorContext): Promise<T>;
export default captureError;
//# sourceMappingURL=errorTracking.d.ts.map