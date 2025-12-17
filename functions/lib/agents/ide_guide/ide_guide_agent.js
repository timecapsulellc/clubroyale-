"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.explainCodeFlow = exports.quickCodeSuggestionFlow = exports.planFeatureImplementation = exports.analyzeBug = exports.getArchitectureGuidance = exports.generateCode = exports.featureImplementationFlow = exports.bugAnalysisFlow = exports.architectureGuidanceFlow = exports.codeGenerationFlow = void 0;
const genkit_1 = require("genkit");
const googleai_1 = require("@genkit-ai/googleai");
const https_1 = require("firebase-functions/v2/https");
// Initialize GenKit with Gemini 2.0 Flash
const ai = (0, genkit_1.genkit)({
    plugins: [(0, googleai_1.googleAI)()],
    model: googleai_1.gemini20FlashExp,
});
// =============================================================================
// SCHEMAS
// =============================================================================
const CodeGenerationInputSchema = genkit_1.z.object({
    task: genkit_1.z.string().describe('The coding task to accomplish'),
    language: genkit_1.z.enum(['dart', 'typescript', 'python']).describe('Target language'),
    projectContext: genkit_1.z.object({
        existingPatterns: genkit_1.z.array(genkit_1.z.string()).optional().describe('Existing code patterns'),
        currentFile: genkit_1.z.string().optional().describe('Current file being edited'),
        dependencies: genkit_1.z.array(genkit_1.z.string()).optional().describe('Available dependencies'),
        architecture: genkit_1.z.string().optional().describe('Project architecture description'),
    }).optional(),
    codeStyle: genkit_1.z.object({
        naming: genkit_1.z.enum(['camelCase', 'snake_case', 'PascalCase']).optional(),
        useRiverpod: genkit_1.z.boolean().optional().describe('Use Riverpod for state management'),
        useFreezed: genkit_1.z.boolean().optional().describe('Use Freezed for data classes'),
    }).optional(),
});
const CodeGenerationOutputSchema = genkit_1.z.object({
    code: genkit_1.z.string().describe('Generated code'),
    explanation: genkit_1.z.string().describe('Explanation of the code'),
    filesToCreate: genkit_1.z.array(genkit_1.z.object({
        path: genkit_1.z.string(),
        content: genkit_1.z.string(),
        description: genkit_1.z.string(),
    })).optional().describe('New files to create'),
    filesToModify: genkit_1.z.array(genkit_1.z.object({
        path: genkit_1.z.string(),
        changes: genkit_1.z.string(),
        reason: genkit_1.z.string(),
    })).optional().describe('Existing files to modify'),
    tests: genkit_1.z.string().optional().describe('Unit tests for the code'),
    dependencies: genkit_1.z.array(genkit_1.z.string()).optional().describe('Required dependencies'),
});
const ArchitectureInputSchema = genkit_1.z.object({
    feature: genkit_1.z.string().describe('Feature to design'),
    requirements: genkit_1.z.array(genkit_1.z.string()).describe('Feature requirements'),
    constraints: genkit_1.z.array(genkit_1.z.string()).optional().describe('Technical constraints'),
    existingArchitecture: genkit_1.z.string().optional().describe('Current architecture description'),
});
const ArchitectureOutputSchema = genkit_1.z.object({
    recommendation: genkit_1.z.object({
        approach: genkit_1.z.string().describe('Recommended approach'),
        components: genkit_1.z.array(genkit_1.z.object({
            name: genkit_1.z.string(),
            type: genkit_1.z.enum(['service', 'widget', 'model', 'provider', 'screen', 'util']),
            responsibility: genkit_1.z.string(),
            file: genkit_1.z.string(),
        })).describe('Components to create'),
        dataFlow: genkit_1.z.string().describe('How data flows through components'),
        integrationPoints: genkit_1.z.array(genkit_1.z.string()).describe('Integration with existing code'),
    }),
    alternatives: genkit_1.z.array(genkit_1.z.object({
        approach: genkit_1.z.string(),
        pros: genkit_1.z.array(genkit_1.z.string()),
        cons: genkit_1.z.array(genkit_1.z.string()),
    })).optional().describe('Alternative approaches'),
    estimatedEffort: genkit_1.z.string().describe('Time estimate'),
    risks: genkit_1.z.array(genkit_1.z.string()).optional().describe('Potential risks'),
});
const BugAnalysisInputSchema = genkit_1.z.object({
    errorMessage: genkit_1.z.string().describe('The error message'),
    stackTrace: genkit_1.z.string().optional().describe('Stack trace if available'),
    codeContext: genkit_1.z.string().optional().describe('Relevant code snippet'),
    recentChanges: genkit_1.z.array(genkit_1.z.string()).optional().describe('Recent code changes'),
    environment: genkit_1.z.enum(['flutter_web', 'flutter_android', 'flutter_ios', 'functions']).optional(),
});
const BugAnalysisOutputSchema = genkit_1.z.object({
    rootCause: genkit_1.z.string().describe('Identified root cause'),
    explanation: genkit_1.z.string().describe('Why this error occurred'),
    suggestedFix: genkit_1.z.string().describe('Code fix suggestion'),
    preventionTips: genkit_1.z.array(genkit_1.z.string()).describe('How to prevent this in future'),
    relatedIssues: genkit_1.z.array(genkit_1.z.string()).optional().describe('Related issues to check'),
    confidence: genkit_1.z.number().min(0).max(1).describe('Confidence in diagnosis'),
});
const FeatureImplementationInputSchema = genkit_1.z.object({
    featureName: genkit_1.z.string().describe('Feature name'),
    featureDescription: genkit_1.z.string().describe('Detailed description'),
    userStories: genkit_1.z.array(genkit_1.z.string()).optional().describe('User stories'),
    acceptanceCriteria: genkit_1.z.array(genkit_1.z.string()).optional().describe('Acceptance criteria'),
    priority: genkit_1.z.enum(['low', 'medium', 'high', 'critical']).optional(),
});
const FeatureImplementationOutputSchema = genkit_1.z.object({
    implementationPlan: genkit_1.z.array(genkit_1.z.object({
        phase: genkit_1.z.number(),
        title: genkit_1.z.string(),
        description: genkit_1.z.string(),
        tasks: genkit_1.z.array(genkit_1.z.object({
            task: genkit_1.z.string(),
            file: genkit_1.z.string(),
            estimatedTime: genkit_1.z.string(),
            dependencies: genkit_1.z.array(genkit_1.z.string()).optional(),
            codeSnippet: genkit_1.z.string().optional(),
        })),
    })).describe('Step-by-step implementation plan'),
    totalEstimatedTime: genkit_1.z.string().describe('Total time estimate'),
    riskAreas: genkit_1.z.array(genkit_1.z.string()).describe('Areas that need careful attention'),
    testPlan: genkit_1.z.array(genkit_1.z.string()).describe('Testing approach'),
    filesAffected: genkit_1.z.array(genkit_1.z.string()).describe('Files that will be created or modified'),
});
// =============================================================================
// GENKIT FLOWS
// =============================================================================
/**
 * Code Generation Flow
 * Generates production-ready code following ClubRoyale patterns
 */
