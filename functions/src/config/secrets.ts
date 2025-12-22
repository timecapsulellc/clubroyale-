/**
 * Secret Manager Service
 * 
 * Provides secure access to secrets stored in Google Cloud Secret Manager.
 * In production, all sensitive credentials should be accessed through this service.
 * 
 * Setup:
 * 1. Enable Secret Manager API in GCP Console
 * 2. Create secrets: gcloud secrets create SECRET_NAME --data-file=secret.txt
 * 3. Grant access: gcloud secrets add-iam-policy-binding SECRET_NAME \
 *    --member="serviceAccount:YOUR_PROJECT@appspot.gserviceaccount.com" \
 *    --role="roles/secretmanager.secretAccessor"
 */

import { SecretManagerServiceClient } from '@google-cloud/secret-manager';
import { getConfig, isProduction } from './environments';

// Lazy initialization of Secret Manager client
let _client: SecretManagerServiceClient | null = null;

function getClient(): SecretManagerServiceClient {
    if (!_client) {
        _client = new SecretManagerServiceClient();
    }
    return _client;
}

// Secret name constants
export const SecretNames = {
    GEMINI_API_KEY: 'gemini-api-key',
    LIVEKIT_API_KEY: 'livekit-api-key',
    LIVEKIT_API_SECRET: 'livekit-api-secret',
    REVENUECAT_API_KEY: 'revenuecat-api-key',
    SENTRY_DSN: 'sentry-dsn',
    SLACK_WEBHOOK_URL: 'slack-webhook-url',
    PAGERDUTY_ROUTING_KEY: 'pagerduty-routing-key',
} as const;

export type SecretName = typeof SecretNames[keyof typeof SecretNames];

// In-memory cache for secrets (TTL: 5 minutes)
const secretCache = new Map<string, { value: string; expiresAt: number }>();
const CACHE_TTL_MS = 5 * 60 * 1000;

/**
 * Get a secret from Secret Manager
 * 
 * In development, falls back to environment variables.
 * In production, uses Secret Manager with caching.
 */
export async function getSecret(secretName: SecretName): Promise<string> {
    const config = getConfig();

    // In development, use environment variables
    if (!isProduction()) {
        const envVarName = secretName.toUpperCase().replace(/-/g, '_');
        const envValue = process.env[envVarName];
        if (envValue) {
            return envValue;
        }
        // Fall back to common env var names
        const fallbacks: Record<string, string | undefined> = {
            'gemini-api-key': process.env.GOOGLE_GENAI_API_KEY,
            'livekit-api-key': process.env.LIVEKIT_API_KEY,
            'livekit-api-secret': process.env.LIVEKIT_API_SECRET,
            'sentry-dsn': process.env.SENTRY_DSN,
        };
        return fallbacks[secretName] || '';
    }

    // Check cache first
    const cached = secretCache.get(secretName);
    if (cached && cached.expiresAt > Date.now()) {
        return cached.value;
    }

    // Fetch from Secret Manager
    try {
        const client = getClient();
        const projectId = config.projectId;
        const name = `projects/${projectId}/secrets/${secretName}/versions/latest`;

        const [version] = await client.accessSecretVersion({ name });
        const value = version.payload?.data?.toString() || '';

        // Cache the result
        secretCache.set(secretName, {
            value,
            expiresAt: Date.now() + CACHE_TTL_MS,
        });

        return value;
    } catch (error) {
        console.error(`[SecretManager] Failed to access secret ${secretName}:`, error);

        // In case of error, try environment variable as fallback
        const envVarName = secretName.toUpperCase().replace(/-/g, '_');
        return process.env[envVarName] || '';
    }
}

/**
 * Get multiple secrets at once
 */
export async function getSecrets(names: SecretName[]): Promise<Record<SecretName, string>> {
    const results = await Promise.all(
        names.map(async (name) => ({ name, value: await getSecret(name) }))
    );

    return results.reduce((acc, { name, value }) => {
        acc[name] = value;
        return acc;
    }, {} as Record<SecretName, string>);
}

/**
 * Clear the secrets cache (useful after rotation)
 */
export function clearSecretCache(): void {
    secretCache.clear();
}

/**
 * Check if all required secrets are available
 */
export async function validateRequiredSecrets(): Promise<{
    valid: boolean;
    missing: string[];
}> {
    const required: SecretName[] = [
        SecretNames.GEMINI_API_KEY,
        SecretNames.LIVEKIT_API_KEY,
        SecretNames.LIVEKIT_API_SECRET,
    ];

    const missing: string[] = [];

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
