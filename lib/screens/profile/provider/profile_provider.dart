import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rudra/config/constants/api_constants.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/screens/profile/models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final apiService = HTTP();
  ProfileModel? profile;

  ProfileProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      final data = await TokenHandler.getString("user");
      if (data.isNotEmpty) {
        profile = ProfileModel(
          status: "success",
          data: Data(profile: Profile.fromJson(jsonDecode(data))),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ [ProfileProvider._init] $e");
    }
  }

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
    try {
      if (!await file.exists()) {
        debugPrint("❌ [updateProfilePhoto] File does not exist: ${file.path}");
        return false;
      }

      // Compress profile photo before upload
      final compressedXFile = await _compressImage(file);
      if (compressedXFile == null) {
        debugPrint("❌ [updateProfilePhoto] Compression failed");
        return false;
      }
      
      final compressedFile = File(compressedXFile.path);
      // Use path.basename for robust platform-agnostic filename extraction
      String filename = path.basename(compressedFile.path);
      
      // Ensure no URL encoding issues in filename
      if (filename.contains('%')) {
        try {
          filename = Uri.decodeComponent(filename);
        } catch (_) {}
      }

      FormData formData = FormData.fromMap({
        "profile_photo": await MultipartFile.fromFile(
          compressedFile.path,
          filename: filename,
          contentType: DioMediaType("image", "jpeg"),
        ),
      });

      debugPrint("🚀 [updateProfilePhoto] Uploading $filename...");
      final response = await apiService.patchMultipart(
        url: "/profile/update-photo",
        formData: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ [updateProfilePhoto] Successfully updated");
        await getProfileData();
        return true;
      }
      debugPrint("⚠️ [updateProfilePhoto] Unexpected status: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      debugPrint("❌ [updateProfilePhoto] DioError: ${e.response?.statusCode} - $errorMsg");
      return false;
    } catch (e) {
      debugPrint("❌ [updateProfilePhoto] Generic Error: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<XFile?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        "${DateTime.now().millisecondsSinceEpoch}_profile.jpg",
      );

      return await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 512, // Profile pics don't need to be huge
        minHeight: 512,
        format: CompressFormat.jpeg,
      );
    } catch (e) {
      debugPrint("❌ [_compressImage] $e");
      return null;
    }
  }

  /// Updates ONLY the address by re-calling POST /profile/create.
  /// Since profile_photo is required by that endpoint, we re-download
  /// the user's existing photo and re-upload it so it stays unchanged.
  Future<bool> updateAddress(String newAddress, {String? newName}) async {
    try {
      debugPrint("🚀 [updateAddress] Invoked with newAddress: '$newAddress', newName: '$newName'");
      final currentProfile = profile?.data?.profile;
      if (currentProfile == null) {
        debugPrint("❌ [updateAddress] Error: currentProfile is null!");
        return false;
      }

      final nameToUse = newName ?? currentProfile.name ?? "";
      final photoLink = currentProfile.profilePhotoLink;
      if (photoLink == null || photoLink.isEmpty || photoLink == "null") {
        debugPrint("❌ [updateAddress] Error: photoLink is null or empty. photoLink: '$photoLink'");
        return false;
      }

      // Download the existing profile photo to a temp file
      final photoUrl = photoLink.startsWith('/') 
          ? "${ApiConstants.imageBaseUrl}$photoLink" 
          : "${ApiConstants.imageBaseUrl}/$photoLink";
          
      debugPrint("🚀 [updateAddress] Downloading photo from URL: $photoUrl");
      final httpResponse = await http.get(Uri.parse(Uri.encodeFull(photoUrl)));
      if (httpResponse.statusCode != 200) {
        debugPrint("❌ [updateAddress] Failed to download photo. statusCode: ${httpResponse.statusCode}");
        return false;
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_profile_photo.jpg');
      await tempFile.writeAsBytes(httpResponse.bodyBytes);
      debugPrint("✅ [updateAddress] Photo successfully downloaded to temp file: ${tempFile.path}");

      // Call POST /profile/create with same photo + new address
      debugPrint("🚀 [updateAddress] Calling POST /profile/create with name: '$nameToUse', com_address: '$newAddress'");
      final formData = FormData.fromMap({
        "name": nameToUse,
        "com_address": newAddress,
        "profile_photo": await MultipartFile.fromFile(
          tempFile.path,
          filename: "profile_photo.jpg",
          contentType: DioMediaType("image", "jpeg"),
        ),
      });

      final response = await apiService.postMultipart(
        url: "/profile/create",
        formData: formData,
      );

      debugPrint("✅ [updateAddress] Response status: ${response.statusCode}, body: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        debugPrint("✅ [updateAddress] Address updated successfully.");
        await getProfileData();
        return true;
      }
      debugPrint("⚠️ [updateAddress] Unexpected status code: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      debugPrint("❌ [updateAddress] DioException! status code: ${e.response?.statusCode}, data: ${e.response?.data}, message: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("❌ [updateAddress] Generic Exception: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateProfile({required String name, required String address}) async {
    try {
      debugPrint("🚀 [updateProfile] Invoked with name: '$name', address: '$address'");
      debugPrint("🚀 [updateProfile] Calling PATCH /profile/update-name with name: '$name'");
      final response = await apiService.patch(
        url: "/profile/update-name",
        data: {"name": name},
      );

      debugPrint("✅ [updateProfile] Response status: ${response.statusCode}, body: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        debugPrint("✅ [updateProfile] Name updated successfully.");
        await getProfileData();
        return true;
      }
      debugPrint("⚠️ [updateProfile] Unexpected status code: ${response.statusCode}");
      return false;
    } on DioException catch (e) {
      debugPrint("❌ [updateProfile] DioException! status code: ${e.response?.statusCode}, data: ${e.response?.data}, message: ${e.message}");
      return false;
    } catch (e) {
      debugPrint("❌ [updateProfile] Generic Exception: $e");
      return false;
    } finally {
      notifyListeners();
    }
  }
}
