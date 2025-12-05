import 'package:flutter_riverpod/flutter_riverpod.dart';


class SettlementTransaction {
  final String fromPlayerId;
  final String toPlayerId;
  final int amount;

  const SettlementTransaction({
    required this.fromPlayerId,
    required this.toPlayerId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromPlayerId': fromPlayerId,
      'toPlayerId': toPlayerId,
      'amount': amount,
    };
  }

  factory SettlementTransaction.fromJson(Map<String, dynamic> json) {
    return SettlementTransaction(
      fromPlayerId: json['fromPlayerId'] as String,
      toPlayerId: json['toPlayerId'] as String,
      amount: json['amount'] as int,
    );
  }
}

final settlementServiceProvider = Provider((ref) => SettlementService());

class SettlementService {
  /// Calculates the minimum number of transactions to settle debts based on scores.
  /// 
  /// [scores]: Map of playerId -> score
  /// [pointValue]: Value of 1 point in currency (default 1)
  /// 
  /// Returns a list of transactions (Who pays Whom and How much).
  List<SettlementTransaction> calculateSettlements(
    Map<String, int> scores, {
    int pointValue = 1,
  }) {
    // 1. Calculate net balances
    // In Call Break, scores can be positive or negative.
    // We need to normalize them so sum is 0 for settlement?
    // Actually, Call Break is usually zero-sum if played with fixed stakes, 
    // but raw scores aren't necessarily zero-sum.
    // 
    // Standard approach: 
    // Calculate average score. 
    // Balance = (Score - Average) * PointValue.
    // 
    // However, if we just want to settle based on raw points:
    // Let's assume we are settling the *difference* from the average, 
    // or if it's a "winner takes all" or "pay per point difference".
    //
    // Common Call Break betting:
    // Everyone pays the winner? Or pay based on difference?
    // 
    // Let's implement the "Pay based on difference from average" model which is fair.
    // If sum of scores is not 0, we center them around the average.
    
    if (scores.isEmpty) return [];

    double totalScore = scores.values.fold(0, (sum, score) => sum + score);
    double averageScore = totalScore / scores.length;

    // Calculate net amount for each player
    // Rounding to nearest integer for simplicity in currency
    Map<String, int> netBalances = {};
    
    scores.forEach((playerId, score) {
      int balance = ((score - averageScore) * pointValue).round();
      netBalances[playerId] = balance;
    });

    // Fix rounding errors to ensure sum is exactly 0
    int balanceSum = netBalances.values.fold(0, (sum, bal) => sum + bal);
    if (balanceSum != 0) {
      // Adjust the first player's balance to make sum 0
      // This is a minor adjustment (usually +/- 1 or 2)
      String firstPlayer = netBalances.keys.first;
      netBalances[firstPlayer] = netBalances[firstPlayer]! - balanceSum;
    }

    // 2. Separate into debtors and creditors
    List<MapEntry<String, int>> debtors = [];
    List<MapEntry<String, int>> creditors = [];

    netBalances.forEach((playerId, amount) {
      if (amount < 0) {
        debtors.add(MapEntry(playerId, amount));
      } else if (amount > 0) {
        creditors.add(MapEntry(playerId, amount));
      }
    });

    // 3. Greedy settlement algorithm
    List<SettlementTransaction> transactions = [];
    
    int i = 0; // debtor index
    int j = 0; // creditor index

    while (i < debtors.length && j < creditors.length) {
      String debtorId = debtors[i].key;
      int debtorAmount = debtors[i].value; // Negative

      String creditorId = creditors[j].key;
      int creditorAmount = creditors[j].value; // Positive

      // The amount to settle is the minimum of absolute debt and credit
      int amount = (-debtorAmount < creditorAmount) ? -debtorAmount : creditorAmount;

      transactions.add(SettlementTransaction(
        fromPlayerId: debtorId,
        toPlayerId: creditorId,
        amount: amount,
      ));

      // Update balances
      debtors[i] = MapEntry(debtorId, debtorAmount + amount);
      creditors[j] = MapEntry(creditorId, creditorAmount - amount);

      // Move indices if settled
      if (debtors[i].value == 0) i++;
      if (creditors[j].value == 0) j++;
    }

    return transactions;
  }
}
