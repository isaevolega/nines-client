import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int timer;
  final bool isMyTurn;
  final VoidCallback? onSkipTurn;

  const TimerWidget({
    super.key,
    required this.timer,
    required this.isMyTurn,
    this.onSkipTurn,
  });

  @override
  Widget build(BuildContext context) {
    final isLowTime = timer <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isLowTime ? Colors.red[100] : Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer,
                color: isLowTime ? Colors.red : Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                '$timer сек',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLowTime ? Colors.red : Colors.blue,
                ),
              ),
            ],
          ),
          if (isMyTurn && onSkipTurn != null)
            ElevatedButton.icon(
              onPressed: onSkipTurn,
              icon: const Icon(Icons.skip_next),
              label: const Text('Пропустить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}