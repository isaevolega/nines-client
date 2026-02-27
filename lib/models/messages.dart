import 'room_state.dart';

abstract class WSMessage {
  final String type;
  WSMessage(this.type);
  Map<String, dynamic> toJson();
}

// Клиент → Сервер
class JoinMessage extends WSMessage {
  final String? roomId;
  final String playerName;
  final String? playerId;
  
  JoinMessage({this.roomId, required this.playerName, this.playerId}) : super('join');
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (roomId != null) 'roomId': roomId,
    'playerName': playerName,
    if (playerId != null) 'playerId': playerId,
  };
}

class StartGameMessage extends WSMessage {
  StartGameMessage() : super('start_game');
  @override
  Map<String, dynamic> toJson() => {'type': type};
}

class PlayCardMessage extends WSMessage {
  final Map<String, dynamic> card;
  PlayCardMessage(this.card) : super('play_card');
  @override
  Map<String, dynamic> toJson() => {'type': type, 'card': card};
}

class SkipTurnMessage extends WSMessage {
  SkipTurnMessage() : super('skip_turn');
  @override
  Map<String, dynamic> toJson() => {'type': type};
}

class LeaveMessage extends WSMessage {
  LeaveMessage() : super('leave');
  @override
  Map<String, dynamic> toJson() => {'type': type};
}

// Сервер → Клиент
class JoinSuccessMessage {
  final String playerId;
  final RoomState roomState;
  JoinSuccessMessage({required this.playerId, required this.roomState});
  
  factory JoinSuccessMessage.fromJson(Map<String, dynamic> json) {
    return JoinSuccessMessage(
      playerId: json['playerId'],
      roomState: RoomState.fromJson(json['roomState']),
    );
  }
}

class GameStateMessage {
  final RoomState data;
  
  GameStateMessage(this.data);
  
  factory GameStateMessage.fromJson(Map<String, dynamic> json) {
    return GameStateMessage(RoomState.fromJson(json['data']));
  }
}

class NotificationMessage {
  final String message;
  final String severity;
  NotificationMessage({required this.message, required this.severity});
  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      message: json['message'],
      severity: json['severity'] ?? 'info',
    );
  }
}

class GameOverMessage {
  final String winner;
  final List<Map<String, dynamic>> rankings;
  GameOverMessage({required this.winner, required this.rankings});
  factory GameOverMessage.fromJson(Map<String, dynamic> json) {
    return GameOverMessage(
      winner: json['winner'],
      rankings: (json['rankings'] as List).cast<Map<String, dynamic>>(),
    );
  }
}