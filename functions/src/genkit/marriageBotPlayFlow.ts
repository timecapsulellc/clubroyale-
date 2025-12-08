/**
 * Marriage Bot Play Flow
 * 
 * Dedicated GenKit AI flow for Marriage card game with
 * game-specific strategy prompts for different difficulty levels.
 */

import { z } from 'zod';
import { ai, geminiPro } from './config';

// Input schema for Marriage bot
const MarriageBotInputSchema = z.object({
    difficulty: z.enum(['easy', 'medium', 'hard', 'expert']),
    hand: z.array(z.string()),
    gameState: z.object({
        phase: z.enum(['drawing', 'discarding', 'declaring']),
        tiplu: z.string().optional(),
        topDiscard: z.string().optional(),
        cardsInDeck: z.number(),
        roundNumber: z.number(),
        myMelds: z.array(z.array(z.string())).optional(),
        opponentCardCounts: z.record(z.number()).optional(),
    }),
});

export type MarriageBotInput = z.infer<typeof MarriageBotInputSchema>;

// Output schema
const MarriageBotOutputSchema = z.object({
    action: z.enum(['drawDeck', 'drawDiscard', 'discard', 'declare']),
    card: z.string().optional(),
    reasoning: z.string().optional(),
});

export type MarriageBotOutput = z.infer<typeof MarriageBotOutputSchema>;

// Strategy prompts based on difficulty
const strategyPrompts: Record<string, string> = {
    easy: `Play casually. Make simple decisions. 
        - Draw from deck randomly
        - Discard high point cards first
        - Don't track opponent cards`,

    medium: `Play with basic strategy.
        - Try to form melds (sets of 3+ same rank, runs of 3+ same suit)
        - Keep cards that might form melds
        - Discard unrelated high-point cards
        - Notice tiplu (wild card) opportunities`,

    hard: `Play strategically.
        - Track which cards have been played
        - Calculate probability of completing melds
        - Use tiplu (wild card) optimally
        - Block opponents by not discarding their likely needs
        - Consider declaring when deadwood < 10 points`,

    expert: `Play like a Marriage champion.
        - Perfect card memory - know what's left in deck
        - Probabilistic meld completion analysis
        - Opponent hand estimation based on picks/discards
        - Optimal tiplu placement in melds
        - Precise timing for declaration
        - Bluffing via strategic discards
        - Minimize opponent's meld opportunities`,
};

// Marriage bot play flow
export const marriageBotPlayFlow = ai.defineFlow(
    {
        name: 'marriageBotPlayFlow',
        inputSchema: MarriageBotInputSchema,
        outputSchema: MarriageBotOutputSchema,
    },
    async (input: MarriageBotInput): Promise<MarriageBotOutput> => {
        const { difficulty, hand, gameState } = input;
        const strategy = strategyPrompts[difficulty];

        const prompt = `You are an AI playing Nepali Marriage card game at ${difficulty} difficulty.

STRATEGY: ${strategy}

YOUR HAND: ${hand.join(', ')}
TIPLU (Wild Card): ${gameState.tiplu || 'Not drawn yet'}
TOP DISCARD: ${gameState.topDiscard || 'None'}
CARDS IN DECK: ${gameState.cardsInDeck}
ROUND: ${gameState.roundNumber}

GAME PHASE: ${gameState.phase}

MARRIAGE RULES:
- Form melds: Sets (3+ same rank) or Runs (3+ consecutive same suit)
- Tiplu acts as a wild card in any meld
- K+Q of same suit in a meld = Marriage bonus (40 trump, 20 non-trump)
- Declare when all 21 cards form valid non-overlapping melds

${gameState.phase === 'drawing' ? `
DRAWING PHASE - Choose one:
- "drawDeck": Draw unknown card from deck
- "drawDiscard": Take the top discard card

Consider: Does the discard card help complete a meld?
` : ''}

${gameState.phase === 'discarding' ? `
DISCARDING PHASE - Choose a card to discard:
- Pick a card that doesn't break potential melds
- Discard high-point cards if they're not useful
- Don't discard cards opponents might want
` : ''}

${gameState.phase === 'declaring' ? `
Should you DECLARE? Only if all 21 cards form valid melds.
If not ready, continue discarding.
` : ''}

Return JSON ONLY:
${gameState.phase === 'drawing'
                ? '{"action": "drawDeck" | "drawDiscard", "reasoning": "brief explanation"}'
                : '{"action": "discard" | "declare", "card": "card code if discarding", "reasoning": "brief explanation"}'}`;

        try {
            const { output } = await ai.generate({
                model: geminiPro,
                prompt,
                output: { schema: MarriageBotOutputSchema },
            });

            if (!output) {
                // Fallback logic
                if (gameState.phase === 'drawing') {
                    return { action: 'drawDeck', reasoning: 'Fallback' };
                } else {
                    const card = hand[Math.floor(Math.random() * hand.length)];
                    return { action: 'discard', card, reasoning: 'Fallback' };
                }
            }

            // Validate the response
            if (gameState.phase === 'discarding' && output.action === 'discard') {
                // Ensure the card is in hand
                if (output.card && !hand.includes(output.card)) {
                    // Fallback: discard a random card
                    output.card = hand[Math.floor(Math.random() * hand.length)];
                    output.reasoning = 'Fallback selection';
                }
            }

            return output;
        } catch (error) {
            // Fallback logic
            if (gameState.phase === 'drawing') {
                return { action: 'drawDeck', reasoning: 'Fallback' };
            } else {
                const card = hand[Math.floor(Math.random() * hand.length)];
                return { action: 'discard', card, reasoning: 'Fallback' };
            }
        }
    }
);
