"use strict";
/**
 * Environment Configuration
 * Manages development, staging, and production environments
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCurrentEnvironment = getCurrentEnvironment;
exports.getConfig = getConfig;
exports.isProduction = isProduction;
exports.isFeatureEnabled = isFeatureEnabled;
const configs = {
    development: {
        name: 'development',
        projectId: 'taasclub-app-dev',
        region: 'us-central1',
        isProduction: false,
        features: {
            enableRateLimiting: false,
            enableDetailedLogging: true,
            enableMetrics: false,
            enableAIAgents: true,
        },
        limits: {
            maxConcurrentGames: 100,
            maxPlayersPerRoom: 8,
            rateLimitWindowMs: 60000,
            rateLimitMaxRequests: 1000, // Very high for dev
        },
    },
    staging: {
        name: 'staging',
        projectId: 'clubroyale-staging',
        region: 'us-central1',
        isProduction: false,
        features: {
            enableRateLimiting: true,
            enableDetailedLogging: true,
            enableMetrics: true,
            enableAIAgents: true,
        },
        limits: {
            maxConcurrentGames: 500,
            maxPlayersPerRoom: 8,
            rateLimitWindowMs: 60000,
            rateLimitMaxRequests: 100,
        },
    },
    production: {
        name: 'production',
        projectId: 'taasclub-app',
        region: 'us-central1',
        isProduction: true,
        features: {
            enableRateLimiting: true,
            enableDetailedLogging: false,
            enableMetrics: true,
            enableAIAgents: true,
        },
        limits: {
            maxConcurrentGames: 10000,
            maxPlayersPerRoom: 8,
            rateLimitWindowMs: 60000,
            rateLimitMaxRequests: 100,
        },
    },
};
/**
 * Get current environment based on Firebase project ID
 */
function getCurrentEnvironment() {
    const projectId = process.env.GCLOUD_PROJECT || process.env.FIREBASE_PROJECT_ID;
    if (projectId?.includes('staging')) {
        return 'staging';
    }
    if (projectId?.includes('dev')) {
        return 'development';
    }
    return 'production';
}
/**
 * Get configuration for current environment
 */
function getConfig() {
    const env = getCurrentEnvironment();
    return configs[env];
}
/**
 * Check if current environment is production
 */
function isProduction() {
    return getConfig().isProduction;
}
/**
 * Check if a feature is enabled
 */
function isFeatureEnabled(feature) {
    return getConfig().features[feature];
}
exports.default = getConfig;
//# sourceMappingURL=environments.js.map