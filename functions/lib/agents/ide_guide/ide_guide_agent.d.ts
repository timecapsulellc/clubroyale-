/**
 * IDE Guide Agent - Development Assistant for ClubRoyale
 *
 * This agent accelerates development by providing:
 * - Code generation with project-aware context
 * - Architecture guidance and recommendations
 * - Bug analysis and fixing suggestions
 * - Feature implementation planning
 *
 * Powered by Google GenKit + Gemini 2.0 Flash
 */
import { z } from 'genkit';
/**
 * Code Generation Flow
 * Generates production-ready code following ClubRoyale patterns
 */
export declare const codeGenerationFlow: import("genkit").CallableFlow<z.ZodObject<{
    task: z.ZodString;
    language: z.ZodEnum<["dart", "typescript", "python"]>;
    projectContext: z.ZodOptional<z.ZodObject<{
        existingPatterns: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
        currentFile: z.ZodOptional<z.ZodString>;
        dependencies: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
        architecture: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        existingPatterns?: string[] | undefined;
        currentFile?: string | undefined;
        dependencies?: string[] | undefined;
        architecture?: string | undefined;
    }, {
        existingPatterns?: string[] | undefined;
        currentFile?: string | undefined;
        dependencies?: string[] | undefined;
        architecture?: string | undefined;
    }>>;
    codeStyle: z.ZodOptional<z.ZodObject<{
        naming: z.ZodOptional<z.ZodEnum<["camelCase", "snake_case", "PascalCase"]>>;
        useRiverpod: z.ZodOptional<z.ZodBoolean>;
        useFreezed: z.ZodOptional<z.ZodBoolean>;
    }, "strip", z.ZodTypeAny, {
        naming?: "camelCase" | "snake_case" | "PascalCase" | undefined;
        useRiverpod?: boolean | undefined;
        useFreezed?: boolean | undefined;
    }, {
        naming?: "camelCase" | "snake_case" | "PascalCase" | undefined;
        useRiverpod?: boolean | undefined;
        useFreezed?: boolean | undefined;
    }>>;
}, "strip", z.ZodTypeAny, {
    task: string;
    language: "dart" | "typescript" | "python";
    projectContext?: {
        existingPatterns?: string[] | undefined;
        currentFile?: string | undefined;
        dependencies?: string[] | undefined;
        architecture?: string | undefined;
    } | undefined;
    codeStyle?: {
        naming?: "camelCase" | "snake_case" | "PascalCase" | undefined;
        useRiverpod?: boolean | undefined;
        useFreezed?: boolean | undefined;
    } | undefined;
}, {
    task: string;
    language: "dart" | "typescript" | "python";
    projectContext?: {
        existingPatterns?: string[] | undefined;
        currentFile?: string | undefined;
        dependencies?: string[] | undefined;
        architecture?: string | undefined;
    } | undefined;
    codeStyle?: {
        naming?: "camelCase" | "snake_case" | "PascalCase" | undefined;
        useRiverpod?: boolean | undefined;
        useFreezed?: boolean | undefined;
    } | undefined;
}>, z.ZodObject<{
    code: z.ZodString;
    explanation: z.ZodString;
    filesToCreate: z.ZodOptional<z.ZodArray<z.ZodObject<{
        path: z.ZodString;
        content: z.ZodString;
        description: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        path: string;
        content: string;
        description: string;
    }, {
        path: string;
        content: string;
        description: string;
    }>, "many">>;
    filesToModify: z.ZodOptional<z.ZodArray<z.ZodObject<{
        path: z.ZodString;
        changes: z.ZodString;
        reason: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        path: string;
        reason: string;
        changes: string;
    }, {
        path: string;
        reason: string;
        changes: string;
    }>, "many">>;
    tests: z.ZodOptional<z.ZodString>;
    dependencies: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    code: string;
    explanation: string;
    dependencies?: string[] | undefined;
    filesToCreate?: {
        path: string;
        content: string;
        description: string;
    }[] | undefined;
    filesToModify?: {
        path: string;
        reason: string;
        changes: string;
    }[] | undefined;
    tests?: string | undefined;
}, {
    code: string;
    explanation: string;
    dependencies?: string[] | undefined;
    filesToCreate?: {
        path: string;
        content: string;
        description: string;
    }[] | undefined;
    filesToModify?: {
        path: string;
        reason: string;
        changes: string;
    }[] | undefined;
    tests?: string | undefined;
}>, z.ZodTypeAny>;
/**
 * Architecture Guidance Flow
 * Provides architecture recommendations for new features
 */
