"use strict";
/**
 * Cognitive AI Agent - Enhanced Bot Decision Flow
 *
 * Implements Tree-of-Thoughts reasoning for human-like gameplay.
 * Supports multiple AI personalities with different play styles.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.cognitivePlayFlow = exports.AI_PERSONALITIES = void 0;
exports.getPersonalityById = getPersonalityById;
exports.getRandomPersonality = getRandomPersonality;
const zod_1 = require("zod");
const config_1 = require("../../genkit/config");
// AI Personality Profiles
exports.AI_PERSONALITIES = {
    trickmaster: {
        id: 'bot_trickmaster',
        name: 'TrickMaster',
        avatar: '🎭',
        difficulty: 'hard',
        style: 'aggressive',
        traits: ['High risk tolerance', 'Bluffs often', 'Targets weakest player'],
        prompt: 'You are TrickMaster, an aggressive and cunning card player. You take calculated risks, bluff when the odds favor you, and always look for opportunities to dominate.',
    },
    cardshark: {
        id: 'bot_cardshark',
        name: 'CardShark',
        avatar: '🃏',
        difficulty: 'medium',
        style: 'conservative',
        traits: ['Low risk', 'Safe plays', 'Preserves high cards'],
        prompt: 'You are CardShark, a careful and methodical player. You minimize risks, preserve your best cards for crucial moments, and rarely make mistakes.',
    },
    luckydice: {
        id: 'bot_luckydice',
        name: 'LuckyDice',
        avatar: '🎲',
        difficulty: 'easy',
        style: 'chaotic',
        traits: ['Unpredictable', 'Makes fun mistakes', 'Easy to beat'],
        prompt: 'You are LuckyDice, a fun and unpredictable player. You sometimes make silly mistakes, pick cards that feel lucky, and keep the game entertaining.',
    },
    deepthink: {
        id: 'bot_deepthink',
        name: 'DeepThink',
        avatar: '🧠',
        difficulty: 'expert',
        style: 'analytical',
        traits: ['Multi-step planning', 'Counts cards', 'Optimal play'],
        prompt: 'You are DeepThink, a brilliant analytical player. You count cards, calculate probabilities, consider multiple future scenarios, and always make the optimal play.',
    },
    royalace: {
        id: 'bot_royalace',
        name: 'RoyalAce',
        avatar: '💎',
        difficulty: 'medium',
        style: 'balanced',
        traits: ['Human-like timing', 'Mixed strategy', 'Adaptive'],
        prompt: 'You are RoyalAce, a well-rounded player. You adapt to opponents, mix up your strategy, and play with realistic human-like timing and hesitation.',
    },
};
// Input schema for cognitive play
const CognitivePlayInputSchema = zod_1.z.object({
    hand: zod_1.z.array(zod_1.z.string()).describe('Cards in hand, e.g., ["AS", "KH", "7D"]'),
    gameState: zod_1.z.object({
        discardPile: zod_1.z.array(zod_1.z.string()).optional(),
        opponentCardCounts: zod_1.z.record(zod_1.z.number()).optional(),
        currentPhase: zod_1.z.string().optional(),
        tiplu: zod_1.z.string().optional(), // Wild card for Marriage
        hasVisited: zod_1.z.boolean().optional(),
        maalPoints: zod_1.z.number().optional(),
        tricksWon: zod_1.z.record(zod_1.z.number()).optional(),
        bids: zod_1.z.record(zod_1.z.number()).optional(),
        currentTrick: zod_1.z.array(zod_1.z.string()).optional(),
    }),
    personality: zod_1.z.enum(['trickmaster', 'cardshark', 'luckydice', 'deepthink', 'royalace']),
    gameType: zod_1.z.enum(['marriage', 'call_break', 'teen_patti', 'in_between']),
});
const CognitivePlayOutputSchema = zod_1.z.object({
    action: zod_1.z.enum(['draw_deck', 'draw_discard', 'discard', 'visit', 'declare', 'bid', 'play']),
    card: zod_1.z.string().optional().describe('Card to play or discard'),
    bidAmount: zod_1.z.number().optional().describe('Bid amount for Call Break'),
    internalThought: zod_1.z.string().describe('AI reasoning (for debugging)'),
    confidenceScore: zod_1.z.number().min(0).max(1).describe('Confidence in this decision'),
    thinkingTimeMs: zod_1.z.number().describe('Suggested delay before action (ms)'),
});
/**
 * Cognitive Play Flow - Tree of Thoughts Decision Making
 */
exports.cognitivePlayFlow = config_1.ai.defineFlow({
    name: 'cognitivePlayFlow',
    inputSchema: CognitivePlayInputSchema,
    outputSchema: CognitivePlayOutputSchema,
}, async (input) => {
    const personalityKey = input.personality;
    const personality = exports.AI_PERSONALITIES[personalityKey];
    // Build the prompt with Tree-of-Thoughts structure
    const totPrompt = `
${personality.prompt}

You are playing ${input.gameType.replace('_', ' ').toUpperCase()}.

CURRENT SITUATION:
- Your hand: ${input.hand.join(', ')}
- Game state: ${JSON.stringify(input.gameState, null, 2)}

TREE OF THOUGHTS REASONING:
Consider 3 possible strategies, evaluate each, then choose the best.

STRATEGY A: [Most aggressive option]
- What would you play?
- Expected outcome?
- Risk level?

STRATEGY B: [Most conservative option]
- What would you play?
- Expected outcome?
- Risk level?

STRATEGY C: [Balanced/creative option]
- What would you play?
- Expected outcome?
- Risk level?

FINAL DECISION:
Based on your ${personality.style} personality and the analysis above, choose the best action.

Respond with a JSON object containing:
- action: "draw_deck|draw_discard|discard|visit|declare|bid|play"
- card: "CARD_CODE_OR_NULL" (e.g., "AS" for Ace of Spades)
- bidAmount: null (or number if bidding)
- internalThought: "Your reasoning here"
- confidenceScore: 0.0-1.0
- thinkingTimeMs: 2000-6000
`;
    const { output } = await config_1.ai.generate({
        model: config_1.geminiFlash,
        prompt: totPrompt,
        output: { schema: CognitivePlayOutputSchema },
        config: {
            temperature: personality.style === 'chaotic' ? 1.0 : 0.3,
            maxOutputTokens: 500,
        },
    });
    if (output) {
        // Apply personality-based timing adjustments
        let thinkingTime = output.thinkingTimeMs || 3000;
        switch (personality.difficulty) {
            case 'easy':
                thinkingTime = Math.min(thinkingTime, 2000);
                break;
            case 'medium':
                thinkingTime = Math.max(2000, Math.min(thinkingTime, 4000));
                break;
            case 'hard':
            case 'expert':
                thinkingTime = Math.max(3000, Math.min(thinkingTime, 6000));
                break;
        }
        return {
            ...output,
            thinkingTimeMs: thinkingTime,
        };
    }
    // Fallback: play first card
    return {
        action: 'discard',
        card: input.hand[0],
        internalThought: 'Fallback: playing first available card',
        confidenceScore: 0.3,
        thinkingTimeMs: 2000,
    };
});
/**
 * Get AI personality by ID
 */
function getPersonalityById(botId) {
    return Object.values(exports.AI_PERSONALITIES).find(p => p.id === botId);
}
/**
 * Get random personality
 */
function getRandomPersonality() {
    const personalities = Object.values(exports.AI_PERSONALITIES);
    return personalities[Math.floor(Math.random() * personalities.length)];
}
//# sourceMappingURL=cognitivePlayFlow.js.map