
import { marriageBotPlayFlow } from '../genkit/marriageBotPlayFlow';
import { z } from 'zod';

async function verifyMarriageBot() {
    console.log('🧪 Starting Marriage Bot Flow Verification...');

    const testInput: any = {
        hand: ['H2', 'H3', 'S10', 'SK', 'DQ'],
        difficulty: 'easy',
        region: 'global',
        gameState: {
            phase: 'drawing',
            cardsInDeck: 20,
            roundNumber: 1,
        }
    };

    console.log('📥 Input:', JSON.stringify(testInput, null, 2));

    try {
        console.log('🔄 Invoking flow...');
        const result = await marriageBotPlayFlow(testInput);
        console.log('✅ Result:', JSON.stringify(result, null, 2));
    } catch (error: any) {
        // We expect an error if the API key is not set, but we want to confirm 
        // it's an API error and not a code/schema error.
        if (error.message && (error.message.includes('API key') || error.message.includes('credential'))) {
            console.log('⚠️ Verified: Flow executed but stopped at API call (Expected without API Key).');
            console.log('Error message:', error.message);
        } else {
            console.error('❌ Verification Failed with unexpected error:', error);
            process.exit(1);
        }
    }
}

verifyMarriageBot();
