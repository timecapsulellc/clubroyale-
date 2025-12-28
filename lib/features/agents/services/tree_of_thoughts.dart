/// Tree of Thoughts (ToT) Reasoning System
/// 
/// Implements structured reasoning for bot decision-making:
/// - Generate multiple thought branches
/// - Evaluate each path's outcome
/// - Select best action based on reasoning
library;

import 'dart:math';

/// A single thought in the reasoning tree
class Thought {
  final String description;
  final double confidence;
  final String action;
  final Map<String, dynamic> evidence;
  
  const Thought({
    required this.description,
    required this.confidence,
    required this.action,
    this.evidence = const {},
  });
  
  @override
  String toString() => 'Thought($action: $description [${(confidence * 100).toStringAsFixed(0)}%])';
}

/// A branch in the thought tree
class ThoughtBranch {
  final String hypothesis;
  final List<Thought> thoughts;
  final double score;
  final String recommendedAction;
  
  const ThoughtBranch({
    required this.hypothesis,
    required this.thoughts,
    required this.score,
    required this.recommendedAction,
  });
  
  factory ThoughtBranch.evaluate({
    required String hypothesis,
    required List<Thought> thoughts,
    required String recommendedAction,
  }) {
    if (thoughts.isEmpty) {
      return ThoughtBranch(
        hypothesis: hypothesis,
        thoughts: thoughts,
        score: 0.0,
        recommendedAction: recommendedAction,
      );
    }
    
    // Score is weighted average of thought confidences
    final totalConfidence = thoughts.fold<double>(0, (sum, t) => sum + t.confidence);
    final score = totalConfidence / thoughts.length;
    
    return ThoughtBranch(
      hypothesis: hypothesis,
      thoughts: thoughts,
      score: score,
      recommendedAction: recommendedAction,
    );
  }
}

/// Tree of Thoughts decision result
class ToTDecision {
  final String selectedAction;
  final List<ThoughtBranch> branches;
  final String reasoning;
  final double confidence;
  final Duration thinkingTime;
  
  const ToTDecision({
    required this.selectedAction,
    required this.branches,
    required this.reasoning,
    required this.confidence,
    required this.thinkingTime,
  });
  
  /// Get the winning branch
  ThoughtBranch? get winningBranch {
    if (branches.isEmpty) return null;
    return branches.reduce((a, b) => a.score > b.score ? a : b);
  }
}

/// Tree of Thoughts Reasoning Engine
class TreeOfThoughtsEngine {
  final Random _random = Random();
  
  /// Make a decision using Tree of Thoughts reasoning
  ToTDecision decide({
    required String gameType,
    required Map<String, dynamic> context,
    required List<String> possibleActions,
    int numBranches = 3,
    int maxDepth = 2,
  }) {
    final startTime = DateTime.now();
    final branches = <ThoughtBranch>[];
    
    // Generate thought branches for each major strategy
    for (int i = 0; i < numBranches && i < possibleActions.length; i++) {
      final action = possibleActions[i];
      final branch = _generateBranch(
        gameType: gameType,
        context: context,
        targetAction: action,
        depth: maxDepth,
      );
      branches.add(branch);
    }
    
    // Sort by score and select best
    branches.sort((a, b) => b.score.compareTo(a.score));
    final selected = branches.isNotEmpty ? branches.first : null;
    
    final thinkingTime = DateTime.now().difference(startTime);
    
    return ToTDecision(
      selectedAction: selected?.recommendedAction ?? possibleActions.first,
      branches: branches,
      reasoning: _generateReasoning(selected),
      confidence: selected?.score ?? 0.5,
      thinkingTime: thinkingTime,
    );
  }
  
  /// Generate a thought branch for an action
  ThoughtBranch _generateBranch({
    required String gameType,
    required Map<String, dynamic> context,
    required String targetAction,
    required int depth,
  }) {
    final thoughts = <Thought>[];
    
    switch (gameType) {
      case 'call_break':
        thoughts.addAll(_callBreakThoughts(context, targetAction));
        break;
      case 'marriage':
        thoughts.addAll(_marriageThoughts(context, targetAction));
        break;
      case 'teen_patti':
        thoughts.addAll(_teenPattiThoughts(context, targetAction));
        break;
      case 'in_between':
        thoughts.addAll(_inBetweenThoughts(context, targetAction));
        break;
    }
    
    return ThoughtBranch.evaluate(
      hypothesis: 'If I $targetAction, what happens?',
      thoughts: thoughts,
      recommendedAction: targetAction,
    );
  }
  
