"use strict";
/**
 * Metrics Collection Utility
 * Performance and business metrics tracking
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.BusinessMetrics = exports.Timer = void 0;
exports.recordMetric = recordMetric;
exports.recordPerformance = recordPerformance;
exports.incrementCounter = incrementCounter;
exports.withMetrics = withMetrics;
const admin = __importStar(require("firebase-admin"));
const environments_1 = require("../config/environments");
const logger_1 = require("./logger");
const logger = (0, logger_1.createLogger)('metrics');
/**
 * Record a custom metric
 */
async function recordMetric(metric) {
    if (!(0, environments_1.isFeatureEnabled)('enableMetrics')) {
        return;
    }
    const config = (0, environments_1.getConfig)();
    const db = admin.firestore();
    const metricEntry = {
        ...metric,
        timestamp: metric.timestamp || admin.firestore.FieldValue.serverTimestamp(),
        environment: config.name,
    };
    try {
        await db.collection('_metrics').add(metricEntry);
    }
    catch (error) {
        logger.warn('Failed to record metric', { metric: metric.name, error: error.message });
    }
}
/**
 * Record function performance
 */
async function recordPerformance(perf) {
    if (!(0, environments_1.isFeatureEnabled)('enableMetrics')) {
        return;
    }
    await recordMetric({
        name: `function.${perf.functionName}.duration`,
        value: perf.duration,
        labels: {
            success: String(perf.success),
            userId: perf.userId || 'anonymous',
        },
    });
    // Log slow functions
    if (perf.duration > 3000) {
        logger.warn(`Slow function: ${perf.functionName}`, {
            duration: perf.duration,
            ...perf.metadata,
        });
    }
}
/**
 * Record a counter metric
 */
async function incrementCounter(name, labels) {
    await recordMetric({
        name: `counter.${name}`,
        value: 1,
        labels,
    });
}
/**
 * Timer utility for measuring durations
 */
class Timer {
    startTime;
    functionName;
    userId;
    constructor(functionName, userId) {
        this.startTime = Date.now();
        this.functionName = functionName;
        this.userId = userId;
    }
    async stop(success = true, metadata) {
        const duration = Date.now() - this.startTime;
        await recordPerformance({
            functionName: this.functionName,
            duration,
            success,
            userId: this.userId,
            metadata,
        });
        return duration;
    }
}
exports.Timer = Timer;
/**
 * Performance-tracked function wrapper
 */
function withMetrics(fn, functionName) {
    return (async (...args) => {
        const userId = args[1]?.auth?.uid;
        const timer = new Timer(functionName, userId);
        try {
            const result = await fn(...args);
            await timer.stop(true);
            return result;
        }
        catch (error) {
            await timer.stop(false, { error: error.message });
            throw error;
        }
    });
}
/**
 * Business metrics helpers
 */
exports.BusinessMetrics = {
    async gameStarted(gameType, playerCount) {
        await incrementCounter('games.started', { gameType, playerCount: String(playerCount) });
    },
    async gameCompleted(gameType, duration) {
        await recordMetric({
            name: 'games.completed',
            value: duration,
            labels: { gameType },
        });
    },
    async userSignedIn(method) {
        await incrementCounter('users.signin', { method });
    },
    async botRoomJoined(gameType) {
        await incrementCounter('bot.room.joined', { gameType });
    },
    async aiAgentAction(agentName, action, duration) {
        await recordMetric({
            name: `agent.${agentName}.${action}`,
            value: duration,
        });
    },
    async diamondTransaction(type, amount) {
        await recordMetric({
            name: `diamonds.${type}`,
            value: amount,
        });
    },
};
exports.default = recordMetric;
//# sourceMappingURL=metrics.js.map