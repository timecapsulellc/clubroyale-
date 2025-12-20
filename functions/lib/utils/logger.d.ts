/**
 * Structured Logger
 * Provides consistent logging with severity levels and metadata
 */
/**
 * Logger class for consistent logging
 */
export declare class Logger {
    private functionName?;
    private userId?;
    private traceId?;
    constructor(options?: {
        functionName?: string;
        userId?: string;
        traceId?: string;
    });
    private log;
    debug(message: string, metadata?: Record<string, unknown>): void;
    info(message: string, metadata?: Record<string, unknown>): void;
    warn(message: string, metadata?: Record<string, unknown>): void;
    error(message: string, error?: Error, metadata?: Record<string, unknown>): void;
    critical(message: string, error?: Error, metadata?: Record<string, unknown>): void;
    /**
     * Create a child logger with additional context
     */
    child(options: {
        userId?: string;
        gameId?: string;
        traceId?: string;
    }): Logger;
}
/**
 * Create a logger for a specific function
 */
export declare function createLogger(functionName: string, userId?: string): Logger;
export default createLogger;
//# sourceMappingURL=logger.d.ts.map