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
        width: 80,
        height: 120,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPlayable ? Colors.green : Colors.grey,
            width: isPlayable ? 3 : 1,
          ),
          boxShadow: isPlayable
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.rank.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: card.suit.color,
              ),
            ),
            Text(
              card.suit.symbol,
              style: TextStyle(
                fontSize: 32,
                color: card.suit.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}