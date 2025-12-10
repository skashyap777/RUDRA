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
    // Determine the correct content type based on file extension
    String extension = file.path.split(".").last.toLowerCase();
    String imageType = "jpeg"; // Default to jpeg
    if (extension == "png") {
      imageType = "png";
    } else if (extension == "gif") {
      imageType = "gif";
    } else if (extension == "webp") {
      imageType = "webp";
    }
    
    // Get filename - handle both iOS and Android path separators
    String filename = file.path.split(Platform.pathSeparator).last;
    
    FormData formData = FormData.fromMap({
      "profile_photo": await MultipartFile.fromFile(
        file.path,
        filename: filename,
        contentType: DioMediaType("image", imageType),
      ),
    });
    try {
      final response = await apiService.patchMultipart(
        url: "/profile/update-photo",
        formData: formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh profile data after successful update
        await getProfileData();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error updating profile photo: $e");
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
