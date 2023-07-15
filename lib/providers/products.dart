import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  final String _url = 'https://dummyjson.com/products';
  List<Product> _items = [];

  List<Product> get items => [..._items];

  int get itemsCount {
    return _items.length;
  }

  Future<void> loadProducts() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load products');
      }
      if (response.body == null || response.body.isEmpty) {
        throw Exception('Empty response body');
      }
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic>? productsData = responseData['products'];
      if (productsData == null) {
        throw Exception('Missing products data');
      }
      _items.clear();
      _items = productsData.map((productData) {
        return Product(
          id: productData['id'].toString(),
          title: productData['title'],
          description: productData['description'],
          price: productData['price'].toDouble(),
          discountPercentage: productData['discountPercentage'].toDouble(),
          rating: productData['rating'].toDouble(),
          stock: productData['stock'],
          brand: productData['brand'],
          category: productData['category'],
          thumbnail: productData['thumbnail'],
          image: productData['images'][0],
        );
      }).toList();

      notifyListeners();
      return Future.value();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> addProduct(Product newProduct) async {
    try {
      final response = await http.post(
        Uri.parse('$_url/add'),
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'image': newProduct.image,
        }),
      );

      _items.add(Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        discountPercentage: newProduct.discountPercentage,
        rating: newProduct.rating,
        stock: newProduct.stock,
        brand: newProduct.brand,
        category: newProduct.category,
        thumbnail: newProduct.thumbnail,
        image: newProduct.image,
      ));
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  void updateProduct(Product product) {
    if (product == null || product.id == null) {
      return;
    }

    final index = _items.indexWhere((prod) => prod.id == product.id);
    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();
    }
  }
}
