/// Ways the catalog can be sorted.
enum SortOption {
  relevance('Pertinence'),
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  nameAsc('Nom (A-Z)'),
  ratingDesc('Meilleures notes');

  const SortOption(this.label);
  final String label;
}

/// Value used by "All categories".
const String kAllCategories = 'Tous';

/// Immutable state describing the current search / filter / sort choices.
class ProductFilter {
  const ProductFilter({
    this.searchQuery = '',
    this.category = kAllCategories,
    this.sortOption = SortOption.relevance,
  });

  final String searchQuery;
  final String category;
  final SortOption sortOption;

  ProductFilter copyWith({
    String? searchQuery,
    String? category,
    SortOption? sortOption,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
