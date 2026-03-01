import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/screens/auth/models/check_location_model.dart';
import 'package:rudra/screens/auth/models/location_model.dart';
import 'package:rudra/screens/auth/models/otp_verify_model.dart';
import 'package:rudra/screens/auth/models/user_details_model.dart';

class AuthProvider extends ChangeNotifier {
  final apiService = HTTP();
  CheckLocationModel? checkLocationData;
  OTPVerifyModel? otpverify;
  Profile? userData;
  UserDetailsModel? profile;
  LocationModel? locationData;

  bool loading = false;

  Future<bool> generateOtp(String mobileNumebr) async {
    try {
      final response = await apiService.post(
        url: "/auth/signup-login",
        data: {"mobile": mobileNumebr, "user_type": "citizen"},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(String mobileNumebr, String otp) async {
    try {
      final response = await apiService.post(
        url: "/auth/verify-otp",
        data: {"mobile": mobileNumebr, "otp": otp},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        otpverify = OTPVerifyModel.fromJson(response.data);
        await TokenHandler.setString("token", otpverify?.data?.token ?? "");
        await TokenHandler.setString("refresh_token", otpverify?.data?.refreshToken ?? "");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ [verifyOtp] $e");
      return false;
    }
  }

  Future<bool> resendOtp(String mobileNumebr) async {
    try {
      final response = await apiService.post(
        url: "/auth/resend-otp",
        data: {"mobile": mobileNumebr},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ [resendOtp] $e");
      return false;
    }
  }

  Future<bool> checkLocation(double latitude, double longitude) async {
    loading = true;
    notifyListeners();
    try {
      final response = await apiService.get(
        url: "/admin/check-location-in-boundary?latitude=$latitude&longitude=$longitude",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        checkLocationData = CheckLocationModel.fromJson(response.data);
        return checkLocationData?.data?.withinBoundary == true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ [checkLocation] $e");
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> getProfileData() async {
    try {
      final response = await apiService.get(url: "/profile");
      if (response.statusCode == 200 || response.statusCode == 201) {
        profile = UserDetailsModel.fromJson(response.data);
        await TokenHandler.setString("user", jsonEncode(profile?.data?.profile));
        userData = Profile.fromJson(response.data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ [getProfileData] $e");
      return false;
    }
  }

  Future<bool> createProfile(FormData data) async {
    try {
      final response = await apiService.postMultipart(
        url: "/profile/create",
        formData: data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final profileData = response.data['data']['profile'];
        await TokenHandler.setString("user", jsonEncode(profileData));
        userData = Profile.fromJson(response.data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ [createProfile] $e");
      return false;
    }
  }

  Future<bool> checkLocationWithpin(int pincode) async {
    loading = true;
    notifyListeners();
    const apiKey = "AIzaSyBU8zniWDcPMAUWkqIJ0iTmGbkF7jtRwzA";
    try {
      final response = await apiService.get(
        url: "https://maps.googleapis.com/maps/api/geocode/json?address=$pincode&key=$apiKey",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        locationData = LocationModel.fromJson(response.data);
        final lat = locationData?.results?[0].geometry?.location?.lat ?? 0.0;
        final lng = locationData?.results?[0].geometry?.location?.lng ?? 0.0;
        return await checkLocation(lat, lng);
      }
      return false;
    } catch (e) {
      debugPrint("❌ [checkLocationWithpin] $e");
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
