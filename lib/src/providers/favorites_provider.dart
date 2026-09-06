import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/favorites_storage.dart';
import 'repository_providers.dart';

/// Owns the set of favorite product ids and keeps [FavoritesStorage] in
/// sync so the selection is persisted across app restarts.
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._storage) : super(_storage.load());

  final FavoritesStorage _storage;

  bool isFavorite(String productId) => state.contains(productId);

  void toggle(String productId) {
    final next = {...state};
    if (!next.remove(productId)) {
      next.add(productId);
    }
    state = next;
    _storage.save(state);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(ref.watch(favoritesStorageProvider));
});
