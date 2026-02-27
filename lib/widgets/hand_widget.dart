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
      // 🔥 Убрали margin справа — группы идут вплотную
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.only(right: 0), // Небольшой отступ между группами
      child: SizedBox(
        height: 110,
        width: 40 + (cards.length - 1) * 28, // 🔥 Расчёт ширины с наложением
        child: Stack(
          children: cards.asMap().entries.map((entry) {
            final index = entry.key;
            final card = entry.value;
            return Positioned(
              left: index * 28, // 🔥 Сдвиг на 28px (карта 56px, наложение ~50%)
              top: 0,
              child: CardWidget(
                card: card,
                isPlayable: isMyTurn,
                onTap: isMyTurn ? () => onCardTap?.call(card) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}