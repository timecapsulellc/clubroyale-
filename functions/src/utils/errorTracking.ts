/**
 * Error Tracking Utility
 * Centralized error handling and reporting
 * Ready for Sentry integration
 */

import { createLogger } from './logger';
import { getConfig, isProduction } from '../config/environments';

interface ErrorContext {
    userId?: string;
    gameId?: string;
    functionName?: string;
    action?: string;
    metadata?: Record<string, unknown>;
}

interface TrackedError {
    id: string;
    timestamp: string;
    environment: string;
    severity: 'warning' | 'error' | 'critical';
    error: {
        name: string;
        message: string;
        stack?: string;
    };
    context: ErrorContext;
    fingerprint?: string;
}

/**
 * Generate unique error ID
 */
function generateErrorId(): string {
    return `err_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Create fingerprint for error deduplication
 */
function createFingerprint(error: Error, context: ErrorContext): string {
    const parts = [
        error.name,
        error.message.substring(0, 100),
        context.functionName || 'unknown',
        context.action || 'unknown',
    ];
    return parts.join('|');
}

/**
 * Capture and track an error
 */
export async function captureError(
    error: Error,
    context: ErrorContext = {},
    severity: 'warning' | 'error' | 'critical' = 'error'
): Promise<string> {
    const config = getConfig();
    const logger = createLogger(context.functionName || 'errorTracker', context.userId);
    const errorId = generateErrorId();

    const trackedError: TrackedError = {
        id: errorId,
        timestamp: new Date().toISOString(),
        environment: config.name,
        severity,
        error: {
            name: error.name,
            message: error.message,
            stack: error.stack,
        },
        context,
        fingerprint: createFingerprint(error, context),
    };

    // Log the error
    if (severity === 'critical') {
        logger.critical(`[${errorId}] ${error.message}`, error, context.metadata);
    } else if (severity === 'error') {
        logger.error(`[${errorId}] ${error.message}`, error, context.metadata);
    } else {
        logger.warn(`[${errorId}] ${error.message}`, context.metadata);
    }

    // In production, send to Sentry (when configured)
    if (isProduction()) {
        await sendToSentry(trackedError);
    }

    return errorId;
}

/**
 * Send error to Sentry (placeholder - requires Sentry SDK setup)
 */
async function sendToSentry(trackedError: TrackedError): Promise<void> {
    // TODO: Integrate @sentry/node when Sentry DSN is configured
    // 
    // import * as Sentry from '@sentry/node';
    // 
    // Sentry.captureException(new Error(trackedError.error.message), {
    //   fingerprint: [trackedError.fingerprint],
    //   tags: {
    //     environment: trackedError.environment,
    //     severity: trackedError.severity,
    //     functionName: trackedError.context.functionName,
    //   },
    //   user: trackedError.context.userId ? { id: trackedError.context.userId } : undefined,
    //   extra: trackedError.context.metadata,
    // });

    // For now, just log that we would send to Sentry
    console.log(`[Sentry Placeholder] Would report error: ${trackedError.id}`);
}

/**
 * Wrap a function with error tracking
 */
export function withErrorTracking<T extends (...args: any[]) => Promise<any>>(
    fn: T,
    functionName: string
): T {
    return (async (...args: any[]) => {
        try {
            return await fn(...args);
        } catch (error) {
            const userId = args[1]?.auth?.uid; // Assumes onCall context pattern
            await captureError(error as Error, {
                functionName,
                userId,
                metadata: { args: args.length > 0 ? 'present' : 'none' },
            });
            throw error;
        }
    }) as T;
}

/**
 * Create a monitored async operation
 */
export async function monitored<T>(
    operation: () => Promise<T>,
    context: ErrorContext
): Promise<T> {
    const startTime = Date.now();
    const logger = createLogger(context.functionName || 'monitored', context.userId);

    try {
        const result = await operation();
        const duration = Date.now() - startTime;

        if (duration > 5000) {
            logger.warn(`Slow operation: ${context.action}`, {
                duration,
                ...context.metadata,
            });
        }

        return result;
    } catch (error) {
        const duration = Date.now() - startTime;
        await captureError(error as Error, {
            ...context,
            metadata: { ...context.metadata, duration },
        });
        throw error;
    }
}

export default captureError;
