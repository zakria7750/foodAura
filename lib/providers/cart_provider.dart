import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get total => _items.fold(0, (sum, i) => sum + i.product.price * i.quantity);

  CartProvider() { _load(); }

  void addToCart(Product product) {
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    _save();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _save();
    notifyListeners();
  }

  void increment(int productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) { _items[idx].quantity++; _save(); notifyListeners(); }
  }

  void decrement(int productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (_items[idx].quantity <= 1) {
        _items.removeAt(idx);
      } else {
        _items[idx].quantity--;
      }
      _save();
      notifyListeners();
    }
  }

  void clear() { _items.clear(); _save(); notifyListeners(); }

  bool isInCart(int productId) => _items.any((i) => i.product.id == productId);

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((i) => {
      'id': i.product.id, 'name': i.product.name, 'price': i.product.price,
      'category': i.product.category, 'imageUrl': i.product.imageUrl,
      'restaurant': i.product.restaurant, 'rating': i.product.rating,
      'quantity': i.quantity,
    }).toList();
    await prefs.setString('foodaura_cart', jsonEncode(data));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('foodaura_cart');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _items.clear();
      for (final e in list) {
        _items.add(CartItem(
          product: Product(
            id: e['id'], name: e['name'], price: e['price'],
            category: e['category'], imageUrl: e['imageUrl'],
            restaurant: e['restaurant'], rating: e['rating'],
          ),
          quantity: e['quantity'],
        ));
      }
      notifyListeners();
    }
  }
}
