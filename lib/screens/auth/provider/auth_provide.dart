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
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {}
  }

  Future<bool> verifyOtp(String mobileNumebr, String otp) async {
    try {
      debugPrint("Verifying OTP for mobile: $mobileNumebr, OTP: $otp");
      final response = await apiService.post(
        url: "/auth/verify-otp",
        data: {"mobile": mobileNumebr, "otp": otp},
      );
      debugPrint("OTP Verify Response Status: ${response.statusCode}");
      debugPrint("OTP Verify Response Data: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        otpverify = OTPVerifyModel.fromJson(response.data);
        await TokenHandler.setString("token", otpverify?.data?.token ?? "");
        debugPrint(
          "OTP verification successful, token saved: ${otpverify?.data?.token}",
        );
        return true;
      }
      debugPrint("OTP verification failed with status: ${response.statusCode}");
      return false;
    } catch (e) {
      debugPrint("OTP verification error: $e");
      return false;
    } finally {}
  }

  Future<bool> checkLocation(double latitude, double longitude) async {
    loading = true;
    notifyListeners();
    try {
      debugPrint(
        "Checking location boundary for coordinates: $latitude, $longitude",
      );
      final response = await apiService.get(
        url:
            "/admin/check-location-in-boundary?latitude=$latitude&longitude=$longitude",
      );
      debugPrint("Location Check Response Status: ${response.statusCode}");
      debugPrint("Location Check Response Data: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        checkLocationData = CheckLocationModel.fromJson(response.data);
        debugPrint(
          "Location boundary check response parsed: within_boundary = ${checkLocationData?.data?.withinBoundary}",
        );

        // Check if location is actually within boundary
        if (checkLocationData?.data?.withinBoundary == true) {
          debugPrint("Location is within boundary - verification successful");
          return true;
        } else {
          debugPrint("Location is NOT within boundary - verification failed");
          return false;
        }
      }
      debugPrint(
        "Location boundary check failed with status: ${response.statusCode}",
      );
      return false;
    } catch (e) {
      debugPrint("Location boundary check error: $e");
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> getProfileData() async {
    try {
      debugPrint("Fetching profile data");
      final response = await apiService.get(url: "/profile");
      debugPrint("Profile Response Status: ${response.statusCode}");
      debugPrint("Profile Response Data: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        profile = UserDetailsModel.fromJson(response.data);
        await TokenHandler.setString(
          "user",
          jsonEncode(profile?.data?.profile),
        );
        userData = Profile.fromJson(response.data);
        debugPrint("Profile data fetched successfully");
        return true;
      }
      debugPrint("Profile fetch failed with status: ${response.statusCode}");
      return false;
    } catch (e) {
      debugPrint("Profile fetch error: $e");
      return false;
    } finally {}
  }

  Future<bool> createProfile(FormData data) async {
    try {
      debugPrint("Creating profile with form data");
      final response = await apiService.postMultipart(
        url: "/profile/create",
        formData: data,
      );
      debugPrint("Create Profile Response Status: ${response.statusCode}");
      debugPrint("Create Profile Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final profile = response.data['data']['profile'];
        await TokenHandler.setString("user", jsonEncode(profile));
        userData = Profile.fromJson(response.data);
        debugPrint("Profile created successfully");
        return true;
      } else {
        debugPrint(
          "Profile creation failed with status: ${response.statusCode}",
        );
        debugPrint("Error response: ${response.data}");
        return false;
      }
    } catch (e) {
      debugPrint("Profile creation error: $e");
      return false;
    }
  }

  Future<bool> checkLocationWithpin(int pincode) async {
    loading = true;
    notifyListeners();
    String apiKey = "AIzaSyBU8zniWDcPMAUWkqIJ0iTmGbkF7jtRwzA";

    try {
      debugPrint("Checking location with pincode: $pincode");
      final response = await apiService.get(
        url:
            "https://maps.googleapis.com/maps/api/geocode/json?address=$pincode&key=$apiKey",
      );
      debugPrint("Geocode Response Status: ${response.statusCode}");
      debugPrint("Geocode Response Data: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        locationData = LocationModel.fromJson(response.data);
        final lat = locationData?.results?[0].geometry?.location?.lat ?? 0.0;
        final lng = locationData?.results?[0].geometry?.location?.lng ?? 0.0;
        debugPrint("Geocoded coordinates: $lat, $lng");
        final res = await checkLocation(lat, lng);
        if (res) {
          debugPrint("Location verification successful with pincode");
          return true;
        } else {
          debugPrint("Location verification failed with pincode");
          return false;
        }
      }
      debugPrint("Geocode API failed with status: ${response.statusCode}");
      return false;
    } catch (e) {
      debugPrint("Pincode location check error: $e");
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
