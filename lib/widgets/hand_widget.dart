import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';
import 'card_widget.dart';

class HandWidget extends StatelessWidget {
  final List<Card> hand;
  final bool isMyTurn;
  final Function(Card)? onCardTap;

  const HandWidget({
    super.key,
    required this.hand,
    required this.isMyTurn,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      color: Colors.green[800],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ваши карты (${hand.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isMyTurn)
                  const Text(
                    'Ждите хода...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          Expanded(
            child: hand.isEmpty
                ? const Center(
                    child: Text(
                      'Нет карт',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hand.length,
                    itemBuilder: (context, index) {
                      final card = hand[index];
                      return CardWidget(
                        card: card,
                        isPlayable: isMyTurn,
                        onTap: isMyTurn ? () => onCardTap?.call(card) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}