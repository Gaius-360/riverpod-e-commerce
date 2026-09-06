import 'package:shared_preferences/shared_preferences.dart';

/// Persists the set of favorite product ids to disk via [SharedPreferences]
/// so favorites survive an app restart.
class FavoritesStorage {
  const FavoritesStorage(this._prefs);

  static const _storageKey = 'favorite_product_ids';

  final SharedPreferences _prefs;

  Set<String> load() {
    return _prefs.getStringList(_storageKey)?.toSet() ?? <String>{};
  }

  Future<void> save(Set<String> favoriteIds) async {
    await _prefs.setStringList(_storageKey, favoriteIds.toList());
  }
}
