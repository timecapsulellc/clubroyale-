
/// Marriage Game AI Prompts
/// 
/// These prompts are ensuring consistency between client-side explanations
/// and server-side behavior.
library;

class MarriagePrompts {
  static const String strategyEasy = 
      "Play casually. I'll make simple decisions and won't track your cards too closely.";

  static const String strategyMedium = 
      "I'll play with basic strategy, trying to form melds and watching for Tiplu (wild cards).";

  static const String strategyHard = 
      "I'm playing to win. I'll track played cards, calculate probabilities, and play defensively.";

  static const String strategyExpert = 
      "Champion mode. I'll memorize every card, calculate optimal Tiplu usage, and bluff when necessary.";

  static String getStrategyDescription(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy': return strategyEasy;
      case 'hard': return strategyHard;
      case 'expert': return strategyExpert;
      case 'medium': 
      default: return strategyMedium;
    }
  }

  static const String systemContext = 
      "You are an AI playing the Nepali Marriage card game. "
      "Your goal is to complete 3 sets (tunelas, trials) or sequences (runs) to declare. "
      "Tiplu is the wild card. Maal cards give bonus points.";
}
