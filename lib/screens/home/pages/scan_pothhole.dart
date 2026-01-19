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
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    // Initialize detector and animation
    _setup();
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
    _controller.repeat(
      reverse: true,
    ); // Changed to true to make it bounce back and forth

    // Start processing after initialization
    _startProcessing();
  }

  Future<void> _setup() async {
    try {
      await detector.loadModel();
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        _startProcessing();
      }
    } catch (e) {
      debugPrint("❌ [SCAN] Failed to initialize detector: $e");
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initError = e.toString();
        });
        AppFunctions.showCustomSnackBar(
          context,
          "AI Model failed to load. Please try again.",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _startProcessing() {
    // Wait for animation to run a bit before showing result
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      try {
        debugPrint("🚀 [SCAN] Starting AI processing...");
        final result = await detector.predict(widget.file);
        debugPrint("✅ [SCAN] AI Prediction result: $result");

        if (!mounted) return;

        // Check for error in result
        if (result.startsWith("Error") || result.contains("not ready")) {
          AppFunctions.showCustomSnackBar(
            context,
            "Analysis failed: $result",
            backgroundColor: Colors.red,
          );
          Navigator.pop(context);
          return;
        }

        // Navigate based on detection result
        final isPotholeDetected =
            result.toLowerCase().contains("pothole") &&
            !result.toLowerCase().contains("no pothole");

        if (isPotholeDetected) {
          debugPrint("🎯 [SCAN] Navigating to pothole detected screen");
          context.pushReplacement('/potholeDetected', extra: widget.file);
        } else {
          debugPrint("ℹ️ [SCAN] Navigating to no pothole detected screen");
          context.pushReplacement('/noPotholeDetected', extra: widget.file);
        }
      } catch (e, stackTrace) {
        debugPrint("❌ [SCAN] Error during AI prediction: $e");
        debugPrint("📍 [SCAN] Stack trace: $stackTrace");
        if (mounted) {
          AppFunctions.showCustomSnackBar(
            context,
            "Failed to analyze image. Please try again.",
            backgroundColor: Colors.red,
          );
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
          Text(
            _isInitializing
                ? "Initializing AI..."
                : _initError != null
                ? "Initialization Failed"
                : "Scanning for Road Issue...",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              _initError != null
                  ? "Error: $_initError"
                  : "Please hold steady. We're analyzing the image to detect a road issue.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          if (_initError != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initError = null;
                  });
                  _setup();
                },
                child: const Text("Retry"),
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