export declare const architectureGuidanceFlow: import("genkit").CallableFlow<z.ZodObject<{
    feature: z.ZodString;
    requirements: z.ZodArray<z.ZodString, "many">;
    constraints: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    existingArchitecture: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    feature: string;
    requirements: string[];
    constraints?: string[] | undefined;
    existingArchitecture?: string | undefined;
}, {
    feature: string;
    requirements: string[];
    constraints?: string[] | undefined;
    existingArchitecture?: string | undefined;
}>, z.ZodObject<{
    recommendation: z.ZodObject<{
        approach: z.ZodString;
        components: z.ZodArray<z.ZodObject<{
            name: z.ZodString;
            type: z.ZodEnum<["service", "widget", "model", "provider", "screen", "util"]>;
            responsibility: z.ZodString;
            file: z.ZodString;
        }, "strip", z.ZodTypeAny, {
            type: "model" | "service" | "widget" | "provider" | "screen" | "util";
            name: string;
            responsibility: string;
            file: string;
        }, {
            type: "model" | "service" | "widget" | "provider" | "screen" | "util";
            name: string;
            responsibility: string;
            file: string;
        }>, "many">;
        dataFlow: z.ZodString;
        integrationPoints: z.ZodArray<z.ZodString, "many">;
    }, "strip", z.ZodTypeAny, {
        approach: string;
        components: {
            type: "model" | "service" | "widget" | "provider" | "screen" | "util";
            name: string;
            responsibility: string;
            file: string;
        }[];
        dataFlow: string;
        integrationPoints: string[];
    }, {
        approach: string;
        components: {
            type: "model" | "service" | "widget" | "provider" | "screen" | "util";
            name: string;
            responsibility: string;
            file: string;
        }[];
        dataFlow: string;
        integrationPoints: string[];
    }>;
    alternatives: z.ZodOptional<z.ZodArray<z.ZodObject<{
        approach: z.ZodString;
        pros: z.ZodArray<z.ZodString, "many">;
        cons: z.ZodArray<z.ZodString, "many">;
    }, "strip", z.ZodTypeAny, {
        approach: string;
        pros: string[];
        cons: string[];
    }, {
        approach: string;
        pros: string[];
        cons: string[];
    }>, "many">>;
    estimatedEffort: z.ZodString;
    risks: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    recommendation: {
        approach: string;
        components: {
            type: "model" | "service" | "widget" | "provider" | "screen" | "util";
            name: string;
            responsibility: string;
            file: string;
        }[];
        dataFlow: string;
        integrationPoints: string[];
    };
    estimatedEffort: string;
    alternatives?: {
        approach: string;
        pros: string[];
        cons: string[];
    }[] | undefined;
    risks?: string[] | undefined;
}, {
    recommendation: {
        approach: string;
        components: {
            type: "model" | "service" | "widget" | "provider" | "screen" | "util";
            name: string;
            responsibility: string;
            file: string;
        }[];
        dataFlow: string;
        integrationPoints: string[];
    };
    estimatedEffort: string;
    alternatives?: {
        approach: string;
        pros: string[];
        cons: string[];
    }[] | undefined;
    risks?: string[] | undefined;
}>, z.ZodTypeAny>;
/**
 * Bug Analysis Flow
 * Analyzes errors and suggests fixes
 */
