import 'package:flutter/material.dart';

import '../models/artwork.dart';
import 'photo_attribution.dart';


class ArtworkSummarySheet extends StatelessWidget {
  final Artwork artwork;
  final String? photoUrl;
  final String? distanceText;
  final VoidCallback onOpenDetail;

  const ArtworkSummarySheet({
    super.key,
    required this.artwork,
    required this.photoUrl,
    required this.distanceText,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  photoUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  semanticLabel: 'Foto de ${artwork.title}',
                  errorBuilder: (context, error, stack) => const SizedBox(
                    height: 140,
                    child: Icon(Icons.broken_image,
                        semanticLabel: 'Foto indisponível'),
                  ),
                ),
              ),
            PhotoAttribution(author: artwork.photoAuthor),
            const SizedBox(height: 8),
            Text(artwork.title, style: Theme.of(context).textTheme.titleLarge),
            if (distanceText != null) Text('a $distanceText'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onOpenDetail,
                child: const Text('Ver ficha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
