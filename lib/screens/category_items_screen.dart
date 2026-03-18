import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart_provider.dart';
import '../models/product.dart';
import '../data/products_data.dart';
import 'product_detail_screen.dart';

class CategoryItemsScreen extends StatelessWidget {
  final String category;

  const CategoryItemsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryProducts =
    products.where((product) => product.category == category).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: const Color(0xFFD4EDF4),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: categoryProducts.isEmpty
            ? Center(
          child: Text(
            "No  found in $category",
            style: const TextStyle(color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: categoryProducts.length,
          itemBuilder: (context, index) {
            final product = categoryProducts[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailScreen(product: product),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                    // Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                      ),
                      child: Center(
                        child: Image.asset(
                          product.image,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Name & price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2A2E30),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.type == ProductType.weight
                                ? "${product.price} LBP / kg"
                                : "${product.price} LBP",
                            style: const TextStyle(
                              color: Color(0xFFF46530),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Color(0xFFF46530),
                      ),
                      onPressed: () {
                        if (product.type == ProductType.unit) {
                          // Add directly
                          Provider.of<CartProvider>(context, listen: false).addItem({
                            "name": product.name,
                            "price": product.price,
                            "quantity": 1,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${product.name} added to cart")),
                          );
                        } else {
                           _showWeightSelector(context, product);
                        }
                      },
                    ),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
void _showWeightSelector(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select weight",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _weightOption(context, product, 0.5),
            _weightOption(context, product, 1),
            _weightOption(context, product, 2),
          ],
        ),
      );
    },
  );
}

Widget _weightOption(BuildContext context, Product product, double weight) {
  return ListTile(
    title: Text("$weight kg"),
    trailing: Text(
      "${(product.price * weight).toStringAsFixed(0)} LBP",
      style: const TextStyle(
        color: Color(0xFFF46530),
        fontWeight: FontWeight.bold,
      ),
    ),
    onTap: () {
      Provider.of<CartProvider>(context, listen: false).addItem({
        "name": product.name,
        "price": product.price * weight,
        "quantity": "$weight kg",
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${product.name} ($weight kg) added to cart")),
      );
    },
  );
}
