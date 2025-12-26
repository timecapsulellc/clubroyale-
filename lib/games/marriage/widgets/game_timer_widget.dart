import 'package:flutter/material.dart';

class GameTimerWidget extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  
  const GameTimerWidget({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = remainingSeconds / totalSeconds;
    
    Color color = Colors.green;
    if (progress < 0.5) color = Colors.orange;
    if (progress < 0.2) color = Colors.red;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 4,
          ),
          Text(
            '$remainingSeconds',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
