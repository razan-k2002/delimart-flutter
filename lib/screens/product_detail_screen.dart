import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart_provider.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  double weight = 1.0; // in kg

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFFD4EDF4),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Image.asset(
                  product.image,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(product.name,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              product.type == ProductType.weight
                  ? "${product.price.toStringAsFixed(2)} LBP/kg"
                  : "${product.price.toStringAsFixed(2)} LBP",
              style: const TextStyle(
                  fontSize: 20, color: Color(0xFFF46530)),
            ),
            const SizedBox(height: 20),

            // Quantity / Weight selector
            if (product.type == ProductType.unit)
              Row(
                children: [
                  const Text("Quantity:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text("$quantity", style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () {
                      setState(() => quantity++);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const Text("Weight (kg):",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {
                      if (weight > 0.1) {
                        setState(() => weight -= 0.1);
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text("${weight.toStringAsFixed(1)}",
                      style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () {
                      setState(() => weight += 0.1);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);

                  if (product.type == ProductType.unit) {
                    cartProvider.addItem({
                      "name": product.name,
                      "price": product.price,
                      "quantity": quantity,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "$quantity x ${product.name} added to cart")));
                  } else {
                    cartProvider.addItem({
                      "name": product.name,
                      "price": product.price,
                      "weight": weight,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "${weight.toStringAsFixed(1)} kg of ${product.name} added to cart")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF46530),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
