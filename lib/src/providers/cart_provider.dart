import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Owns the shopping cart contents and every mutation performed on it.
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  void addProduct(Product product, {int quantity = 1}) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      state = [...state, CartItem(product: product, quantity: quantity)];
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == product.id)
          item.copyWith(quantity: item.quantity + quantity)
        else
          item,
    ];
  }

  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void incrementQuantity(String productId) {
    final item = state.firstWhere((item) => item.product.id == productId);
    setQuantity(productId, item.quantity + 1);
  }

  void decrementQuantity(String productId) {
    final item = state.firstWhere((item) => item.product.id == productId);
    setQuantity(productId, item.quantity - 1);
  }

  void clear() {
    state = const [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// Total number of items in the cart (sum of quantities), used for the
/// badge on the cart tab.
final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (total, item) => total + item.quantity);
});

/// Total price of everything currently in the cart.
final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<double>(0, (total, item) => total + item.subtotal);
});
