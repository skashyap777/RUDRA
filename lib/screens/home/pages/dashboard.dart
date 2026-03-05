import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/constants/api_constants.dart';
import 'package:rudra/config/utils/app_functions.dart';
import 'package:rudra/config/utils/assets.dart';
import 'package:rudra/screens/home/provider/home_provider.dart';
import 'package:rudra/screens/reports/provider/report_provider.dart' as rudra_report;
import 'package:rudra/screens/reports/models/report_model.dart' as rudra_report;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

// Data model for photo with coordinates
class PotholePhoto {
  final File imageFile;
  final Position? location;
  final String result;
  final DateTime timestamp;

  PotholePhoto({
    required this.imageFile,
    this.location,
    required this.result,
    required this.timestamp,
  });
}

class Dashboard extends StatefulWidget {
  final VoidCallback? onViewAllReports;

  const Dashboard({super.key, this.onViewAllReports});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<PotholePhoto> capturedPhotos = [];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    // Fetch recent reports to display in the list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<rudra_report.ReportProvider>(context, listen: false).fetchReports();
      Provider.of<HomeProvider>(context, listen: false).getUserDetails();
    });
    // Pre-load the model so it's ready when user taps capture
    PotholeDetector.instance.loadModel();
  }

  Future<void> getUserDetails() async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    provider.getUserDetails();
  }

  void _removePhoto(int index) {
    setState(() {
      capturedPhotos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, store, child) {
        return Scaffold(
          backgroundColor: AppPallet.backgroundColor,
          body: Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                decoration: const BoxDecoration(
                  color: AppPallet.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: store.userdetails?.profilePhotoLink != null && store.userdetails?.profilePhotoLink != 'null'
                            ? Image.network(
                                "${ApiConstants.imageBaseUrl}${store.userdetails!.profilePhotoLink}",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    Assets.profile,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                Assets.profile,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back,",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            store.userdetails?.name ?? "User",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Notification Icon could go here
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Camera Card (Full Width - Gallery functionality removed)
                      GestureDetector(
                        onTap: () async {
                          store.clearReportData();
                          final res =
                              await AppFunctions.captureImageFromCamera();
                          if (res != null) {
                            context.push('/scanpothole', extra: res);
                          }
                        },
                        child: Container(
                          height: 240,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF8C300), Color(0xFFFFA000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF8C300).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background decoration icon
                              Positioned(
                                right: -30,
                                bottom: -30,
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 180,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              // Main content - centered
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Large camera icon
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 64,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Title
                                    const Text(
                                      "Capture Pothole",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Subtitle
                                    const Text(
                                      "Tap to open camera",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Recent Captures Header
                      const SizedBox(height: 32),

                      // Recent Reports Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Reports",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppPallet.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (widget.onViewAllReports != null) {
                                widget.onViewAllReports!();
                              }
                            },
                            child: const Text(
                              "View All",
                              style: TextStyle(color: AppPallet.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Recent Reports List using ReportProvider
                      Consumer<rudra_report.ReportProvider>(
                        builder: (context, reportStore, child) {
                          if (reportStore.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppPallet.primaryColor,
                                ),
                              ),
                            );
                          }

                          if (reportStore.reports.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.assignment_outlined,
                                    size: 48,
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "No reports submitted yet",
                                    style: TextStyle(
                                      color: Colors.grey.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Get up to 3 most recent reports
                          final recentReports = reportStore.reports.take(3).toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentReports.length,
                            itemBuilder: (context, index) {
                              final report = recentReports[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report.status ?? '').withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getStatusIcon(report.status ?? ''),
                                      color: _getStatusColor(report.status ?? ''),
                                    ),
                                  ),
                                  title: Text(
                                    _buildShortLocation(report),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppPallet.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          _formatStatus(report.status ?? ''),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _getStatusColor(report.status ?? ''),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _formatShortDate(report.createdAt ?? ''),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppPallet.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 80), // Bottom padding
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

  // --- Helpers for Recent Reports UI ---

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return const Color(0xFF2196F3);
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.file_upload_outlined;
      case 'in_progress':
        return Icons.hourglass_top_rounded;
      case 'completed':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'submitted':
        return 'Submitted';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatShortDate(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return '';
    }
  }

  String _buildShortLocation(rudra_report.Data report) {
    if (report.roadName != null && report.roadName!.isNotEmpty) return report.roadName!;
    if (report.areaDetails != null && report.areaDetails!.isNotEmpty) return report.areaDetails!;
    if (report.districtName != null && report.districtName!.isNotEmpty) return report.districtName!;
    return 'Location not specified';
  }
}

/// Singleton PotholeDetector — loads the model once, reused everywhere.
/// Release-safe: guards against uninitialized interpreter and double-load.
class PotholeDetector {
  // ── Singleton ──────────────────────────────────────────────────────
  static final PotholeDetector instance = PotholeDetector._internal();
  factory PotholeDetector() => instance;
  PotholeDetector._internal();

  // ── State ──────────────────────────────────────────────────────────
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;
  bool _isLoading = false;          // prevents concurrent loadModel() calls
  String _lastError = '';

  final int inputSize = 640;
  final double confidenceThreshold = 0.75;

  String get lastError => _lastError;
  bool get isLoaded => _isLoaded;
  List<String> get labelsList => _labels;
  String get inputInfo => _interpreter != null
      ? 'Interpreter ready'
      : 'Interpreter not created';

  // ── Load Model (idempotent) ────────────────────────────────────────
  Future<void> loadModel() async {
    // Already loaded — nothing to do
    if (_isLoaded && _interpreter != null) return;

    // Another call is already loading — wait for it
    if (_isLoading) {
      // Busy-wait until the other call finishes (max ~10 s)
      for (int i = 0; i < 100; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (_isLoaded || _lastError.isNotEmpty) return;
      }
      return;
    }

    _isLoading = true;
    _lastError = '';

    try {
      // 1. Verify asset bytes exist (catches missing-asset early)
      final modelBytes = await rootBundle.load('assets/model/best_float32.tflite');

      // 2. Create interpreter from asset
      _interpreter = await Interpreter.fromAsset('assets/model/best_float32.tflite');

      // 4. Load labels
      final labelsRaw = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelsRaw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      _isLoaded = true;
    } catch (e, st) {
      _isLoaded = false;
      _interpreter = null;

      if (e.toString().contains('TfLiteModelCreate') ||
          e.toString().contains('symbol not found')) {
        _lastError =
            'TensorFlow Lite native library not linked.\n'
            'Run: cd ios && rm -rf Pods Podfile.lock && pod install\n'
            'Then archive from Xcode.\n\nOriginal: $e';
      } else {
        _lastError = '$e';
      }
      debugPrint('❌ [DETECTOR] $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  // ── Predict ────────────────────────────────────────────────────────
  Future<String> predict(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      return 'Error: Model not loaded';
    }

    try {
      // 1. Load & decode image
      final bytes = await imageFile.readAsBytes();
      final raw = img.decodeImage(bytes);
      if (raw == null) return 'Invalid image';

      // 2. Bake EXIF orientation so portrait photos are correct
      final oriented = img.bakeOrientation(raw);

      // 3. Crop to square (center crop) — YOLO models expect square input
      final int w = oriented.width;
      final int h = oriented.height;
      final int cropSize = w < h ? w : h;
      final int xOffset = ((w - cropSize) / 2).round();
      final int yOffset = ((h - cropSize) / 2).round();
      final cropped = img.copyCrop(
        oriented,
        x: xOffset,
        y: yOffset,
        width: cropSize,
        height: cropSize,
      );

      // 4. Resize to 640x640
      final resized = img.copyResize(cropped, width: inputSize, height: inputSize);

      // 5. Normalize pixels to [0, 1] into a flat Float32List
      final inputBuffer = Float32List(1 * inputSize * inputSize * 3);
      int pixelIndex = 0;
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final p = resized.getPixel(x, y);
          inputBuffer[pixelIndex++] = p.r / 255.0;
          inputBuffer[pixelIndex++] = p.g / 255.0;
          inputBuffer[pixelIndex++] = p.b / 255.0;
        }
      }

      // 6. Reshape input to [1, 640, 640, 3]
      final inputTensor = inputBuffer.reshape([1, inputSize, inputSize, 3]);

      // ── DIAGNOSTIC: Log actual tensor shapes from the interpreter ──
      final inputTensorInfo = _interpreter!.getInputTensor(0);
      final outputTensorInfo = _interpreter!.getOutputTensor(0);
      debugPrint('📐 INPUT tensor shape: ${inputTensorInfo.shape}, type: ${inputTensorInfo.type}');
      debugPrint('📐 OUTPUT tensor shape: ${outputTensorInfo.shape}, type: ${outputTensorInfo.type}');

      final outputShape = outputTensorInfo.shape;
      final int dim1 = outputShape.length >= 2 ? outputShape[1] : 0;
      final int dim2 = outputShape.length >= 3 ? outputShape[2] : 0;

      // 7. Dynamically create output buffer based on ACTUAL model shape
      late List<List<List<double>>> output;
      bool isTransposed = false; // [1, 8400, 5] = transposed

      if (dim1 == 5 && dim2 == 8400) {
        // Standard YOLO: [1, 5, 8400]
        output = List.generate(1, (_) => List.generate(5, (_) => List.filled(8400, 0.0)));
        isTransposed = false;
      } else if (dim1 == 8400 && dim2 == 5) {
        // Transposed: [1, 8400, 5]
        output = List.generate(1, (_) => List.generate(8400, (_) => List.filled(5, 0.0)));
        isTransposed = true;
      } else {
        // Unknown shape — try standard [1, 5, 8400] as fallback
        debugPrint('⚠️ Unexpected output shape: $outputShape, trying [1, 5, 8400]');
        output = List.generate(1, (_) => List.generate(5, (_) => List.filled(8400, 0.0)));
        isTransposed = false;
      }

      // 8. Run inference
      _interpreter!.run(inputTensor, output);

      // ── DIAGNOSTIC: Dump sample raw output values ──
      if (!isTransposed) {
        debugPrint('📊 Sample output[0][0][0..4] (bbox x): ${output[0][0].sublist(0, 5)}');
        debugPrint('📊 Sample output[0][4][0..4] (conf):    ${output[0][4].sublist(0, 5)}');
      } else {
        debugPrint('📊 Sample output[0][0][0..4] (box0):    ${output[0][0]}');
        debugPrint('📊 Sample output[0][1][0..4] (box1):    ${output[0][1]}');
      }

      // 9. Parse YOLO output based on detected shape
      double maxConfidence = 0.0;
      int highConfCount = 0;

      if (!isTransposed) {
        // [1, 5, 8400]: confidence = output[0][4][i]
        for (int i = 0; i < 8400; i++) {
          final double conf = output[0][4][i];
          if (conf > maxConfidence) maxConfidence = conf;
          if (conf > confidenceThreshold) highConfCount++;
        }
      } else {
        // [1, 8400, 5]: confidence = output[0][i][4]
        for (int i = 0; i < 8400; i++) {
          final double conf = output[0][i][4];
          if (conf > maxConfidence) maxConfidence = conf;
          if (conf > confidenceThreshold) highConfCount++;
        }
      }

      final String topLabel = _labels.isNotEmpty ? _labels[0] : 'Pothole';
      final String pct = (maxConfidence * 100).toStringAsFixed(1);

      debugPrint('🔍 Shape: ${isTransposed ? "[1,8400,5]" : "[1,5,8400]"} | Max conf: $pct% | High conf: $highConfCount | Threshold: ${(confidenceThreshold * 100).toStringAsFixed(0)}%');

      // 10. Detection decision
      if (maxConfidence > 0.5 || highConfCount > 0) {
        return '$topLabel detected ($pct%)';
      } else {
        return 'no pothole detected';
      }
    } catch (e) {
      debugPrint('❌ Prediction error: $e');
      return 'Error: $e';
    }
  }

  // ── Dispose (optional — singleton lives for app lifetime) ──────────
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
