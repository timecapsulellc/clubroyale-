/**
 * Rate Limiter Middleware
 * Prevents API abuse with per-user and per-endpoint limits
 */

import * as admin from 'firebase-admin';
import { getConfig, isFeatureEnabled } from '../config/environments';

interface RateLimitConfig {
    windowMs: number;
    maxRequests: number;
}

// Rate limits by endpoint type
const RATE_LIMITS: Record<string, RateLimitConfig> = {
    default: { windowMs: 60000, maxRequests: 100 },
    auth: { windowMs: 60000, maxRequests: 10 },
    chat: { windowMs: 1000, maxRequests: 5 },
    ai: { windowMs: 60000, maxRequests: 30 },
    game: { windowMs: 1000, maxRequests: 10 },
    social: { windowMs: 60000, maxRequests: 50 },
};

interface RateLimitResult {
    allowed: boolean;
    remaining: number;
    resetAt: number;
    retryAfterMs?: number;
}

/**
 * Check if a request should be rate limited
 */
export async function checkRateLimit(
    userId: string,
    endpoint: string
): Promise<RateLimitResult> {
    // Skip rate limiting if disabled
    if (!isFeatureEnabled('enableRateLimiting')) {
        return { allowed: true, remaining: 999, resetAt: Date.now() + 60000 };
    }

    const db = admin.firestore();
    const config = RATE_LIMITS[endpoint] || RATE_LIMITS.default;
    const now = Date.now();
    const windowStart = now - config.windowMs;

    const ref = db.collection('_rate_limits').doc(`${userId}_${endpoint}`);

    return db.runTransaction(async (transaction) => {
        const doc = await transaction.get(ref);
        const data = doc.data() || { requests: [] };

        // Filter requests within current window
        const recentRequests = (data.requests as number[]).filter(
            (timestamp) => timestamp > windowStart
        );

        if (recentRequests.length >= config.maxRequests) {
            const oldestRequest = Math.min(...recentRequests);
            const resetAt = oldestRequest + config.windowMs;
            return {
                allowed: false,
                remaining: 0,
                resetAt,
                retryAfterMs: resetAt - now,
            };
        }

        // Add current request
        recentRequests.push(now);
        transaction.set(ref, {
            requests: recentRequests,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
            allowed: true,
            remaining: config.maxRequests - recentRequests.length,
            resetAt: now + config.windowMs,
        };
    });
}

/**
 * Rate limit decorator for Cloud Functions
 */
export function withRateLimit(endpoint: string) {
    return function <T extends (...args: any[]) => Promise<any>>(fn: T): T {
        return (async (...args: any[]) => {
            const context = args[1]; // onCall context
            const userId = context?.auth?.uid;

            if (!userId) {
                throw new Error('Authentication required');
            }

            const result = await checkRateLimit(userId, endpoint);

            if (!result.allowed) {
                const error = new Error(
                    `Rate limit exceeded. Try again in ${Math.ceil(
                        (result.retryAfterMs || 0) / 1000
                    )} seconds.`
                );
                (error as any).code = 'resource-exhausted';
                throw error;
            }

            return fn(...args);
        }) as T;
    };
}

/**
 * Clean up old rate limit records (scheduled)
 */
export async function cleanupRateLimits(): Promise<number> {
    const db = admin.firestore();
    const oneHourAgo = new Date(Date.now() - 3600000);

    const snapshot = await db
        .collection('_rate_limits')
        .where('updatedAt', '<', oneHourAgo)
        .limit(500)
        .get();

    const batch = db.batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    return snapshot.size;
}
