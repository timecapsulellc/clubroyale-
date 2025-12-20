/**
 * Cognitive AI Agent - Enhanced Bot Decision Flow
 * 
 * Implements Tree-of-Thoughts reasoning for human-like gameplay.
 * Supports multiple AI personalities with different play styles.
 */

import { z } from 'zod';
import { ai, geminiFlash } from '../../genkit/config';

// AI Personality Profiles
export const AI_PERSONALITIES = {
    trickmaster: {
        id: 'bot_trickmaster',
        name: 'TrickMaster',
        avatar: '🎭',
        difficulty: 'hard' as const,
        style: 'aggressive' as const,
        traits: ['High risk tolerance', 'Bluffs often', 'Targets weakest player'],
        prompt: 'You are TrickMaster, an aggressive and cunning card player. You take calculated risks, bluff when the odds favor you, and always look for opportunities to dominate.',
    },
    cardshark: {
        id: 'bot_cardshark',
        name: 'CardShark',
        avatar: '🃏',
        difficulty: 'medium' as const,
        style: 'conservative' as const,
        traits: ['Low risk', 'Safe plays', 'Preserves high cards'],
        prompt: 'You are CardShark, a careful and methodical player. You minimize risks, preserve your best cards for crucial moments, and rarely make mistakes.',
    },
    luckydice: {
        id: 'bot_luckydice',
        name: 'LuckyDice',
        avatar: '🎲',
        difficulty: 'easy' as const,
        style: 'chaotic' as const,
        traits: ['Unpredictable', 'Makes fun mistakes', 'Easy to beat'],
        prompt: 'You are LuckyDice, a fun and unpredictable player. You sometimes make silly mistakes, pick cards that feel lucky, and keep the game entertaining.',
    },
    deepthink: {
        id: 'bot_deepthink',
        name: 'DeepThink',
        avatar: '🧠',
        difficulty: 'expert' as const,
        style: 'analytical' as const,
        traits: ['Multi-step planning', 'Counts cards', 'Optimal play'],
        prompt: 'You are DeepThink, a brilliant analytical player. You count cards, calculate probabilities, consider multiple future scenarios, and always make the optimal play.',
    },
    royalace: {
        id: 'bot_royalace',
        name: 'RoyalAce',
        avatar: '💎',
        difficulty: 'medium' as const,
        style: 'balanced' as const,
        traits: ['Human-like timing', 'Mixed strategy', 'Adaptive'],
        prompt: 'You are RoyalAce, a well-rounded player. You adapt to opponents, mix up your strategy, and play with realistic human-like timing and hesitation.',
    },
};

type PersonalityKey = keyof typeof AI_PERSONALITIES;

// Input schema for cognitive play
const CognitivePlayInputSchema = z.object({
    hand: z.array(z.string()).describe('Cards in hand, e.g., ["AS", "KH", "7D"]'),
    gameState: z.object({
        discardPile: z.array(z.string()).optional(),
        opponentCardCounts: z.record(z.number()).optional(),
        currentPhase: z.string().optional(),
        tiplu: z.string().optional(), // Wild card for Marriage
        hasVisited: z.boolean().optional(),
        maalPoints: z.number().optional(),
        tricksWon: z.record(z.number()).optional(),
        bids: z.record(z.number()).optional(),
        currentTrick: z.array(z.string()).optional(),
    }),
    personality: z.enum(['trickmaster', 'cardshark', 'luckydice', 'deepthink', 'royalace']),
    gameType: z.enum(['marriage', 'call_break', 'teen_patti', 'in_between']),
});

const CognitivePlayOutputSchema = z.object({
    action: z.enum(['draw_deck', 'draw_discard', 'discard', 'visit', 'declare', 'bid', 'play']),
    card: z.string().optional().describe('Card to play or discard'),
    bidAmount: z.number().optional().describe('Bid amount for Call Break'),
    internalThought: z.string().describe('AI reasoning (for debugging)'),
    confidenceScore: z.number().min(0).max(1).describe('Confidence in this decision'),
    thinkingTimeMs: z.number().describe('Suggested delay before action (ms)'),
});

/**
 * Cognitive Play Flow - Tree of Thoughts Decision Making
 */
export const cognitivePlayFlow = ai.defineFlow(
    {
        name: 'cognitivePlayFlow',
        inputSchema: CognitivePlayInputSchema,
        outputSchema: CognitivePlayOutputSchema,
    },
    async (input) => {
        const personalityKey = input.personality as PersonalityKey;
        const personality = AI_PERSONALITIES[personalityKey];

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

        const { output } = await ai.generate({
            model: geminiFlash,
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
            action: 'discard' as const,
            card: input.hand[0],
            internalThought: 'Fallback: playing first available card',
            confidenceScore: 0.3,
            thinkingTimeMs: 2000,
        };
    }
);

/**
 * Get AI personality by ID
 */
export function getPersonalityById(botId: string) {
    return Object.values(AI_PERSONALITIES).find(p => p.id === botId);
}

/**
 * Get random personality
 */
export function getRandomPersonality() {
    const personalities = Object.values(AI_PERSONALITIES);
    return personalities[Math.floor(Math.random() * personalities.length)];
}

export type CognitivePlayInput = z.infer<typeof CognitivePlayInputSchema>;
export type CognitivePlayOutput = z.infer<typeof CognitivePlayOutputSchema>;
