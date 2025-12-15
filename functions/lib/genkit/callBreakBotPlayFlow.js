"use strict";
/**
 * Call Break Bot Play Flow
 *
 * Dedicated GenKit AI flow for Call Break card game with
 * trick-taking strategy prompts for different difficulty levels.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.callBreakBotPlayFlow = void 0;
const zod_1 = require("zod");
const config_1 = require("./config");
// Input schema for Call Break bot
const CallBreakBotInputSchema = zod_1.z.object({
    difficulty: zod_1.z.enum(['easy', 'medium', 'hard', 'expert']),
    hand: zod_1.z.array(zod_1.z.string()),
    gameState: zod_1.z.object({
        phase: zod_1.z.enum(['bidding', 'playing']),
        trumpSuit: zod_1.z.string().default('spades'),
        currentTrick: zod_1.z.array(zod_1.z.object({
            playerId: zod_1.z.string(),
            card: zod_1.z.string(),
        })),
        myBid: zod_1.z.number().optional(),
        tricksWon: zod_1.z.number(),
        tricksNeeded: zod_1.z.number(),
        roundNumber: zod_1.z.number(),
        leadSuit: zod_1.z.string().optional(),
        bids: zod_1.z.record(zod_1.z.number()).optional(),
    }),
});
// Output schema
const CallBreakBotOutputSchema = zod_1.z.object({
    action: zod_1.z.enum(['bid', 'playCard']),
    value: zod_1.z.union([zod_1.z.number(), zod_1.z.string()]),
    reasoning: zod_1.z.string().optional(),
});
// Strategy prompts based on difficulty
const strategyPrompts = {
    easy: `Play casually with simple decisions.
        - Bid conservatively (2-3 tricks)
        - Play your highest card when leading
        - Follow suit with any card
        - Don't strategize about trumping`,
    medium: `Play with basic trick-taking strategy.
        - Count high cards (A, K, Q) and trump cards for bidding
        - Lead with your strongest suit
        - Follow suit with winner or lowest card
        - Trump only when you can't follow suit`,
    hard: `Play strategically.
        - Accurate bid based on hand analysis
        - Track which cards have been played
        - Force opponents to use trumps early
        - Save trumps for key tricks
        - Lead with card that tests opponent hands`,
    expert: `Play like a Call Break champion.
        - Perfect card counting
        - Predict opponent hands based on plays
        - Optimal trump management
        - Calculate probabilities for each trick
        - Sacrifice tricks strategically to meet bid exactly
        - Force opponents to overbid or underbid`,
};
// Helper to check if player can follow suit
function canFollowSuit(hand, leadSuit) {
    return hand.some((c) => c.slice(-1).toLowerCase() === leadSuit.toLowerCase());
}
// Call Break bot play flow
exports.callBreakBotPlayFlow = config_1.ai.defineFlow({
    name: 'callBreakBotPlayFlow',
    inputSchema: CallBreakBotInputSchema,
    outputSchema: CallBreakBotOutputSchema,
}, async (input) => {
    const { difficulty, hand, gameState } = input;
    const strategy = strategyPrompts[difficulty];
    const prompt = `You are an AI playing Call Break at ${difficulty} difficulty.

STRATEGY: ${strategy}

YOUR HAND: ${hand.join(', ')}
TRUMP SUIT: ${gameState.trumpSuit} (Spades)
ROUND: ${gameState.roundNumber}/5

${gameState.phase === 'bidding' ? `
BIDDING PHASE:
- You must bid 1-13 tricks you think you'll win
- Count your high cards (A=high, K, Q, J)
- Count your trump cards (spades)
- Consider your shortest suits (opportunities to trump)

Other bids so far: ${JSON.stringify(gameState.bids || {})}

Return JSON: {"action": "bid", "value": <number 1-13>, "reasoning": "..."}
` : `
PLAYING PHASE:
Your Bid: ${gameState.myBid}
Tricks Won: ${gameState.tricksWon}
Tricks Needed: ${gameState.tricksNeeded}

Current Trick: ${gameState.currentTrick.length === 0 ? 'You lead' : gameState.currentTrick.map((t) => t.card).join(', ')}
Lead Suit: ${gameState.leadSuit || 'You choose'}

RULES:
- Must follow suit if possible
- Spades (trump) beats all other suits
- Highest card of lead suit wins (unless trumped)
- If you can't follow suit, you may play any card

${gameState.currentTrick.length === 0 ?
        'You are LEADING. Choose wisely - strong cards or try to draw out trumps.' :
        canFollowSuit(hand, gameState.leadSuit || '') ?
            `You MUST follow suit (${gameState.leadSuit}). Play a winner or save high cards.` :
            'You cannot follow suit. Consider trumping to win or discarding a low card.'}

Return JSON: {"action": "playCard", "value": "<card code>", "reasoning": "..."}
`}`;
    try {
        const { output } = await config_1.ai.generate({
            model: config_1.geminiPro,
            prompt,
            output: { schema: CallBreakBotOutputSchema },
        });
        if (!output) {
            // Fallback logic
            if (gameState.phase === 'bidding') {
                const highCards = hand.filter((c) => ['A', 'K', 'Q'].includes(c.slice(0, -1)));
                return { action: 'bid', value: Math.max(1, highCards.length), reasoning: 'Fallback' };
            }
            else {
                const leadSuit = gameState.leadSuit;
                if (leadSuit && canFollowSuit(hand, leadSuit)) {
                    const card = hand.find((c) => c.slice(-1).toLowerCase() === leadSuit.toLowerCase());
                    return { action: 'playCard', value: card, reasoning: 'Fallback' };
                }
                return { action: 'playCard', value: hand[0], reasoning: 'Fallback' };
            }
        }
        // Validate the response
        if (gameState.phase === 'playing') {
            const chosenCard = output.value;
            // Ensure card is in hand
            if (!hand.includes(chosenCard)) {
                // Must follow suit if possible
                const leadSuit = gameState.leadSuit;
                if (leadSuit && canFollowSuit(hand, leadSuit)) {
                    const suitCards = hand.filter((c) => c.slice(-1).toLowerCase() === leadSuit.toLowerCase());
                    output.value = suitCards[0];
                }
                else {
                    output.value = hand[0];
                }
                output.reasoning = 'Fallback selection';
            }
            // Validate follow suit rule
            const leadSuit = gameState.leadSuit;
            if (leadSuit && canFollowSuit(hand, leadSuit)) {
                const chosenSuit = output.value.slice(-1).toLowerCase();
                if (chosenSuit !== leadSuit.toLowerCase()) {
                    const suitCards = hand.filter((c) => c.slice(-1).toLowerCase() === leadSuit.toLowerCase());
                    output.value = suitCards[0];
                    output.reasoning = 'Corrected: must follow suit';
                }
            }
        }
        else if (gameState.phase === 'bidding') {
            // Validate bid range
            const bid = output.value;
            if (bid < 1 || bid > 13) {
                output.value = Math.min(13, Math.max(1, Math.round(hand.length / 4)));
            }
        }
        return output;
    }
    catch (error) {
        // Fallback logic
        if (gameState.phase === 'bidding') {
            const highCards = hand.filter((c) => ['A', 'K', 'Q'].includes(c.slice(0, -1)));
            return { action: 'bid', value: Math.max(1, highCards.length), reasoning: 'Fallback' };
        }
        else {
            const leadSuit = gameState.leadSuit;
            if (leadSuit && canFollowSuit(hand, leadSuit)) {
                const card = hand.find((c) => c.slice(-1).toLowerCase() === leadSuit.toLowerCase());
                return { action: 'playCard', value: card, reasoning: 'Fallback' };
            }
            return { action: 'playCard', value: hand[0], reasoning: 'Fallback' };
        }
    }
});
//# sourceMappingURL=callBreakBotPlayFlow.js.map