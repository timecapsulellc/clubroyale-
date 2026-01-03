// Settlement Bill Splitter
//
// Generates shareable receipt image at end of game.
// Uses "Points" terminology per Safe Harbor guidelines.

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Settlement transaction
class SettlementTransaction {
  final String from;
  final String to;
  final int points; // NOT "amount" or "money"

  SettlementTransaction({
    required this.from,
    required this.to,
    required this.points,
  });

  @override
  String toString() => '$from → $to: $points points';
}

/// Settlement bill data
class SettlementBill {
  final String roomCode;
  final String gameType;
  final DateTime timestamp;
  final List<SettlementTransaction> transactions;
  final Map<String, int> finalScores;

  SettlementBill({
    required this.roomCode,
    required this.gameType,
    required this.timestamp,
    required this.transactions,
    required this.finalScores,
  });
}

/// Bill splitter service
class BillSplitterService {
  /// Calculate settlement transactions (minimize payments)
  static List<SettlementTransaction> calculateSettlement(
    Map<String, int> scores,
    double pointMultiplier,
  ) {
    final transactions = <SettlementTransaction>[];

    // Separate winners and losers
    final balances = <String, double>{};
    for (final entry in scores.entries) {
      balances[entry.key] = entry.value * pointMultiplier;
    }

    final creditors = balances.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final debtors =
        balances.entries
            .where((e) => e.value < 0)
            .map((e) => MapEntry(e.key, -e.value))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Match debtors to creditors
    var i = 0;
    var j = 0;
    final creditorBalances = {for (var c in creditors) c.key: c.value};
    final debtorBalances = {for (var d in debtors) d.key: d.value};

    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i].key;
      final debtor = debtors[j].key;

      final creditorNeed = creditorBalances[creditor]!;
      final debtorOwes = debtorBalances[debtor]!;

      final payment = creditorNeed < debtorOwes ? creditorNeed : debtorOwes;

      if (payment > 0) {
        transactions.add(
          SettlementTransaction(
            from: debtor,
            to: creditor,
            points: payment.round(),
          ),
        );
      }

      creditorBalances[creditor] = creditorNeed - payment;
      debtorBalances[debtor] = debtorOwes - payment;

      if (creditorBalances[creditor]! <= 0.01) i++;
      if (debtorBalances[debtor]! <= 0.01) j++;
    }

    return transactions;
  }

  /// Generate WhatsApp-friendly text
  static String generateWhatsAppText(SettlementBill bill) {
    final buffer = StringBuffer();

    buffer.writeln('🎴 ClubRoyale Settlement');
    buffer.writeln('Room: ${bill.roomCode}');
    buffer.writeln('Game: ${bill.gameType}');
    buffer.writeln('');
    buffer.writeln('📊 Results:');

    for (final tx in bill.transactions) {
      buffer.writeln('• ${tx.from} → ${tx.to}: ${tx.points} points');
    }

    if (bill.transactions.isEmpty) {
      buffer.writeln('• No settlements needed (tie)');
    }

    buffer.writeln('');
    buffer.writeln('Settle via your preferred app');
    buffer.writeln('---');
    buffer.writeln('Powered by ClubRoyale');

    return buffer.toString();
  }

  /// Share to WhatsApp
  static Future<void> shareToWhatsApp(SettlementBill bill) async {
    final text = generateWhatsAppText(bill);
    await Share.share(text);
  }
}

/// Settlement receipt widget (for screenshot)
class SettlementReceiptWidget extends StatelessWidget {
  final SettlementBill bill;
  final GlobalKey repaintKey = GlobalKey();

  SettlementReceiptWidget({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Icon(Icons.receipt_long, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 8),
            const Text(
              '🎴 ClubRoyale',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Settlement Receipt',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Room info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Room: ${bill.roomCode} • ${bill.gameType}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            // Transactions
            ...bill.transactions.map(
              (tx) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tx.from,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 16),
                    Expanded(
                      child: Text(
                        tx.to,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${tx.points} pts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (bill.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No settlements needed',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            const SizedBox(height: 16),
            const Divider(),

            // Footer
            Text(
              'Generated ${_formatDate(bill.timestamp)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Capture widget as image
  Future<Uint8List?> captureAsImage() async {
    try {
      final boundary =
          repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Save and share image
  Future<void> shareAsImage() async {
    final bytes = await captureAsImage();
    if (bytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/settlement_${bill.roomCode}.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'ClubRoyale Settlement - Room ${bill.roomCode}');
  }
}
