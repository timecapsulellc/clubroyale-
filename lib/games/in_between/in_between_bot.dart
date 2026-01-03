/// In Between Bot Strategy
///
/// AI-powered bot decision making for In Between (Acey Deucey) game
/// Probability-based betting based on card spread
library;

import 'dart:math';
import 'package:clubroyale/core/card_engine/pile.dart';

/// Bot difficulty level
enum InBetweenBotDifficulty {
  easy, // Random, overbets sometimes
  medium, // Basic probability calculation
  hard, // Optimal probability-based betting
}

/// In Between Bot Strategy
class InBetweenBotStrategy {
  final Random _random = Random();
  final InBetweenBotDifficulty difficulty;

  InBetweenBotStrategy({this.difficulty = InBetweenBotDifficulty.medium});

  /// Decide bet amount based on cards and probability
  /// Returns 0 to pass, or positive amount to bet
  int decideBetAmount({
    required Card lowCard,
    required Card highCard,
    required int pot,
    required int chips,
    required int cardsRemaining,
  }) {
    final probability = calculateWinProbability(
      lowCard: lowCard,
      highCard: highCard,
      cardsRemaining: cardsRemaining,
    );

    final maxBet = chips < pot ? chips : pot;

    switch (difficulty) {
      case InBetweenBotDifficulty.easy:
        return _decideEasyBet(probability, maxBet);

      case InBetweenBotDifficulty.medium:
        return _decideMediumBet(probability, maxBet);

      case InBetweenBotDifficulty.hard:
        return _decideHardBet(probability, maxBet, pot);
    }
  }

  /// Easy bot: Random betting, sometimes overbets
  int _decideEasyBet(double probability, int maxBet) {
    // Easy bot makes random decisions
    if (probability < 0.15) {
      // Very narrow spread - still might bet
      return _random.nextDouble() < 0.3 ? (maxBet * 0.2).round() : 0;
    }

    // Random bet amount between 20-80% of max
    final betPercent = 0.2 + _random.nextDouble() * 0.6;
    return (maxBet * betPercent).round();
  }

  /// Medium bot: Basic probability-based betting
  int _decideMediumBet(double probability, int maxBet) {
    // Pass if probability is too low
    if (probability < 0.25) return 0;

    // Low probability - small bet
    if (probability < 0.40) {
      return (maxBet * 0.2).round();
    }

    // Medium probability - medium bet
    if (probability < 0.60) {
      return (maxBet * 0.4).round();
    }

    // High probability - large bet
    if (probability < 0.80) {
      return (maxBet * 0.6).round();
    }

    // Very high probability - max bet
    return maxBet;
  }

  /// Hard bot: Optimal Kelly Criterion-inspired betting
  int _decideHardBet(double probability, int maxBet, int pot) {
    // Calculate expected value
    final ev = calculateExpectedValue(probability, maxBet);

    // Only bet if EV is positive
    if (ev <= 0) return 0;

    // Post risk: hitting boundary loses double
    // Adjust probability for post risk
    final adjustedProbability = probability * 0.92; // ~8% post risk

    if (adjustedProbability < 0.30) return 0;

    // Kelly Criterion: f* = (bp - q) / b
    // where b = odds (1:1 for win), p = probability, q = 1-p
    // For in-between: b = 1 (win equals bet)
    // f* = 2p - 1 (simplified for 1:1 odds)
    // But we also have post risk (lose double), so be more conservative

    double kellyFraction = (2 * adjustedProbability - 1);

    // Use half-Kelly for safety
    kellyFraction = kellyFraction * 0.5;

    if (kellyFraction <= 0) return 0;

    // Cap at 80% of max to leave room for error
    kellyFraction = kellyFraction.clamp(0.0, 0.8);

    return (maxBet * kellyFraction).round();
  }

  /// Calculate probability of middle card being between low and high
  double calculateWinProbability({
    required Card lowCard,
    required Card highCard,
    required int cardsRemaining,
  }) {
    final lowValue = _cardValue(lowCard);
    final highValue = _cardValue(highCard);

    // Cards that would win (strictly between)
    final winningRanks = highValue - lowValue - 1;

    if (winningRanks <= 0) return 0.0;

    // Each rank has 4 cards (4 suits)
    // Approximate: winningRanks * 4 cards / remaining cards
    // This is simplified - doesn't account for cards already played
    final winningCards = winningRanks * 4;

    if (cardsRemaining <= 0) return 0.0;

    return (winningCards / cardsRemaining).clamp(0.0, 1.0);
  }

  /// Calculate post probability (hitting a boundary)
  double calculatePostProbability({
    required Card lowCard,
    required Card highCard,
    required int cardsRemaining,
  }) {
    // 2 boundary cards, 4 suits each = 8 cards could post
    // Minus the 2 already shown = 6 remaining
    if (cardsRemaining <= 0) return 0.0;
    return (6 / cardsRemaining).clamp(0.0, 1.0);
  }

  /// Calculate expected value of betting
  double calculateExpectedValue(double winProbability, int betAmount) {
    final postProbability = 0.08; // Approximate
    final loseProbability = 1 - winProbability - postProbability;

    // EV = P(win) * betAmount - P(lose) * betAmount - P(post) * 2 * betAmount
    final ev =
        winProbability * betAmount -
        loseProbability * betAmount -
        postProbability * 2 * betAmount;

    return ev;
  }

  /// Get card numeric value (Ace high = 14)
  int _cardValue(Card card) {
    switch (card.rank) {
      case Rank.ace:
        return 14;
      case Rank.king:
        return 13;
      case Rank.queen:
        return 12;
      case Rank.jack:
        return 11;
      default:
        return card.rank.points;
    }
  }

  /// Get description of current odds for display
  String getOddsDescription({
    required Card lowCard,
    required Card highCard,
    required int cardsRemaining,
  }) {
    final probability = calculateWinProbability(
      lowCard: lowCard,
      highCard: highCard,
      cardsRemaining: cardsRemaining,
    );

    final percent = (probability * 100).round();

    if (percent >= 80) return 'Excellent ($percent%)';
    if (percent >= 60) return 'Good ($percent%)';
    if (percent >= 40) return 'Fair ($percent%)';
    if (percent >= 20) return 'Risky ($percent%)';
    return 'Terrible ($percent%)';
  }
}
