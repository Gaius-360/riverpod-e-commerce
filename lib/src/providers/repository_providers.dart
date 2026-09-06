import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/favorites_storage.dart';
import '../data/product_repository.dart';
import '../data/user_repository.dart';

/// Overridden in `main()` once `SharedPreferences.getInstance()` resolves,
/// so the rest of the app can depend on it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before runApp.',
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return const ProductRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return const UserRepository();
});

final favoritesStorageProvider = Provider<FavoritesStorage>((ref) {
  return FavoritesStorage(ref.watch(sharedPreferencesProvider));
});
