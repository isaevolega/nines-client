import 'package:flutter/foundation.dart';
import '../models/room_state.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../services/websocket_service.dart';
import '../models/messages.dart';

class GameProvider extends ChangeNotifier {
  final WebSocketService _wsService;
  
  RoomState? _roomState;
  String? _playerId;
  bool _isOrganizer = false;
  List<Card> _myHand = [];
  
  RoomState? get roomState => _roomState;
  String? get playerId => _playerId;
  bool get isOrganizer => _isOrganizer;
  List<Card> get myHand => _myHand;
  Player? get myPlayer => _roomState?.players.firstWhere(
    (p) => p.id == _playerId,
    orElse: () => _roomState?.players.first ?? Player(
      id: '', name: '', cardCount: 0,
      isCurrentTurn: false, status: PlayerStatus.lobby, isOrganizer: false,
    ),
  );
  
  GameProvider(this._wsService) {
    _wsService.messageStream.listen(_handleMessage);
  }
  
  void _handleMessage(Map<String, dynamic> msg) {
    switch (msg['type']) {
      case 'join_success':
        final data = JoinSuccessMessage.fromJson(msg);
        _playerId = data.playerId;
        _roomState = data.roomState;
        _updateOrganizerStatus();
        notifyListeners();
        break;
        
      case 'game_state':
        final data = GameStateMessage.fromJson(msg);
        _roomState = data.data;
        _updateOrganizerStatus();
        notifyListeners();
        break;
        
      case 'notification':
        final data = NotificationMessage.fromJson(msg);
        // Можно добавить snackbar через callback
        print('Notification: ${data.message}');
        notifyListeners();
        break;
        
      case 'game_over':
        final data = GameOverMessage.fromJson(msg);
        // Обработка конца игры
        print('Game Over! Winner: ${data.winner}');
        notifyListeners();
        break;
        
      case 'connection_status':
        // Обработка статуса подключения
        notifyListeners();
        break;
    }
  }
  
  void _updateOrganizerStatus() {
    _isOrganizer = _roomState?.players
        .firstWhere((p) => p.id == _playerId, orElse: () => Player(
          id: '', name: '', cardCount: 0,
          isCurrentTurn: false, status: PlayerStatus.lobby, isOrganizer: false,
        ))
        .isOrganizer ?? false;
  }
  
  // Действия
  void joinGame(String playerName, {String? roomId, String? playerId}) {
    _wsService.send(JoinMessage(
      roomId: roomId,
      playerName: playerName,
      playerId: playerId,
    ));
  }
  
  void startGame() {
    _wsService.send(StartGameMessage());
  }
  
  void playCard(Card card) {
    _wsService.send(PlayCardMessage(card.toJson()));
  }
  
  void skipTurn() {
    _wsService.send(SkipTurnMessage());
  }
  
  void leaveGame() {
    _wsService.send(LeaveMessage());
  }
  
  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }
}