/**
 * Bid Suggestion Flow - AI recommends optimal bid based on hand strength
 * 
 * Analyzes cards dealt and suggests how many tricks the player can win.
 */

import { z } from 'zod';
import { ai, geminiFlash } from '../config';

// Input schema for bid suggestion
const BidSuggestionInputSchema = z.object({
    hand: z.array(z.string()).describe('13 cards dealt to player'),
    position: z.number().min(1).max(4).describe('Bidding position (1-4, 1 bids first)'),
    previousBids: z.array(z.number()).optional().describe('Bids from previous players'),
});

// Output schema for bid suggestion
const BidSuggestionOutputSchema = z.object({
    suggestedBid: z.number().min(1).max(13).describe('Recommended bid'),
    confidence: z.enum(['high', 'medium', 'low']).describe('Confidence in the bid'),
    reasoning: z.string().describe('Brief explanation'),
    handStrength: z.enum(['weak', 'average', 'strong', 'very_strong']).describe('Assessment of hand'),
    riskLevel: z.enum(['safe', 'moderate', 'aggressive']).describe('Risk level of bid'),
});

// Define the bid suggestion flow
export const bidSuggestionFlow = ai.defineFlow(
    {
        name: 'bidSuggestionFlow',
        inputSchema: BidSuggestionInputSchema,
        outputSchema: BidSuggestionOutputSchema,
    },
    async (input) => {
        // Sort hand for better analysis
        const prompt = `You are an expert Call Break player analyzing a hand for bidding.

## Your Hand (13 cards):
${input.hand.join(', ')}

## Bidding Position: ${input.position} of 4
${input.previousBids?.length ? `Previous bids: ${input.previousBids.join(', ')}` : 'You are bidding first.'}

## Bidding Guidelines:
1. Count sure tricks:
   - ♠A is almost always a trick (trump ace)
   - Other aces are likely tricks if you can protect them
   - High spades (K, Q) are valuable
   
2. Consider:
   - Long suits: More cards = more control
   - Short suits: Can trump when void
   - Spade count: More spades = more tricks
   
3. Common bid ranges:
   - Weak hand (no aces, few spades): 1-2
   - Average hand: 3-4
   - Strong hand (2+ aces, 4+ spades): 5-6
   - Very strong: 7+

4. Position matters:
   - Early position: Bid slightly conservative
   - Late position: Can adjust based on others' bids

Analyze this hand and suggest the optimal bid (1-13).

Respond with:
- suggestedBid: The recommended bid (number 1-13)
- confidence: "high", "medium", or "low"
- reasoning: One sentence explanation
- handStrength: "weak", "average", "strong", or "very_strong"
- riskLevel: "safe", "moderate", or "aggressive"`;

        const { output } = await ai.generate({
            model: geminiFlash,
            prompt,
            output: { schema: BidSuggestionOutputSchema },
        });

        return output || {
            suggestedBid: 3,
            confidence: 'low' as const,
            reasoning: 'Default safe bid',
            handStrength: 'average' as const,
            riskLevel: 'safe' as const,
        };
    }
);

export type BidSuggestionInput = z.infer<typeof BidSuggestionInputSchema>;
export type BidSuggestionOutput = z.infer<typeof BidSuggestionOutputSchema>;
