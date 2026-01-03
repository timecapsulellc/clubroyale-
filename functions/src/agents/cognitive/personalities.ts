/**
 * Bot Personalities Configuration
 * Shared definitions for AI opponent behaviors.
 */

export enum AIDifficulty {
    EASY = 'easy',
    MEDIUM = 'medium',
    HARD = 'hard',
    EXPERT = 'expert'
}

export interface BotPersonality {
    id: string;
    name: string;
    description: string;
    difficulty: AIDifficulty;
    traits: {
        aggression: number; // 0-1
        bluffing: number;   // 0-1
        risk: number;       // 0-1
    };
    promptModifier: string; // Text appended to LLM prompt
}

export const personalities: Record<string, BotPersonality> = {
    trick_master: {
        id: 'trick_master',
        name: 'TrickMaster',
        description: 'Aggressive bluffer who plays mind games.',
        difficulty: AIDifficulty.HARD,
        traits: { aggression: 0.9, bluffing: 0.8, risk: 0.7 },
        promptModifier: 'You are TrickMaster. Play aggressively. Bluff often. Intimidate opponents with high bids.'
    },
    card_shark: {
        id: 'card_shark',
        name: 'CardShark',
        description: 'Conservative player who minimizes risk.',
        difficulty: AIDifficulty.MEDIUM,
        traits: { aggression: 0.3, bluffing: 0.1, risk: 0.2 },
        promptModifier: 'You are CardShark. Play safely. Do not bluff. Only bet high with strong hands.'
    },
    lucky_dice: {
        id: 'lucky_dice',
        name: 'LuckyDice',
        description: 'Unpredictable and chaotic.',
        difficulty: AIDifficulty.EASY,
        traits: { aggression: 0.6, bluffing: 0.5, risk: 0.9 },
        promptModifier: 'You are LuckyDice. Make random, unpredictable moves. Take unnecessary risks for fun.'
    },
    deep_think: {
        id: 'deep_think',
        name: 'DeepThink',
        description: 'Analytical genius who counts cards.',
        difficulty: AIDifficulty.EXPERT,
        traits: { aggression: 0.4, bluffing: 0.2, risk: 0.3 },
        promptModifier: 'You are DeepThink. Calculate probabilities. Memorize played cards. Play optimally.'
    },
    royal_ace: {
        id: 'royal_ace',
        name: 'RoyalAce',
        description: 'Balanced and adaptive.',
        difficulty: AIDifficulty.MEDIUM,
        traits: { aggression: 0.5, bluffing: 0.3, risk: 0.5 },
        promptModifier: 'You are RoyalAce. Play a balanced game. Adapt to the situation.'
    }
};

export const getBotById = (id: string): BotPersonality | undefined => personalities[id];
export const getRandomBot = (): BotPersonality => {
    const ids = Object.keys(personalities);
    return personalities[ids[Math.floor(Math.random() * ids.length)]];
};
