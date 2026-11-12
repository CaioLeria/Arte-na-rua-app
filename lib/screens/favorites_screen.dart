import 'package:flutter/material.dart';

import '../models/artwork.dart';
import '../services/curation_service.dart';
import '../services/favorites_service.dart';
import '../services/places_service.dart';
import '../utils/load_state.dart';
import '../widgets/artwork_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/google_attribution.dart';
import 'artwork_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final PlacesService? placesService;
  final CurationService? curationService;
  final FavoritesService? favoritesService;

  const FavoritesScreen({
    super.key,
    this.placesService,
    this.curationService,
    this.favoritesService,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final PlacesService service = widget.placesService ?? PlacesService();
  late final CurationService curationService =
      widget.curationService ?? CurationService();
  late final FavoritesService favoritesService =
      widget.favoritesService ?? FavoritesService();

  List<Artwork> artworks = [];
  LoadState state = LoadState.initial;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  /// Guardamos só o id; a ficha é buscada de novo na Places.
  Future<void> loadFavorites() async {
    setState(() => state = LoadState.loading);
    try {
      final ids = await favoritesService.getFavoriteIds();
      final curations = await curationService.load();
      final loaded = await Future.wait(
        ids.map((id) => service.getArtworkById(id)),
      );
      if (!mounted) return;
      setState(() {
        artworks = loaded.map((a) => a.withCuration(curations[a.id])).toList();
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

  Future<void> removeFavorite(Artwork artwork) async {
    await favoritesService.toggleFavorite(artwork.id);
    if (!mounted) return;
    setState(() => artworks.removeWhere((a) => a.id == artwork.id));
  }

  Future<void> openDetail(Artwork artwork) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ArtworkDetailScreen(artwork: artwork),
      ),
    );
    if (changed == true) await loadFavorites();
  }

  Widget buildBody() {
    switch (state) {
      case LoadState.initial:
      case LoadState.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadState.error:
        return ErrorView(message: errorMessage, onRetry: loadFavorites);
      case LoadState.success:
        if (artworks.isEmpty) {
          return const EmptyView(
            icon: Icons.favorite_border,
            message: 'Toque no coração de uma obra para guardá-la aqui',
          );
        }
        return ListView.builder(
          itemCount: artworks.length,
          itemBuilder: (context, index) {
            final artwork = artworks[index];
            return ArtworkCard(
              artwork: artwork,
              isFavorite: true,
              onTap: () => openDetail(artwork),
              onFavorite: () => removeFavorite(artwork),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: buildBody()),
        const GoogleAttribution(),
      ],
    );
  }
}
