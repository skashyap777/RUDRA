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
    debugPrint("📸 [iOS DEBUG] Starting profile photo upload...");
    debugPrint("📸 [iOS DEBUG] Platform: ${Platform.operatingSystem}");
    debugPrint("📸 [iOS DEBUG] Platform.isIOS: ${Platform.isIOS}");
    debugPrint("📁 [iOS DEBUG] File path: ${file.path}");
    
    try {
      // Check if file exists
      bool exists = await file.exists();
      debugPrint("📁 [iOS DEBUG] File exists: $exists");
      
      if (!exists) {
        debugPrint("❌ [iOS DEBUG] File does not exist!");
        return false;
      }
      
      int fileSize = await file.length();
      debugPrint("📁 [iOS DEBUG] File size: $fileSize bytes");
      
      String filename = file.path.split("/").last;
      debugPrint("📝 [iOS DEBUG] Filename: $filename");
      
      final fileExtension = file.path.split('.').last.toLowerCase();
      debugPrint("📝 [iOS DEBUG] File extension: $fileExtension");
      
      final contentType = fileExtension == 'png'
          ? 'image/png'
          : fileExtension == 'jpg' || fileExtension == 'jpeg'
              ? 'image/jpeg'
              : 'image/jpeg'; // fallback
      
      debugPrint("📝 [iOS DEBUG] Content type: $contentType");
      
      // Read file bytes to verify
      final fileBytes = await file.readAsBytes();
      debugPrint("📁 [iOS DEBUG] File bytes read successfully: ${fileBytes.length} bytes");
      
      FormData formData = FormData.fromMap({
        "profile_photo": await MultipartFile.fromFile(
          file.path,
          filename: filename,
          contentType: DioMediaType.parse(contentType),
        ),
      });
      
      debugPrint("📦 [iOS DEBUG] FormData created successfully");
      debugPrint("📦 [iOS DEBUG] FormData fields: ${formData.fields}");
      debugPrint("📦 [iOS DEBUG] FormData files: ${formData.files.length}");
      
      debugPrint("🚀 [iOS DEBUG] Sending PATCH request to /profile/update-photo");
      
      final response = await apiService.patchMultipart(
        url: "/profile/update-photo",
        formData: formData,
      );
      
      debugPrint("✅ [iOS DEBUG] Response received");
      debugPrint("✅ [iOS DEBUG] Response status: ${response.statusCode}");
      debugPrint("✅ [iOS DEBUG] Response headers: ${response.headers}");
      debugPrint("✅ [iOS DEBUG] Response data: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ [iOS DEBUG] Profile photo upload successful, refreshing profile data...");
        await getProfileData();
        return true;
      }
      debugPrint("❌ [iOS DEBUG] Unexpected status: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      debugPrint("❌ [iOS DEBUG] DioException occurred");
      debugPrint("❌ [iOS DEBUG] DioException type: ${e.type}");
      debugPrint("❌ [iOS DEBUG] DioException message: ${e.message}");
      debugPrint("❌ [iOS DEBUG] DioException response status: ${e.response?.statusCode}");
      debugPrint("❌ [iOS DEBUG] DioException response headers: ${e.response?.headers}");
      debugPrint("❌ [iOS DEBUG] DioException response data: ${e.response?.data}");
      debugPrint("❌ [iOS DEBUG] DioException request path: ${e.requestOptions.path}");
      debugPrint("❌ [iOS DEBUG] DioException request headers: ${e.requestOptions.headers}");
      debugPrint("❌ [iOS DEBUG] Stack trace: ${e.stackTrace}");
      return false;
    } catch (e) {
      debugPrint("❌ [iOS DEBUG] General error: $e");
      debugPrint("❌ [iOS DEBUG] Stack trace: ${StackTrace.current}");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateProfile({required String name, required String address}) async {
    debugPrint("👤 [iOS DEBUG] Starting profile update...");
    debugPrint("👤 [iOS DEBUG] Platform: ${Platform.operatingSystem}");
    debugPrint("👤 [iOS DEBUG] Name: $name");
    debugPrint("👤 [iOS DEBUG] Address: $address");
    
    try {
      final requestData = {
        "name": name,
        "address": address,
      };
      debugPrint("📦 [iOS DEBUG] Request data: $requestData");
      
      final response = await apiService.patch(
        url: "/profile/update-name",
        data: requestData,
      );
      
      debugPrint("✅ [iOS DEBUG] Profile update response received");
      debugPrint("✅ [iOS DEBUG] Response status: ${response.statusCode}");
      debugPrint("✅ [iOS DEBUG] Response headers: ${response.headers}");
      debugPrint("✅ [iOS DEBUG] Response data: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ [iOS DEBUG] Profile update successful, refreshing profile data...");
        // Refresh profile data after successful update
        await getProfileData();
        return true;
      }
      debugPrint("❌ [iOS DEBUG] Unexpected status code: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      debugPrint("❌ [iOS DEBUG] DioException in profile update");
      debugPrint("❌ [iOS DEBUG] DioException type: ${e.type}");
      debugPrint("❌ [iOS DEBUG] DioException message: ${e.message}");
      debugPrint("❌ [iOS DEBUG] DioException response status: ${e.response?.statusCode}");
      debugPrint("❌ [iOS DEBUG] DioException response data: ${e.response?.data}");
      debugPrint("❌ [iOS DEBUG] Stack trace: ${e.stackTrace}");
      return false;
    } catch (e) {
      debugPrint("❌ [iOS DEBUG] General error in profile update: $e");
      debugPrint("❌ [iOS DEBUG] Stack trace: ${StackTrace.current}");
      return false;
    } finally {
      notifyListeners();
    }
  }
}
