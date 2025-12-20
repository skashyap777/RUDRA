import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/screens/profile/models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final apiService = HTTP();
  ProfileModel? profile;

  Future<bool> getProfileData() async {
    try {
      final response = await apiService.get(url: "/profile");
      if (response.statusCode == 200 || response.statusCode == 201) {
        profile = ProfileModel.fromJson(response.data);
        await TokenHandler.setString(
          "user",
          jsonEncode(profile?.data?.profile),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateProfilePhoto(File file) async {
    debugPrint("📸 Starting profile photo upload...");
    debugPrint("📁 File path: ${file.path}");
    
    try {
      // Check if file exists
      bool exists = await file.exists();
      debugPrint("📁 File exists: $exists");
      
      if (!exists) {
        debugPrint("❌ File does not exist!");
        return false;
      }
      
      int fileSize = await file.length();
      debugPrint("📁 File size: $fileSize bytes");
      
      String filename = file.path.split("/").last;
      debugPrint("📝 Filename: $filename");
      
      FormData formData = FormData.fromMap({
        "profile_photo": await MultipartFile.fromFile(
          file.path,
          filename: filename,
          contentType: DioMediaType("image", "png"),
        ),
      });
      
      debugPrint("🚀 Sending PATCH request to /profile/update-photo");
      
      final response = await apiService.patchMultipart(
        url: "/profile/update-photo",
        formData: formData,
      );
      
      debugPrint("✅ Response status: ${response.statusCode}");
      debugPrint("✅ Response data: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getProfileData();
        return true;
      }
      debugPrint("❌ Unexpected status: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      debugPrint("❌ DioException type: ${e.type}");
      debugPrint("❌ DioException message: ${e.message}");
      debugPrint("❌ DioException response status: ${e.response?.statusCode}");
      debugPrint("❌ DioException response data: ${e.response?.data}");
      return false;
    } catch (e) {
      debugPrint("❌ General error: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateUserName(String name) async {
    try {
      final response = await apiService.patch(
        url: "/profile/update-name",
        data: {
          "name": name,
        }, // Fixed: Use "name" as the key, not the variable name
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh profile data after successful update
        await getProfileData();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      notifyListeners();
    }
  }
}
