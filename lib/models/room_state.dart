import 'card.dart';
import 'player.dart';

class RoomState {
  final String roomId;
  final List<Player> players;
  final Map<Suit, List<String>> centerPiles; // Ранги карт в стопках
  final int timer;
  final bool gameOver;
  final bool firstMoveAutoPlayed;
  
  RoomState({
    required this.roomId,
    required this.players,
    required this.centerPiles,
    required this.timer,
    required this.gameOver,
    required this.firstMoveAutoPlayed,
  });
  
  factory RoomState.fromJson(Map<String, dynamic> json) {
    return RoomState(
      roomId: json['roomId'] ?? '',
      players: (json['players'] as List?)
          ?.map((p) => Player.fromJson(p))
          .toList() ?? [],
      centerPiles: _parsePiles(json['centerPiles']),
      timer: json['timer'] ?? 30,
      gameOver: json['gameOver'] ?? false,
      firstMoveAutoPlayed: json['firstMoveAutoPlayed'] ?? false,
    );
  }
  
  static Map<Suit, List<String>> _parsePiles(dynamic json) {
    if (json == null) return {};
    return {
      Suit.diamonds: (json['diamonds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      Suit.hearts: (json['hearts'] as List?)?.map((e) => e.toString()).toList() ?? [],
      Suit.spades: (json['spades'] as List?)?.map((e) => e.toString()).toList() ?? [],
      Suit.clubs: (json['clubs'] as List?)?.map((e) => e.toString()).toList() ?? [],
    };
  }
  
  Player? get currentPlayer => players.firstWhere((p) => p.isCurrentTurn, orElse: () => players.first);
  
  Player? get localPlayer => players.first; // Упрощённо: первый игрок — локальный
}