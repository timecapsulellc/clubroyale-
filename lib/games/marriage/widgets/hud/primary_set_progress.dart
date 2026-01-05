import 'package:flutter/material.dart';

class PrimarySetProgress extends StatelessWidget {
  final int count;
  final int requiredCount;

  const PrimarySetProgress({
    super.key,
    required this.count,
    this.requiredCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRIMARY SETS',
                style: TextStyle(
                  color: Colors.white.withAlpha(180), // 0.7 * 255
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '$count/$requiredCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(requiredCount, (index) {
              final isCompleted = index < count;
              return Container(
                width: 50, // Fixed width for 3 items in ~170px space
                height: 6,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.greenAccent : Colors.white12,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: Colors.greenAccent.withAlpha(100), // ~0.4 * 255
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
