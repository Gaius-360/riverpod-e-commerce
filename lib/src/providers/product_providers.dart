import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../models/product_filter.dart';
import 'repository_providers.dart';

/// Raw product catalog, fetched asynchronously. UI layers consume this
/// through [AsyncValue] to render loading / error / data states.
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProducts();
});

/// Holds the user's current search / category / sort choices.
class ProductFilterNotifier extends StateNotifier<ProductFilter> {
  ProductFilterNotifier() : super(const ProductFilter());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void reset() {
    state = const ProductFilter();
  }
}

final productFilterProvider =
    StateNotifierProvider<ProductFilterNotifier, ProductFilter>((ref) {
  return ProductFilterNotifier();
});

/// All distinct categories available in the catalog, plus "Tous" first.
final categoriesProvider = Provider<List<String>>((ref) {
  final products = ref.watch(productListProvider).valueOrNull ?? const [];
  final categories = products.map((p) => p.category).toSet().toList()
    ..sort();
  return [kAllCategories, ...categories];
});

/// The catalog after applying the current search query, category filter and
/// sort order. Stays an [AsyncValue] so the UI keeps handling loading/error
/// uniformly, while the actual filtering/sorting logic lives here instead of
/// in a widget.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final filter = ref.watch(productFilterProvider);
  return ref.watch(productListProvider).whenData((products) {
    var result = products.where((product) {
      final matchesCategory =
          filter.category == kAllCategories || product.category == filter.category;
      final matchesQuery = filter.searchQuery.isEmpty ||
          product.name.toLowerCase().contains(filter.searchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    switch (filter.sortOption) {
      case SortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.ratingDesc:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case SortOption.relevance:
        break;
    }
    return result;
  });
});
