import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';

class CardWidget extends StatelessWidget {
  final Card card;
  final bool isPlayable;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.isPlayable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: Container(
        width: 70,
        height: 100,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPlayable ? card.suit.color : Colors.grey,
            width: isPlayable ? 3 : 1,
          ),
          boxShadow: isPlayable
              ? [
                  BoxShadow(
                    color: card.suit.color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Верхний левый угол
            Positioned(
              left: 6,
              top: 6,
              child: Column(
                children: [
                  Text(
                    card.rank.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: card.suit.color,
                    ),
                  ),
                  Text(
                    card.suit.symbol,
                    style: TextStyle(
                      fontSize: 14,
                      color: card.suit.color,
                    ),
                  ),
                ],
              ),
            ),
            // Центр
            Center(
              child: Text(
                card.suit.symbol,
                style: TextStyle(
                  fontSize: 36,
                  color: card.suit.color,
                ),
              ),
            ),
            // Нижний правый угол (перевёрнутый)
            Positioned(
              right: 6,
              bottom: 6,
              child: Transform.rotate(
                angle: 3.14159,
                child: Column(
                  children: [
                    Text(
                      card.rank.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: card.suit.color,
                      ),
                    ),
                    Text(
                      card.suit.symbol,
                      style: TextStyle(
                        fontSize: 14,
                        color: card.suit.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}