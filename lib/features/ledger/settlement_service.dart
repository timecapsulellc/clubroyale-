import 'transaction_model.dart';

class SettlementService {
  List<Transaction> calculateDebts(
      Map<String, int> playerScores, double pointValue) {
    final transactions = <Transaction>[];
    final players = playerScores.keys.toList();
    final scores = playerScores.values.toList();

    final winners = <String>[];
    final losers = <String>[];

    for (var i = 0; i < players.length; i++) {
      if (scores[i] > 0) {
        winners.add(players[i]);
      } else if (scores[i] < 0) {
        losers.add(players[i]);
      }
    }

    for (final loser in losers) {
      var loserDebt = playerScores[loser]!.abs() * pointValue;
      for (final winner in winners) {
        if (loserDebt == 0) continue;

        final winnerCredit = playerScores[winner]! * pointValue;
        final payment = (loserDebt < winnerCredit) ? loserDebt : winnerCredit;

        transactions.add(Transaction(
          fromPlayer: loser,
          toPlayer: winner,
          amount: payment,
        ));

        playerScores[winner] = (winnerCredit - payment).toInt();
        loserDebt -= payment;
      }
    }

    return transactions;
  }
}
