// lib/widgets/timer_widget.dart

import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int timer;
  final bool isMyTurn;
  final bool hasValidMoves;  // 🔥 Новый параметр
  final VoidCallback? onSkipTurn;

  const TimerWidget({
    super.key,
    required this.timer,
    required this.isMyTurn,
    required this.hasValidMoves,  // ← Обязательный параметр
    this.onSkipTurn,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 Разные цвета для разных ситуаций
    final isLowTime = timer <= 5;
    final isSkipTimer = !hasValidMoves;  // 10-секундный таймер пропуска
    
    Color bgColor;
    Color textColor;
    
    if (isSkipTimer) {
      bgColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
    } else if (isLowTime) {
      bgColor = Colors.red[100]!;
      textColor = Colors.red[800]!;
    } else {
      bgColor = Colors.blue[50]!;
      textColor = Colors.blue[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isSkipTimer ? Icons.hourglass_empty : Icons.timer,
                color: textColor,
              ),
              const SizedBox(width: 8),
              Text(
                '$timer сек',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (isSkipTimer) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'НЕТ ХОДОВ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          // 🔥 Кнопка показывается ТОЛЬКО если нет валидных ходов
          if (isMyTurn && !hasValidMoves && onSkipTurn != null)
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