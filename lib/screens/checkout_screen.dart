import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cart_provider.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final bool isGuest;
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double deliveryFee;
  final double total;

  CheckoutScreen({
    super.key,
    required this.isGuest,
    required this.cartItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  late final String orderId;

  @override
  void initState() {
    super.initState();
    orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";

    if (!widget.isGuest) {
      final user = FirebaseAuth.instance.currentUser;
      emailController.text = user?.email ?? "";
      nameController.text = user?.displayName ?? "";
    }
  }

  String _formattedTimestamp() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year} "
        "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}";
  }

  double get total =>
      widget.cartItems.fold(
        0.0,
            (sum, item) =>
        sum +
            ((item['unitPrice'] ?? 0.0) * (item['quantity'] ?? 0.0)),
      ) +
          widget.deliveryFee;

  String _buildWhatsAppMessage() {
    String message = "🛒 *New Order*\n\n";
    message += "📦 Order ID: $orderId\n";
    message += "🕒 Time: ${_formattedTimestamp()}\n\n";

    for (var item in widget.cartItems) {
      final name = item["name"];
      final unit = item["unit"];
      final qty = (item["quantity"] ?? 0).toDouble();

      if (unit == "kg") {
        message += "• $name: ${qty.toStringAsFixed(2)} kg\n";
      } else {
        message += "• $name: ${qty.toInt()} pcs\n";
      }
    }

    message += "\nSubtotal: ${widget.subtotal.toStringAsFixed(0)} LBP";
    message += "\nDelivery: ${widget.deliveryFee.toStringAsFixed(0)} LBP";
    message += "\n*Total: ${total.toStringAsFixed(0)} LBP*\n\n";

    message += "👤 Name: ${nameController.text}\n";
    message += "📞 Phone: ${phoneController.text}\n";
    message += "📧 Email: ${emailController.text}";

    return message;
  }

  Future<void> _sendOrderViaWhatsApp() async {
    const businessPhone = "96171513505"; // no +
    final message = _buildWhatsAppMessage();

    final url = Uri.parse(
      "https://wa.me/$businessPhone?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open WhatsApp")),
      );
    }
  }

  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.isGuest) {
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await userCredential.user?.updateDisplayName(nameController.text.trim());
        await userCredential.user?.reload();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final ordersRef = FirebaseFirestore.instance
          .collection("orders")
          .doc(user.uid)
          .collection("userOrders");

      await ordersRef.add({
        "orderId": orderId,
        "items": widget.cartItems,
        "subtotal": widget.subtotal,
        "deliveryFee": widget.deliveryFee,
        "total": total,
        "timestamp": FieldValue.serverTimestamp(),
        "customerName": nameController.text.trim(),
        "customerEmail": emailController.text.trim(),
        "customerPhone": phoneController.text.trim(),
      });

      await _sendOrderViaWhatsApp();

      Provider.of<CartProvider>(context, listen: false).clearCart();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const OrdersScreen(isGuest: false)),
              (route) => route.isFirst,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: const Color(0xFFD4EDF4),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v == null || v.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter your email" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter your phone" : null,
              ),
              const SizedBox(height: 16),
              if (widget.isGuest)
                TextFormField(
                  controller: passwordController,
                  decoration:
                  const InputDecoration(labelText: "Create Password"),
                  obscureText: true,
                  validator: (v) =>
                  v == null || v.length < 6 ? "Min 6 characters" : null,
                ),
              const SizedBox(height: 16),
              Text(
                "Total: ${total.toStringAsFixed(2)} LBP",
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF46530),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.isGuest
                        ? "Create Account & Checkout"
                        : "Checkout",
                    style: const TextStyle(
                        fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}