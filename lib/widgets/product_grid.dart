import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_grid_item.dart';
import '../providers/products.dart';

class ProductGrid extends StatelessWidget {
  final String? selectedCategory;
  final String searchTerm;

  ProductGrid({this.selectedCategory, required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<Products>(context);
    final products = productsProvider.items.where((product) {
      if (selectedCategory != null && product.category != selectedCategory) {
        return false;
      }
      if (searchTerm.isNotEmpty &&
          !product.title.toLowerCase().contains(searchTerm.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductGridItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
