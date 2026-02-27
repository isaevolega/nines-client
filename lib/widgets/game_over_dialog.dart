import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final String winner;
  final List<Map<String, dynamic>> rankings;
  final String myPlayerId;
  final VoidCallback onBackToLobby;

  const GameOverDialog({
    super.key,
    required this.winner,
    required this.rankings,
    required this.myPlayerId,
    required this.onBackToLobby,
  });

  @override
  Widget build(BuildContext context) {
    final myRank = rankings.firstWhere(
      (r) => r['playerId'] == myPlayerId,
      orElse: () => {'place': 0},
    );
    final myPlace = myRank['place'] as int?;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            myPlace == 1 ? Icons.emoji_events : Icons.info,
            color: myPlace == 1 ? Colors.amber : Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(myPlace == 1 ? 'Победа!' : 'Игра окончена'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            myPlace == 1
                ? '🎉 Поздравляем! Вы выиграли!'
                : '🏆 Место: #$myPlace',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Результаты:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...rankings.map((rank) {
            final place = rank['place'] as int;
            final playerId = rank['playerId'] as String;
            final isMe = playerId == myPlayerId;
            
            return ListTile(
              leading: Icon(
                place == 1
                    ? Icons.emoji_events
                    : place == 2
                        ? Icons.looks_two
                        : place == 3
                            ? Icons.looks_3
                            : Icons.tag,
                color: place == 1
                    ? Colors.amber
                    : place == 2
                        ? Colors.grey
                        : Colors.brown,
              ),
              title: Text(
                'Место #$place${isMe ? ' (Вы)' : ''}',
                style: TextStyle(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ],
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: onBackToLobby,
          icon: const Icon(Icons.home),
          label: const Text('В лобби'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}