import 'dart:io';
import 'package:flutter/material.dart';
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

  bool _isInitializing = true;
  String? _initError;
  String? _scanError;
  bool _hasStartedProcessing = false;
  bool _showDebugLog = false;

  // On-screen debug log entries
  final List<_DebugEntry> _debugLog = [];

  void _log(String message, {bool isError = false, bool isSuccess = false}) {
    final entry = _DebugEntry(
      time: DateTime.now(),
      message: message,
      isError: isError,
      isSuccess: isSuccess,
    );
    if (mounted) {
      setState(() {
        _debugLog.add(entry);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    _log('🔄 Platform: ${Platform.operatingSystem}');
    _log('🔄 Image: ${widget.file.path.split('/').last}');
    _log('🔄 Image size: ${widget.file.lengthSync()} bytes');

    // Single entry point: load model then process
    _setup();
  }

  Future<void> _setup() async {
    try {
      _log('🔄 Loading AI model…');

      final detector = PotholeDetector.instance;

      if (detector.isLoaded) {
        _log('✅ Model already loaded (cached)', isSuccess: true);
      } else {
        _log('🔄 First time loading — creating interpreter…');
      }

      await detector.loadModel();

      if (!mounted) return;

      _log('✅ Model loaded successfully', isSuccess: true);
      _log('✅ Labels: ${detector.labelsList.join(", ")}', isSuccess: true);
      _log('✅ Input size: ${detector.inputSize}x${detector.inputSize}', isSuccess: true);
      _log('✅ Confidence threshold: ${detector.confidenceThreshold}', isSuccess: true);

      setState(() {
        _isInitializing = false;
      });

      // Only start processing ONCE after model is ready
      _startProcessing();
    } catch (e, st) {
      _log('❌ MODEL LOAD FAILED', isError: true);
      _log('❌ Error: $e', isError: true);
      _log('❌ Stack: ${st.toString().split('\n').take(3).join('\n')}', isError: true);

      // Categorize error for user
      final errorStr = e.toString();
      String userFriendlyError;
      if (errorStr.contains('TfLiteModelCreate') || errorStr.contains('symbol not found')) {
        userFriendlyError = 'TensorFlow Lite native library not linked.\n\n'
            'Fix: On Mac, run:\n'
            '  cd ios\n'
            '  rm -rf Pods Podfile.lock\n'
            '  pod install\n'
            '  Then archive from Xcode.';
        _log('❌ Cause: TFLite native symbols missing', isError: true);
      } else if (errorStr.contains('not found') || errorStr.contains('Unable to open')) {
        userFriendlyError = 'Model file not found in app bundle.';
        _log('❌ Cause: Model asset missing from bundle', isError: true);
      } else {
        userFriendlyError = PotholeDetector.instance.lastError.isNotEmpty
            ? PotholeDetector.instance.lastError
            : e.toString();
      }

      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _initError = userFriendlyError;
        _showDebugLog = true; // Auto-show debug log on error
      });
    }
  }

  void _startProcessing() {
    // Guard: only run once
    if (_hasStartedProcessing) return;
    _hasStartedProcessing = true;

    _log('🔄 Starting image analysis…');

    // Brief delay for the scan animation to play
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      try {
        _log('🔄 Reading image bytes…');
        final fileSize = await widget.file.length();
        _log('🔄 File size: ${(fileSize / 1024).toStringAsFixed(1)} KB');

        _log('🔄 Running AI prediction…');
        final stopwatch = Stopwatch()..start();
        final result = await PotholeDetector.instance.predict(widget.file);
        stopwatch.stop();

        _log('✅ Prediction completed in ${stopwatch.elapsedMilliseconds}ms', isSuccess: true);
        _log('✅ Raw result: "$result"', isSuccess: true);

        if (!mounted) return;

        // Check for error in result
        if (result.startsWith("Error") || result.contains("not loaded")) {
          _log('❌ Prediction returned error: $result', isError: true);
          setState(() {
            _scanError = result;
            _showDebugLog = true;
          });
          return;
        }

        // Navigate based on result
        final isPotholeDetected =
            result.toLowerCase().contains("pothole") &&
            !result.toLowerCase().startsWith("no pothole");

        if (isPotholeDetected) {
          _log('🎯 POTHOLE DETECTED → navigating', isSuccess: true);
          if (mounted) {
            context.pushReplacement('/potholeDetected', extra: widget.file);
          }
        } else {
          _log('ℹ️ No pothole detected → navigating');
          if (mounted) {
            context.pushReplacement('/noPotholeDetected', extra: widget.file);
          }
        }
      } catch (e, st) {
        _log('❌ PREDICTION CRASHED', isError: true);
        _log('❌ Error: $e', isError: true);
        _log('❌ Stack: ${st.toString().split('\n').take(3).join('\n')}', isError: true);

        if (mounted) {
          setState(() {
            _scanError = e.toString();
            _showDebugLog = true;
          });
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
          top: 400 * _animation.value,
          left: 0,
          right: 0,
          child: Container(
            height: 8,
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

  /// On-screen debug log panel
  Widget _buildDebugPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Debug Log',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_debugLog.length} entries',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Log entries
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: _debugLog.length,
              itemBuilder: (context, index) {
                final entry = _debugLog[index];
                final timeStr =
                    '${entry.time.hour.toString().padLeft(2, '0')}:'
                    '${entry.time.minute.toString().padLeft(2, '0')}:'
                    '${entry.time.second.toString().padLeft(2, '0')}.'
                    '${entry.time.millisecond.toString().padLeft(3, '0')}';

                Color textColor;
                if (entry.isError) {
                  textColor = const Color(0xFFFF6B6B);
                } else if (entry.isSuccess) {
                  textColor = const Color(0xFF69DB7C);
                } else {
                  textColor = const Color(0xFFCCC);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '[$timeStr] ',
                          style: const TextStyle(color: Colors.white38),
                        ),
                        TextSpan(
                          text: entry.message,
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _initError != null || _scanError != null;
    final errorTitle = _initError != null
        ? 'Model Failed to Load'
        : 'Scan Failed';
    final errorDetail = _initError ?? _scanError ?? '';

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
          "Scanning Pothole",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Image with scanner overlay
            if (!hasError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        widget.file,
                        height: _showDebugLog ? 200 : 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    _buildScannerBorder(),
                    if (!_showDebugLog) _buildScannerLine(),
                  ],
                ),
              ),

            if (!hasError) ...[
              const SizedBox(height: 20),

              // Loading spinner
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Colors.green.withOpacity(0.5),
                        backgroundColor: Colors.green.withOpacity(0.1),
                      ),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: const Icon(
                        Icons.document_scanner_outlined,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _isInitializing
                    ? "Initializing AI…"
                    : "Scanning for Road Issue…",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  "Please hold steady. Analyzing the image…",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],

            // ── Error State ──────────────────────────────────────────
            if (hasError) ...[
              const SizedBox(height: 20),

              // Error image (small)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    widget.file,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Error icon
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red.withOpacity(0.1),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                errorTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),

              // Error details in a styled container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Text(
                  errorDetail,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isInitializing = true;
                            _initError = null;
                            _scanError = null;
                            _hasStartedProcessing = false;
                            _debugLog.clear();
                          });
                          _setup();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallet.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text("Go Back"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppPallet.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: AppPallet.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Debug Log Panel ────────────────────────────────────
            if (_showDebugLog) _buildDebugPanel(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Single debug log entry
class _DebugEntry {
  final DateTime time;
  final String message;
  final bool isError;
  final bool isSuccess;

  _DebugEntry({
    required this.time,
    required this.message,
    this.isError = false,
    this.isSuccess = false,
  });
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

    double corner = 30;
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
