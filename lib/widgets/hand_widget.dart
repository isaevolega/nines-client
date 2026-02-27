// lib/widgets/hand_widget.dart

import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';
import 'card_widget.dart';

class HandWidget extends StatelessWidget {
  final List<Card> hand;
  final bool isMyTurn;
  final List<Card> validMoves;
  final Function(Card)? onCardTap;

  const HandWidget({
    super.key,
    required this.hand,
    required this.isMyTurn,
    required this.validMoves,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // Группируем карты по мастям
    final groupedHand = <Suit, List<Card>>{};
    for (final card in hand) {
      if (!groupedHand.containsKey(card.suit)) {
        groupedHand[card.suit] = [];
      }
      groupedHand[card.suit]!.add(card);
    }

    // Сортируем карты внутри каждой масти по рангу
    for (final suit in groupedHand.keys) {
      groupedHand[suit]!.sort((a, b) => a.rank.value.compareTo(b.rank.value));
    }

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
                    itemCount: groupedHand.length,
                    itemBuilder: (context, suitIndex) {
                      final suit = groupedHand.keys.elementAt(suitIndex);
                      final cards = groupedHand[suit]!;
                      
                      return _buildSuitGroup(suit, cards);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuitGroup(Suit suit, List<Card> cards) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.only(right: 8), // Отступ между группами
      child: SizedBox(
        // 🔥 ИСПРАВЛЕНО: правильный расчёт ширины
        // Первая карта: 56px (полная ширина)
        // Каждая следующая: +28px (с учётом наложения 50%)
        width: 56 + (cards.length - 1) * 28,
        height: 110,
        child: Stack(
          clipBehavior: Clip.none, // 🔥 Важно: не обрезать содержимое
          children: cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            
            // Проверяем, является ли карта валидной
            final isValid = validMoves.contains(card);
            
            return Positioned(
              left: index * 28.0, // Сдвиг на 28px
              top: 0,
              child: CardWidget(
                card: card,
                isPlayable: isMyTurn && isValid,
                onTap: (isMyTurn && isValid) ? () => onCardTap?.call(card) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}