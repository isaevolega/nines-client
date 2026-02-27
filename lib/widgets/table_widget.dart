import 'dart:ffi';

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
            angle: 1.57,
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

    // Определяем крайние карты (которые видны полностью)
    final topEdgeCard = higherCards.isNotEmpty ? higherCards.last : nineCard;
    final bottomEdgeCard = lowerCards.isNotEmpty ? lowerCards.last : nineCard;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 200, // Фиксированная высота стопки
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🔥 НИЖНИЕ карты (6, 7, 8) — растут вниз от центра
          ..._buildLowerCardsStack(lowerCards, suit, bottomEdgeCard),
          
          // 🔥 ЦЕНТР (9) — если есть
          if (nineCard != null)
            _buildCardWidget(
              nineCard,
              suit,
              isEdge: nineCard == topEdgeCard || nineCard == bottomEdgeCard,
              offsetY: 0,
            ),
          
          // 🔥 ВЕРХНИЕ карты (10, J, Q, K, A) — растут вверх от центра
          ..._buildHigherCardsStack(higherCards, suit, topEdgeCard),
        ],
      ),
    );
  }

  // Строим нижние карты через Stack
  List<Widget> _buildLowerCardsStack(List<String> cards, Suit suit, String? edgeCard) {
    if (cards.isEmpty) return [];
    
    return cards.asMap().entries.map((entry) {
      final index = entry.key;
      final rank = entry.value;
      final isEdge = rank == edgeCard;
      
      // Смещение вниз: каждая следующая карта ниже предыдущей
      final offsetY = 18 + (index * 14.0); // 14px — плотное наложение
      
      return _buildCardWidget(rank, suit, isEdge: isEdge, offsetY: offsetY);
    }).toList();
  }

  // Строим верхние карты через Stack
  List<Widget> _buildHigherCardsStack(List<String> cards, Suit suit, String? edgeCard) {
    if (cards.isEmpty) return [];
    
    return cards.asMap().entries.map((entry) {
      final index = entry.key;
      final rank = entry.value;
      final isEdge = rank == edgeCard;
      
      // Смещение вверх: каждая следующая карта выше предыдущей
      final offsetY = -(18 + (index * 14.0)); // Отрицательный Y — вверх
      
      return _buildCardWidget(rank, suit, isEdge: isEdge, offsetY: offsetY);
    }).toList();
  }

  // Виджет одной карты
  Widget _buildCardWidget(String rank, Suit suit, {required bool isEdge, required double offsetY}) {
    final card = Card(suit: suit, rank: _parseRank(rank));
    
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Transform.rotate(
        angle: -1.57,
        child: Container(
          width: 40,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isEdge ? suit.color : suit.color.withOpacity(0.2),
              width: isEdge ? 2 : 1,
            ),
            boxShadow: isEdge
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Opacity(
              opacity: isEdge ? 1.0 : 0.3, // 🔥 Средние карты полупрозрачные (30%)
              child: Image.asset(
                card.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        rank,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isEdge ? FontWeight.bold : FontWeight.normal,
                          color: suit.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

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