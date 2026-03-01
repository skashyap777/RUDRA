import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/screens/auth/models/user_details_model.dart';

class HomeProvider extends ChangeNotifier {
  final apiService = HTTP();
  Profile? userdetails;
  List<File> potholeImages = [];
  List<Map<String, double>> coordinates = [];
  bool loading = true;

  void clearReportData() {
    potholeImages.clear();
    coordinates.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> createPothole(FormData formData) async {
    try {
      final response = await apiService.postMultipart(
        url: "/pothole/create",
        formData: formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Report submitted successfully'};
      }
      return {'success': false, 'message': 'Failed to submit report'};
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        String message = 'Server Error ($statusCode)';
        
        if (errorData is Map && errorData['message'] != null) {
          message = errorData['message'];
          // Handle existing case logic
          String? existingCaseNo = errorData['data']?['existing_case_no'];
          if (existingCaseNo != null) {
            message += '\n\nExisting Case: $existingCaseNo';
          }
        } else if (statusCode == 413) {
          message = 'The report data is too large. Try taking fewer or smaller photos.';
        } else if (statusCode == 500) {
          message = 'Internal server error. Please try again later.';
        }
        
        return {'success': false, 'message': message};
      }
      
      String networkMessage = 'Network error. Please check your connection.';
      if (e.type == DioExceptionType.connectionTimeout) {
        networkMessage = 'Connection timed out. Your connection might be too slow.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        networkMessage = 'Server is taking too long to respond. Please try again.';
      } else if (e.type == DioExceptionType.cancel) {
        networkMessage = 'Request was cancelled.';
      }
      
      return {
        'success': false,
        'message': networkMessage,
      };
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: ${e.toString()}'};
    }
  }

  Future<void> addCurrentCordinate() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      coordinates.add({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "accuracy": position.accuracy,
      });

      notifyListeners();
    } catch (e) {
      debugPrint("❌ [addCurrentCordinate] $e");
    }
  }

  /// Returns the GPS accuracy (in meters) of the most recent coordinate.
  double? get lastAccuracy {
    if (coordinates.isEmpty) return null;
    return coordinates.last['accuracy'];
  }

  Future<void> addPotholeImage(File image) async {
    try {
      potholeImages.add(image);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [addPotholeImage] $e");
    }
  }

  HomeProvider() {
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    try {
      final data = await TokenHandler.getString("user");
      if (data.isNotEmpty) {
        userdetails = Profile.fromJson(jsonDecode(data));
      } else {
        userdetails = null;
      }
    } catch (e) {
      debugPrint("❌ [getUserDetails] $e");
      userdetails = null;
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

      // Resize and compress: 1024px is plenty for potholes
      return await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      debugPrint("❌ [compressImage] $e");
      return null;
    }
  }
}
