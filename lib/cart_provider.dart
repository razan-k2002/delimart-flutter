import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> item) {
    final index = _items.indexWhere((i) => i["name"] == item["name"]);

    final incomingQty = (item['quantity'] ?? item['weight'] ?? 1.0).toDouble();

    if (index >= 0) {

      final existingItem = Map<String, dynamic>.from(_items[index]);

      final isWeightItem = item.containsKey('weight') || (existingItem['unit'] == 'kg');

      if (isWeightItem) {
        final currentQty = (existingItem['quantity'] ?? 0.0).toDouble();
        existingItem['quantity'] = currentQty + incomingQty;
      } else {
        final currentQty = (existingItem['quantity'] ?? 0.0).toDouble();
        existingItem['quantity'] = currentQty + incomingQty;
      }
      _items[index] = existingItem;

    } else {

      _items.add({
        ...item,
        "unitPrice": (item['price'] ?? item['unitPrice'] ?? 0.0).toDouble(),
        "quantity": incomingQty,
        "unit": item.containsKey('weight') ? 'kg' : 'piece',
      });
    }

    notifyListeners();
  }


  double get subtotal {
    double sum = 0;
    for (var item in _items) {
      final price = (item["unitPrice"] ?? 0.0).toDouble();
      final quantity = (item["quantity"] ?? 0.0).toDouble();
      sum += price * quantity;
    }
    return sum;
  }
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void increaseQuantity(int index) {
    final currentItem = Map<String, dynamic>.from(_items[index]);
    double currentQty = (currentItem["quantity"] ?? 1.0).toDouble();

    currentItem["quantity"] = currentQty + 1.0;
    _items[index] = currentItem;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    final currentItem = Map<String, dynamic>.from(_items[index]);
    double currentQty = (currentItem["quantity"] ?? 1.0).toDouble();

    if (currentQty > 1.0) {
      currentItem["quantity"] = currentQty - 1.0;
      _items[index] = currentItem;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void updateWeight(int index, double newWeightKg) {
    final currentItem = Map<String, dynamic>.from(_items[index]);
    currentItem["quantity"] = newWeightKg;
    _items[index] = currentItem;
    notifyListeners();
  }

  double get deliveryFee => 200000.0;

  double get total => subtotal + deliveryFee;

  void clear() {
    _items.clear();
    notifyListeners();
  }
}