import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../models/curation.dart';
import '../models/recognition_result.dart';
import '../services/curation_service.dart';
import '../services/gemini_recognition_service.dart';
import '../services/recognition_service.dart';
import '../utils/load_state.dart';
import '../widgets/ai_description.dart';
import '../widgets/ai_notice.dart';
import '../widgets/error_view.dart';
import 'artwork_detail_screen.dart';
import 'fallback_candidates_screen.dart';

class RecognitionResultScreen extends StatefulWidget {
  final XFile photo;
  final RecognitionService? recognitionService;
  final CurationService? curationService;

  const RecognitionResultScreen({
    super.key,
    required this.photo,
    this.recognitionService,
    this.curationService,
  });

  @override
  State<RecognitionResultScreen> createState() =>
      _RecognitionResultScreenState();
}

class _RecognitionResultScreenState extends State<RecognitionResultScreen> {
  late final RecognitionService service =
      widget.recognitionService ?? GeminiRecognitionService();
  late final CurationService curationService =
      widget.curationService ?? CurationService();

  RecognitionResult? result;
  Curation? bestCuration;
  List<Curation> candidates = [];
  LoadState state = LoadState.initial;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    recognize();
  }

  @override
  void dispose() {
    // A foto do usuário não fica guardada no aparelho.
    if (!kIsWeb) {
      try {
        File(widget.photo.path).deleteSync();
      } catch (_) {}
    }
    super.dispose();
  }

  Future<void> recognize() async {
    setState(() => state = LoadState.loading);
    try {
      final curations = await curationService.load();
      candidates = curations.values.toList();
      final found = await service.recognize(widget.photo, candidates);
      if (!mounted) return;

      if (!found.isFound) {
        openFallback(found);
        return;
      }
      setState(() {
        result = found;
        bestCuration = curations[found.placeId];
        state = LoadState.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        state = LoadState.error;
      });
    }
  }

  void openFallback([RecognitionResult? found]) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FallbackCandidatesScreen(
          candidates: candidates,
          aiDescription: found?.aiDescription,
        ),
      ),
    );
  }

  void openDetail(String placeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtworkDetailScreen(placeId: placeId),
      ),
    );
  }

  Widget buildBody() {
    switch (state) {
      case LoadState.initial:
      case LoadState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Analisando a foto...'),
            ],
          ),
        );
      case LoadState.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorView(message: errorMessage, onRetry: recognize),
            TextButton(
              onPressed: openFallback,
              child: const Text('Ver candidatas'),
            ),
          ],
        );
      case LoadState.success:
        final aiDescription = result!.aiDescription;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline, size: 64),
              const SizedBox(height: 12),
              Text(
                'Parece ser ${bestCuration?.title ?? 'uma obra conhecida'}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (aiDescription != null && aiDescription.trim().isNotEmpty)
                AiDescription(text: aiDescription)
              else
                const AiNotice(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => openDetail(result!.placeId!),
                child: const Text('Ver ficha'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: buildBody(),
    );
  }
}
