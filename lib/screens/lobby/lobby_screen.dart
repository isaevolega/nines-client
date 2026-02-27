import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/player.dart';
import '../../widgets/player_status_icon.dart';
import '../game/game_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    // Подключаемся к WebSocket при входе на экран
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      if (gameProvider.wsStatus != WSStatus.connected) {
        gameProvider.connect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final roomState = gameProvider.roomState;
        final isOrganizer = gameProvider.isOrganizer;
        final playerId = gameProvider.playerId;
        
        // Если игра уже началась — переходим на игровой экран
        if (roomState != null && roomState.gameOver == false && 
            roomState.firstMoveAutoPlayed == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GameScreen()),
            );
          });
        }

        return WillPopScope(
          onWillPop: () async {
            _leaveGame(gameProvider);
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Лобби'),
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: _buildBody(context, gameProvider, roomState, isOrganizer, playerId),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    GameProvider gameProvider,
    dynamic roomState,
    bool isOrganizer,
    String? playerId,
  ) {
    final connectionStatus = gameProvider.wsStatus;

    if (connectionStatus == WSStatus.connecting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (connectionStatus == WSStatus.error || connectionStatus == WSStatus.disconnected) {
      return _buildErrorState(context, gameProvider);
    }

    if (roomState == null) {
      return _buildJoinForm(context, gameProvider);
    }

    return _buildLobbyState(context, gameProvider, roomState, isOrganizer, playerId);
  }

  // === Форма входа (если ещё не в комнате) ===
  Widget _buildJoinForm(BuildContext context, GameProvider gameProvider) {
    final roomIdController = TextEditingController();
    final playerNameController = TextEditingController(
      text: gameProvider.savedPlayerName ?? 'Игрок',
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Логотип / Заголовок
          const Icon(Icons.games, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Девятка',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),

          // Поле ввода имени
          TextField(
            controller: playerNameController,
            decoration: const InputDecoration(
              labelText: 'Ваше имя',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            maxLength: 20,
          ),
          const SizedBox(height: 16),

          // Поле ввода кода комнаты
          TextField(
            controller: roomIdController,
            decoration: const InputDecoration(
              labelText: 'Код комнаты (если есть)',
              prefixIcon: Icon(Icons.meeting_room),
              border: OutlineInputBorder(),
            ),
            maxLength: 6,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 24),

          // Кнопка "Создать игру"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final name = playerNameController.text.trim();
                if (name.isEmpty) {
                  _showSnackBar(context, 'Введите имя', isError: true);
                  return;
                }
                gameProvider.savePlayerName(name);
                gameProvider.joinGame(name);
              },
              icon: const Icon(Icons.add),
              label: const Text('Создать игру'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Кнопка "Войти"
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final name = playerNameController.text.trim();
                final roomId = roomIdController.text.trim().toUpperCase();
                if (name.isEmpty) {
                  _showSnackBar(context, 'Введите имя', isError: true);
                  return;
                }
                if (roomId.isEmpty) {
                  _showSnackBar(context, 'Введите код комнаты', isError: true);
                  return;
                }
                gameProvider.savePlayerName(name);
                gameProvider.joinGame(name, roomId: roomId);
              },
              icon: const Icon(Icons.login),
              label: const Text('Войти в комнату'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // Статус подключения
          const SizedBox(height: 24),
          Consumer<GameProvider>(
            builder: (context, gameProvider, _) {
              return Text(
                _getStatusText(gameProvider.wsStatus),
                style: TextStyle(
                  color: gameProvider.wsStatus == WSStatus.connected
                      ? Colors.green
                      : Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // === Лобби (если уже в комнате) ===
  Widget _buildLobbyState(
    BuildContext context,
    GameProvider gameProvider,
    dynamic roomState,
    bool isOrganizer,
    String? playerId,
  ) {
    final activePlayers = roomState.players
        .where((p) => p.status == PlayerStatus.active || p.status == PlayerStatus.lobby)
        .length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Код комнаты
          _buildRoomCodeCard(context, roomState.roomId),
          const SizedBox(height: 24),

          // Список игроков
          Expanded(
            child: _buildPlayerList(roomState.players, playerId),
          ),

          const SizedBox(height: 16),

          // Кнопки действий
          _buildActionButtons(context, gameProvider, isOrganizer, activePlayers),
        ],
      ),
    );
  }

  // === Карточка с кодом комнаты ===
  Widget _buildRoomCodeCard(BuildContext context, String roomId) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Код комнаты',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  roomId,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: roomId));
                    _showSnackBar(context, 'Код скопирован', isSuccess: true);
                  },
                  tooltip: 'Копировать',
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Реализовать шаринг через share_plus
                    Clipboard.setData(ClipboardData(text: roomId));
                    _showSnackBar(context, 'Код скопирован для отправки', isSuccess: true);
                  },
                  tooltip: 'Поделиться',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === Список игроков ===
  Widget _buildPlayerList(List<dynamic> players, String? playerId) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isLocalPlayer = player.id == playerId;
        final isOrganizer = player.isOrganizer;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: PlayerStatusIcon(status: player.status),
            title: Row(
              children: [
                Text(
                  player.name,
                  style: TextStyle(
                    fontWeight: isLocalPlayer ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isOrganizer) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                ],
                if (isLocalPlayer) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Вы',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(_getStatusLabel(player.status)),
            trailing: Text(
              '${player.cardCount} карт',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  // === Кнопки действий ===
  Widget _buildActionButtons(
    BuildContext context,
    GameProvider gameProvider,
    bool isOrganizer,
    int activePlayers,
  ) {
    return Column(
      children: [
        // Кнопка "Начать игру" (только организатор)
        if (isOrganizer)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: activePlayers >= 2
                  ? () => gameProvider.startGame()
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(
                activePlayers >= 2
                    ? 'Начать игру (${activePlayers}/2+)'
                    : 'Ждём игроков (${activePlayers}/2+)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: activePlayers >= 2
                    ? Colors.green[700]
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Кнопка "Назад"
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _leaveGame(gameProvider),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Покинуть комнату'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // === Экран ошибки подключения ===
  Widget _buildErrorState(BuildContext context, GameProvider gameProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Нет соединения с сервером',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => gameProvider.connect(),
            icon: const Icon(Icons.refresh),
            label: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  // === Утилиты ===
  void _leaveGame(GameProvider gameProvider) {
    gameProvider.leaveGame();
    Navigator.pop(context);
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : isSuccess
                ? Colors.green
                : null,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  String _getStatusText(WSStatus status) {
    switch (status) {
      case WSStatus.connected:
        return '● Подключено';
      case WSStatus.connecting:
        return '○ Подключение...';
      case WSStatus.disconnected:
        return '○ Отключено';
      case WSStatus.error:
        return '✕ Ошибка подключения';
    }
  }

  String _getStatusLabel(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.lobby:
        return 'В лобби';
      case PlayerStatus.active:
        return 'Активен';
      case PlayerStatus.offline:
        return 'Не в сети';
      case PlayerStatus.left:
        return 'Вышел';
    }
  }
}