export declare const bugAnalysisFlow: import("genkit").CallableFlow<z.ZodObject<{
    errorMessage: z.ZodString;
    stackTrace: z.ZodOptional<z.ZodString>;
    codeContext: z.ZodOptional<z.ZodString>;
    recentChanges: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    environment: z.ZodOptional<z.ZodEnum<["flutter_web", "flutter_android", "flutter_ios", "functions"]>>;
}, "strip", z.ZodTypeAny, {
    errorMessage: string;
    stackTrace?: string | undefined;
    codeContext?: string | undefined;
    recentChanges?: string[] | undefined;
    environment?: "flutter_web" | "flutter_android" | "flutter_ios" | "functions" | undefined;
}, {
    errorMessage: string;
    stackTrace?: string | undefined;
    codeContext?: string | undefined;
    recentChanges?: string[] | undefined;
    environment?: "flutter_web" | "flutter_android" | "flutter_ios" | "functions" | undefined;
}>, z.ZodObject<{
    rootCause: z.ZodString;
    explanation: z.ZodString;
    suggestedFix: z.ZodString;
    preventionTips: z.ZodArray<z.ZodString, "many">;
    relatedIssues: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    confidence: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    confidence: number;
    explanation: string;
    rootCause: string;
    suggestedFix: string;
    preventionTips: string[];
    relatedIssues?: string[] | undefined;
}, {
    confidence: number;
    explanation: string;
    rootCause: string;
    suggestedFix: string;
    preventionTips: string[];
    relatedIssues?: string[] | undefined;
}>, z.ZodTypeAny>;
/**
 * Feature Implementation Flow
 * Creates step-by-step implementation plans
 */
export declare const featureImplementationFlow: import("genkit").CallableFlow<z.ZodObject<{
    featureName: z.ZodString;
    featureDescription: z.ZodString;
    userStories: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    acceptanceCriteria: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    priority: z.ZodOptional<z.ZodEnum<["low", "medium", "high", "critical"]>>;
}, "strip", z.ZodTypeAny, {
    featureName: string;
    featureDescription: string;
    priority?: "high" | "medium" | "low" | "critical" | undefined;
    userStories?: string[] | undefined;
    acceptanceCriteria?: string[] | undefined;
}, {
    featureName: string;
    featureDescription: string;
    priority?: "high" | "medium" | "low" | "critical" | undefined;
    userStories?: string[] | undefined;
    acceptanceCriteria?: string[] | undefined;
}>, z.ZodObject<{
    implementationPlan: z.ZodArray<z.ZodObject<{
        phase: z.ZodNumber;
        title: z.ZodString;
        description: z.ZodString;
        tasks: z.ZodArray<z.ZodObject<{
            task: z.ZodString;
            file: z.ZodString;
            estimatedTime: z.ZodString;
            dependencies: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
            codeSnippet: z.ZodOptional<z.ZodString>;
        }, "strip", z.ZodTypeAny, {
            task: string;
            file: string;
            estimatedTime: string;
            dependencies?: string[] | undefined;
            codeSnippet?: string | undefined;
        }, {
            task: string;
            file: string;
            estimatedTime: string;
            dependencies?: string[] | undefined;
            codeSnippet?: string | undefined;
        }>, "many">;
    }, "strip", z.ZodTypeAny, {
        phase: number;
        description: string;
        title: string;
        tasks: {
            task: string;
            file: string;
            estimatedTime: string;
            dependencies?: string[] | undefined;
            codeSnippet?: string | undefined;
        }[];
    }, {
        phase: number;
        description: string;
        title: string;
        tasks: {
            task: string;
            file: string;
            estimatedTime: string;
            dependencies?: string[] | undefined;
            codeSnippet?: string | undefined;
        }[];
    }>, "many">;
    totalEstimatedTime: z.ZodString;
    riskAreas: z.ZodArray<z.ZodString, "many">;
    testPlan: z.ZodArray<z.ZodString, "many">;
    filesAffected: z.ZodArray<z.ZodString, "many">;
}, "strip", z.ZodTypeAny, {
    implementationPlan: {
        phase: number;
        description: string;
        title: string;
        tasks: {
            task: string;
            file: string;
            estimatedTime: string;
            dependencies?: string[] | undefined;
            codeSnippet?: string | undefined;
        }[];
    }[];
    totalEstimatedTime: string;
    riskAreas: string[];
    testPlan: string[];
    filesAffected: string[];
}, {
    implementationPlan: {
        phase: number;
        description: string;
        title: string;
        tasks: {
            task: string;
            file: string;
            estimatedTime: string;
            dependencies?: string[] | undefined;
            codeSnippet?: string | undefined;
        }[];
    }[];
    totalEstimatedTime: string;
    riskAreas: string[];
    testPlan: string[];
    filesAffected: string[];
}>, z.ZodTypeAny>;
/**
 * Generate Code - Firebase Callable Function
 */
