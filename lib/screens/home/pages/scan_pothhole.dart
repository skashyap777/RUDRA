import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/app_functions.dart';
import 'package:rudra/screens/home/pages/dashboard.dart';

class ScanPothhole extends StatefulWidget {
  final File file;
  const ScanPothhole({super.key, required this.file});

  @override
  State<ScanPothhole> createState() => _ScanPothholeState();
}

class _ScanPothholeState extends State<ScanPothhole>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final detector = PotholeDetector();

  @override
  void initState() {
    super.initState();
    // Initialize detector and animation
    _initializeDetector();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1500,
      ), // Faster, smoother animation
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation
    _controller.repeat(reverse: true); // Changed to true to make it bounce back and forth

    // Start processing after initialization
    _startProcessing();
  }

  Future<void> _initializeDetector() async {
    try {
      await detector.loadModel();
      print("Detector initialized successfully");
    } catch (e) {
      print("Failed to initialize detector: $e");
    }
  }

  void _startProcessing() {
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        try {
          print("Starting AI processing...");
          // Use the detector instance that was already initialized
          // Run prediction in background to prevent UI freezing
          final result = await detector.predictInBackground(widget.file);
          print("AI Prediction result: $result");

          // Navigate to appropriate screen based on detection result
          if (result.contains("pothole detected") && !result.contains("No pothole detected")) {
            // Pothole detected - navigate to success screen
            context.pushReplacement('/potholeDetected', extra: widget.file);
          } else {
            // No pothole detected - navigate to info screen
            context.pushReplacement('/noPotholeDetected', extra: widget.file);
          }
        } catch (e) {
          print("Error during AI prediction: $e");
          AppFunctions.showCustomSnackBar(
            context,
            "Failed to analyze image. Please try again.",
            backgroundColor: Colors.red,
          );
          // Navigate back to dashboard on error
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildScannerBorder() {
    return Positioned.fill(child: CustomPaint(painter: ScannerBorderPainter()));
  }

  Widget _buildScannerLine() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 400 * _animation.value, // match image height (400)
          left: 0,
          right: 0,
          child: Container(
            height: 8, // increased thickness
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

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
          "Scanning Pothole Screen",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.file,
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                _buildScannerBorder(),
                _buildScannerLine(),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated ripple effect
                SizedBox(
                  height: 80,
                  width: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: Colors.green.withOpacity(0.5),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                ),

                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Scanning Text
          const Text(
            "Scanning for Road Issue...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "Please hold steady. We're analyzing the image to detect a road issue.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for scanner corners
class ScannerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke;

    double corner = 30; // length of L-shape
    double w = size.width;
    double h = size.height;

    // Top Left
    canvas.drawLine(Offset(0, 0), Offset(corner, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, corner), paint);

    // Top Right
    canvas.drawLine(Offset(w, 0), Offset(w - corner, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, corner), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, h), Offset(corner, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - corner), paint);

    // Bottom Right
    canvas.drawLine(Offset(w, h), Offset(w - corner, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - corner), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}