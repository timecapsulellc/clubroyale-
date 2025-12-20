"use strict";
/**
 * Error Tracking Utility
 * Centralized error handling and reporting
 * Ready for Sentry integration
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.captureError = captureError;
exports.withErrorTracking = withErrorTracking;
exports.monitored = monitored;
const logger_1 = require("./logger");
const environments_1 = require("../config/environments");
/**
 * Generate unique error ID
 */
function generateErrorId() {
    return `err_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
}
/**
 * Create fingerprint for error deduplication
 */
function createFingerprint(error, context) {
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
async function captureError(error, context = {}, severity = 'error') {
    const config = (0, environments_1.getConfig)();
    const logger = (0, logger_1.createLogger)(context.functionName || 'errorTracker', context.userId);
    const errorId = generateErrorId();
    const trackedError = {
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
    }
    else if (severity === 'error') {
        logger.error(`[${errorId}] ${error.message}`, error, context.metadata);
    }
    else {
        logger.warn(`[${errorId}] ${error.message}`, context.metadata);
    }
    // In production, send to Sentry (when configured)
    if ((0, environments_1.isProduction)()) {
        await sendToSentry(trackedError);
    }
    return errorId;
}
/**
 * Send error to Sentry (placeholder - requires Sentry SDK setup)
 */
async function sendToSentry(trackedError) {
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
function withErrorTracking(fn, functionName) {
    return (async (...args) => {
        try {
            return await fn(...args);
        }
        catch (error) {
            const userId = args[1]?.auth?.uid; // Assumes onCall context pattern
            await captureError(error, {
                functionName,
                userId,
                metadata: { args: args.length > 0 ? 'present' : 'none' },
            });
            throw error;
        }
    });
}
/**
 * Create a monitored async operation
 */
async function monitored(operation, context) {
    const startTime = Date.now();
    const logger = (0, logger_1.createLogger)(context.functionName || 'monitored', context.userId);
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
    }
    catch (error) {
        const duration = Date.now() - startTime;
        await captureError(error, {
            ...context,
            metadata: { ...context.metadata, duration },
        });
        throw error;
    }
}
exports.default = captureError;
//# sourceMappingURL=errorTracking.js.map