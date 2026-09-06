import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/product.dart';

/// Fetches the product catalog.
///
/// This mimics a remote API: the data actually lives in a bundled JSON
/// asset, but it is read asynchronously and an artificial delay is added
/// so the UI has to genuinely handle loading / error states through
/// [AsyncValue] rather than assuming data is always instantly available.
class ProductRepository {
  const ProductRepository();

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 700));

    final raw = await rootBundle.loadString('assets/data/products.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