exports.codeGenerationFlow = ai.defineFlow({
    name: 'generateCode',
    inputSchema: CodeGenerationInputSchema,
    outputSchema: CodeGenerationOutputSchema,
}, async (input) => {
    const systemPrompt = `You are the IDE Guide Agent for ClubRoyale, a Flutter-based social gaming platform.

Project Stack:
- Flutter 3.x with Dart
- Firebase (Firestore, Auth, Functions, Storage)
- Riverpod for state management
- Freezed for immutable data classes
- GoRouter for navigation
- Google GenKit for AI features

Code Style:
- Use ${input.codeStyle?.naming || 'camelCase'} for variables
- ${input.codeStyle?.useRiverpod ? 'Use Riverpod providers' : 'Use standard patterns'}
- ${input.codeStyle?.useFreezed ? 'Use @freezed for data classes' : 'Use regular classes'}
- Always add documentation comments
- Use const constructors where possible
- Handle errors gracefully with try-catch

${input.projectContext?.architecture ? `Architecture: ${input.projectContext.architecture}` : ''}
${input.projectContext?.existingPatterns?.length ? `Existing Patterns: ${input.projectContext.existingPatterns.join(', ')}` : ''}
${input.projectContext?.dependencies?.length ? `Available Dependencies: ${input.projectContext.dependencies.join(', ')}` : ''}`;
    const prompt = `${systemPrompt}

Task: ${input.task}
Language: ${input.language}
${input.projectContext?.currentFile ? `Current File: ${input.projectContext.currentFile}` : ''}

Generate clean, production-ready code. Include:
1. The main code with proper documentation
2. Any additional files needed
3. Unit tests if applicable
4. Required dependencies`;
    const { output } = await ai.generate({
        prompt,
        output: { schema: CodeGenerationOutputSchema },
    });
    return output ?? { code: '', explanation: 'Failed to generate code' };
});
/**
 * Architecture Guidance Flow
 * Provides architecture recommendations for new features
 */
