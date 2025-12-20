/**
 * Rate Limiter Middleware
 * Prevents API abuse with per-user and per-endpoint limits
 */
interface RateLimitResult {
    allowed: boolean;
    remaining: number;
    resetAt: number;
    retryAfterMs?: number;
}
/**
 * Check if a request should be rate limited
 */
export declare function checkRateLimit(userId: string, endpoint: string): Promise<RateLimitResult>;
/**
 * Rate limit decorator for Cloud Functions
 */
export declare function withRateLimit(endpoint: string): <T extends (...args: any[]) => Promise<any>>(fn: T) => T;
/**
 * Clean up old rate limit records (scheduled)
 */
export declare function cleanupRateLimits(): Promise<number>;
export {};
//# sourceMappingURL=rateLimiter.d.ts.map