/**
 * Game Tip Flow - AI-powered card suggestions for Call Break
 * 
 * Analyzes the current game state and suggests the best card to play.
 */

import { z } from 'zod';
import { ai, geminiFlash } from '../config';

// Input schema for game tip request
const GameTipInputSchema = z.object({
    hand: z.array(z.string()).describe('Cards in player hand, e.g., ["♠A", "♥K", "♦10"]'),
    trickCards: z.array(z.string()).describe('Cards currently on the table'),
    tricksNeeded: z.number().describe('Number of tricks player still needs to win'),
    tricksWon: z.number().describe('Tricks won so far'),
    bid: z.number().describe('Player bid for this round'),
    trumpSuit: z.string().default('spades').describe('Trump suit (always spades in Call Break)'),
    ledSuit: z.string().optional().describe('Suit that was led in current trick'),
});

// Output schema for game tip response
const GameTipOutputSchema = z.object({
    suggestedCard: z.string().describe('The recommended card to play'),
    reasoning: z.string().describe('Brief explanation of why this card is suggested'),
    confidence: z.enum(['high', 'medium', 'low']).describe('Confidence level of the suggestion'),
    alternativeCard: z.string().optional().describe('Second-best option if available'),
});

// Define the game tip flow
export const gameTipFlow = ai.defineFlow(
    {
        name: 'gameTipFlow',
        inputSchema: GameTipInputSchema,
        outputSchema: GameTipOutputSchema,
    },
    async (input) => {
        const prompt = `You are an expert Call Break card game player. Analyze the current game state and suggest the best card to play.

## Game Rules Reminder:
- Spades (♠) is always trump and beats all other suits
- You must follow the led suit if you have it
- If you can't follow suit, you may play any card (including trump)
- Higher rank wins within the same suit
- Ace is the highest rank

## Current Situation:
- Your hand: ${input.hand.join(', ')}
- Cards on table: ${input.trickCards.length > 0 ? input.trickCards.join(', ') : 'None (you lead)'}
- Led suit: ${input.ledSuit || 'N/A (you are leading)'}
- Your bid: ${input.bid}
- Tricks won so far: ${input.tricksWon}
- Tricks still needed: ${input.tricksNeeded}

## Your Task:
Analyze the situation and recommend the best card to play. Consider:
1. Do you need to win this trick to meet your bid?
2. Can you save high cards for later?
3. If leading, what's the safest/best lead?
4. If following, should you try to win or dump a low card?

Respond with a JSON object containing:
- suggestedCard: The card to play (e.g., "♠A")
- reasoning: Brief explanation (1-2 sentences)
- confidence: "high", "medium", or "low"
- alternativeCard: (optional) Second-best choice`;

        const { output } = await ai.generate({
            model: geminiFlash,
            prompt,
            output: { schema: GameTipOutputSchema },
        });

        return output || {
            suggestedCard: input.hand[0],
            reasoning: 'Unable to analyze, playing first available card',
            confidence: 'low' as const,
        };
    }
);

export type GameTipInput = z.infer<typeof GameTipInputSchema>;
export type GameTipOutput = z.infer<typeof GameTipOutputSchema>;
