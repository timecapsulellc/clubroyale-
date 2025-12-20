"use strict";
/**
 * Structured Logger
 * Provides consistent logging with severity levels and metadata
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.Logger = void 0;
exports.createLogger = createLogger;
const environments_1 = require("../config/environments");
/**
 * Create a structured log entry
 */
function createLogEntry(severity, message, context) {
    const config = (0, environments_1.getConfig)();
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
function outputLog(entry) {
    const config = (0, environments_1.getConfig)();
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
    }
    else if (entry.severity === 'WARN') {
        console.warn(`${prefix}${context}${game} ${entry.message}`);
    }
    else {
        console.log(`${prefix}${context}${game} ${entry.message}`);
    }
    // Log detailed metadata in dev mode
    if ((0, environments_1.isFeatureEnabled)('enableDetailedLogging') && entry.metadata) {
        console.log('  Metadata:', JSON.stringify(entry.metadata, null, 2));
    }
}
/**
 * Logger class for consistent logging
 */
class Logger {
    functionName;
    userId;
    traceId;
    constructor(options) {
        this.functionName = options?.functionName;
        this.userId = options?.userId;
        this.traceId = options?.traceId;
    }
    log(severity, message, metadata) {
        const entry = createLogEntry(severity, message, {
            functionName: this.functionName,
            userId: this.userId,
            traceId: this.traceId,
            metadata,
        });
        outputLog(entry);
    }
    debug(message, metadata) {
        if ((0, environments_1.isFeatureEnabled)('enableDetailedLogging')) {
            this.log('DEBUG', message, metadata);
        }
    }
    info(message, metadata) {
        this.log('INFO', message, metadata);
    }
    warn(message, metadata) {
        this.log('WARN', message, metadata);
    }
    error(message, error, metadata) {
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
    critical(message, error, metadata) {
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
    child(options) {
        const logger = new Logger({
            functionName: this.functionName,
            userId: options.userId || this.userId,
            traceId: options.traceId || this.traceId,
        });
        return logger;
    }
}
exports.Logger = Logger;
/**
 * Create a logger for a specific function
 */
function createLogger(functionName, userId) {
    return new Logger({ functionName, userId });
}
exports.default = createLogger;
//# sourceMappingURL=logger.js.map