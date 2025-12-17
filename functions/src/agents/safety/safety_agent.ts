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

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { stepwiseToT } from '../tot/tot_utils';

const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// =============================================================================
// SCHEMAS
// =============================================================================

const ContentModerationInputSchema = z.object({
    contentType: z.enum(['text', 'username', 'bio', 'story', 'comment']),
    content: z.string(),
    context: z.object({
        userId: z.string(),
        location: z.string(),
        previousViolations: z.number().default(0),
    }),
    language: z.string().default('en'),
});

const ContentModerationOutputSchema = z.object({
    isSafe: z.boolean(),
    categories: z.array(z.object({
        category: z.string(),
        severity: z.enum(['none', 'low', 'medium', 'high', 'critical']),
        confidence: z.number(),
    })),
    suggestedAction: z.enum(['allow', 'warn', 'filter', 'block', 'escalate']),
    filteredContent: z.string().optional(),
    explanation: z.string(),
});

const BehaviorAnalysisInputSchema = z.object({
    userId: z.string(),
    recentActions: z.array(z.object({
        action: z.string(),
        timestamp: z.string(),
        target: z.string().optional(),
    })),
    reportHistory: z.array(z.object({
        reason: z.string(),
        outcome: z.string(),
        date: z.string(),
    })).optional(),
});

const BehaviorAnalysisOutputSchema = z.object({
    riskLevel: z.enum(['low', 'medium', 'high', 'critical']),
    concerns: z.array(z.string()),
    recommendedAction: z.string(),
    monitoringLevel: z.enum(['normal', 'increased', 'strict']),
});

// =============================================================================
// GENKIT FLOWS
// =============================================================================

/**
 * Content Moderation - Enhanced with Tree of Thoughts
 * 
 * Stepwise analysis with backtracking:
 * Step 1: Explicit violation check (slurs, threats, explicit content)
 * Step 2: Context-aware analysis (gaming context makes some terms safe)
 * Step 3: Severity assessment with backtracking if context changes interpretation
 */
