import 'package:flutter/material.dart';

import '../models/artwork.dart';
import '../models/artwork_distance.dart';
import '../models/curation.dart';
import '../models/user_position.dart';
import '../services/curation_service.dart';
import '../services/favorites_service.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../utils/geo_utils.dart';
import '../utils/load_state.dart';
import '../utils/regions.dart';
import '../widgets/artwork_card.dart';
import '../widgets/artwork_map.dart';
import '../widgets/artwork_summary_sheet.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/google_attribution.dart';
import '../widgets/location_notice.dart';
import '../widgets/region_chips.dart';
import '../widgets/search_field.dart';
import 'artwork_detail_screen.dart';
import 'capture_screen.dart';

typedef MapBuilder = Widget Function(
  List<Artwork> artworks,
  UserPosition? position,
  ValueChanged<Artwork> onMarkerTap,
);

class ArtworkListScreen extends StatefulWidget {
  final PlacesService? placesService;
  final CurationService? curationService;
  final FavoritesService? favoritesService;
  final LocationService? locationService;

  
  final MapBuilder? mapBuilder;

  const ArtworkListScreen({
    super.key,
    this.placesService,
    this.curationService,
    this.favoritesService,
    this.locationService,
    this.mapBuilder,
  });

  @override
  State<ArtworkListScreen> createState() => _ArtworkListScreenState();
}

class _ArtworkListScreenState extends State<ArtworkListScreen> {
  late final PlacesService service = widget.placesService ?? PlacesService();
  late final CurationService curationService =
      widget.curationService ?? CurationService();
  late final FavoritesService favoritesService =
      widget.favoritesService ?? FavoritesService();
  late final LocationService locationService =
      widget.locationService ?? LocationService();

  String region = regions.first;
  List<Artwork> artworks = [];
  Set<String> favoriteIds = {};
  String query = '';
  LoadState state = LoadState.initial;
  String errorMessage = '';

  
  LocationStatus locationStatus = LocationStatus.initial;
  String? locationMessage;
  UserPosition? position;
  List<ArtworkDistance> nearby = [];
  bool nearbyActive = false;


  static const bool mapEnabled = false;
  bool showMap = false;

  @override
  void initState() {
    super.initState();
    loadArtworks();
  }