exports.architectureGuidanceFlow = ai.defineFlow({
    name: 'architectureGuidance',
    inputSchema: ArchitectureInputSchema,
    outputSchema: ArchitectureOutputSchema,
}, async (input) => {
    const prompt = `You are the Architecture Advisor for ClubRoyale.

ClubRoyale Architecture Overview:
- lib/features/ - Feature modules (lobby, game, social, wallet, etc.)
- lib/core/ - Shared widgets, services, utilities
- lib/games/ - Game engines (call_break, marriage, teen_patti, in_between)
- lib/config/ - Theme and app configuration
- functions/src/ - Firebase Cloud Functions (TypeScript)

Each feature module contains:
- screens/ - UI screens
- widgets/ - Reusable widgets
- services/ - Business logic
- providers/ - Riverpod providers
- models/ - Data models

Feature: ${input.feature}
Requirements: 
${input.requirements.map((r, i) => `${i + 1}. ${r}`).join('\n')}
${input.constraints?.length ? `Constraints: ${input.constraints.join(', ')}` : ''}
${input.existingArchitecture ? `Current Architecture: ${input.existingArchitecture}` : ''}

Provide a detailed architecture recommendation including:
1. Recommended approach with justification
2. Components to create with responsibilities
3. Data flow diagram description
4. Integration points with existing code
5. Alternative approaches with pros/cons
6. Time estimate and risks`;
    const { output } = await ai.generate({
        prompt,
        output: { schema: ArchitectureOutputSchema },
    });
    return output ?? {
        recommendation: { approach: '', components: [], dataFlow: '', integrationPoints: [] },
        estimatedEffort: 'Unable to estimate',
    };
});
/**
 * Bug Analysis Flow
 * Analyzes errors and suggests fixes
 */
exports.bugAnalysisFlow = ai.defineFlow({
    name: 'bugAnalysis',
    inputSchema: BugAnalysisInputSchema,
    outputSchema: BugAnalysisOutputSchema,
}, async (input) => {
    const prompt = `You are a senior Flutter/Firebase debugging expert for ClubRoyale.

Error: ${input.errorMessage}
${input.stackTrace ? `Stack Trace:\n${input.stackTrace}` : ''}
${input.codeContext ? `Code Context:\n${input.codeContext}` : ''}
${input.recentChanges?.length ? `Recent Changes: ${input.recentChanges.join(', ')}` : ''}
${input.environment ? `Environment: ${input.environment}` : ''}

Common ClubRoyale Issues to Consider:
- Riverpod provider scope issues
- Firestore permission errors
- WebRTC connection failures
- State management race conditions
- Widget lifecycle issues
- Null safety violations

Analyze this error and provide:
1. Root cause identification
2. Clear explanation of why it occurred
3. Specific code fix with example
4. Prevention tips for the future
5. Related issues that might occur`;
    const { output } = await ai.generate({
        prompt,
        output: { schema: BugAnalysisOutputSchema },
    });
    return output ?? {
        rootCause: 'Unable to analyze',
        explanation: 'Analysis failed',
        suggestedFix: '',
        preventionTips: [],
        confidence: 0,
    };
});
/**
 * Feature Implementation Flow
 * Creates step-by-step implementation plans
 */
exports.featureImplementationFlow = ai.defineFlow({
    name: 'featureImplementation',
    inputSchema: FeatureImplementationInputSchema,
    outputSchema: FeatureImplementationOutputSchema,
}, async (input) => {
    const prompt = `You are a senior Flutter architect planning feature implementation for ClubRoyale.

Feature: ${input.featureName}
Description: ${input.featureDescription}
Priority: ${input.priority || 'medium'}

${input.userStories?.length ? `User Stories:\n${input.userStories.map((s, i) => `- ${s}`).join('\n')}` : ''}
${input.acceptanceCriteria?.length ? `Acceptance Criteria:\n${input.acceptanceCriteria.map((c, i) => `✓ ${c}`).join('\n')}` : ''}

ClubRoyale Project Structure:
- lib/features/{feature}/ - Feature modules
- lib/core/widgets/ - Shared widgets
- lib/core/services/ - Core services
- functions/src/ - Cloud functions

Create a detailed implementation plan with:
1. Phased approach (Backend → Service → UI → Polish)
2. Specific tasks with file paths
3. Time estimates per task
4. Dependencies between tasks
5. Code snippets for key components
6. Risk areas to watch
7. Testing strategy`;
    const { output } = await ai.generate({
        prompt,
        output: { schema: FeatureImplementationOutputSchema },
    });
    return output ?? {
        implementationPlan: [],
        totalEstimatedTime: 'Unable to estimate',
        riskAreas: [],
        testPlan: [],
        filesAffected: [],
    };
});
// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================
/**
 * Generate Code - Firebase Callable Function
 */