export const moderateContentFlow = ai.defineFlow(
    {
        name: 'moderateContent',
        inputSchema: ContentModerationInputSchema,
        outputSchema: ContentModerationOutputSchema,
    },
    async (input) => {
        // Define moderation steps for stepwise ToT
        const steps = [
            {
                name: 'Explicit Violation Check',
                prompt: `STEP 1: Check for EXPLICIT violations in this ${input.contentType}.

Scan for:
- Slurs or hate speech (racial, gender, religious)
- Explicit threats of violence
- Adult/sexual content
- Spam patterns (URLs, repeated text)
- Personal information exposure (phone, address, SSN)
- Self-harm content

This is a FIRST PASS - be thorough but note that context will be evaluated next.
If no explicit violations found, mark as passed.
If violations found, note severity (low/medium/high/critical).`,
            },
            {
                name: 'Context-Aware Analysis',
                prompt: `STEP 2: Analyze content IN CONTEXT.

This content appears in: ${input.context.location}
Content type: ${input.contentType}
Language: ${input.language}

IMPORTANT - Gaming Context Rules:
- "kill", "destroy", "attack", "die" in gaming context = SAFE (e.g., "I'll kill you in the next round")
- Competitive trash talk between players = Usually SAFE if not personal attacks
- "noob", "gg", "rekt" = Gaming slang, SAFE

IMPORTANT - Backtracking:
- If previous step flagged something that is actually gaming context, mark shouldBacktrack=true
- Example: "I'm going to destroy you" flagged as threat → In game chat → Actually safe

Consider user's violation history: ${input.context.previousViolations} previous violations
${input.context.previousViolations > 2 ? 'WARNING: Repeat offender - be stricter' : ''}`,
            },
            {
                name: 'Severity Assessment',
                prompt: `STEP 3: Final severity assessment.

Based on Steps 1 and 2, determine:
1. Is content ultimately SAFE or UNSAFE?
2. What is the final severity level?
3. What action should be taken?

Action guidelines:
- allow: Clearly safe content
- warn: Borderline content, educate user
- filter: Partially unsafe, can be cleaned (e.g., replace bad words with ***)
- block: Clearly unsafe, do not show
- escalate: Ambiguous, needs human review

If context analysis (Step 2) cleared a flagged item, prefer 'allow' or 'warn'.
Consider: Is blocking this content worth potentially upsetting a user who was just using gaming terms?`,
            },
        ];

        const contextInfo = {
            contentType: input.contentType,
            location: input.context.location,
            userId: input.context.userId,
            previousViolations: input.context.previousViolations,
            language: input.language,
            isGamingContext: ['game', 'match', 'table', 'room'].some(g =>
                input.context.location.toLowerCase().includes(g)
            ),
        };

        try {
            // Run stepwise ToT moderation
            const { result, stepResults, shouldBlock } = await stepwiseToT(
                input.content,
                steps,
                contextInfo,
                ContentModerationOutputSchema
            );

            // Override if stepwise analysis determined block
            if (shouldBlock && result.suggestedAction === 'allow') {
                return {
                    ...result,
                    isSafe: false,
                    suggestedAction: 'block' as const,
                };
            }

            return result;
        } catch (error) {
            // Fallback to simple moderation if ToT fails
            console.error('ToT moderation failed, using fallback:', error);

            const prompt = `You are the Safety Agent for ClubRoyale.

Moderate this ${input.contentType}:
"${input.content}"

Context:
- Location: ${input.context.location}
- Previous violations: ${input.context.previousViolations}
- Language: ${input.language}

Check for:
1. Hate speech or harassment
2. Adult/explicit content
3. Violence references
4. Spam or scams
5. Personal information
6. Impersonation
7. Self-harm
8. Illegal content

Be strict but fair. Consider:
- Gaming context (competitive trash talk may be acceptable)
- Cultural differences
- Intent vs. impact

Provide action: allow (safe), warn (borderline), filter (partially unsafe), block (unsafe), escalate (needs human review).`;

            const { output } = await ai.generate({
                prompt,
                output: { schema: ContentModerationOutputSchema },
            });

            return output ?? {
                isSafe: true,
                categories: [],
                suggestedAction: 'allow' as const,
                explanation: 'Default safe',
            };
        }
    }
);

export const analyzeBehaviorFlow = ai.defineFlow(
    {
        name: 'analyzeBehavior',
        inputSchema: BehaviorAnalysisInputSchema,
        outputSchema: BehaviorAnalysisOutputSchema,
    },
    async (input) => {
        const prompt = `Analyze user behavior for safety concerns.

User: ${input.userId}
Recent Actions: ${input.recentActions.length}
${input.recentActions.slice(-10).map(a => `- ${a.action}${a.target ? ` → ${a.target}` : ''}`).join('\n')}

${input.reportHistory?.length ? `
Report History:
${input.reportHistory.map(r => `- ${r.reason}: ${r.outcome}`).join('\n')}
` : 'No report history'}

Assess:
1. Overall risk level
2. Specific concerns
3. Recommended action
4. Monitoring level needed

Focus on patterns, not isolated incidents.`;

        const { output } = await ai.generate({
            prompt,
            output: { schema: BehaviorAnalysisOutputSchema },
        });

        return output ?? {
            riskLevel: 'low' as const,
            concerns: [],
            recommendedAction: 'No action needed',
            monitoringLevel: 'normal' as const,
        };
    }
);

// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================

export const moderateContent = onCall(
    { maxInstances: 50, timeoutSeconds: 10 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await moderateContentFlow(request.data);
        } catch (error: any) {
            // Fail safe - allow content if moderation fails
            return {
                isSafe: true,
                categories: [],
                suggestedAction: 'allow',
                explanation: 'Moderation unavailable',
            };
        }
    }
);

export const analyzeBehavior = onCall(
    { maxInstances: 10, timeoutSeconds: 30 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await analyzeBehaviorFlow(request.data);
        } catch (error: any) {
            throw new HttpsError('internal', error.message);
        }
    }
);
