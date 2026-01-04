import 'package:flutter_test/flutter_test.dart';
import 'package:clubroyale/features/ledger/services/settlement_service.dart';

void main() {
  late SettlementService settlementService;

  setUp(() {
    settlementService = SettlementService();
  });

  group('SettlementService', () {
    test('should return empty list for empty scores', () {
      final transactions = settlementService.calculateSettlements({});
      expect(transactions, isEmpty);
    });

    test('should settle simple 2-player debt', () {
      // A: 10, B: -10
      // Average: 0
      // A is +10, B is -10
      // B pays A 10
      final scores = {'A': 10, 'B': -10};
      final transactions = settlementService.calculateSettlements(scores);

      expect(transactions.length, 1);
      expect(transactions.first.fromPlayerId, 'B');
      expect(transactions.first.toPlayerId, 'A');
      expect(transactions.first.amount, 10);
    });

    test('should settle 3-player circular debt scenario', () {
      // A: 20, B: -10, C: -10
      // Average: 0
      // A: +20, B: -10, C: -10
      // B pays A 10, C pays A 10
      final scores = {'A': 20, 'B': -10, 'C': -10};
      final transactions = settlementService.calculateSettlements(scores);

      expect(transactions.length, 2);

      // Verify total amount received by A is 20
      final totalReceivedByA = transactions
          .where((t) => t.toPlayerId == 'A')
          .fold(0, (sum, t) => sum + t.amount);
      expect(totalReceivedByA, 20);

      // Verify B and C pay 10 each
      expect(
        transactions.any((t) => t.fromPlayerId == 'B' && t.amount == 10),
        isTrue,
      );
      expect(
        transactions.any((t) => t.fromPlayerId == 'C' && t.amount == 10),
        isTrue,
      );
    });

    test('should handle non-zero sum scores by centering around average', () {
      // A: 100, B: 80
      // Average: 90
      // A: +10, B: -10
      // B pays A 10
      final scores = {'A': 100, 'B': 80};
      final transactions = settlementService.calculateSettlements(scores);

      expect(transactions.length, 1);
      expect(transactions.first.fromPlayerId, 'B');
      expect(transactions.first.toPlayerId, 'A');
      expect(transactions.first.amount, 10);
    });

    test('should handle complex 4-player scenario', () {
      // A: 50, B: 20, C: -30, D: -40
      // Sum: 0, Avg: 0
      // Creditors: A(50), B(20)
      // Debtors: C(-30), D(-40)

      // Greedy approach might do:
      // D(-40) pays A(50) -> D pays 40 to A. A remains +10. D settled.
      // C(-30) pays A(10) -> C pays 10 to A. A settled. C remains -20.
      // C(-20) pays B(20) -> C pays 20 to B. Both settled.

      final scores = {'A': 50, 'B': 20, 'C': -30, 'D': -40};
      final transactions = settlementService.calculateSettlements(scores);

      // Verify all debts are settled
      final netFlow = <String, int>{};
      for (var t in transactions) {
        netFlow[t.fromPlayerId] = (netFlow[t.fromPlayerId] ?? 0) - t.amount;
        netFlow[t.toPlayerId] = (netFlow[t.toPlayerId] ?? 0) + t.amount;
      }

      expect(netFlow['A'], 50);
      expect(netFlow['B'], 20);
      expect(netFlow['C'], -30);
      expect(netFlow['D'], -40);
    });
  });
}
