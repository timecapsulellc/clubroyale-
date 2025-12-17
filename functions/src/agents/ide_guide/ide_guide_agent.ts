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

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { onCall, HttpsError } from 'firebase-functions/v2/https';

// Initialize GenKit with Gemini 2.0 Flash
const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// =============================================================================
// SCHEMAS
// =============================================================================

const CodeGenerationInputSchema = z.object({
    task: z.string().describe('The coding task to accomplish'),
    language: z.enum(['dart', 'typescript', 'python']).describe('Target language'),
    projectContext: z.object({
        existingPatterns: z.array(z.string()).optional().describe('Existing code patterns'),
        currentFile: z.string().optional().describe('Current file being edited'),
        dependencies: z.array(z.string()).optional().describe('Available dependencies'),
        architecture: z.string().optional().describe('Project architecture description'),
    }).optional(),
    codeStyle: z.object({
        naming: z.enum(['camelCase', 'snake_case', 'PascalCase']).optional(),
        useRiverpod: z.boolean().optional().describe('Use Riverpod for state management'),
        useFreezed: z.boolean().optional().describe('Use Freezed for data classes'),
    }).optional(),
});

const CodeGenerationOutputSchema = z.object({
    code: z.string().describe('Generated code'),
    explanation: z.string().describe('Explanation of the code'),
    filesToCreate: z.array(z.object({
        path: z.string(),
        content: z.string(),
        description: z.string(),
    })).optional().describe('New files to create'),
    filesToModify: z.array(z.object({
        path: z.string(),
        changes: z.string(),
        reason: z.string(),
    })).optional().describe('Existing files to modify'),
    tests: z.string().optional().describe('Unit tests for the code'),
    dependencies: z.array(z.string()).optional().describe('Required dependencies'),
});

const ArchitectureInputSchema = z.object({
    feature: z.string().describe('Feature to design'),
    requirements: z.array(z.string()).describe('Feature requirements'),
    constraints: z.array(z.string()).optional().describe('Technical constraints'),
    existingArchitecture: z.string().optional().describe('Current architecture description'),
});

const ArchitectureOutputSchema = z.object({
    recommendation: z.object({
        approach: z.string().describe('Recommended approach'),
        components: z.array(z.object({
            name: z.string(),
            type: z.enum(['service', 'widget', 'model', 'provider', 'screen', 'util']),
            responsibility: z.string(),
            file: z.string(),
        })).describe('Components to create'),
        dataFlow: z.string().describe('How data flows through components'),
        integrationPoints: z.array(z.string()).describe('Integration with existing code'),
    }),
    alternatives: z.array(z.object({
        approach: z.string(),
        pros: z.array(z.string()),
        cons: z.array(z.string()),
    })).optional().describe('Alternative approaches'),
    estimatedEffort: z.string().describe('Time estimate'),
    risks: z.array(z.string()).optional().describe('Potential risks'),
});

const BugAnalysisInputSchema = z.object({
    errorMessage: z.string().describe('The error message'),
    stackTrace: z.string().optional().describe('Stack trace if available'),
    codeContext: z.string().optional().describe('Relevant code snippet'),
    recentChanges: z.array(z.string()).optional().describe('Recent code changes'),
    environment: z.enum(['flutter_web', 'flutter_android', 'flutter_ios', 'functions']).optional(),
});

const BugAnalysisOutputSchema = z.object({
    rootCause: z.string().describe('Identified root cause'),
    explanation: z.string().describe('Why this error occurred'),
    suggestedFix: z.string().describe('Code fix suggestion'),
    preventionTips: z.array(z.string()).describe('How to prevent this in future'),
    relatedIssues: z.array(z.string()).optional().describe('Related issues to check'),
    confidence: z.number().min(0).max(1).describe('Confidence in diagnosis'),
});

const FeatureImplementationInputSchema = z.object({
    featureName: z.string().describe('Feature name'),
    featureDescription: z.string().describe('Detailed description'),
    userStories: z.array(z.string()).optional().describe('User stories'),
    acceptanceCriteria: z.array(z.string()).optional().describe('Acceptance criteria'),
    priority: z.enum(['low', 'medium', 'high', 'critical']).optional(),
});

const FeatureImplementationOutputSchema = z.object({
    implementationPlan: z.array(z.object({
        phase: z.number(),
        title: z.string(),
        description: z.string(),
        tasks: z.array(z.object({
            task: z.string(),
            file: z.string(),
            estimatedTime: z.string(),
            dependencies: z.array(z.string()).optional(),
            codeSnippet: z.string().optional(),
        })),
    })).describe('Step-by-step implementation plan'),
    totalEstimatedTime: z.string().describe('Total time estimate'),
    riskAreas: z.array(z.string()).describe('Areas that need careful attention'),
    testPlan: z.array(z.string()).describe('Testing approach'),
    filesAffected: z.array(z.string()).describe('Files that will be created or modified'),
});

