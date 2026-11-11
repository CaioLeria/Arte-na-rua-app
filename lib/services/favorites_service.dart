import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorites';

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  Future<bool> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = (prefs.getStringList(_key) ?? const <String>[]).toList();
    final nowFavorite = !ids.contains(id);
    if (nowFavorite) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await prefs.setStringList(_key, ids);
    return nowFavorite;
  }
}
