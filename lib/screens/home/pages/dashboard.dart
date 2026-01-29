import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/app_functions.dart';
import 'package:rudra/config/utils/assets.dart';
import 'package:rudra/screens/home/provider/home_provider.dart';
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
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final detector = PotholeDetector();
  List<PotholePhoto> capturedPhotos = [];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    detector.loadModel();
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
                        child:
                            store.loading
                                ? const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                                : Image.network(
                                  "${Constants.baseUrl}${store.userdetails?.profilePhotoLink}",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      Assets.profile,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    );
                                  },
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Captures",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppPallet.textPrimary,
                            ),
                          ),
                          if (capturedPhotos.isNotEmpty)
                            Text(
                              "${capturedPhotos.length} items",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppPallet.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Processing Indicator
                      if (isProcessing)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Processing image..."),
                            ],
                          ),
                        ),

                      // Photos List
                      if (capturedPhotos.isEmpty)
                        Container(
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
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.grey.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No photos captured yet",
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: capturedPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = capturedPhotos[index];
                            final isPothole = photo.result.contains('Pothole');
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
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    photo.imageFile,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  photo.result,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isPothole
                                            ? Colors.red
                                            : AppPallet.primaryColor,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    photo.timestamp.toString().substring(0, 16),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppPallet.textSecondary,
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () => _removePhoto(index),
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 80), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton:
              capturedPhotos.isNotEmpty
                  ? FloatingActionButton.extended(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Submit functionality to be implemented',
                          ),
                        ),
                      );
                    },
                    backgroundColor: AppPallet.primaryColor,
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text("Submit Reports"),
                  )
                  : null,
        );
      },
    );
  }

  @override
  void dispose() {
    detector.dispose();
    super.dispose();
  }
}

class PotholeDetector {
  late Interpreter _interpreter;
  late List<String> _labels;
  String? _lastError; // Store detailed error info
  bool _isLoaded = false;

  final int inputSize = 640;
  final double confidenceThreshold = 0.3;

  // Get detailed error information
  String get lastError => _lastError ?? "No error information available";
  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      _lastError = null;
      debugPrint("🔄 [DEBUG] Starting model loading...");
      debugPrint("🔄 [DEBUG] Platform: ${Platform.operatingSystem}");
      
      // Check if model file exists
      try {
        final modelBytes = await rootBundle.load('assets/model/best_float32.tflite');
        debugPrint("✅ [DEBUG] Model file found: ${modelBytes.lengthInBytes} bytes");
      } catch (e) {
        _lastError = "Model file 'assets/model/best_float32.tflite' not found: $e";
        throw Exception(_lastError);
      }
      
      // Check if labels file exists
      try {
        final labelsString = await rootBundle.loadString('assets/model/labels.txt');
        debugPrint("✅ [DEBUG] Labels file found: ${labelsString.length} characters");
      } catch (e) {
        _lastError = "Labels file 'assets/model/labels.txt' not found: $e";
        throw Exception(_lastError);
      }
      
      // Load TFLite interpreter
      try {
        _interpreter = await Interpreter.fromAsset('assets/model/best_float32.tflite');
        debugPrint("✅ [DEBUG] TFLite interpreter created successfully");
      } catch (e) {
        _lastError = "Failed to create TFLite interpreter (TensorFlow Lite library issue): $e";
        throw Exception(_lastError);
      }
      
      // Load labels
      try {
        _labels = (await rootBundle.loadString('assets/model/labels.txt'))
            .split('\n')
            .where((e) => e.trim().isNotEmpty)
            .toList();
        debugPrint("✅ [DEBUG] Labels loaded: ${_labels.length} labels: $_labels");
      } catch (e) {
        _lastError = "Failed to parse labels file: $e";
        throw Exception(_lastError);
      }
      
      _isLoaded = true;
      debugPrint("✅ [DEBUG] Model loaded successfully!");
      
    } catch (e) {
      _isLoaded = false;
      if (_lastError == null) {
        _lastError = "Unknown error: $e";
      }
      debugPrint("❌ [DEBUG] Model loading failed: $_lastError");
      throw Exception("AI Model Loading Failed: $_lastError");
    }
  }

  Future<String> predict(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final raw = img.decodeImage(bytes);
    if (raw == null) return "Invalid image";

    final resized = img.copyResize(raw, width: inputSize, height: inputSize);

    // Build input: shape [1, 640, 640, 3]
    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(inputSize, (y) {
        return List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;
          return [r, g, b];
        });
      }),
    );

    // Correct output buffer: shape [1, 5, 8400]
    final output = List.generate(
      1,
      (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
    );

    _interpreter.run(input, output);

    final results = output[0]; // Shape: [5, 8400]
    String? topLabel;
    double maxConfidence = 0.0;

    for (int i = 0; i < 8400; i++) {
      final confidence = results[4][i];

      if (confidence < confidenceThreshold) continue;
      if (confidence > maxConfidence) {
        maxConfidence = confidence;
        topLabel = _labels.isNotEmpty ? _labels[0] : "Pothole";
      }
    }

    if (topLabel != null && (maxConfidence * 100) > 50.0) {
      return "$topLabel (${(maxConfidence * 100).toStringAsFixed(2)}%)";
    } else {
      return "$topLabel";
    }
  }

  // New method to run prediction in background isolate
  Future<String> predictInBackground(File imageFile) async {
    return await predict(imageFile);
  }

  void dispose() {
    _interpreter.close();
  }
}


