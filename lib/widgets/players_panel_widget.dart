import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayersPanelWidget extends StatelessWidget {
  final List<Player> players;

  const PlayersPanelWidget({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: players.map((player) {
          return _buildPlayerChip(player);
        }).toList(),
      ),
    );
  }

  Widget _buildPlayerChip(Player player) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: player.isCurrentTurn ? Colors.green[100] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: player.isCurrentTurn ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getStatusIcon(player.status),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                '${player.cardCount} карт',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.active:
      case PlayerStatus.lobby:
        return const Icon(Icons.circle, color: Colors.green, size: 12);
      case PlayerStatus.offline:
        return const Icon(Icons.circle, color: Colors.orange, size: 12);
      case PlayerStatus.left:
        return const Icon(Icons.circle, color: Colors.grey, size: 12);
    }
  }
}