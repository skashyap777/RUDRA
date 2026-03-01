import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/app_functions.dart';
import 'package:rudra/screens/home/provider/home_provider.dart';
import 'package:provider/provider.dart';

class PotholeDetectedScreen extends StatelessWidget {
  final File file;
  const PotholeDetectedScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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
              if (homeProvider.potholeImages.length > 1)
                SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...homeProvider.potholeImages.map((image) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              image,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Success Icon
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Pothole Detected Successfully!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "The scanned image shows a clear road issue.",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),

              const Spacer(),

              // Buttons
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: AppPallet.buttonColor),
                        ),
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          // Show iOS-style loading
                          showCupertinoDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CupertinoActivityIndicator(radius: 16),
                            ),
                          );
                          homeProvider.addPotholeImage(file);
                          await homeProvider.addCurrentCordinate();
                          
                          if (context.mounted) {
                            Navigator.pop(context); // close dialog
                            final res = await AppFunctions.captureImageFromCamera();
                            if (res != null) {
                              context.pushReplacement('/scanpothole', extra: res);
                            }
                          }
                        },
                        child: const Text(
                          "Add More Images",
                          style: TextStyle(color: AppPallet.buttonColor),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: AppPallet.buttonColor,
                        ),
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          // Show iOS-style loading
                          showCupertinoDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CupertinoActivityIndicator(radius: 16),
                            ),
                          );
                          homeProvider.addPotholeImage(file);
                          await homeProvider.addCurrentCordinate();
                          
                          if (context.mounted) {
                            Navigator.pop(context); // close dialog
                            context.push('/addPothole');
                          }
                        },
                        child: const Text("Continue"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
