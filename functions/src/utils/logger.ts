/**
 * Structured Logger
 * Provides consistent logging with severity levels and metadata
 */

import { getConfig, isFeatureEnabled } from '../config/environments';

type LogSeverity = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR' | 'CRITICAL';

interface LogEntry {
    severity: LogSeverity;
    message: string;
    timestamp: string;
    environment: string;
    functionName?: string;
    userId?: string;
    gameId?: string;
    traceId?: string;
    error?: {
        name: string;
        message: string;
        stack?: string;
    };
    metadata?: Record<string, unknown>;
}

/**
 * Create a structured log entry
 */
function createLogEntry(
    severity: LogSeverity,
    message: string,
    context?: Partial<LogEntry>
): LogEntry {
    const config = getConfig();

    return {
        severity,
        message,
        timestamp: new Date().toISOString(),
        environment: config.name,
        ...context,
    };
}

/**
 * Format and output log entry
 */
function outputLog(entry: LogEntry): void {
    const config = getConfig();

    // In production, use structured JSON for Cloud Logging
    if (config.isProduction) {
        console.log(JSON.stringify(entry));
        return;
    }

    // In development, use readable format
    const prefix = `[${entry.severity}] [${entry.timestamp}]`;
    const context = entry.userId ? ` [user:${entry.userId}]` : '';
    const game = entry.gameId ? ` [game:${entry.gameId}]` : '';

    if (entry.severity === 'ERROR' || entry.severity === 'CRITICAL') {
        console.error(`${prefix}${context}${game} ${entry.message}`, entry.error || '');
    } else if (entry.severity === 'WARN') {
        console.warn(`${prefix}${context}${game} ${entry.message}`);
    } else {
        console.log(`${prefix}${context}${game} ${entry.message}`);
    }

    // Log detailed metadata in dev mode
    if (isFeatureEnabled('enableDetailedLogging') && entry.metadata) {
        console.log('  Metadata:', JSON.stringify(entry.metadata, null, 2));
    }
}

/**
 * Logger class for consistent logging
 */
export class Logger {
    private functionName?: string;
    private userId?: string;
    private traceId?: string;

    constructor(options?: { functionName?: string; userId?: string; traceId?: string }) {
        this.functionName = options?.functionName;
        this.userId = options?.userId;
        this.traceId = options?.traceId;
    }

    private log(severity: LogSeverity, message: string, metadata?: Record<string, unknown>): void {
        const entry = createLogEntry(severity, message, {
            functionName: this.functionName,
            userId: this.userId,
            traceId: this.traceId,
            metadata,
        });
        outputLog(entry);
    }

    debug(message: string, metadata?: Record<string, unknown>): void {
        if (isFeatureEnabled('enableDetailedLogging')) {
            this.log('DEBUG', message, metadata);
        }
    }

    info(message: string, metadata?: Record<string, unknown>): void {
        this.log('INFO', message, metadata);
    }

    warn(message: string, metadata?: Record<string, unknown>): void {
        this.log('WARN', message, metadata);
    }

    error(message: string, error?: Error, metadata?: Record<string, unknown>): void {
        const entry = createLogEntry('ERROR', message, {
            functionName: this.functionName,
            userId: this.userId,
            traceId: this.traceId,
            error: error
                ? {
                    name: error.name,
                    message: error.message,
                    stack: error.stack,
                }
                : undefined,
            metadata,
        });
        outputLog(entry);
    }

    critical(message: string, error?: Error, metadata?: Record<string, unknown>): void {
        const entry = createLogEntry('CRITICAL', message, {
            functionName: this.functionName,
            userId: this.userId,
            traceId: this.traceId,
            error: error
                ? {
                    name: error.name,
                    message: error.message,
                    stack: error.stack,
                }
                : undefined,
            metadata,
        });
        outputLog(entry);
    }

    /**
     * Create a child logger with additional context
     */
    child(options: { userId?: string; gameId?: string; traceId?: string }): Logger {
        const logger = new Logger({
            functionName: this.functionName,
            userId: options.userId || this.userId,
            traceId: options.traceId || this.traceId,
        });
        return logger;
    }
}

/**
 * Create a logger for a specific function
 */
export function createLogger(functionName: string, userId?: string): Logger {
    return new Logger({ functionName, userId });
}

export default createLogger;
