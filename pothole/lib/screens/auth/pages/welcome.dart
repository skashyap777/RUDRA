import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/config/utils/assets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PWD Logo
              Image.asset(
                Assets.logo, // Replace with your asset path
                height: 100,
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Welcome to PWD Assam',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Sub-title (Thanks message)
              const Text(
                'Thanks for joining us',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              const Text(
                'Let’s work together to make our roads safer.\nStart by reporting a pothole near you.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.go("/home");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallet.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
