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
    FormData formData = FormData.fromMap({
      "profile_photo": await MultipartFile.fromFile(
        file.path, // <-- local path
        filename: file.path.split("/").last,
        contentType: DioMediaType("image", "png"),
      ),
    });
    try {
      final response = await apiService.patch(
        url: "/profile/update-photo",
        data: formData,
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
