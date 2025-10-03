import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/app_functions.dart';

class NoPotholeDetectedScreen extends StatelessWidget {
  final File file;
  const NoPotholeDetectedScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppPallet.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Scan Result",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Info Icon
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: const Icon(Icons.info, color: Colors.orange, size: 50),
          ),

          const SizedBox(height: 20),

          const Text(
            "No Pothole Detected",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "The scanned image does not show a clear road issue. Please try again with a different image.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),

          const Spacer(),

          // Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppPallet.buttonColor),
                    ),
                    onPressed: () async {
                      final res = await AppFunctions.captureImageFromCamera();
                      if (res != null) {
                        context.pushReplacement('/scanpothole', extra: res);
                      }
                    },
                    child: const Text(
                      "Try Again",
                      style: TextStyle(color: AppPallet.buttonColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppPallet.buttonColor,
                    ),
                    onPressed: () {
                      // Navigate back to home/dashboard
                      Navigator.pop(context);
                    },
                    child: const Text("Back to Home"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
