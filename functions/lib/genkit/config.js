"use strict";
/**
 * Genkit Configuration for TaasClub
 *
 * This file initializes Genkit with the Google AI (Gemini) plugin.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.geminiPro = exports.geminiFlash = exports.ai = void 0;
const genkit_1 = require("genkit");
const googleai_1 = require("@genkit-ai/googleai");
// Initialize Genkit with Google AI plugin
exports.ai = (0, genkit_1.genkit)({
    plugins: [
        (0, googleai_1.googleAI)({
        // API key is read from GOOGLE_GENAI_API_KEY environment variable
        // Set this in your .env file or Firebase Functions config
        }),
    ],
});
// Export model references for use in flows
exports.geminiFlash = 'googleai/gemini-1.5-flash';
exports.geminiPro = 'googleai/gemini-1.5-pro';
//# sourceMappingURL=config.js.map