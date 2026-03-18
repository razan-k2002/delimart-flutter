import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool isGuest;
  const ProfileScreen({super.key, required this.isGuest});

  @override
  Widget build(BuildContext context) {

    Future<String> getDisplayName() async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return "User";

      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      if (user?.displayName != null && user!.displayName!.isNotEmpty) {
        return user.displayName!;
      } else if (user?.email != null) {
        return user!.email!.split('@')[0];
      }
      return "User";
    }

    Widget buildBody() {
      if (isGuest || FirebaseAuth.instance.currentUser == null) {
        return _buildGuestView(context);
      }

      return FutureBuilder<String>(
        future: getDisplayName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final name = snapshot.data ?? "User";

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 80, color: Colors.grey),
              const SizedBox(height: 10),
              Text(
                "Hello, $name",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF46530),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size(0, 45),
                ),
                child: const Text(
                  "Log Out",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFFD4EDF4),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: buildBody(),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 20),
        const Text(
          "Welcome to DeliMart",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text("Log in to track orders and save your profile"),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF46530),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            "Log in / Create Account",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}