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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: Suit.values.map((suit) {
                  final cards = centerPiles[suit] ?? [];
                  return Expanded(
                    child: PileWidget(
                      suit: suit,
                      cards: cards,
                      isMyTurn: isMyTurn,
                    ),
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
    if (cards.isEmpty) {
      // Пустая стопка
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.5),
        ),
        child: Center(
          child: Transform.rotate(
            angle: 1.57, // 90 градусов
            child: Text(
              suit.symbol,
              style: TextStyle(
                fontSize: 40,
                color: suit.color.withOpacity(0.3),
              ),
            ),
          ),
        ),
      );
    }

    // Разделяем карты на нижние (меньше 9) и верхние (больше 9)
    final lowerCards = <String>[];  // 8, 7, 6 (идут вниз от 9)
    final higherCards = <String>[]; // 10, J, Q, K, A (идут вверх от 9)
    String? nineCard;

    for (final card in cards) {
      if (card == '9') {
        nineCard = card;
      } else if (_getCardValue(card) < 3) {  // 6=0, 7=1, 8=2
        lowerCards.add(card);
      } else {  // 10=4, J=5, Q=6, K=7, A=8
        higherCards.add(card);
      }
    }

    // Сортируем: нижние по убыванию (8, 7, 6), верхние по возрастанию (10, J, Q, K, A)
    lowerCards.sort((a, b) => _getCardValue(b).compareTo(_getCardValue(a)));
    higherCards.sort((a, b) => _getCardValue(a).compareTo(_getCardValue(b)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: suit.color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ВЕРХНИЕ карты (10, J, Q, K, A) — растут вверх
          ...higherCards.reversed.map((rank) => _buildMiniCard(rank, suit)),
          
          // ЦЕНТР (9)
          if (nineCard != null) _buildMiniCard(nineCard, suit, isCenter: true),
          
          // НИЖНИЕ карты (8, 7, 6) — растут вниз
          ...lowerCards.map((rank) => _buildMiniCard(rank, suit)),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String rank, Suit suit, {bool isCenter = false}) {
    // Создаём объект Card для получения пути к изображению
    final card = Card(
      suit: suit,
      rank: _parseRank(rank),
    );
    
    return Transform.rotate(
      angle: -1.57, // 90 градусов по часовой стрелке
      child: Container(
        width: 40,
        height: 56,
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCenter ? Colors.green : suit.color,
            width: isCenter ? 3 : 1,
          ),
          boxShadow: isCenter
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            card.assetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Фоллбэк на текст если изображения нет
              return Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    rank,
                    style: TextStyle(
                      fontSize: isCenter ? 18 : 14,
                      fontWeight: isCenter ? FontWeight.bold : FontWeight.normal,
                      color: suit.color,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Хелпер для парсинга ранга из строки
  Rank _parseRank(String rank) {
    switch (rank) {
      case '6': return Rank.r6;
      case '7': return Rank.r7;
      case '8': return Rank.r8;
      case '9': return Rank.r9;
      case '10': return Rank.r10;
      case 'J': return Rank.J;
      case 'Q': return Rank.Q;
      case 'K': return Rank.K;
      case 'A': return Rank.A;
      default: return Rank.r6;
    }
  }

  int _getCardValue(String rank) {
    switch (rank) {
      case '6': return 0;
      case '7': return 1;
      case '8': return 2;
      case '9': return 3;
      case '10': return 4;
      case 'J': return 5;
      case 'Q': return 6;
      case 'K': return 7;
      case 'A': return 8;
      default: return 0;
    }
  }
}