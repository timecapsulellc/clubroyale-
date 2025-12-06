"use strict";
/**
 * Bid Suggestion Flow - AI recommends optimal bid based on hand strength
 *
 * Analyzes cards dealt and suggests how many tricks the player can win.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.bidSuggestionFlow = void 0;
const zod_1 = require("zod");
const config_1 = require("../config");
// Input schema for bid suggestion
const BidSuggestionInputSchema = zod_1.z.object({
    hand: zod_1.z.array(zod_1.z.string()).describe('13 cards dealt to player'),
    position: zod_1.z.number().min(1).max(4).describe('Bidding position (1-4, 1 bids first)'),
    previousBids: zod_1.z.array(zod_1.z.number()).optional().describe('Bids from previous players'),
});
// Output schema for bid suggestion
const BidSuggestionOutputSchema = zod_1.z.object({
    suggestedBid: zod_1.z.number().min(1).max(13).describe('Recommended bid'),
    confidence: zod_1.z.enum(['high', 'medium', 'low']).describe('Confidence in the bid'),
    reasoning: zod_1.z.string().describe('Brief explanation'),
    handStrength: zod_1.z.enum(['weak', 'average', 'strong', 'very_strong']).describe('Assessment of hand'),
    riskLevel: zod_1.z.enum(['safe', 'moderate', 'aggressive']).describe('Risk level of bid'),
});
// Define the bid suggestion flow
exports.bidSuggestionFlow = config_1.ai.defineFlow({
    name: 'bidSuggestionFlow',
    inputSchema: BidSuggestionInputSchema,
    outputSchema: BidSuggestionOutputSchema,
}, async (input) => {
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
    const { output } = await config_1.ai.generate({
        model: config_1.geminiFlash,
        prompt,
        output: { schema: BidSuggestionOutputSchema },
    });
    return output || {
        suggestedBid: 3,
        confidence: 'low',
        reasoning: 'Default safe bid',
        handStrength: 'average',
        riskLevel: 'safe',
    };
});
//# sourceMappingURL=bidSuggestionFlow.js.map