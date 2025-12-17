"use strict";
/**
 * Streaming Agent - Live Content Management
 *
 * Features:
 * - Stream enhancement suggestions
 * - Auto-highlight detection
 * - Live chat moderation
 * - Viewer engagement tracking
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.detectHighlights = exports.enhanceStream = exports.detectHighlightsFlow = exports.enhanceStreamFlow = void 0;
const genkit_1 = require("genkit");
const googleai_1 = require("@genkit-ai/googleai");
const https_1 = require("firebase-functions/v2/https");
const ai = (0, genkit_1.genkit)({
    plugins: [(0, googleai_1.googleAI)()],
    model: googleai_1.gemini20FlashExp,
});
// =============================================================================
// SCHEMAS
// =============================================================================
const StreamEnhancementInputSchema = genkit_1.z.object({
    streamId: genkit_1.z.string(),
    streamType: genkit_1.z.enum(['game', 'chat', 'tutorial', 'social']),
    gameType: genkit_1.z.string().optional(),
    viewerCount: genkit_1.z.number(),
    streamDuration: genkit_1.z.number(), // in seconds
    recentEvents: genkit_1.z.array(genkit_1.z.object({
        type: genkit_1.z.string(),
        timestamp: genkit_1.z.number(),
        data: genkit_1.z.any(),
    })).optional(),
});
const StreamEnhancementOutputSchema = genkit_1.z.object({
    overlays: genkit_1.z.array(genkit_1.z.object({
        type: genkit_1.z.string(),
        content: genkit_1.z.string(),
        position: genkit_1.z.string(),
        duration: genkit_1.z.number(),
    })),
    interactionPrompts: genkit_1.z.array(genkit_1.z.string()),
    suggestedPolls: genkit_1.z.array(genkit_1.z.object({
        question: genkit_1.z.string(),
        options: genkit_1.z.array(genkit_1.z.string()),
    })),
    engagementTips: genkit_1.z.array(genkit_1.z.string()),
});
const HighlightDetectionInputSchema = genkit_1.z.object({
    streamId: genkit_1.z.string(),
    gameEvents: genkit_1.z.array(genkit_1.z.object({
        timestamp: genkit_1.z.number(),
        event: genkit_1.z.string(),
        significance: genkit_1.z.number(),
    })),
    viewerReactions: genkit_1.z.array(genkit_1.z.object({
        timestamp: genkit_1.z.number(),
        type: genkit_1.z.string(),
        count: genkit_1.z.number(),
    })).optional(),
});
const HighlightDetectionOutputSchema = genkit_1.z.object({
    highlights: genkit_1.z.array(genkit_1.z.object({
        startTime: genkit_1.z.number(),
        endTime: genkit_1.z.number(),
        title: genkit_1.z.string(),
        score: genkit_1.z.number(),
        category: genkit_1.z.string(),
    })),
    bestMoment: genkit_1.z.object({
        timestamp: genkit_1.z.number(),
        description: genkit_1.z.string(),
    }).optional(),
});
// =============================================================================
// GENKIT FLOWS
// =============================================================================
exports.enhanceStreamFlow = ai.defineFlow({
    name: 'enhanceStream',
    inputSchema: StreamEnhancementInputSchema,
    outputSchema: StreamEnhancementOutputSchema,
}, async (input) => {
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
});
exports.detectHighlightsFlow = ai.defineFlow({
    name: 'detectHighlights',
    inputSchema: HighlightDetectionInputSchema,
    outputSchema: HighlightDetectionOutputSchema,
}, async (input) => {
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
});
// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================
exports.enhanceStream = (0, https_1.onCall)({ maxInstances: 20, timeoutSeconds: 15 }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    try {
        return await (0, exports.enhanceStreamFlow)(request.data);
    }
    catch (error) {
        throw new https_1.HttpsError('internal', error.message);
    }
});
exports.detectHighlights = (0, https_1.onCall)({ maxInstances: 10, timeoutSeconds: 30 }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    try {
        return await (0, exports.detectHighlightsFlow)(request.data);
    }
    catch (error) {
        throw new https_1.HttpsError('internal', error.message);
    }
});
//# sourceMappingURL=streaming_agent.js.map