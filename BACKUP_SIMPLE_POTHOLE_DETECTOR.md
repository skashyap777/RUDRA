# Backup: Simple PotholeDetector Implementation

This is the simpler PotholeDetector code from the old working version.

**Use this if the current complex version continues to fail on iOS.**

## How to Use

Replace the `PotholeDetector` class in `lib/screens/home/pages/dashboard.dart` with this code:

```dart
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
```

## Key Differences from Current Version

1. **No platform-specific logic** - Same code for iOS and Android
2. **Lower confidence threshold** - 0.3 (30%) vs 0.40/0.50
3. **No minimum detection count** - Single detection is enough
4. **Simpler input format** - Nested lists instead of Float32List
5. **Fixed output shape** - [1, 5, 8400] instead of dynamic detection
6. **No debug logging** - Clean and simple
7. **No image orientation handling** - Just resize

## When to Use This

If after fixing the Podfile, the AI model still fails to load on iOS, try this simpler implementation. It worked in the old version and might be more compatible.
