enum PlayerStatus { lobby, active, offline, left }

extension PlayerStatusExtension on PlayerStatus {
  String get label {
    switch (this) {
      case PlayerStatus.lobby: return 'В лобби';
      case PlayerStatus.active: return 'Активен';
      case PlayerStatus.offline: return 'Не в сети';
      case PlayerStatus.left: return 'Вышел';
    }
  }
}

class Player {
  final String id;
  final String name;
  final int cardCount;
  final bool isCurrentTurn;
  final PlayerStatus status;
  final bool isOrganizer;
  
  Player({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.isCurrentTurn,
    required this.status,
    required this.isOrganizer,
  });
  
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      cardCount: json['cardCount'] ?? 0,
      isCurrentTurn: json['isCurrentTurn'] ?? false,
      status: PlayerStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PlayerStatus.lobby,
      ),
      isOrganizer: json['isOrganizer'] ?? false,
    );
  }
}