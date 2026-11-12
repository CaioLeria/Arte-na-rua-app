import 'package:flutter/material.dart';

class PhotoAttribution extends StatelessWidget {
  final String? author;

  const PhotoAttribution({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    if (author == null || author!.isEmpty) return const SizedBox.shrink();
    return Text(
      'Foto: $author',
      style: Theme.of(context).textTheme.bodySmall,
      overflow: TextOverflow.ellipsis,
    );
  }
}
