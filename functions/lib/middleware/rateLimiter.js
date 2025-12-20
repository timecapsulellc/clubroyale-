"use strict";
/**
 * Rate Limiter Middleware
 * Prevents API abuse with per-user and per-endpoint limits
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
exports.checkRateLimit = checkRateLimit;
exports.withRateLimit = withRateLimit;
exports.cleanupRateLimits = cleanupRateLimits;
const admin = __importStar(require("firebase-admin"));
const environments_1 = require("../config/environments");
// Rate limits by endpoint type
const RATE_LIMITS = {
    default: { windowMs: 60000, maxRequests: 100 },
    auth: { windowMs: 60000, maxRequests: 10 },
    chat: { windowMs: 1000, maxRequests: 5 },
    ai: { windowMs: 60000, maxRequests: 30 },
    game: { windowMs: 1000, maxRequests: 10 },
    social: { windowMs: 60000, maxRequests: 50 },
};
/**
 * Check if a request should be rate limited
 */
async function checkRateLimit(userId, endpoint) {
    // Skip rate limiting if disabled
    if (!(0, environments_1.isFeatureEnabled)('enableRateLimiting')) {
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
        const recentRequests = data.requests.filter((timestamp) => timestamp > windowStart);
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
function withRateLimit(endpoint) {
    return function (fn) {
        return (async (...args) => {
            const context = args[1]; // onCall context
            const userId = context?.auth?.uid;
            if (!userId) {
                throw new Error('Authentication required');
            }
            const result = await checkRateLimit(userId, endpoint);
            if (!result.allowed) {
                const error = new Error(`Rate limit exceeded. Try again in ${Math.ceil((result.retryAfterMs || 0) / 1000)} seconds.`);
                error.code = 'resource-exhausted';
                throw error;
            }
            return fn(...args);
        });
    };
}
/**
 * Clean up old rate limit records (scheduled)
 */
async function cleanupRateLimits() {
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
//# sourceMappingURL=rateLimiter.js.map