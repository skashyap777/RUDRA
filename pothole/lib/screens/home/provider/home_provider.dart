import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pothole/config/network/dio.dart';
import 'package:pothole/config/utils/local_storage.dart';
import 'package:pothole/screens/auth/models/user_details_model.dart';

class HomeProvider extends ChangeNotifier {
  final apiService = HTTP();
  Profile? userdetails;
  List<File> potholeImages = [];
  List<Map<String, double>> coordinates = [];
  bool loading = true;

  Future<bool> createPothole(FormData formData) async {
    try {
      final response = await apiService.post(
        url: "/api/v1/pothole/create",
        data: formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {}
  }

  Future<void> addCurrentCordinate() async {
    try {
      // Ensure permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print(" Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(" Location permissions are permanently denied");
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      coordinates.add({
        "latitude": position.latitude,
        "longitude": position.longitude,
      });

      notifyListeners();
      print(
        "Added current location: ${position.latitude}, ${position.longitude}",
      );
    } catch (e) {
      print("Error getting device location: $e");
    }
  }

  Future<void> addPotholeImage(File image) async {
    try {
      potholeImages.add(image);
      notifyListeners();
    } catch (e) {
      print("Error uploading pothole images: $e");
    }
  }

  Future<void> getUserDetails() async {
    try {
      final data = await TokenHandler.getString("user");
      userdetails = Profile.fromJson(jsonDecode(data));
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<XFile?> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        "${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}",
      );

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70, // reduce size (0–100)
        format: CompressFormat.jpeg,
      );

      return result;
    } catch (e) {
      print("❌ Error compressing image: $e");
      return null;
    }
  }
}
