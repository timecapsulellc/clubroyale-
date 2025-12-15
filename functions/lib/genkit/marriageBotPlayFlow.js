"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.marriageBotPlayFlow = void 0;
const zod_1 = require("zod");
const config_1 = require("./config");
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
// Input schema for bot - now includes region
const MarriageBotInputSchema = zod_1.z.object({
    difficulty: zod_1.z.enum(['easy', 'medium', 'hard', 'expert']),
    hand: zod_1.z.array(zod_1.z.string()),
    region: zod_1.z.enum(['global', 'southAsia']).default('global'),
    gameState: zod_1.z.object({
        phase: zod_1.z.enum(['drawing', 'discarding', 'declaring']),
        tiplu: zod_1.z.string().optional(),
        topDiscard: zod_1.z.string().optional(),
        cardsInDeck: zod_1.z.number(),
        roundNumber: zod_1.z.number(),
        myMelds: zod_1.z.array(zod_1.z.array(zod_1.z.string())).optional(),
        opponentCardCounts: zod_1.z.record(zod_1.z.number()).optional(),
    }),
});
// Output schema
const MarriageBotOutputSchema = zod_1.z.object({
    action: zod_1.z.enum(['drawDeck', 'drawDiscard', 'discard', 'declare']),
    card: zod_1.z.string().optional(),
    reasoning: zod_1.z.string().optional(),
});
// Strategy prompts generator based on difficulty and terminology
const getStrategyPrompt = (difficulty, terms) => {
    const strategies = {
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
exports.marriageBotPlayFlow = config_1.ai.defineFlow({
    name: 'marriageBotPlayFlow',
    inputSchema: MarriageBotInputSchema,
    outputSchema: MarriageBotOutputSchema,
}, async (input) => {
    const { difficulty, hand, gameState, region = 'global' } = input;
    const terms = terminology[region];
    const strategy = getStrategyPrompt(difficulty, terms);
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
        const { output } = await config_1.ai.generate({
            model: config_1.geminiPro,
            prompt,
            output: { schema: MarriageBotOutputSchema },
        });
        if (!output) {
            // Fallback logic
            if (gameState.phase === 'drawing') {
                return { action: 'drawDeck', reasoning: 'Fallback' };
            }
            else {
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
    }
    catch (error) {
        // Fallback logic
        if (gameState.phase === 'drawing') {
            return { action: 'drawDeck', reasoning: 'Fallback' };
        }
        else {
            const card = hand[Math.floor(Math.random() * hand.length)];
            return { action: 'discard', card, reasoning: 'Fallback' };
        }
    }
});
//# sourceMappingURL=marriageBotPlayFlow.js.map