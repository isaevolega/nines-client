import 'package:flutter/foundation.dart';
import 'package:nines_client/models/ws_status.dart';
import 'package:nines_client/services/storage_service.dart';
import '../models/room_state.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../services/websocket_service.dart';
import '../models/messages.dart';

class GameProvider extends ChangeNotifier {
  final WebSocketService _wsService;

  WSStatus get wsStatus => _wsService.status;
  
  RoomState? _roomState;
  String? _playerId;
  String? _savedPlayerName;
  bool _isOrganizer = false;
  List<Card> _myHand = [];
  WSStatus _wsStatus = WSStatus.disconnected;
  
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
  String? get savedPlayerName => _savedPlayerName;

  List<Card> get sortedHand {
    final suitOrder = [Suit.diamonds, Suit.hearts, Suit.spades, Suit.clubs];
    
    final sorted = List<Card>.from(_myHand);
    sorted.sort((a, b) {
      // Сначала сортируем по масти
      final suitCompare = suitOrder.indexOf(a.suit).compareTo(suitOrder.indexOf(b.suit));
      if (suitCompare != 0) return suitCompare;
      
      // Затем по рангу (6, 7, 8, 9, 10, J, Q, K, A)
      return a.rank.value.compareTo(b.rank.value);
    });
    
    return sorted;
  }
  
  GameProvider(this._wsService) {
    _wsService.messageStream.listen(_handleMessage);
    _loadSavedData();
  }

  String? get winnerId {
    // Победитель — игрок с 0 карт
    return _roomState?.players.firstWhere(
      (p) => p.cardCount == 0,
      orElse: () => _roomState?.players.first ?? Player(
        id: '', name: '', cardCount: 0,
        isCurrentTurn: false, status: PlayerStatus.lobby, isOrganizer: false,
      ),
    ).id;
  }

  List<Map<String, dynamic>>? get rankings => _rankings;
  List<Map<String, dynamic>> _rankings = [];

  Future<void> _loadSavedData() async {
    final storage = StorageService();
    _playerId = await storage.getPlayerId();
    _savedPlayerName = await storage.getPlayerName();
    notifyListeners();
  }
  
  void _handleMessage(Map<String, dynamic> msg) {
    print('[CLIENT] Получено сообщение: ${msg['type']}');

    switch (msg['type']) {
      case 'connection_status':
        _wsStatus = WSStatus.values.firstWhere(
          (s) => s.name == msg['status'],
          orElse: () => WSStatus.disconnected,
        );
        notifyListeners();
        break;
        
      case 'join_success':
        final data = JoinSuccessMessage.fromJson(msg);
        _playerId = data.playerId;
        _roomState = data.roomState;
        _myHand = data.roomState.myHand ?? [];
        _updateOrganizerStatus();
        _savePlayerId();
        notifyListeners();
        break;
        
      case 'game_state':
        final data = GameStateMessage.fromJson(msg);
        _roomState = data.data;
        _myHand = data.data.myHand ?? [];

        print('[CLIENT] centerPiles: ${data.data.centerPiles}');  // ← Лог
        print('[CLIENT] Моя рука: ${_myHand.length} карт');  // ← Лог

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
        _rankings = data.rankings;
        notifyListeners();
        break;
    }
  }

  Future<void> _savePlayerId() async {
    if (_playerId != null) {
      await StorageService().savePlayerId(_playerId!);
    }
  }
  
  void savePlayerName(String name) {
    _savedPlayerName = name;
    StorageService().savePlayerName(name);
  }
  
  void connect() {
    _wsService.connect();
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