/**
 * Metrics Collection Utility
 * Performance and business metrics tracking
 */

import * as admin from 'firebase-admin';
import { getConfig, isFeatureEnabled } from '../config/environments';
import { createLogger } from './logger';

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

const logger = createLogger('metrics');

/**
 * Record a custom metric
 */
export async function recordMetric(metric: MetricData): Promise<void> {
    if (!isFeatureEnabled('enableMetrics')) {
        return;
    }

    const config = getConfig();
    const db = admin.firestore();

    const metricEntry = {
        ...metric,
        timestamp: metric.timestamp || admin.firestore.FieldValue.serverTimestamp(),
        environment: config.name,
    };

    try {
        await db.collection('_metrics').add(metricEntry);
    } catch (error) {
        logger.warn('Failed to record metric', { metric: metric.name, error: (error as Error).message });
    }
}

/**
 * Record function performance
 */
export async function recordPerformance(perf: PerformanceMetric): Promise<void> {
    if (!isFeatureEnabled('enableMetrics')) {
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
export async function incrementCounter(
    name: string,
    labels?: Record<string, string>
): Promise<void> {
    await recordMetric({
        name: `counter.${name}`,
        value: 1,
        labels,
    });
}

/**
 * Timer utility for measuring durations
 */
export class Timer {
    private startTime: number;
    private functionName: string;
    private userId?: string;

    constructor(functionName: string, userId?: string) {
        this.startTime = Date.now();
        this.functionName = functionName;
        this.userId = userId;
    }

    async stop(success: boolean = true, metadata?: Record<string, unknown>): Promise<number> {
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

/**
 * Performance-tracked function wrapper
 */
export function withMetrics<T extends (...args: any[]) => Promise<any>>(
    fn: T,
    functionName: string
): T {
    return (async (...args: any[]) => {
        const userId = args[1]?.auth?.uid;
        const timer = new Timer(functionName, userId);

        try {
            const result = await fn(...args);
            await timer.stop(true);
            return result;
        } catch (error) {
            await timer.stop(false, { error: (error as Error).message });
            throw error;
        }
    }) as T;
}

/**
 * Business metrics helpers
 */
export const BusinessMetrics = {
    async gameStarted(gameType: string, playerCount: number): Promise<void> {
        await incrementCounter('games.started', { gameType, playerCount: String(playerCount) });
    },

    async gameCompleted(gameType: string, duration: number): Promise<void> {
        await recordMetric({
            name: 'games.completed',
            value: duration,
            labels: { gameType },
        });
    },

    async userSignedIn(method: string): Promise<void> {
        await incrementCounter('users.signin', { method });
    },

    async botRoomJoined(gameType: string): Promise<void> {
        await incrementCounter('bot.room.joined', { gameType });
    },

    async aiAgentAction(agentName: string, action: string, duration: number): Promise<void> {
        await recordMetric({
            name: `agent.${agentName}.${action}`,
            value: duration,
        });
    },

    async diamondTransaction(type: string, amount: number): Promise<void> {
        await recordMetric({
            name: `diamonds.${type}`,
            value: amount,
        });
    },
};

export default recordMetric;
