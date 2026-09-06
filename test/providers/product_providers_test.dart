import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ecommerce/src/models/product_filter.dart';
import 'package:riverpod_ecommerce/src/providers/product_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('filteredProductsProvider filters by category and sorts by price', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(productListProvider.future);

    container.read(productFilterProvider.notifier).setCategory('Sport');
    final sportOnly = container.read(filteredProductsProvider).requireValue;
    expect(sportOnly, isNotEmpty);
    expect(sportOnly.every((p) => p.category == 'Sport'), isTrue);

    container.read(productFilterProvider.notifier).setSortOption(SortOption.priceAsc);
    final sorted = container.read(filteredProductsProvider).requireValue;
    for (var i = 1; i < sorted.length; i++) {
      expect(sorted[i].price, greaterThanOrEqualTo(sorted[i - 1].price));
    }
  });

  test('filteredProductsProvider filters by search query', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(productListProvider.future);

    container.read(productFilterProvider.notifier).setSearchQuery('yoga');
    final results = container.read(filteredProductsProvider).requireValue;

    expect(results, hasLength(1));
    expect(results.single.name.toLowerCase(), contains('yoga'));
  });
}
