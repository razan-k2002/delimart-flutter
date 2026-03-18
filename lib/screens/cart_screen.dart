import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'checkout_screen.dart';
import 'package:provider/provider.dart';
import '../cart_provider.dart';

class CartScreen extends StatelessWidget {
  final bool isGuest;
  const CartScreen({super.key, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;
    final deliveryFee = cartProvider.deliveryFee;
    final subtotal = cartProvider.subtotal;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        backgroundColor: const Color(0xFFD4EDF4),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // CART ITEMS
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(child: Text("Your cart is empty"))
                  : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (_, index) {
                  final item = cartItems[index];
                  final isWeight = item.containsKey("unit") ? item["unit"] == "kg" : item.containsKey("weight");
                  double quantity = double.tryParse(item["quantity"].toString()) ?? 1.0;
                  final double unitPrice = double.tryParse(item["unitPrice"].toString()) ?? 0.0;
                  final subtotalItem = unitPrice * quantity;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"] ?? "Unnamed",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A2E30),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (isWeight) ...[
                                    SizedBox(
                                      height: 22,
                                      child: ElevatedButton(
                                        onPressed: () => _showWeightModal(context, index, item),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFF46530),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          "Weight",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    isWeight
                                        ? "${quantity.toStringAsFixed(2)} kg"
                                        : "Quantity: ${quantity.toInt()}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              if (!isWeight)
                                Row(
                                  children: [
                                    _QtyButton(
                                      icon: Icons.remove,
                                      onTap: () => cartProvider.decreaseQuantity(index),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        quantity.toInt().toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    _QtyButton(
                                      icon: Icons.add,
                                      onTap: () => cartProvider.increaseQuantity(index),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // PRICE AND REMOVE BUTTON
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => cartProvider.removeItem(index),
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${subtotalItem.toStringAsFixed(0)} LBP",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF46530),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Column(
              children: [
                _PriceRow("Subtotal", subtotal),
                _PriceRow("Delivery", deliveryFee),
                const Divider(height: 30),
                _PriceRow("Total", total, isTotal: true),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        isGuest: isGuest,
                        cartItems: cartItems,
                        subtotal: subtotal,
                        deliveryFee: deliveryFee,
                        total: total,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF46530),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Proceed to Checkout",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Quantity Button
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFD4EDF4),
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}


// PRICE ROW WIDGET
class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _PriceRow(this.label, this.value, {this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            "${value.toStringAsFixed(0)} LBP",
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFFF46530) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// WEIGHT MODAL

void _showWeightModal(BuildContext context, int index, Map item) {
  double currentWeight = (item["quantity"] ?? 0.0).toDouble();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      double selectedWeight = currentWeight;

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Weight",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  "${selectedWeight.toStringAsFixed(2)} kg",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF46530),
                  ),
                ),
                Slider(
                  value: selectedWeight,
                  min: 0.25,
                  max: 5.0,
                  divisions: 19,
                  activeColor: const Color(0xFFF46530),
                  onChanged: (value) {
                    setState(() {
                      selectedWeight = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF46530),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .updateWeight(index, selectedWeight);
                      Navigator.pop(context);
                    },
                    child: const Text("Confirm Weight", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}