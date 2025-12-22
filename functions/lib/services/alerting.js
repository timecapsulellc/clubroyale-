"use strict";
/**
 * Alerting Service
 *
 * Sends alerts to Slack and PagerDuty for critical events.
 * Used for production monitoring and incident response.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendAlert = sendAlert;
exports.alertHighErrorRate = alertHighErrorRate;
exports.alertSecurityEvent = alertSecurityEvent;
exports.alertInfrastructureIssue = alertInfrastructureIssue;
exports.alertAnomalousActivity = alertAnomalousActivity;
const secrets_1 = require("../config/secrets");
const environments_1 = require("../config/environments");
/**
 * Send alert to configured channels
 */
async function sendAlert(payload) {
    const config = (0, environments_1.getConfig)();
    // Only send alerts in production/staging
    if (config.name === 'development') {
        console.log(`[Alert] ${payload.severity.toUpperCase()}: ${payload.title} - ${payload.message}`);
        return;
    }
    const promises = [];
    // Always send to Slack
    promises.push(sendSlackAlert(payload));
    // Send to PagerDuty for critical errors
    if (payload.severity === 'critical' || payload.severity === 'error') {
        promises.push(sendPagerDutyAlert(payload));
    }
    await Promise.allSettled(promises);
}
/**
 * Send alert to Slack
 */
async function sendSlackAlert(payload) {
    try {
        const webhookUrl = await (0, secrets_1.getSecret)(secrets_1.SecretNames.SLACK_WEBHOOK_URL);
        if (!webhookUrl) {
            console.warn('[Alert] Slack webhook URL not configured');
            return;
        }
        const color = {
            info: '#36a64f',
            warning: '#ffcc00',
            error: '#ff6600',
            critical: '#ff0000',
        }[payload.severity];
        const slackPayload = {
            attachments: [
                {
                    color,
                    title: `${getEmojiForSeverity(payload.severity)} ${payload.title}`,
                    text: payload.message,
                    fields: payload.context
                        ? Object.entries(payload.context).map(([key, value]) => ({
                            title: key,
                            value: String(value),
                            short: true,
                        }))
                        : [],
                    footer: `ClubRoyale | ${(0, environments_1.getConfig)().name}`,
                    ts: Math.floor(Date.now() / 1000),
                },
            ],
        };
        const response = await fetch(webhookUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(slackPayload),
        });
        if (!response.ok) {
            console.error(`[Alert] Slack responded with ${response.status}`);
        }
    }
    catch (error) {
        console.error('[Alert] Failed to send Slack alert:', error);
    }
}
/**
 * Send alert to PagerDuty
 */
async function sendPagerDutyAlert(payload) {
    try {
        const routingKey = await (0, secrets_1.getSecret)(secrets_1.SecretNames.PAGERDUTY_ROUTING_KEY);
        if (!routingKey) {
            console.warn('[Alert] PagerDuty routing key not configured');
            return;
        }
        const pdPayload = {
            routing_key: routingKey,
            event_action: 'trigger',
            dedup_key: `clubroyale-${payload.title}-${Date.now()}`,
            payload: {
                summary: `${payload.title}: ${payload.message}`,
                severity: payload.severity === 'critical' ? 'critical' : 'error',
                source: 'ClubRoyale Backend',
                custom_details: payload.context,
            },
        };
        const response = await fetch('https://events.pagerduty.com/v2/enqueue', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(pdPayload),
        });
        if (!response.ok) {
            console.error(`[Alert] PagerDuty responded with ${response.status}`);
        }
    }
    catch (error) {
        console.error('[Alert] Failed to send PagerDuty alert:', error);
    }
}
function getEmojiForSeverity(severity) {
    return {
        info: 'ℹ️',
        warning: '⚠️',
        error: '🔴',
        critical: '🚨',
    }[severity];
}
// ==================== Specific Alert Functions ====================
/**
 * Alert for high error rate
 */
async function alertHighErrorRate(errorRate, threshold) {
    await sendAlert({
        title: 'High Error Rate Detected',
        message: `Error rate ${(errorRate * 100).toFixed(1)}% exceeds threshold ${(threshold * 100).toFixed(1)}%`,
        severity: errorRate > threshold * 2 ? 'critical' : 'error',
        context: {
            errorRate: `${(errorRate * 100).toFixed(1)}%`,
            threshold: `${(threshold * 100).toFixed(1)}%`,
        },
    });
}
/**
 * Alert for security events
 */
async function alertSecurityEvent(eventType, userId, details) {
    await sendAlert({
        title: 'Security Alert',
        message: `${eventType}: ${details}`,
        severity: 'warning',
        context: {
            eventType,
            userId,
            timestamp: new Date().toISOString(),
        },
    });
}
/**
 * Alert for infrastructure issues
 */
async function alertInfrastructureIssue(component, issue) {
    await sendAlert({
        title: 'Infrastructure Issue',
        message: `${component}: ${issue}`,
        severity: 'error',
        context: {
            component,
            timestamp: new Date().toISOString(),
        },
    });
}
/**
 * Alert for anomalous activity
 */
async function alertAnomalousActivity(userId, activityType, details) {
    await sendAlert({
        title: 'Anomalous Activity Detected',
        message: `User ${userId}: ${activityType}`,
        severity: 'warning',
        context: {
            userId,
            activityType,
            details,
            timestamp: new Date().toISOString(),
        },
    });
}
//# sourceMappingURL=alerting.js.map