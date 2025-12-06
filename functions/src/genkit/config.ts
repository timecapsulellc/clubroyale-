/**
 * Genkit Configuration for TaasClub
 * 
 * This file initializes Genkit with the Google AI (Gemini) plugin.
 */

import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/googleai';

// Initialize Genkit with Google AI plugin
export const ai = genkit({
    plugins: [
        googleAI({
            // API key is read from GOOGLE_GENAI_API_KEY environment variable
            // Set this in your .env file or Firebase Functions config
        }),
    ],
});

// Export model references for use in flows
export const geminiFlash = 'googleai/gemini-1.5-flash';
export const geminiPro = 'googleai/gemini-1.5-pro';
