import 'package:flutter/material.dart';

import '../models/artwork.dart';

class ArtworkCard extends StatelessWidget {
  final Artwork artwork;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final String? distanceText;

  const ArtworkCard({
    super.key,
    required this.artwork,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    this.distanceText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // O GestureDetector substitui o InkWell para tornar o card clicável
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha superior: Título e Botão de Favorito
              Row(
                children: [
                  Expanded(
                    child: Text(
                      artwork.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                  ),
                ],
              ),
              
              // Endereço da obra
              Text(
                artwork.address,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),

              // Linha inferior: Distância e Curadoria
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (distanceText != null)
                    Text(
                      'A $distanceText',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (artwork.isCurated)
                    Text(
                      'Curadoria ArteNaRua',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}