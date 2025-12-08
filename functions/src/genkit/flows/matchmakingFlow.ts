/**
 * GenKit Matchmaking Flow
 * 
 * AI-powered matchmaking suggestions based on play patterns.
 */

import { z } from 'zod';
import { ai, geminiFlash } from '../config';

// Input schema
const matchmakingInputSchema = z.object({
    userId: z.string().describe('User ID seeking match'),
    gameType: z.string().describe('Type of game (call_break, marriage, etc.)'),
    elo: z.number().describe('Player ELO rating'),
    preferredTime: z.string().optional().describe('Preferred play time'),
    recentOpponents: z.array(z.string()).optional().describe('Recent opponents to avoid'),
});

// Output schema
const matchmakingOutputSchema = z.object({
    suggestions: z.array(z.string()).describe('Suggested player IDs to match with'),
    reasoning: z.string().describe('Why these players are suggested'),
    waitTimeEstimate: z.number().describe('Estimated wait time in seconds'),
    alternativeGameType: z.string().optional().describe('Alternative game with more players'),
});

/**
 * AI-powered matchmaking flow
 */
export const matchmakingFlow = ai.defineFlow(
    {
        name: 'matchmakingFlow',
        inputSchema: matchmakingInputSchema,
        outputSchema: matchmakingOutputSchema,
    },
    async (input) => {
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

        const { output } = await ai.generate({
            model: geminiFlash,
            prompt,
            output: { schema: matchmakingOutputSchema },
        });

        return output || {
            suggestions: [],
            reasoning: 'No suggestions available at this time',
            waitTimeEstimate: 60,
        };
    }
);

export type MatchmakingInput = z.infer<typeof matchmakingInputSchema>;
export type MatchmakingOutput = z.infer<typeof matchmakingOutputSchema>;
