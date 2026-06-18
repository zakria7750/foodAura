import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  FavoritesProvider() { _load(); }

  bool isFavorite(int productId) => _favorites.any((p) => p.id == productId);

  void toggle(Product product) {
    if (isFavorite(product.id)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _favorites.map((p) => {
      'id': p.id, 'name': p.name, 'price': p.price, 'category': p.category,
      'imageUrl': p.imageUrl, 'restaurant': p.restaurant, 'rating': p.rating,
    }).toList();
    await prefs.setString('foodaura_favorites', jsonEncode(data));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('foodaura_favorites');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _favorites.clear();
      _favorites.addAll(list.map((e) => Product(
        id: e['id'], name: e['name'], price: e['price'],
        category: e['category'], imageUrl: e['imageUrl'],
        restaurant: e['restaurant'], rating: e['rating'],
      )));
      notifyListeners();
    }
  }
}
