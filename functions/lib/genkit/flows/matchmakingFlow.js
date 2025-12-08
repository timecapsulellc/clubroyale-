"use strict";
/**
 * GenKit Matchmaking Flow
 *
 * AI-powered matchmaking suggestions based on play patterns.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.matchmakingFlow = void 0;
const zod_1 = require("zod");
const config_1 = require("../config");
// Input schema
const matchmakingInputSchema = zod_1.z.object({
    userId: zod_1.z.string().describe('User ID seeking match'),
    gameType: zod_1.z.string().describe('Type of game (call_break, marriage, etc.)'),
    elo: zod_1.z.number().describe('Player ELO rating'),
    preferredTime: zod_1.z.string().optional().describe('Preferred play time'),
    recentOpponents: zod_1.z.array(zod_1.z.string()).optional().describe('Recent opponents to avoid'),
});
// Output schema
const matchmakingOutputSchema = zod_1.z.object({
    suggestions: zod_1.z.array(zod_1.z.string()).describe('Suggested player IDs to match with'),
    reasoning: zod_1.z.string().describe('Why these players are suggested'),
    waitTimeEstimate: zod_1.z.number().describe('Estimated wait time in seconds'),
    alternativeGameType: zod_1.z.string().optional().describe('Alternative game with more players'),
});
/**
 * AI-powered matchmaking flow
 */
exports.matchmakingFlow = config_1.ai.defineFlow({
    name: 'matchmakingFlow',
    inputSchema: matchmakingInputSchema,
    outputSchema: matchmakingOutputSchema,
}, async (input) => {
    const prompt = `You are a matchmaking assistant for a card game app.

A player is looking for a match with these details:
- User ID: ${input.userId}
- Game Type: ${input.gameType}
- ELO Rating: ${input.elo}
- Preferred Time: ${input.preferredTime || 'Any'}
- Recent Opponents to Avoid: ${input.recentOpponents?.join(', ') || 'None'}

Based on this information, provide matchmaking suggestions:

1. Consider skill balance (±200 ELO is ideal)
2. Consider avoiding recent opponents for variety
3. Estimate wait time based on game popularity
4. Suggest alternative games if wait time is long

Respond in JSON format matching the output schema.`;
    const { output } = await config_1.ai.generate({
        model: config_1.geminiFlash,
        prompt,
        output: { schema: matchmakingOutputSchema },
    });
    return output || {
        suggestions: [],
        reasoning: 'No suggestions available at this time',
        waitTimeEstimate: 60,
    };
});
//# sourceMappingURL=matchmakingFlow.js.map