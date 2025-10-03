import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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
          appBar: AppBar(
            backgroundColor: const Color(
              0xFF2E7D6F,
            ), // green shade like your image
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight:
                80, // Increased height for proper circular profile image
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 65,
                bottom: 15,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25), // Same as radius
                    child:
                        store.loading
                            ? CircularProgressIndicator()
                            : Image.network(
                              "${Constants.baseUrl}${store.userdetails?.profilePhotoLink}",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  Assets.profile,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                  ),
                  const SizedBox(width: 12),

                  // Name + Address
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            store.userdetails?.name ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            store.userdetails?.address ?? "",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Report Pothole",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text("Take photos and submit to report potholes"),
                      if (capturedPhotos.isNotEmpty)
                        Text(
                          "${capturedPhotos.length} photo(s) captured",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final res =
                                await AppFunctions.captureImageFromCamera();
                            if (res != null) {
                              context.push('/scanpothole', extra: res);
                            }
                          },
                          icon: Icon(Icons.document_scanner, size: 20),
                          label: Text(
                            "Click Here",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallet.buttonColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (capturedPhotos.isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Submit functionality to be implemented',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.upload, size: 20),
                            label: Text(
                              "Submit Reports",
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Processing Indicator
                if (isProcessing)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text("Processing image..."),
                      ],
                    ),
                  ),

                // Photos List
                Expanded(
                  child:
                      capturedPhotos.isEmpty
                          ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_camera_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No photos captured yet",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: capturedPhotos.length,
                            itemBuilder: (context, index) {
                              final photo = capturedPhotos[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
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
                                      fontWeight: FontWeight.w500,
                                      color:
                                          photo.result.contains('Pothole')
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Captured: ${photo.timestamp.toString().substring(0, 19)}",
                                      ),
                                      if (photo.location != null)
                                        Text(
                                          "Location: ${photo.location!.latitude.toStringAsFixed(6)}, ${photo.location!.longitude.toStringAsFixed(6)}",
                                          style: const TextStyle(fontSize: 12),
                                        )
                                      else
                                        const Text(
                                          "Location: Not available",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => _removePhoto(index),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
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

  final int inputSize = 640;
  final double confidenceThreshold =
      0.02; // Consistent threshold for classification and final check

  Future<void> loadModel() async {
    try {
      print("Loading AI model...");
      _interpreter = await Interpreter.fromAsset(
        'assets/model/best_float32.tflite',
      );
      _labels =
          (await rootBundle.loadString(
            'assets/model/labels.txt',
          )).split('\n').where((e) => e.trim().isNotEmpty).toList();
      print("AI Model loaded successfully. Labels: $_labels");
      print("Model input shape: ${_interpreter.getInputTensors()}");
      print("Model output shape: ${_interpreter.getOutputTensors()}");
    } catch (e) {
      print("Error loading AI model: $e");
      throw Exception("Failed to load AI model: $e");
    }
  }

  Future<String> predict(File imageFile) async {
    try {
      print("Starting prediction...");
      final bytes = await imageFile.readAsBytes();
      print("Image bytes loaded: ${bytes.length}");
      final raw = img.decodeImage(bytes);
      if (raw == null) {
        print("Failed to decode image");
        return "Invalid image";
      }
      print("Image decoded successfully: ${raw.width}x${raw.height}");

      final resized = img.copyResize(raw, width: inputSize, height: inputSize);
      print("Image resized to: ${resized.width}x${resized.height}");

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
      print("Input tensor created with shape: [1, $inputSize, $inputSize, 3]");

      // Output buffer: shape [1, 5, 8400] for YOLO format [batch, features, anchors]
      final output = List.generate(
        1,
        (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
      );
      print("Output buffer created with shape: [1, 5, 8400]");

      print("Running model inference...");
      _interpreter.run(input, output);
      print("Model inference completed");

      final results = output[0]; // Shape: [5, 8400]
      double maxConfidence = 0.0;
      int bestClassIndex = -1;

      // Parse YOLO outputs
      List<double> confidenceValues = [];
      int highConfidenceCount = 0;
      for (int i = 0; i < 8400; i++) {
        // YOLO format: [x, y, w, h, confidence, class1, class2, ...]
        // But our model outputs [x, y, w, h, confidence] where confidence is objectness * class_prob
        final confidence = results[4][i];
        confidenceValues.add(confidence);

        // Count high confidence detections
        if (confidence > confidenceThreshold) {
          highConfidenceCount++;
        }

        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          // For this model, use relative confidence - higher values indicate detections
          // Since the model produces values in range 0.0001-0.13, we use a consistent threshold
          bestClassIndex =
              confidence > confidenceThreshold
                  ? 0
                  : 1; // 0 = pothole, 1 = no_pothole
        }
      }

      // Debug: Show some sample confidence values
      print(
        "Sample confidence values (first 10): ${confidenceValues.take(10)}",
      );
      print(
        "Max confidence in all values: ${confidenceValues.reduce((a, b) => a > b ? a : b)}",
      );
      print(
        "Min confidence in all values: ${confidenceValues.reduce((a, b) => a < b ? a : b)}",
      );
      print(
        "Values above ${confidenceThreshold * 100}% threshold: ${confidenceValues.where((c) => c > confidenceThreshold).length}",
      );

      print(
        "Max confidence found: $maxConfidence, Best class index: $bestClassIndex",
      );

      if (bestClassIndex != -1 && maxConfidence >= confidenceThreshold) {
        final label = _labels[bestClassIndex];
        final percentage = (maxConfidence * 100).toStringAsFixed(1);
        print("Prediction result: $label detected (${percentage}%)");
        return "$label detected (${percentage}%)";
      } else {
        print("No detection above threshold");
        return "No pothole detected";
      }
    } catch (e) {
      print("Error during prediction: $e");
      return "Error processing image";
    }
  }

  // New method to run prediction in background isolate
  Future<String> predictInBackground(File imageFile) async {
    // Use compute to run the prediction in a background isolate
    return await compute(_predictInBackground, imageFile.path);
  }

  void dispose() {
    _interpreter.close();
  }
}

// Top-level function for background processing
Future<String> _predictInBackground(String imagePath) async {
  // This function runs in a background isolate
  // We need to re-initialize the model in the isolate
  try {
    // Load model in isolate
    final interpreter = await Interpreter.fromAsset(
      'assets/model/best_float32.tflite',
    );
    final labelData = await rootBundle.loadString('assets/model/labels.txt');
    final labels =
        labelData.split('\n').where((e) => e.trim().isNotEmpty).toList();

    final imageFile = File(imagePath);
    final bytes = await imageFile.readAsBytes();
    final raw = img.decodeImage(bytes);
    if (raw == null) {
      return "Invalid image";
    }

    final inputSize = 640;
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

    // Output buffer: shape [1, 5, 8400] for YOLO format [batch, features, anchors]
    final output = List.generate(
      1,
      (_) => List.generate(5, (_) => List.filled(8400, 0.0)),
    );

    interpreter.run(input, output);
    interpreter.close();

    final results = output[0]; // Shape: [5, 8400]
    double maxConfidence = 0.0;
    int bestClassIndex = -1;
    final confidenceThreshold = 0.02;

    // Parse YOLO outputs
    for (int i = 0; i < 8400; i++) {
      final confidence = results[4][i];
      if (confidence > maxConfidence) {
        maxConfidence = confidence;
        bestClassIndex =
            confidence > confidenceThreshold
                ? 0
                : 1; // 0 = pothole, 1 = no_pothole
      }
    }

    if (bestClassIndex != -1 && maxConfidence >= confidenceThreshold) {
      // Note: We can't access _labels here in the isolate, so we'll use hardcoded values
      final label = bestClassIndex == 0 ? "pothole" : "no_pothole";
      final percentage = (maxConfidence * 100).toStringAsFixed(1);
      return "$label detected (${percentage}%)";
    } else {
      return "No pothole detected";
    }
  } catch (e) {
    return "Error processing image";
  }
}
