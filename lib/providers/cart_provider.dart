import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  static const _storageKey = 'khyate_cart_items';

  final List<CartItem> _items = [];
  SharedPreferences? _prefs;

  CartProvider() {
    _restoreCart();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalPrice {
    int sum = 0;
    for (var item in _items) {
      sum += item.price;
    }
    return sum;
  }

  void addItem(CartItem item) {
    _items.add(item);
    _persistCart();
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _persistCart();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _persistCart();
    notifyListeners();
  }

  void _restoreCart() {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      final stored = prefs.getStringList(_storageKey);
      if (stored == null || stored.isEmpty) return;

      final restoredItems = stored
          .map((encoded) => CartItem.fromMap(jsonDecode(encoded) as Map<String, dynamic>))
          .toList();
      _items
        ..clear()
        ..addAll(restoredItems);
      notifyListeners();
    });
  }

  void _persistCart() {
    final encodedItems = _items.map((item) => jsonEncode(item.toMap())).toList();
    if (_prefs != null) {
      _prefs!.setStringList(_storageKey, encodedItems);
    } else {
      SharedPreferences.getInstance().then((prefs) {
        _prefs = prefs;
        prefs.setStringList(_storageKey, encodedItems);
      });
    }
  }
}
