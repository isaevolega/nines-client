// lib/providers/game_provider.dart

import 'package:flutter/foundation.dart';
import 'package:nines_client/models/ws_status.dart';
import 'package:nines_client/services/storage_service.dart';
import '../models/room_state.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../services/websocket_service.dart';
import '../models/messages.dart';
import '../utils/move_validator.dart'; // 🔥 Импортируем валидатор

class GameProvider extends ChangeNotifier {
  final WebSocketService _wsService;

  // 🔥 Callback для показа уведомлений (устанавливается из GameScreen)
  Function(String, String)? _onNotification;
  
  RoomState? _roomState;
  String? _playerId;
  String? _savedPlayerName;
  bool _isOrganizer = false;
  List<Card> _myHand = [];
  int _serverTimer = 30;
  List<Map<String, dynamic>> _rankings = [];

  // Геттеры
  WSStatus get wsStatus => _wsService.status;
  int get serverTimer => _serverTimer;
  RoomState? get roomState => _roomState;
  String? get playerId => _playerId;
  bool get isOrganizer => _isOrganizer;
  List<Card> get myHand => _myHand;
  String? get savedPlayerName => _savedPlayerName;
  List<Map<String, dynamic>>? get rankings => _rankings.isNotEmpty ? _rankings : null;
  
  // 🔥 Текущий игрок
  Player? get myPlayer => _roomState?.players.firstWhere(
    (p) => p.id == _playerId,
    orElse: () => _roomState?.players.first ?? Player(
      id: '', name: '', cardCount: 0,
      isCurrentTurn: false, status: PlayerStatus.lobby, isOrganizer: false,
    ),
  );
  
  // 🔥 Победитель (игрок с 0 карт)
  String? get winnerId {
    if (_roomState?.gameOver != true) return null;
    
    try {
      return _roomState?.players.firstWhere(
        (p) => p.cardCount == 0,
        orElse: () => _roomState?.players.first ?? Player(
          id: '', name: '', cardCount: 0,
          isCurrentTurn: false, status: PlayerStatus.lobby, isOrganizer: false,
        ),
      ).id;
    } catch (e) {
      return null;
    }
  }

  // 🔥 Отсортированная рука (по мастям и рангам)
  List<Card> get sortedHand {
    final suitOrder = [Suit.diamonds, Suit.hearts, Suit.spades, Suit.clubs];
    
    final sorted = List<Card>.from(_myHand);
    sorted.sort((a, b) {
      final suitCompare = suitOrder.indexOf(a.suit).compareTo(suitOrder.indexOf(b.suit));
      if (suitCompare != 0) return suitCompare;
      return a.rank.value.compareTo(b.rank.value);
    });
    
    return sorted;
  }
  
  // 🔥 Валидные ходы (карты, которыми можно походить сейчас)
  List<Card> get validMoves {
    if (_roomState == null || !myPlayer!.isCurrentTurn) return [];
    return MoveValidator.getValidMoves(_myHand, _roomState!.centerPiles);
  }
  
  // 🔥 Проверка конкретной карты на валидность
  bool isValidCard(Card card) {
    if (_roomState == null) return false;
    return MoveValidator.isValidMove(card, _roomState!.centerPiles);
  }
  
  // 🔥 Есть ли вообще валидные ходы
  bool get hasValidMoves => validMoves.isNotEmpty;

  GameProvider(this._wsService) {
    _wsService.messageStream.listen(_handleMessage);
    _loadSavedData();
  }

  // 🔥 Установка callback для уведомлений
  void setNotificationCallback(Function(String, String) callback) {
    _onNotification = callback;
  }

  Future<void> _loadSavedData() async {
    final storage = StorageService();
    _playerId = await storage.getPlayerId();
    _savedPlayerName = await storage.getPlayerName();
    notifyListeners();
  }
  
  void _handleMessage(Map<String, dynamic> msg) {
    print('[PROVIDER] Получено сообщение: ${msg['type']}');
    
    switch (msg['type']) {
      case 'connection_status':
        // Статус соединения обрабатывается в WebSocketService
        break;
        
      case 'join_success':
        final data = JoinSuccessMessage.fromJson(msg);
        _playerId = data.playerId;
        _roomState = data.roomState;
        _myHand = data.roomState.myHand ?? [];
        _serverTimer = data.roomState.timer;
        _updateOrganizerStatus();
        _savePlayerId();
        print('[PROVIDER] Join success: playerId=$_playerId, roomId=${_roomState?.roomId}');
        notifyListeners();
        break;
        
      case 'game_state':
        final data = GameStateMessage.fromJson(msg);
        _roomState = data.data;
        _myHand = data.data.myHand ?? [];
        _serverTimer = data.data.timer;
        _updateOrganizerStatus();
        
        print('[PROVIDER] Game state: timer=$_serverTimer, мой ход=${myPlayer?.isCurrentTurn}');
        notifyListeners();
        break;
        
      case 'notification':
        final data = NotificationMessage.fromJson(msg);
        print('[PROVIDER] Notification: ${data.message} (${data.severity})');
        
        // 🔥 Вызываем callback для показа Snackbar
        if (_onNotification != null) {
          _onNotification!(data.message, data.severity);
        }
        
        notifyListeners();
        break;
        
      case 'game_over':
        final data = GameOverMessage.fromJson(msg);
        _rankings = data.rankings;
        print('[PROVIDER] Game over! Rankings: $_rankings');
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
  
  // 🔥 Действия (отправка на сервер)
  void joinGame(String playerName, {String? roomId, String? playerId}) {
    print('[PROVIDER] Join game: roomId=$roomId, playerName=$playerName');
    _wsService.send(JoinMessage(
      roomId: roomId,
      playerName: playerName,
      playerId: playerId ?? _playerId,
    ));
  }
  
  void startGame() {
    print('[PROVIDER] Start game');
    _wsService.send(StartGameMessage());
  }
  
  void playCard(Card card) {
    print('[PROVIDER] Play card: ${card.rank}${card.suit}');
    _wsService.send(PlayCardMessage(card.toJson()));
  }
  
  void skipTurn() {
    print('[PROVIDER] Skip turn');
    _wsService.send(SkipTurnMessage());
  }
  
  void leaveGame() {
    print('[PROVIDER] Leave game');
    _wsService.send(LeaveMessage());
  }
  
  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }
}