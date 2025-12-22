"use strict";
/**
 * Secret Manager Service
 *
 * Provides secure access to secrets using environment variables.
 * In production, use Firebase Functions secrets:
 *   firebase functions:secrets:set SECRET_NAME
 *   Then reference in function: { secrets: ['SECRET_NAME'] }
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.SecretNames = void 0;
exports.getSecret = getSecret;
exports.getSecrets = getSecrets;
exports.clearSecretCache = clearSecretCache;
exports.validateRequiredSecrets = validateRequiredSecrets;
// Secret name constants
exports.SecretNames = {
    GEMINI_API_KEY: 'gemini-api-key',
    LIVEKIT_API_KEY: 'livekit-api-key',
    LIVEKIT_API_SECRET: 'livekit-api-secret',
    REVENUECAT_API_KEY: 'revenuecat-api-key',
    SENTRY_DSN: 'sentry-dsn',
    SLACK_WEBHOOK_URL: 'slack-webhook-url',
    PAGERDUTY_ROUTING_KEY: 'pagerduty-routing-key',
};
// In-memory cache for secrets (TTL: 5 minutes)
const secretCache = new Map();
const CACHE_TTL_MS = 5 * 60 * 1000;
/**
 * Get a secret from environment variables
 */
async function getSecret(secretName) {
    // Check cache first
    const cached = secretCache.get(secretName);
    if (cached && cached.expiresAt > Date.now()) {
        return cached.value;
    }
    // Convert secret name to env var format (e.g., 'gemini-api-key' -> 'GEMINI_API_KEY')
    const envVarName = secretName.toUpperCase().replace(/-/g, '_');
    let value = process.env[envVarName] || '';
    // Fall back to common env var names
    if (!value) {
        const fallbacks = {
            'gemini-api-key': process.env.GOOGLE_GENAI_API_KEY,
            'livekit-api-key': process.env.LIVEKIT_API_KEY,
            'livekit-api-secret': process.env.LIVEKIT_API_SECRET,
            'sentry-dsn': process.env.SENTRY_DSN,
            'slack-webhook-url': process.env.SLACK_WEBHOOK_URL,
            'pagerduty-routing-key': process.env.PAGERDUTY_ROUTING_KEY,
        };
        value = fallbacks[secretName] || '';
    }
    // Cache the result
    if (value) {
        secretCache.set(secretName, {
            value,
            expiresAt: Date.now() + CACHE_TTL_MS,
        });
    }
    return value;
}
/**
 * Get multiple secrets at once
 */
async function getSecrets(names) {
    const results = await Promise.all(names.map(async (name) => ({ name, value: await getSecret(name) })));
    return results.reduce((acc, { name, value }) => {
        acc[name] = value;
        return acc;
    }, {});
}
/**
 * Clear the secrets cache (useful after rotation)
 */
function clearSecretCache() {
    secretCache.clear();
}
/**
 * Check if all required secrets are available
 */
async function validateRequiredSecrets() {
    const required = [
        exports.SecretNames.GEMINI_API_KEY,
        exports.SecretNames.LIVEKIT_API_KEY,
        exports.SecretNames.LIVEKIT_API_SECRET,
    ];
    const missing = [];
    for (const secretName of required) {
        const value = await getSecret(secretName);
        if (!value) {
            missing.push(secretName);
        }
    }
    return {
        valid: missing.length === 0,
        missing,
    };
}
//# sourceMappingURL=secrets.js.map