export declare const generateCode: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    code: string;
    explanation: string;
    dependencies?: string[] | undefined;
    filesToCreate?: {
        path: string;
        content: string;
        description: string;
    }[] | undefined;
    filesToModify?: {
        path: string;
        reason: string;
        changes: string;
    }[] | undefined;
    tests?: string | undefined;
}>, unknown>;
/**
 * Architecture Guidance - Firebase Callable Function
 */
export declare const getArchitectureGuidance: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    recommendation: {
        approach: string;
        components: {
            type: "model" | "service" | "widget" | "provider" | "screen" | "util";
            name: string;
            responsibility: string;
            file: string;
        }[];
        dataFlow: string;
        integrationPoints: string[];
    };
    estimatedEffort: string;
    alternatives?: {
        approach: string;
        pros: string[];
        cons: string[];
    }[] | undefined;
    risks?: string[] | undefined;
}>, unknown>;
/**
 * Bug Analysis - Firebase Callable Function
 */
export declare const analyzeBug: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    confidence: number;
    explanation: string;
    rootCause: string;
    suggestedFix: string;
    preventionTips: string[];
    relatedIssues?: string[] | undefined;
}>, unknown>;
/**
 * Feature Implementation Plan - Firebase Callable Function
 */
export declare const planFeatureImplementation: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    implementationPlan: {
        phase: number;
        description: string;
        title: string;
        tasks: {
            task: string;
            file: string;
            estimatedTime: string;
            dependencies?: string[] | undefined;
            codeSnippet?: string | undefined;
        }[];
    }[];
    totalEstimatedTime: string;
    riskAreas: string[];
    testPlan: string[];
    filesAffected: string[];
}>, unknown>;
/**
 * Quick code suggestion without full generation
 */
export declare const quickCodeSuggestionFlow: import("genkit").CallableFlow<z.ZodObject<{
    prompt: z.ZodString;
    language: z.ZodString;
}, "strip", z.ZodTypeAny, {
    prompt: string;
    language: string;
}, {
    prompt: string;
    language: string;
}>, z.ZodObject<{
    suggestion: z.ZodString;
    confidence: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    confidence: number;
    suggestion: string;
}, {
    confidence: number;
    suggestion: string;
}>, z.ZodTypeAny>;
/**
 * Explain code functionality
 */
export declare const explainCodeFlow: import("genkit").CallableFlow<z.ZodObject<{
    code: z.ZodString;
    language: z.ZodString;
}, "strip", z.ZodTypeAny, {
    code: string;
    language: string;
}, {
    code: string;
    language: string;
}>, z.ZodObject<{
    explanation: z.ZodString;
    keyComponents: z.ZodArray<z.ZodString, "many">;
    potentialIssues: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    explanation: string;
    keyComponents: string[];
    potentialIssues?: string[] | undefined;
}, {
    explanation: string;
    keyComponents: string[];
    potentialIssues?: string[] | undefined;
}>, z.ZodTypeAny>;
//# sourceMappingURL=ide_guide_agent.d.ts.map