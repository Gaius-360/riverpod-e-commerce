import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_filter.dart';
import '../providers/product_providers.dart';

/// Search field, category chips and sort dropdown driving [productFilterProvider].
class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(productFilterProvider);
    final notifier = ref.read(productFilterProvider.notifier);
    final categories = ref.watch(categoriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: notifier.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort),
                tooltip: 'Trier',
                initialValue: filter.sortOption,
                onSelected: notifier.setSortOption,
                itemBuilder: (context) => SortOption.values
                    .map(
                      (option) => PopupMenuItem(
                        value: option,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = filter.category == category;
              return ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) => notifier.setCategory(category),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
