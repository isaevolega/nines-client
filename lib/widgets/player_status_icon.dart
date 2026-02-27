import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerStatusIcon extends StatelessWidget {
  final PlayerStatus status;

  const PlayerStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case PlayerStatus.active:
      case PlayerStatus.lobby:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.green[700]),
        );

      case PlayerStatus.offline:
        return Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_off, color: Colors.white),
        );

      case PlayerStatus.left:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.grey),
        );
    }
  }
}