// =============================================================================
// GENKIT FLOWS
// =============================================================================

/**
 * Code Generation Flow
 * Generates production-ready code following ClubRoyale patterns
 */
export const codeGenerationFlow = ai.defineFlow(
    {
        name: 'generateCode',
        inputSchema: CodeGenerationInputSchema,
        outputSchema: CodeGenerationOutputSchema,
    },
    async (input) => {
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
    }
);

/**
 * Architecture Guidance Flow
 * Provides architecture recommendations for new features
 */
export const architectureGuidanceFlow = ai.defineFlow(
    {
        name: 'architectureGuidance',
        inputSchema: ArchitectureInputSchema,
        outputSchema: ArchitectureOutputSchema,
    },
    async (input) => {
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
    }
);

/**
 * Bug Analysis Flow
 * Analyzes errors and suggests fixes
 */
export const bugAnalysisFlow = ai.defineFlow(
    {
        name: 'bugAnalysis',
        inputSchema: BugAnalysisInputSchema,
        outputSchema: BugAnalysisOutputSchema,
    },
    async (input) => {
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
    }
);

/**
 * Feature Implementation Flow
 * Creates step-by-step implementation plans
 */
export const featureImplementationFlow = ai.defineFlow(
    {
        name: 'featureImplementation',
        inputSchema: FeatureImplementationInputSchema,
        outputSchema: FeatureImplementationOutputSchema,
    },
    async (input) => {
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
    }
);

// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================

/**
 * Generate Code - Firebase Callable Function
 */
export const generateCode = onCall(
    { maxInstances: 10, timeoutSeconds: 60 },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'Authentication required');
        }

        try {
            const result = await codeGenerationFlow(request.data);
            return result;
        } catch (error: any) {
            console.error('Code generation error:', error);
            throw new HttpsError('internal', error.message);
        }
    }
);

/**
 * Architecture Guidance - Firebase Callable Function
 */
export const getArchitectureGuidance = onCall(
    { maxInstances: 10, timeoutSeconds: 60 },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'Authentication required');
        }

        try {
            const result = await architectureGuidanceFlow(request.data);
            return result;
        } catch (error: any) {
            console.error('Architecture guidance error:', error);
            throw new HttpsError('internal', error.message);
        }
    }
);

/**
 * Bug Analysis - Firebase Callable Function
 */
export const analyzeBug = onCall(
    { maxInstances: 10, timeoutSeconds: 30 },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'Authentication required');
        }

        try {
            const result = await bugAnalysisFlow(request.data);
            return result;
        } catch (error: any) {
            console.error('Bug analysis error:', error);
            throw new HttpsError('internal', error.message);
        }
    }
);

/**
 * Feature Implementation Plan - Firebase Callable Function
 */
export const planFeatureImplementation = onCall(
    { maxInstances: 10, timeoutSeconds: 60 },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'Authentication required');
        }

        try {
            const result = await featureImplementationFlow(request.data);
            return result;
        } catch (error: any) {
            console.error('Feature planning error:', error);
            throw new HttpsError('internal', error.message);
        }
    }
);

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/**
 * Quick code suggestion without full generation
 */
export const quickCodeSuggestionFlow = ai.defineFlow(
    {
        name: 'quickCodeSuggestion',
        inputSchema: z.object({
            prompt: z.string(),
            language: z.string(),
        }),
        outputSchema: z.object({
            suggestion: z.string(),
            confidence: z.number(),
        }),
    },
    async (input) => {
        const { output } = await ai.generate({
            prompt: `Quick ${input.language} code suggestion for ClubRoyale:\n${input.prompt}\n\nProvide a concise code snippet.`,
            output: {
                schema: z.object({
                    suggestion: z.string(),
                    confidence: z.number(),
                }),
            },
        });
        return output ?? { suggestion: '', confidence: 0 };
    }
);

/**
 * Explain code functionality
 */
export const explainCodeFlow = ai.defineFlow(
    {
        name: 'explainCode',
        inputSchema: z.object({
            code: z.string(),
            language: z.string(),
        }),
        outputSchema: z.object({
            explanation: z.string(),
            keyComponents: z.array(z.string()),
            potentialIssues: z.array(z.string()).optional(),
        }),
    },
    async (input) => {
        const { output } = await ai.generate({
            prompt: `Explain this ${input.language} code from ClubRoyale:\n\n${input.code}\n\nProvide a clear explanation with key components and any potential issues.`,
            output: {
                schema: z.object({
                    explanation: z.string(),
                    keyComponents: z.array(z.string()),
                    potentialIssues: z.array(z.string()).optional(),
                }),
            },
        });
        return output ?? { explanation: '', keyComponents: [] };
    }
);