  Future<void> loadArtworks() async {
    setState(() => state = LoadState.loading);
    try {
      final Map<String, Curation> curations = await curationService.load();
      final found = await service.searchArtworks(
        region,
        curatedIds: curations.keys.toSet(),
      );
      final ids = await favoritesService.getFavoriteIds();

      if (!mounted) return;
      setState(() {
        artworks = curatedFirst(
            found.map((a) => a.withCuration(curations[a.id])).toList());
        favoriteIds = ids;
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

  List<Artwork> curatedFirst(List<Artwork> list) {
    return [
      ...list.where((a) => a.isCurated),
      ...list.where((a) => !a.isCurated),
    ];
  }

  Future<void> loadNearby() async {
    setState(() {
      locationStatus = LocationStatus.searching;
      locationMessage = null;
    });
    try {
      final current = await locationService.getCurrentPosition();
      final curations = await curationService.load();
      final found = await service.searchNearby(
        current,
        curatedIds: curations.keys.toSet(),
      );
      final ids = await favoritesService.getFavoriteIds();
      if (!mounted) return;
      setState(() {
        position = current;
        nearby = found
            .map((d) => ArtworkDistance(
                  artwork: d.artwork.withCuration(curations[d.artwork.id]),
                  distanceMeters: d.distanceMeters,
                ))
            .toList();
        favoriteIds = ids;
        nearbyActive = true;
        locationStatus = LocationStatus.available;
      });
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        locationStatus = e.status;
        nearbyActive = false;
        position = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        locationStatus = LocationStatus.error;
        locationMessage = e.toString().replaceFirst('Exception: ', '');
        nearbyActive = false;
      });
    }
  }

  void toggleNearby(bool selected) {
    if (selected) {
      loadNearby();
    } else {
      setState(() {
        nearbyActive = false;
        position = null;
        locationStatus = LocationStatus.initial;
      });
    }
  }

  Future<void> reloadFavorites() async {
    final ids = await favoritesService.getFavoriteIds();
    if (!mounted) return;
    setState(() => favoriteIds = ids);
  }

  Future<void> toggleFavorite(Artwork artwork) async {
    await favoritesService.toggleFavorite(artwork.id);
    await reloadFavorites();
  }

  Future<void> openDetail(Artwork artwork) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ArtworkDetailScreen(artwork: artwork),
      ),
    );
    if (changed == true) await reloadFavorites();
  }

  void openCapture() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CaptureScreen()),
    );
  }

  void changeRegion(String newRegion) {
    if (newRegion == region && !nearbyActive) return;
    setState(() {
      region = newRegion;
      nearbyActive = false;
      position = null;
      locationStatus = LocationStatus.initial;
    });
    loadArtworks();
  }

  String? distanceTextFor(Artwork artwork) {
    if (!nearbyActive) return null;
    for (final item in nearby) {
      if (item.artwork.id == artwork.id) {
        return formatDistance(item.distanceMeters);
      }
    }
    return null;
  }

  void openSummary(Artwork artwork) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => ArtworkSummarySheet(
        artwork: artwork,
        photoUrl: artwork.photoName == null
            ? null
            : service.photoUrl(artwork.photoName!),
        distanceText: distanceTextFor(artwork),
        onOpenDetail: () {
          Navigator.pop(sheetContext);
          openDetail(artwork);
        },
      ),
    );
  }

  Widget buildMap(List<Artwork> visible) {
    final builder = widget.mapBuilder;
    if (builder != null) return builder(visible, position, openSummary);
    return ArtworkMap(
      artworks: visible,
      position: position,
      onMarkerTap: openSummary,
    );
  }

  Widget buildList(List<Artwork> visible) {
    return RefreshIndicator(
      onRefresh: nearbyActive ? loadNearby : loadArtworks,
      child: ListView.builder(
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final artwork = visible[index];
          return ArtworkCard(
            artwork: artwork,
            isFavorite: favoriteIds.contains(artwork.id),
            distanceText: distanceTextFor(artwork),
            onTap: () => openDetail(artwork),
            onFavorite: () => toggleFavorite(artwork),
          );
        },
      ),
    );
  }

  Widget buildBody() {
    if (nearbyActive) {
      final visible =
          service.search(nearby.map((d) => d.artwork).toList(), query);
      if (visible.isEmpty) {
        return const EmptyView(message: 'Nenhuma obra perto de você');
      }
      return showMap ? buildMap(visible) : buildList(visible);
    }

    switch (state) {
      case LoadState.initial:
      case LoadState.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadState.error:
        return ErrorView(message: errorMessage, onRetry: loadArtworks);
      case LoadState.success:
        final visible = service.search(artworks, query);
        if (visible.isEmpty) {
          return const EmptyView(message: 'Nada encontrado nesta região');
        }
        return showMap ? buildMap(visible) : buildList(visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegionChips(
          regions: regions,
          selected: nearbyActive ? '' : region,
          onSelected: changeRegion,
        ),
        SearchField(onChanged: (value) => setState(() => query = value)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Perto de mim'),
                avatar: locationStatus == LocationStatus.searching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 18),
                selected: nearbyActive,
                onSelected: locationStatus == LocationStatus.searching
                    ? null
                    : toggleNearby,
              ),
              if (mapEnabled) ...[
                const Spacer(),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('Lista')),
                    ButtonSegment(value: true, label: Text('Mapa')),
                  ],
                  selected: {showMap},
                  onSelectionChanged: (value) =>
                      setState(() => showMap = value.first),
                ),
              ],
            ],
          ),
        ),
        LocationNotice(
          status: locationStatus,
          message: locationMessage,
          onRetry: loadNearby,
          onOpenSettings: locationService.openSettings,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              onPressed: openCapture,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Reconhecer por foto'),
            ),
          ),
        ),
        Expanded(child: buildBody()),
      
        if (!showMap) const GoogleAttribution(),
      ],
    );
  }
}