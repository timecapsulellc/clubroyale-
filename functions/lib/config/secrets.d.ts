/**
 * Secret Manager Service
 *
 * Provides secure access to secrets using environment variables.
 * In production, use Firebase Functions secrets:
 *   firebase functions:secrets:set SECRET_NAME
 *   Then reference in function: { secrets: ['SECRET_NAME'] }
 */
export declare const SecretNames: {
    readonly GEMINI_API_KEY: "gemini-api-key";
    readonly LIVEKIT_API_KEY: "livekit-api-key";
    readonly LIVEKIT_API_SECRET: "livekit-api-secret";
    readonly REVENUECAT_API_KEY: "revenuecat-api-key";
    readonly SENTRY_DSN: "sentry-dsn";
    readonly SLACK_WEBHOOK_URL: "slack-webhook-url";
    readonly PAGERDUTY_ROUTING_KEY: "pagerduty-routing-key";
};
export type SecretName = typeof SecretNames[keyof typeof SecretNames];
/**
 * Get a secret from environment variables
 */
export declare function getSecret(secretName: SecretName): Promise<string>;
/**
 * Get multiple secrets at once
 */
export declare function getSecrets(names: SecretName[]): Promise<Record<SecretName, string>>;
/**
 * Clear the secrets cache (useful after rotation)
 */
export declare function clearSecretCache(): void;
/**
 * Check if all required secrets are available
 */
export declare function validateRequiredSecrets(): Promise<{
    valid: boolean;
    missing: string[];
}>;
//# sourceMappingURL=secrets.d.ts.map