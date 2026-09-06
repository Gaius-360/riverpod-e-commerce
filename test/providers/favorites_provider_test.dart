import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ecommerce/src/providers/favorites_provider.dart';
import 'package:riverpod_ecommerce/src/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('toggle adds and removes a favorite, persisting it to SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(favoritesProvider), isEmpty);

    container.read(favoritesProvider.notifier).toggle('p1');
    expect(container.read(favoritesProvider), {'p1'});
    expect(prefs.getStringList('favorite_product_ids'), ['p1']);

    container.read(favoritesProvider.notifier).toggle('p1');
    expect(container.read(favoritesProvider), isEmpty);
    expect(prefs.getStringList('favorite_product_ids'), isEmpty);
  });

  test('favorites are restored from SharedPreferences on startup', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_product_ids': ['p1', 'p2'],
    });
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(favoritesProvider), {'p1', 'p2'});
  });
}
