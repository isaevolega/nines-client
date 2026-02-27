import 'dart:ui';

enum Suit { diamonds, hearts, spades, clubs }
enum Rank { r6, r7, r8, r9, r10, J, Q, K, A }

extension SuitExtension on Suit {
  String get name {
    switch (this) {
      case Suit.diamonds: return 'diamonds';
      case Suit.hearts: return 'hearts';
      case Suit.spades: return 'spades';
      case Suit.clubs: return 'clubs';
    }
  }
  
  String get symbol {
    switch (this) {
      case Suit.diamonds: return '♦';
      case Suit.hearts: return '♥';
      case Suit.spades: return '♠';
      case Suit.clubs: return '♣';
    }
  }
  
  Color get color {
    switch (this) {
      case Suit.diamonds:
      case Suit.hearts: return const Color(0xFFE74C3C);
      case Suit.spades:
      case Suit.clubs: return const Color(0xFF2C3E50);
    }
  }
}

extension RankExtension on Rank {
  String get name {
    switch (this) {
      case Rank.r6: return '6';
      case Rank.r7: return '7';
      case Rank.r8: return '8';
      case Rank.r9: return '9';
      case Rank.r10: return '10';
      case Rank.J: return 'J';
      case Rank.Q: return 'Q';
      case Rank.K: return 'K';
      case Rank.A: return 'A';
    }
  }
  
  int get value {
    switch (this) {
      case Rank.r6: return 0;
      case Rank.r7: return 1;
      case Rank.r8: return 2;
      case Rank.r9: return 3;
      case Rank.r10: return 4;
      case Rank.J: return 5;
      case Rank.Q: return 6;
      case Rank.K: return 7;
      case Rank.A: return 8;
    }
  }
}

class Card {
  final Suit suit;
  final Rank rank;
  
  Card({required this.suit, required this.rank});
  
  factory Card.fromJson(Map<String, dynamic> json) {
    final rankString = json['rank'] as String;
    
    return Card(
      suit: Suit.values.firstWhere((s) => s.name == json['suit']),
      rank: _parseRank(rankString),
    );
  }

  static Rank _parseRank(String rank) {
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
      default: throw Exception('Неизвестный ранг: $rank');
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'suit': suit.name,
      'rank': rank.name.replaceFirst('r', ''),
    };
  }
  
  String get assetPath {
    // Формат: 6_of_clubs.png, queen_of_hearts.png, 10_of_diamonds.png, ace_of_spades.png
    final suitName = _getSuitName();
    final rankName = _getRankName();
    return 'assets/images/cards/${rankName}_of_$suitName.png';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card && runtimeType == other.runtimeType && suit == other.suit && rank == other.rank;
  
  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  String _getSuitName() {
    switch (suit) {
      case Suit.diamonds: return 'diamonds';
      case Suit.hearts: return 'hearts';
      case Suit.spades: return 'spades';
      case Suit.clubs: return 'clubs';
    }
  }
  
  String _getRankName() {
    switch (rank) {
      case Rank.r6: return '6';
      case Rank.r7: return '7';
      case Rank.r8: return '8';
      case Rank.r9: return '9';
      case Rank.r10: return '10';
      case Rank.J: return 'jack';
      case Rank.Q: return 'queen';
      case Rank.K: return 'king';
      case Rank.A: return 'ace';
    }
  }
}