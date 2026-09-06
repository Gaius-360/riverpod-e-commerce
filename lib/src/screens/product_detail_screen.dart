import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_providers.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/async_value_view.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du produit')),
      body: AsyncValueView(
        value: productsAsync,
        onRetry: () => ref.invalidate(productListProvider),
        data: (context, products) {
          final matches = products.where((p) => p.id == widget.productId);
          final product = matches.isEmpty ? null : matches.first;
          if (product == null) {
            return const Center(child: Text('Produit introuvable.'));
          }
          return _ProductDetailBody(
            product: product,
            quantity: _quantity,
            onQuantityChanged: (value) => setState(() => _quantity = value),
          );
        },
      ),
    );
  }
}

class _ProductDetailBody extends ConsumerWidget {
  const _ProductDetailBody({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((favorites) => favorites.contains(product.id)),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ProductImage(imageUrl: product.imageUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(product.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(favoritesProvider.notifier).toggle(product.id),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : null,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text('${product.rating} · ${product.category}'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${product.price.toStringAsFixed(2)} €',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  product.stock > 0 ? '${product.stock} en stock' : 'Rupture de stock',
                  style: TextStyle(
                    color: product.stock > 0 ? Colors.green : Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('Quantité', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
                    ),
                    Text('$quantity', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => onQuantityChanged(quantity + 1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: AddToCartButton(
                    onPressed: product.stock > 0
                        ? () {
                            ref
                                .read(cartProvider.notifier)
                                .addProduct(product, quantity: quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} ajouté au panier'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        : () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
