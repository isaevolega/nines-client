import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';

class TableWidget extends StatelessWidget {
  final Map<Suit, List<String>> centerPiles;
  final bool isMyTurn;
  final Function(Card)? onCardPlay;

  const TableWidget({
    super.key,
    required this.centerPiles,
    required this.isMyTurn,
    this.onCardPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[50],
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Стол',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: Suit.values.map((suit) {
                  final cards = centerPiles[suit] ?? [];
                  return PileWidget(
                    suit: suit,
                    cards: cards,
                    isMyTurn: isMyTurn,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PileWidget extends StatelessWidget {
  final Suit suit;
  final List<String> cards;
  final bool isMyTurn;

  const PileWidget({
    super.key,
    required this.suit,
    required this.cards,
    required this.isMyTurn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Название масти
        Text(
          _getSuitName(suit),
          style: TextStyle(
            fontSize: 12,
            color: suit.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Стопка карт
        Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: cards.isEmpty
              ? Center(
                  child: Text(
                    suit.symbol,
                    style: TextStyle(
                      fontSize: 32,
                      color: suit.color.withOpacity(0.5),
                    ),
                  ),
                )
              : Stack(
                  children: cards.take(3).toList().reversed.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final rank = entry.value;
                    return Positioned(
                      left: index * 2,
                      top: index * 2,
                      child: _buildCardPreview(rank, suit),
                    );
                  }).toList(),
                ),
        ),
        
        // Количество карт в стопке
        if (cards.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${cards.length - 3}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildCardPreview(String rank, Suit suit) {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Center(
        child: Text(
          rank,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: suit.color,
          ),
        ),
      ),
    );
  }

  String _getSuitName(Suit suit) {
    switch (suit) {
      case Suit.diamonds: return 'Буби';
      case Suit.hearts: return 'Черви';
      case Suit.spades: return 'Пики';
      case Suit.clubs: return 'Трефы';
    }
  }
}