exports.generateCode = (0, https_1.onCall)({ maxInstances: 10, timeoutSeconds: 60 }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    try {
        const result = await (0, exports.codeGenerationFlow)(request.data);
        return result;
    }
    catch (error) {
        console.error('Code generation error:', error);
        throw new https_1.HttpsError('internal', error.message);
    }
});
/**
 * Architecture Guidance - Firebase Callable Function
 */
exports.getArchitectureGuidance = (0, https_1.onCall)({ maxInstances: 10, timeoutSeconds: 60 }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    try {
        const result = await (0, exports.architectureGuidanceFlow)(request.data);
        return result;
    }
    catch (error) {
        console.error('Architecture guidance error:', error);
        throw new https_1.HttpsError('internal', error.message);
    }
});
/**
 * Bug Analysis - Firebase Callable Function
 */
exports.analyzeBug = (0, https_1.onCall)({ maxInstances: 10, timeoutSeconds: 30 }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    try {
        const result = await (0, exports.bugAnalysisFlow)(request.data);
        return result;
    }
    catch (error) {
        console.error('Bug analysis error:', error);
        throw new https_1.HttpsError('internal', error.message);
    }
});
/**
 * Feature Implementation Plan - Firebase Callable Function
 */
exports.planFeatureImplementation = (0, https_1.onCall)({ maxInstances: 10, timeoutSeconds: 60 }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    try {
        const result = await (0, exports.featureImplementationFlow)(request.data);
        return result;
    }
    catch (error) {
        console.error('Feature planning error:', error);
        throw new https_1.HttpsError('internal', error.message);
    }
});
// =============================================================================
// HELPER FUNCTIONS
// =============================================================================
/**
 * Quick code suggestion without full generation
 */
exports.quickCodeSuggestionFlow = ai.defineFlow({
    name: 'quickCodeSuggestion',
    inputSchema: genkit_1.z.object({
        prompt: genkit_1.z.string(),
        language: genkit_1.z.string(),
    }),
    outputSchema: genkit_1.z.object({
        suggestion: genkit_1.z.string(),
        confidence: genkit_1.z.number(),
    }),
}, async (input) => {
    const { output } = await ai.generate({
        prompt: `Quick ${input.language} code suggestion for ClubRoyale:\n${input.prompt}\n\nProvide a concise code snippet.`,
        output: {
            schema: genkit_1.z.object({
                suggestion: genkit_1.z.string(),
                confidence: genkit_1.z.number(),
            }),
        },
    });
    return output ?? { suggestion: '', confidence: 0 };
});
/**
 * Explain code functionality
 */
exports.explainCodeFlow = ai.defineFlow({
    name: 'explainCode',
    inputSchema: genkit_1.z.object({
        code: genkit_1.z.string(),
        language: genkit_1.z.string(),
    }),
    outputSchema: genkit_1.z.object({
        explanation: genkit_1.z.string(),
        keyComponents: genkit_1.z.array(genkit_1.z.string()),
        potentialIssues: genkit_1.z.array(genkit_1.z.string()).optional(),
    }),
}, async (input) => {
    const { output } = await ai.generate({
        prompt: `Explain this ${input.language} code from ClubRoyale:\n\n${input.code}\n\nProvide a clear explanation with key components and any potential issues.`,
        output: {
            schema: genkit_1.z.object({
                explanation: genkit_1.z.string(),
                keyComponents: genkit_1.z.array(genkit_1.z.string()),
                potentialIssues: genkit_1.z.array(genkit_1.z.string()).optional(),
            }),
        },
    });
    return output ?? { explanation: '', keyComponents: [] };
});
//# sourceMappingURL=ide_guide_agent.js.map