import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pothole/config/utils/assets.dart';
import 'package:pothole/config/utils/local_storage.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      checkLogin();
    });
  }

  Future<void> checkLogin() async {
    final token = await TokenHandler.getString("token");
    if (token.isNotEmpty) {
      context.go("/home");
    } else {
      context.go("/onboarding");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    Assets.logo, // Replace with Assets.logo if using constant
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),

                // App Title
                const Text(
                  "Pothole Reporting App",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
