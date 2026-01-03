/**
 * Royal Meld / Marriage Bot Play Flow
 * 
 * Dedicated GenKit AI flow for Royal Meld (Marriage) card game with
 * game-specific strategy prompts for different difficulty levels.
 * 
 * Supports dual terminology:
 * - Global: Royal Meld, Wild Card, High Wild, Low Wild, Royal Sequence, Go Royale
 * - South Asia: Marriage, Tiplu, Poplu, Jhiplu, Marriage, Declare
 */

import { z } from 'zod';
import { ai, geminiPro } from './config';
import { personalities } from '../agents/cognitive/personalities';

// Terminology configurations for each region
const terminology = {
    global: {
        gameName: 'Royal Meld',
        wildCard: 'Wild Card',
        highWild: 'High Wild',
        lowWild: 'Low Wild',
        royalSequence: 'Royal Sequence',
        declare: 'Go Royale',
        description: 'card game',
    },
    southAsia: {
        gameName: 'Marriage',
        wildCard: 'Tiplu',
        highWild: 'Poplu',
        lowWild: 'Jhiplu',
        royalSequence: 'Marriage',
        declare: 'Declare',
        description: 'Nepali card game',
    },
};

// Input schema for bot - now includes region and personality
const MarriageBotInputSchema = z.object({
    difficulty: z.enum(['easy', 'medium', 'hard', 'expert']),
    personalityId: z.string().optional(),
    hand: z.array(z.string()),
    region: z.enum(['global', 'southAsia']).default('global'),
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

// Strategy prompts generator based on difficulty and terminology
const getStrategyPrompt = (difficulty: string, terms: typeof terminology.global): string => {
    const strategies: Record<string, string> = {
        easy: `Play casually. Make simple decisions. 
        - Draw from deck randomly
        - Discard high point cards first
        - Don't track opponent cards`,

        medium: `Play with basic strategy.
        - Try to form melds (sets of 3+ same rank, runs of 3+ same suit)
        - Keep cards that might form melds
        - Discard unrelated high-point cards
        - Notice ${terms.wildCard} (wild card) opportunities`,

        hard: `Play strategically.
        - Track which cards have been played
        - Calculate probability of completing melds
        - Use ${terms.wildCard} (wild card) optimally
        - Block opponents by not discarding their likely needs
        - Consider ${terms.declare.toLowerCase()}ing when deadwood < 10 points`,

        expert: `Play like a ${terms.gameName} champion.
        - Perfect card memory - know what's left in deck
        - Probabilistic meld completion analysis
        - Opponent hand estimation based on picks/discards
        - Optimal ${terms.wildCard} placement in melds
        - Precise timing for ${terms.declare}
        - Bluffing via strategic discards
        - Minimize opponent's meld opportunities`,
    };
    return strategies[difficulty] || strategies.medium;
};

// Royal Meld / Marriage bot play flow
export const marriageBotPlayFlow = ai.defineFlow(
    {
        name: 'marriageBotPlayFlow',
        inputSchema: MarriageBotInputSchema,
        outputSchema: MarriageBotOutputSchema,
    },
    async (input: MarriageBotInput): Promise<MarriageBotOutput> => {
        const { difficulty, personalityId, hand, gameState, region = 'global' } = input;
        const terms = terminology[region];
        let strategy = getStrategyPrompt(difficulty, terms);

        // Inject Personality Trait if provided
        if (personalityId && personalities[personalityId]) {
            const p = personalities[personalityId];
            strategy += `\n\nPERSONALITY (${p.name}): ${p.promptModifier}`;
        }

        const prompt = `You are an AI playing ${terms.gameName} ${terms.description} at ${difficulty} difficulty.

STRATEGY: ${strategy}

YOUR HAND: ${hand.join(', ')}
${terms.wildCard.toUpperCase()} (Wild Card): ${gameState.tiplu || 'Not drawn yet'}
TOP DISCARD: ${gameState.topDiscard || 'None'}
CARDS IN DECK: ${gameState.cardsInDeck}
ROUND: ${gameState.roundNumber}

GAME PHASE: ${gameState.phase}

${terms.gameName.toUpperCase()} RULES:
- Form melds: Sets (3+ same rank) or Runs (3+ consecutive same suit)
- ${terms.wildCard} acts as a wild card in any meld
- ${terms.lowWild} + ${terms.wildCard} + ${terms.highWild} of same suit = ${terms.royalSequence} bonus (40 trump, 20 non-trump)
- ${terms.declare} when all 21 cards form valid non-overlapping melds

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
Should you ${terms.declare.toUpperCase()}? Only if all 21 cards form valid melds.
If not ready, continue discarding.
` : ''}

Return JSON ONLY:
${gameState.phase === 'drawing'
                ? '{"action": "drawDeck" | "drawDiscard", "reasoning": "brief explanation"}'
                : `{"action": "discard" | "declare", "card": "card code if discarding", "reasoning": "brief explanation"}`}`;

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
