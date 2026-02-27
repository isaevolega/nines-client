// lib/utils/move_validator.dart

import '../models/card.dart';
import '../models/room_state.dart';

class MoveValidator {
  // Проверка, можно ли походить данной картой
  static bool isValidMove(Card card, Map<Suit, List<String>> centerPiles) {
    final pile = centerPiles[card.suit] ?? [];
    
    // 🔥 1. Если стопка пустая — можно только 9
    if (pile.isEmpty) {
      return card.rank == Rank.r9;
    }
    
    // 🔥 2. Если стопка не пустая — 9 класть нельзя
    if (card.rank == Rank.r9) {
      return false;
    }
    
    // 🔥 3. СОРТИРУЕМ стопку по рангу (как на сервере!)
    final sortedPile = List<String>.from(pile);
    sortedPile.sort((a, b) {
      return _getRankValue(a).compareTo(_getRankValue(b));
    });
    
    // 🔥 4. Берём нижнюю и верхнюю карты из ОТСОРТИРОВАННОЙ стопки
    final bottomValue = _getRankValue(sortedPile.first);   // Самая младшая (6, 7, 8...)
    final topValue = _getRankValue(sortedPile.last);       // Самая старшая (...10, J, Q, K, A)
    final cardValue = card.rank.value;
    
    print('[VALIDATOR] Стопка: $pile → отсортировано: $sortedPile');
    print('[VALIDATOR] Bottom: $bottomValue, Top: $topValue, Карта: $cardValue');
    
    // 🔥 5. Можно положить на 1 выше верхней ИЛИ на 1 ниже нижней
    final canPlaceOnTop = cardValue == topValue + 1;
    final canPlaceOnBottom = cardValue == bottomValue - 1;
    
    print('[VALIDATOR] canPlaceOnTop: $canPlaceOnTop, canPlaceOnBottom: $canPlaceOnBottom');
    
    return canPlaceOnTop || canPlaceOnBottom;
  }
  
  // Получить все валидные карты из руки
  static List<Card> getValidMoves(List<Card> hand, Map<Suit, List<String>> centerPiles) {
    return hand.where((card) => isValidMove(card, centerPiles)).toList();
  }
  
  static int _getRankValue(String rank) {
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