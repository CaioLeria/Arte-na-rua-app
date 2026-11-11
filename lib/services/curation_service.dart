import '../models/curation.dart';

class CurationService {
  /// Dados mockados em memória, eliminando a necessidade de ler arquivos assets/json.
  static final Map<String, Curation> mockCurations = {
    'PLACE_ID_BECO_DO_BATMAN': Curation(
      placeId: 'PLACE_ID_BECO_DO_BATMAN',
      title: 'Beco do Batman',
      artistName: 'Vários artistas',
      year: 1980,
      history:
          'Viela histórica na Vila Madalena com muros repletos de grafites e murais que se renovam com frequência.',
      audioDescription:
          'Viela estreita de paralelepípedos com paredes totalmente grafitadas em cores vibrantes e formas geométricas.',
    ),
    'PLACE_ID_MURAL_KOBRA': Curation(
      placeId: 'PLACE_ID_MURAL_KOBRA',
      title: 'Mural Oscar Niemeyer',
      artistName: 'Eduardo Kobra',
      year: 2013,
      history:
          'Mural de 52 metros de altura na Avenida Paulista em homenagem ao renomado arquiteto brasileiro.',
      audioDescription:
          'Mural gigante vertical em estilo caleidoscópio geométrico retratando o rosto do arquiteto Oscar Niemeyer.',
    ),
  };

  /// Retorna o mapa de curadorias indexadas por `placeId`.
  Future<Map<String, Curation>> load() async {
    return mockCurations;
  }

  /// Busca a curadoria de uma obra específica pelo seu `placeId`.
  Curation? getByPlaceId(String placeId) {
    return mockCurations[placeId];
  }
}
