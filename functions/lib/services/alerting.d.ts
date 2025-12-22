/**
 * Alerting Service
 *
 * Sends alerts to Slack and PagerDuty for critical events.
 * Used for production monitoring and incident response.
 */
interface AlertPayload {
    title: string;
    message: string;
    severity: 'info' | 'warning' | 'error' | 'critical';
    context?: Record<string, unknown>;
}
/**
 * Send alert to configured channels
 */
export declare function sendAlert(payload: AlertPayload): Promise<void>;
/**
 * Alert for high error rate
 */
export declare function alertHighErrorRate(errorRate: number, threshold: number): Promise<void>;
/**
 * Alert for security events
 */
export declare function alertSecurityEvent(eventType: string, userId: string, details: string): Promise<void>;
/**
 * Alert for infrastructure issues
 */
export declare function alertInfrastructureIssue(component: string, issue: string): Promise<void>;
/**
 * Alert for anomalous activity
 */
export declare function alertAnomalousActivity(userId: string, activityType: string, details: string): Promise<void>;
export {};
//# sourceMappingURL=alerting.d.ts.map