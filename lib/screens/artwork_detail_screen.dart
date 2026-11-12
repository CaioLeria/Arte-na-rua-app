import 'package:flutter/material.dart';

import '../models/artwork.dart';
import '../services/curation_service.dart';
import '../services/favorites_service.dart';
import '../services/places_service.dart';
import '../services/tts_service.dart';
import '../utils/load_state.dart';
import '../widgets/error_view.dart';
import '../widgets/google_attribution.dart';
import '../widgets/listen_button.dart';
import '../widgets/photo_attribution.dart';

class ArtworkDetailScreen extends StatefulWidget {
  final Artwork? artwork;
  final String? placeId;
  final PlacesService? placesService;
  final CurationService? curationService;
  final FavoritesService? favoritesService;
  final TtsService? ttsService;

  const ArtworkDetailScreen({
    super.key,
    this.artwork,
    this.placeId,
    this.placesService,
    this.curationService,
    this.favoritesService,
    this.ttsService,
  }) : assert(artwork != null || placeId != null,
            'Informe artwork ou placeId');

  @override
  State<ArtworkDetailScreen> createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends State<ArtworkDetailScreen> {
  late final PlacesService service = widget.placesService ?? PlacesService();
  late final CurationService curationService =
      widget.curationService ?? CurationService();
  late final FavoritesService favoritesService =
      widget.favoritesService ?? FavoritesService();
  late final TtsService tts = widget.ttsService ?? TtsService();

  Artwork? artwork;
  LoadState state = LoadState.initial;
  String errorMessage = '';
  bool isFavorite = false;
  bool favoritesChanged = false;
  bool speaking = false;

  @override
  void initState() {
    super.initState();
    loadArtwork();
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  Future<void> loadArtwork() async {
    setState(() => state = LoadState.loading);
    try {
      final curations = await curationService.load();
      var loaded = widget.artwork ?? await service.getArtworkById(widget.placeId!);
      loaded = loaded.withCuration(curations[loaded.id] ?? loaded.curation);
      final ids = await favoritesService.getFavoriteIds();
      if (!mounted) return;
      setState(() {
        artwork = loaded;
        isFavorite = ids.contains(loaded.id);
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

  Future<void> toggleFavorite() async {
    final current = artwork;
    if (current == null) return;
    final now = await favoritesService.toggleFavorite(current.id);
    if (!mounted) return;
    setState(() {
      isFavorite = now;
      favoritesChanged = true;
    });
  }

  Future<void> toggleSpeech() async {
    final current = artwork;
    if (current == null) return;
    if (speaking) {
      await tts.stop();
      if (!mounted) return;
      setState(() => speaking = false);
      return;
    }
    setState(() => speaking = true);
    await tts.speak(current.audioText);
    if (!mounted) return;
    setState(() => speaking = false);
  }

  Widget buildContent(Artwork art) {
    final curation = art.curation;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (art.photoName != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              service.photoUrl(art.photoName!, maxWidthPx: 900),
              height: 220,
              fit: BoxFit.cover,
              semanticLabel: 'Foto de ${art.title}',
              errorBuilder: (context, error, stack) => const SizedBox(
                height: 220,
                child: Icon(Icons.broken_image, semanticLabel: 'Foto indisponível'),
              ),
            ),
          ),
        PhotoAttribution(author: art.photoAuthor),
        const SizedBox(height: 12),
        Text(art.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(art.address),
        if (curation != null) ...[
          const SizedBox(height: 12),
          if (curation.artistName != null) Text('Artista: ${curation.artistName}'),
          if (curation.year != null) Text('Ano: ${curation.year}'),
          if (curation.history != null) ...[
            const SizedBox(height: 8),
            Text(curation.history!),
          ],
        ],
        const SizedBox(height: 16),
        Text('Audiodescrição', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(art.audioText),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: ListenButton(speaking: speaking, onPressed: toggleSpeech),
        ),
        const GoogleAttribution(),
      ],
    );
  }

  Widget buildBody() {
    switch (state) {
      case LoadState.initial:
      case LoadState.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadState.error:
        return ErrorView(message: errorMessage, onRetry: loadArtwork);
      case LoadState.success:
        return buildContent(artwork!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, favoritesChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(artwork?.title ?? 'Obra'),
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, favoritesChanged),
          ),
          actions: [
            if (artwork != null)
              IconButton(
                tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: toggleFavorite,
              ),
          ],
        ),
        body: buildBody(),
      ),
    );
  }
}
