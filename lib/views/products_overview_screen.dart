import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/product_grid_item.dart';
import '../widgets/product_grid.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
import '../providers/cart.dart';
import '../utils/app_routes.dart';
import '../widgets/search_box.dart';

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isLoading = true;
  String? _selectedCategory;
  String _searchTerm = '';
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    Provider.of<Products>(context, listen: false).loadProducts().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse('https://dummyjson.com/products/categories');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as List<dynamic>;
      final categories = extractedData.cast<String>();
      setState(() {
        _categories = categories;
      });
    } catch (error) {
      print(error);
      throw error;
    }
  }

  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedCategory = null;
    });
  }

  void _searchProducts(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Loja'),
        actions: <Widget>[
          SearchBox(onSearch: _searchProducts),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filtrar por Categoria',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                child: Text(
                                  'Limpar',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: _clearFilter,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _categories.length,
                            itemBuilder: (ctx, index) {
                              final category = _categories[index];
                              return ListTile(
                                title: Text(category),
                                onTap: () {
                                  _selectCategory(category);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Consumer<Cart>(
            builder: (ctx, cart, _) => TextButton(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.shopping_cart,
                    color: Theme.of(context).hintColor,
                  ),
                  Text(
                    '${cart.itemsCount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.CART);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ProductGrid(
        selectedCategory: _selectedCategory,
        searchTerm: _searchTerm,
      ),
      drawer: AppDrawer(),
    );
  }
}
