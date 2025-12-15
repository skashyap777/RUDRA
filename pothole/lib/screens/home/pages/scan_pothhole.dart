import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/config/utils/app_functions.dart';
import 'package:pothole/screens/home/pages/dashboard.dart';

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
    detector.loadModel();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final result = await detector.predict(widget.file);
        AppFunctions.showCustomSnackBar(context, result);
        context.pushReplacement('/potholeDetected', extra: widget.file);
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
            "Scanning for Pothole...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              "Please hold steady. We're analyzing the image to detect a pothole.",
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
