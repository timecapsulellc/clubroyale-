/**
 * Safety Agent - Enhanced Content Safety
 *
 * Features:
 * - Advanced content moderation with Tree of Thoughts reasoning
 * - Real-time toxicity detection with context awareness
 * - User behavior analysis with pattern detection
 * - Report handling with stepwise evaluation
 *
 * Enhanced with Tree of Thoughts (ToT) for deliberate, multi-step moderation
 */
import { z } from 'genkit';
/**
 * Content Moderation - Enhanced with Tree of Thoughts
 *
 * Stepwise analysis with backtracking:
 * Step 1: Explicit violation check (slurs, threats, explicit content)
 * Step 2: Context-aware analysis (gaming context makes some terms safe)
 * Step 3: Severity assessment with backtracking if context changes interpretation
 */
export declare const moderateContentFlow: import("genkit").CallableFlow<z.ZodObject<{
    contentType: z.ZodEnum<["text", "username", "bio", "story", "comment"]>;
    content: z.ZodString;
    context: z.ZodObject<{
        userId: z.ZodString;
        location: z.ZodString;
        previousViolations: z.ZodDefault<z.ZodNumber>;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        location: string;
        previousViolations: number;
    }, {
        userId: string;
        location: string;
        previousViolations?: number | undefined;
    }>;
    language: z.ZodDefault<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    content: string;
    language: string;
    context: {
        userId: string;
        location: string;
        previousViolations: number;
    };
    contentType: "text" | "story" | "bio" | "comment" | "username";
}, {
    content: string;
    context: {
        userId: string;
        location: string;
        previousViolations?: number | undefined;
    };
    contentType: "text" | "story" | "bio" | "comment" | "username";
    language?: string | undefined;
}>, z.ZodObject<{
    isSafe: z.ZodBoolean;
    categories: z.ZodArray<z.ZodObject<{
        category: z.ZodString;
        severity: z.ZodEnum<["none", "low", "medium", "high", "critical"]>;
        confidence: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        confidence: number;
        category: string;
        severity: "high" | "medium" | "low" | "critical" | "none";
    }, {
        confidence: number;
        category: string;
        severity: "high" | "medium" | "low" | "critical" | "none";
    }>, "many">;
    suggestedAction: z.ZodEnum<["allow", "warn", "filter", "block", "escalate"]>;
    filteredContent: z.ZodOptional<z.ZodString>;
    explanation: z.ZodString;
}, "strip", z.ZodTypeAny, {
    explanation: string;
    isSafe: boolean;
    categories: {
        confidence: number;
        category: string;
        severity: "high" | "medium" | "low" | "critical" | "none";
    }[];
    suggestedAction: "filter" | "allow" | "warn" | "block" | "escalate";
    filteredContent?: string | undefined;
}, {
    explanation: string;
    isSafe: boolean;
    categories: {
        confidence: number;
        category: string;
        severity: "high" | "medium" | "low" | "critical" | "none";
    }[];
    suggestedAction: "filter" | "allow" | "warn" | "block" | "escalate";
    filteredContent?: string | undefined;
}>, z.ZodTypeAny>;
export declare const analyzeBehaviorFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    recentActions: z.ZodArray<z.ZodObject<{
        action: z.ZodString;
        timestamp: z.ZodString;
        target: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        action: string;
        timestamp: string;
        target?: string | undefined;
    }, {
        action: string;
        timestamp: string;
        target?: string | undefined;
    }>, "many">;
    reportHistory: z.ZodOptional<z.ZodArray<z.ZodObject<{
        reason: z.ZodString;
        outcome: z.ZodString;
        date: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        date: string;
        reason: string;
        outcome: string;
    }, {
        date: string;
        reason: string;
        outcome: string;
    }>, "many">>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    recentActions: {
        action: string;
        timestamp: string;
        target?: string | undefined;
    }[];
    reportHistory?: {
        date: string;
        reason: string;
        outcome: string;
    }[] | undefined;
}, {
    userId: string;
    recentActions: {
        action: string;
        timestamp: string;
        target?: string | undefined;
    }[];
    reportHistory?: {
        date: string;
        reason: string;
        outcome: string;
    }[] | undefined;
}>, z.ZodObject<{
    riskLevel: z.ZodEnum<["low", "medium", "high", "critical"]>;
    concerns: z.ZodArray<z.ZodString, "many">;
    recommendedAction: z.ZodString;
    monitoringLevel: z.ZodEnum<["normal", "increased", "strict"]>;
}, "strip", z.ZodTypeAny, {
    riskLevel: "high" | "medium" | "low" | "critical";
    concerns: string[];
    recommendedAction: string;
    monitoringLevel: "normal" | "increased" | "strict";
}, {
    riskLevel: "high" | "medium" | "low" | "critical";
    concerns: string[];
    recommendedAction: string;
    monitoringLevel: "normal" | "increased" | "strict";
}>, z.ZodTypeAny>;
export declare const moderateContent: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    explanation: string;
    isSafe: boolean;
    categories: {
        confidence: number;
        category: string;
        severity: "high" | "medium" | "low" | "critical" | "none";
    }[];
    suggestedAction: "filter" | "allow" | "warn" | "block" | "escalate";
    filteredContent?: string | undefined;
} | {
    isSafe: boolean;
    categories: never[];
    suggestedAction: string;
    explanation: string;
}>, unknown>;
export declare const analyzeBehavior: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    riskLevel: "high" | "medium" | "low" | "critical";
    concerns: string[];
    recommendedAction: string;
    monitoringLevel: "normal" | "increased" | "strict";
}>, unknown>;
//# sourceMappingURL=safety_agent.d.ts.map