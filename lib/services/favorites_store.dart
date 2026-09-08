import 'package:shared_preferences/shared_preferences.dart';

/// Persists the fighters a fan follows, so push segmentation survives restarts.
class FavoritesStore {
  static const _key = 'efc_followed_fighters';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  Future<void> save(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }
}