  /// Generate thoughts for Call Break
  List<Thought> _callBreakThoughts(Map<String, dynamic> context, String action) {
    final thoughts = <Thought>[];
    final cardsPlayed = context['cardsPlayed'] as int? ?? 0;
    final tricksWon = context['tricksWon'] as int? ?? 0;
    final bid = context['bid'] as int? ?? 0;
    
    if (action.contains('spades')) {
      thoughts.add(Thought(
        description: 'Playing trump could win this trick',
        confidence: 0.8,
        action: action,
        evidence: {'isTrump': true},
      ));
      
      if (tricksWon < bid) {
        thoughts.add(Thought(
          description: 'Need more tricks to make bid',
          confidence: 0.7,
          action: action,
          evidence: {'tricksNeeded': bid - tricksWon},
        ));
      }
    }
    
    // Low card strategy
    if (action.contains('2') || action.contains('3')) {
      thoughts.add(Thought(
        description: 'Playing low to dump losing card',
        confidence: 0.6,
        action: action,
      ));
    }
    
    // High card for winning
    if (action.contains('ace') || action.contains('king')) {
      thoughts.add(Thought(
        description: 'High card likely to win trick',
        confidence: 0.85,
        action: action,
      ));
    }
    
    return thoughts;
  }
  
  /// Generate thoughts for Marriage
  List<Thought> _marriageThoughts(Map<String, dynamic> context, String action) {
    final thoughts = <Thought>[];
    final handSize = context['handSize'] as int? ?? 13;
    final hasVisited = context['hasVisited'] as bool? ?? false;
    
    if (action == 'drawDeck') {
      thoughts.add(Thought(
        description: 'Drawing from deck gives unknown card',
        confidence: 0.5,
        action: action,
      ));
    }
    
    if (action == 'drawDiscard') {
      thoughts.add(Thought(
        description: 'Discard pile card is known - can help meld',
        confidence: 0.7,
        action: action,
      ));
    }
    
    if (action == 'visit' && !hasVisited) {
      thoughts.add(Thought(
        description: 'Visiting unlocks meld points',
        confidence: 0.8,
        action: action,
      ));
    }
    
    if (action == 'declare') {
      thoughts.add(Thought(
        description: 'Declaring ends round - check if optimal',
        confidence: handSize <= 1 ? 0.9 : 0.3,
        action: action,
      ));
    }
    
    return thoughts;
  }
  
  /// Generate thoughts for Teen Patti
  List<Thought> _teenPattiThoughts(Map<String, dynamic> context, String action) {
    final thoughts = <Thought>[];
    final handStrength = context['handStrength'] as double? ?? 0.5;
    final potSize = context['pot'] as int? ?? 100;
    final playersRemaining = context['playersRemaining'] as int? ?? 2;
    
    if (action == 'bet' || action == 'raise') {
      if (handStrength > 0.7) {
        thoughts.add(Thought(
          description: 'Strong hand - betting for value',
          confidence: 0.85,
          action: action,
        ));
      } else if (playersRemaining <= 2) {
        thoughts.add(Thought(
          description: 'Heads up - can pressure opponent',
          confidence: 0.6,
          action: action,
        ));
      }
    }
    
    if (action == 'fold') {
      thoughts.add(Thought(
        description: 'Weak hand - minimize losses',
        confidence: handStrength < 0.3 ? 0.8 : 0.4,
        action: action,
      ));
    }
    
    if (action == 'see') {
      thoughts.add(Thought(
        description: 'Seeing cards gives information advantage',
        confidence: 0.6,
        action: action,
      ));
    }
    
    return thoughts;
  }
  
  /// Generate thoughts for In-Between
  List<Thought> _inBetweenThoughts(Map<String, dynamic> context, String action) {
    final thoughts = <Thought>[];
    final spread = context['spread'] as int? ?? 0;
    final winProbability = context['winProbability'] as double? ?? 0;
    
    if (action == 'bet') {
      if (spread >= 8) {
        thoughts.add(Thought(
          description: 'Wide spread - good bet opportunity',
          confidence: 0.8,
          action: action,
          evidence: {'spread': spread},
        ));
      } else if (spread <= 3) {
        thoughts.add(Thought(
          description: 'Narrow spread - risky bet',
          confidence: 0.3,
          action: action,
        ));
      }
    }
    
    if (action == 'pass') {
      thoughts.add(Thought(
        description: 'Passing preserves chips for better opportunity',
        confidence: winProbability < 0.3 ? 0.8 : 0.4,
        action: action,
      ));
    }
    
    return thoughts;
  }
  
  /// Generate human-readable reasoning
  String _generateReasoning(ThoughtBranch? branch) {
    if (branch == null) return 'No clear reasoning available.';
    
    final thoughts = branch.thoughts;
    if (thoughts.isEmpty) return 'Acting on instinct.';
    
    final topThought = thoughts.reduce((a, b) => a.confidence > b.confidence ? a : b);
    return topThought.description;
  }
}

/// Singleton instance
final treeOfThoughtsEngine = TreeOfThoughtsEngine();
