/**
 * Streaming Agent - Live Content Management
 * 
 * Features:
 * - Stream enhancement suggestions
 * - Auto-highlight detection
 * - Live chat moderation
 * - Viewer engagement tracking
 */

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { onCall, HttpsError } from 'firebase-functions/v2/https';

const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// =============================================================================
// SCHEMAS
// =============================================================================

const StreamEnhancementInputSchema = z.object({
    streamId: z.string(),
    streamType: z.enum(['game', 'chat', 'tutorial', 'social']),
    gameType: z.string().optional(),
    viewerCount: z.number(),
    streamDuration: z.number(), // in seconds
    recentEvents: z.array(z.object({
        type: z.string(),
        timestamp: z.number(),
        data: z.any(),
    })).optional(),
});

const StreamEnhancementOutputSchema = z.object({
    overlays: z.array(z.object({
        type: z.string(),
        content: z.string(),
        position: z.string(),
        duration: z.number(),
    })),
    interactionPrompts: z.array(z.string()),
    suggestedPolls: z.array(z.object({
        question: z.string(),
        options: z.array(z.string()),
    })),
    engagementTips: z.array(z.string()),
});

const HighlightDetectionInputSchema = z.object({
    streamId: z.string(),
    gameEvents: z.array(z.object({
        timestamp: z.number(),
        event: z.string(),
        significance: z.number(),
    })),
    viewerReactions: z.array(z.object({
        timestamp: z.number(),
        type: z.string(),
        count: z.number(),
    })).optional(),
});

const HighlightDetectionOutputSchema = z.object({
    highlights: z.array(z.object({
        startTime: z.number(),
        endTime: z.number(),
        title: z.string(),
        score: z.number(),
        category: z.string(),
    })),
    bestMoment: z.object({
        timestamp: z.number(),
        description: z.string(),
    }).optional(),
});

// =============================================================================
// GENKIT FLOWS
// =============================================================================

export const enhanceStreamFlow = ai.defineFlow(
    {
        name: 'enhanceStream',
        inputSchema: StreamEnhancementInputSchema,
        outputSchema: StreamEnhancementOutputSchema,
    },
    async (input) => {
        const prompt = `You are the Streaming Agent for ClubRoyale live streams.

Stream Info:
- Type: ${input.streamType}
- Viewers: ${input.viewerCount}
- Duration: ${Math.floor(input.streamDuration / 60)} minutes
${input.gameType ? `- Game: ${input.gameType}` : ''}

${input.recentEvents?.length ? `Recent Events: ${input.recentEvents.slice(-5).map(e => e.type).join(', ')}` : ''}

Suggest:
1. Overlay text/graphics to show
2. Viewer interaction prompts
3. Poll questions to boost engagement
4. Tips to improve the stream

Keep suggestions relevant to ${input.streamType} content.`;

        const { output } = await ai.generate({
            prompt,
            output: { schema: StreamEnhancementOutputSchema },
        });

        return output ?? {
            overlays: [],
            interactionPrompts: ['Type your predictions in chat!'],
            suggestedPolls: [{ question: 'Who will win?', options: ['Streamer', 'Opponent'] }],
            engagementTips: ['Acknowledge viewers by name'],
        };
    }
);

export const detectHighlightsFlow = ai.defineFlow(
    {
        name: 'detectHighlights',
        inputSchema: HighlightDetectionInputSchema,
        outputSchema: HighlightDetectionOutputSchema,
    },
    async (input) => {
        const prompt = `Analyze game events to detect highlight moments.

Events: ${input.gameEvents.length} total
Top events by significance:
${input.gameEvents
                .sort((a, b) => b.significance - a.significance)
                .slice(0, 10)
                .map(e => `- ${e.event} at ${e.timestamp}s (score: ${e.significance})`)
                .join('\n')}

${input.viewerReactions?.length ? `
Viewer Reactions:
${input.viewerReactions.slice(-10).map(r => `- ${r.type}: ${r.count} at ${r.timestamp}s`).join('\n')}
` : ''}

Identify:
1. Key highlights (exciting moments worth clipping)
2. The single best moment of the stream
3. Appropriate titles for each highlight`;

        const { output } = await ai.generate({
            prompt,
            output: { schema: HighlightDetectionOutputSchema },
        });

        return output ?? {
            highlights: [],
            bestMoment: input.gameEvents.length > 0 ? {
                timestamp: input.gameEvents[0].timestamp,
                description: 'Key moment',
            } : undefined,
        };
    }
);

// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================

export const enhanceStream = onCall(
    { maxInstances: 20, timeoutSeconds: 15 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await enhanceStreamFlow(request.data);
        } catch (error: any) {
            throw new HttpsError('internal', error.message);
        }
    }
);

export const detectHighlights = onCall(
    { maxInstances: 10, timeoutSeconds: 30 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await detectHighlightsFlow(request.data);
        } catch (error: any) {
            throw new HttpsError('internal', error.message);
        }
    }
);
