// lib/screens/game/game_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../models/player.dart';
import '../../models/card.dart';
import '../../widgets/table_widget.dart';
import '../../widgets/hand_widget.dart';
import '../../widgets/players_panel_widget.dart';
import '../../widgets/timer_widget.dart';
import '../../widgets/game_over_dialog.dart';
import '../lobby/lobby_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // 🔥 Флаг чтобы показать диалог только один раз
  bool _gameOverDialogShown = false;

  @override
  void initState() {
    super.initState();
    
    // 🔥 Устанавливаем callback для показа уведомлений (Snackbar)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final gameProvider = context.read<GameProvider>();
      gameProvider.setNotificationCallback(_showNotification);
    });
  }

  // 🔥 Показ уведомления через Snackbar
  void _showNotification(String message, String severity) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: severity == 'error' 
            ? Colors.red 
            : severity == 'success' 
                ? Colors.green 
                : Colors.blue,
        duration: Duration(seconds: severity == 'error' ? 4 : 2),
        action: severity == 'error' 
            ? SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final roomState = gameProvider.roomState;
        final myPlayer = gameProvider.myPlayer;
        final isMyTurn = myPlayer?.isCurrentTurn ?? false;
        final timer = gameProvider.serverTimer;
        
        // 🔥 Проверяем наличие валидных ходов
        final hasValidMoves = gameProvider.hasValidMoves;

        // 🔥 Если игра завершилась — показываем диалог (только один раз)
        if (roomState?.gameOver == true && !_gameOverDialogShown) {
          _gameOverDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showGameOverDialog(context, gameProvider);
            }
          });
        }

        return WillPopScope(
          onWillPop: () async {
            _showLeaveConfirmation(context, gameProvider);
            return false;
          },
          child: Scaffold(
            appBar: _buildAppBar(context, roomState),
            body: _buildGameBody(
              context, 
              gameProvider, 
              roomState, 
              isMyTurn, 
              timer,
              hasValidMoves,  // ← Передаем наличие ходов
            ),
          ),
        );
      },
    );
  }

  // === App Bar ===
  PreferredSizeWidget _buildAppBar(BuildContext context, dynamic roomState) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Игра', style: TextStyle(fontSize: 18)),
          if (roomState != null)
            Text(
              'Комната: ${roomState.roomId}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
        ],
      ),
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showRulesDialog(context),
          tooltip: 'Правила',
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => _showLeaveConfirmation(context, context.read<GameProvider>()),
          tooltip: 'Выйти',
        ),
      ],
    );
  }

  // === Основное тело экрана ===
  Widget _buildGameBody(
    BuildContext context,
    GameProvider gameProvider,
    dynamic roomState,
    bool isMyTurn,
    int timer,
    bool hasValidMoves,  // ← Новый параметр
  ) {
    if (roomState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Панель игроков (сверху)
        PlayersPanelWidget(players: roomState.players),

        // 🔥 Таймер хода с кнопкой «Пропустить»
        TimerWidget(
          timer: timer,
          isMyTurn: isMyTurn,
          hasValidMoves: hasValidMoves,  // ← Передаем наличие ходов
          onSkipTurn: (isMyTurn && !hasValidMoves) 
              ? () => gameProvider.skipTurn() 
              : null,  // ← Кнопка только если нет ходов
        ),

        // Игровой стол (4 стопки)
        Expanded(
          child: TableWidget(
            centerPiles: roomState.centerPiles,
            isMyTurn: isMyTurn,
            onCardPlay: (card) => gameProvider.playCard(card),
          ),
        ),

        // 🔥 Рука игрока с подсветкой валидных карт
        HandWidget(
          hand: gameProvider.sortedHand,
          isMyTurn: isMyTurn,
          validMoves: gameProvider.validMoves,  // ← Передаем валидные ходы
          onCardTap: isMyTurn ? (card) => gameProvider.playCard(card) : null,
        ),

        // 🔥 Индикатор чей ход с учётом наличия ходов
        _buildTurnIndicator(context, roomState, isMyTurn, hasValidMoves),
      ],
    );
  }

  // === Индикатор текущего хода ===
  Widget _buildTurnIndicator(
    BuildContext context, 
    dynamic roomState, 
    bool isMyTurn,
    bool hasValidMoves,
  ) {
    // 🔥 ИСПРАВЛЕНО: используем firstWhere с orElse вместо firstOrNull
    Player? currentPlayer;
    if (roomState.players.isNotEmpty) {
      try {
        currentPlayer = roomState.players.firstWhere(
          (p) => p.isCurrentTurn,
          orElse: () => roomState.players.first,
        );
      } catch (e) {
        currentPlayer = roomState.players.first;
      }
    }
    
    final myPlayer = context.read<GameProvider>().myPlayer;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isMyTurn 
          ? (hasValidMoves ? Colors.green[100] : Colors.orange[100]) 
          : Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isMyTurn) ...[
            Icon(
              hasValidMoves ? Icons.arrow_downward : Icons.warning,
              color: hasValidMoves ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            isMyTurn
                ? (hasValidMoves 
                    ? 'Ваш ход!' 
                    : 'Нет ходов — пропустите или ждите')
                : 'Ход игрока: ${currentPlayer?.name ?? "..."}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMyTurn 
                  ? (hasValidMoves ? Colors.green[800] : Colors.orange[800]) 
                  : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // === Диалог конца игры ===
  void _showGameOverDialog(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        winner: gameProvider.winnerId ?? '',
        rankings: gameProvider.rankings ?? [],
        myPlayerId: gameProvider.playerId ?? '',
        onBackToLobby: () {
          Navigator.of(context).pop(); // Закрыть диалог
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LobbyScreen()),
          );
        },
      ),
    );
  }

  // === Подтверждение выхода ===
  void _showLeaveConfirmation(BuildContext context, GameProvider gameProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Покинуть игру?'),
        content: const Text('Вы уверены, что хотите выйти из игры?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              gameProvider.leaveGame();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LobbyScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Выйти', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === Диалог правил ===
  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Правила игры'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎯 **Цель:** Первым избавиться от всех карт'),
              SizedBox(height: 12),
              Text('🃏 **Правила ходов:**'),
              Text('• Первым ходом всегда идёт 9♦'),
              Text('• Можно положить карту на 1 ранг выше верхней'),
              Text('• ИЛИ на 1 ранг ниже нижней в стопке'),
              Text('• 9 можно класть только в пустую стопку'),
              SizedBox(height: 12),
              Text('⏱️ **Таймер:** 30 секунд на ход'),
              Text('• Если ходов нет — автоматический пропуск'),
              Text('• Если ходы есть — случайная карта'),
              SizedBox(height: 12),
              Text('🏆 **Победа:** Игрок с 0 карт выигрывает'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}