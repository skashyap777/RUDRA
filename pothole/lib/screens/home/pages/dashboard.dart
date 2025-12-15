import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/config/utils/app_functions.dart';
import 'package:pothole/config/utils/assets.dart';
import 'package:pothole/screens/home/provider/home_provider.dart';
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
            flexibleSpace: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 40,
                bottom: 10,
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
                      children: [
                        Text(
                          store.userdetails?.name ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          store.userdetails?.address ?? "",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
  final double confidenceThreshold = 0.3;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/model/best_float32.tflite',
    );
    _labels =
        (await rootBundle.loadString(
          'assets/model/labels.txt',
        )).split('\n').where((e) => e.trim().isNotEmpty).toList();
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

  void dispose() {
    _interpreter.close();
  }
}

// // Enhanced AppFunctions class with scanner support
// class AppFunctions {
//   static Future<Position?> requestLocationPermission() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return null;
//     }

//     var status = await Permission.location.request();

//     if (status.isGranted) {
//       try {
//         Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high,
//         );
//         return position;
//       } catch (e) {
//         return null;
//       }
//     } else if (status.isDenied) {
//       return null;
//     } else if (status.isPermanentlyDenied) {
//       openAppSettings();
//       return null;
//     }

//     return null;
//   }

//   static Future<File?> captureImageFromCamera() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? photo = await picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 85,
//     );
//     if (photo != null) {
//       return File(photo.path);
//     }
//     return null;
//   }

//   static Future<File?> uploadFromDevice() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? photo = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//     );
//     if (photo != null) {
//       return File(photo.path);
//     }
//     return null;
//   }
// }
