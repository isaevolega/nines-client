import 'package:flutter/material.dart' hide Card;
import '../models/card.dart';

class CardWidget extends StatelessWidget {
  final Card card;
  final bool isPlayable;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.card,
    this.isPlayable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: Container(
        width: 56,
        height: 80,
        margin: const EdgeInsets.only(right: 2), // Уменьшили отступ для наложения
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isPlayable ? Colors.white : Colors.grey[600]!,
            width: isPlayable ? 2 : 1,
          ),
          boxShadow: isPlayable
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            card.assetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Ошибка загрузки карты: $error');
              // Фоллбэк на текстовую карту если изображения нет
              return _buildTextCard();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextCard() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          '${card.rank.name}${card.suit.symbol}',
          style: TextStyle(
            fontSize: 20,
            color: card.suit.color,
          ),
        ),
      ),
    );
  }
}