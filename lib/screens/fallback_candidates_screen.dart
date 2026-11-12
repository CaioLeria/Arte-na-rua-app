import 'package:flutter/material.dart';

import '../models/curation.dart';
import '../widgets/ai_description.dart';
import '../widgets/ai_notice.dart';
import 'artwork_detail_screen.dart';

class FallbackCandidatesScreen extends StatefulWidget {
  final List<Curation> candidates;
  final String? aiDescription;

  const FallbackCandidatesScreen(
      {super.key, required this.candidates, this.aiDescription});

  @override
  State<FallbackCandidatesScreen> createState() =>
      _FallbackCandidatesScreenState();
}

class _FallbackCandidatesScreenState extends State<FallbackCandidatesScreen> {
  void openDetail(Curation curation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtworkDetailScreen(placeId: curation.placeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Será que é uma destas?')),
      body: Column(
        children: [
          if (widget.aiDescription != null &&
              widget.aiDescription!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: AiDescription(text: widget.aiDescription!),
            )
          else
            const Padding(
              padding: EdgeInsets.all(12),
              child: AiNotice(),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.candidates.length,
              itemBuilder: (context, index) {
                final curation = widget.candidates[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(curation.title),
                    subtitle: curation.artistName == null
                        ? null
                        : Text(curation.artistName!),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openDetail(curation),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tirar outra foto'),
            ),
          ),
        ],
      ),
    );
  }
}
