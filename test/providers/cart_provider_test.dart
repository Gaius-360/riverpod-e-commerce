import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_ecommerce/src/models/product.dart';
import 'package:riverpod_ecommerce/src/providers/cart_provider.dart';

const _product = Product(
  id: 'p1',
  name: 'Test Product',
  description: 'A product used for testing.',
  price: 10,
  imageUrl: 'https://example.com/image.png',
  category: 'Test',
  rating: 4.0,
  stock: 5,
);

void main() {
  test('addProduct adds a new line item, then increments quantity on repeat', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(cartProvider.notifier).addProduct(_product);
    expect(container.read(cartProvider).single.quantity, 1);

    container.read(cartProvider.notifier).addProduct(_product);
    expect(container.read(cartProvider).single.quantity, 2);
    expect(container.read(cartItemCountProvider), 2);
    expect(container.read(cartTotalProvider), 20);
  });

  test('setQuantity to zero removes the item', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(cartProvider.notifier).addProduct(_product, quantity: 3);
    container.read(cartProvider.notifier).setQuantity(_product.id, 0);

    expect(container.read(cartProvider), isEmpty);
    expect(container.read(cartTotalProvider), 0);
  });

  test('clear empties the cart', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(cartProvider.notifier).addProduct(_product, quantity: 2);
    container.read(cartProvider.notifier).clear();

    expect(container.read(cartProvider), isEmpty);
  });
}
