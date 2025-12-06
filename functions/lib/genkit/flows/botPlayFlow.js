"use strict";
/**
 * Bot Player Flow - AI that plays as a bot in Call Break
 *
 * Used when a player disconnects or for practice mode.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.botPlayFlow = void 0;
const zod_1 = require("zod");
const config_1 = require("../config");
// Input schema for bot decision
const BotPlayInputSchema = zod_1.z.object({
    hand: zod_1.z.array(zod_1.z.string()).describe('Cards in bot hand'),
    trickCards: zod_1.z.array(zod_1.z.object({
        card: zod_1.z.string(),
        playerId: zod_1.z.string(),
    })).describe('Cards played in current trick with player IDs'),
    currentRound: zod_1.z.number().describe('Current round number'),
    bid: zod_1.z.number().describe('Bot bid for this round'),
    tricksWon: zod_1.z.number().describe('Tricks won so far'),
    allBids: zod_1.z.record(zod_1.z.number()).describe('All player bids for current round'),
    allTricksWon: zod_1.z.record(zod_1.z.number()).describe('Tricks won by each player'),
    difficulty: zod_1.z.enum(['easy', 'medium', 'hard']).default('medium'),
});
// Output schema for bot decision
const BotPlayOutputSchema = zod_1.z.object({
    selectedCard: zod_1.z.string().describe('Card the bot chooses to play'),
    strategy: zod_1.z.string().describe('Brief explanation of the strategy used'),
});
// Define the bot player flow
exports.botPlayFlow = config_1.ai.defineFlow({
    name: 'botPlayFlow',
    inputSchema: BotPlayInputSchema,
    outputSchema: BotPlayOutputSchema,
}, async (input) => {
    const difficultyPrompt = {
        easy: 'Play somewhat randomly, occasionally making suboptimal choices.',
        medium: 'Play reasonably well, following basic strategy.',
        hard: 'Play optimally, considering all available information to maximize chances of meeting your bid.',
    };
    const trickDescription = input.trickCards.length > 0
        ? input.trickCards.map(t => `${t.playerId}: ${t.card}`).join(', ')
        : 'You are leading (first to play)';
    const opponentAnalysis = Object.entries(input.allBids)
        .map(([id, bid]) => `${id}: bid ${bid}, won ${input.allTricksWon[id] || 0}`)
        .join('\n');
    const prompt = `You are a Call Break bot player. ${difficultyPrompt[input.difficulty]}

## Your Hand:
${input.hand.join(', ')}

## Current Trick:
${trickDescription}

## Game State:
- Round: ${input.currentRound}
- Your bid: ${input.bid}
- Your tricks won: ${input.tricksWon}
- Tricks still needed: ${Math.max(0, input.bid - input.tricksWon)}

## Opponent Analysis:
${opponentAnalysis}

## Rules:
- Must follow the led suit if possible
- Spades (♠) is trump
- Must select a card from your hand

Select the best card to play and explain your strategy briefly.`;
    const { output } = await config_1.ai.generate({
        model: config_1.geminiPro,
        prompt,
        output: { schema: BotPlayOutputSchema },
    });
    // Fallback if AI fails
    if (!output) {
        return {
            selectedCard: input.hand[0],
            strategy: 'Fallback: playing first available card',
        };
    }
    // Validate the selected card is in hand
    if (!input.hand.includes(output.selectedCard)) {
        // Find closest match or use first card
        const matchingCard = input.hand.find(c => c.includes(output.selectedCard) || output.selectedCard.includes(c));
        return {
            selectedCard: matchingCard || input.hand[0],
            strategy: output.strategy,
        };
    }
    return output;
});
//# sourceMappingURL=botPlayFlow.js.map