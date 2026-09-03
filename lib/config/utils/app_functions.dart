import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AppFunctions {
  static Future<Position?> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Use Geolocator's permission system instead of permission_handler
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission denied - stay in app, don't redirect to settings
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied - stay in app, don't redirect to settings
      return null;
    }

    // Permission granted, get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> captureImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }

  static Future<File?> uploadFromDevice() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      return File(photo.path);
    }
    return null;
  }

  static void showCustomSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: backgroundColor ?? Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String formatIndianDate(dynamic dateInput) {
    if (dateInput == null || dateInput.toString().trim().isEmpty) return '';
    try {
      DateTime dt;
      if (dateInput is DateTime) {
        dt = dateInput.toLocal();
      } else {
        dt = DateTime.parse(dateInput.toString()).toLocal();
      }
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString().substring(2);
      return '$day-$month-$year';
    } catch (e) {
      return dateInput.toString();
    }
  }

  static String formatIndianDateTime(dynamic dateInput) {
    if (dateInput == null || dateInput.toString().trim().isEmpty) return '';
    try {
      DateTime dt;
      if (dateInput is DateTime) {
        dt = dateInput.toLocal();
      } else {
        dt = DateTime.parse(dateInput.toString()).toLocal();
      }
      String day = dt.day.toString().padLeft(2, '0');
      String month = dt.month.toString().padLeft(2, '0');
      String year = dt.year.toString().substring(2);
      
      int hour = dt.hour;
      int minute = dt.minute;
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      String formattedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      
      return '$day-$month-$year $formattedTime';
    } catch (e) {
      return dateInput.toString();
    }
  }

  static int getDaysElapsed(dynamic dateInput) {
    if (dateInput == null || dateInput.toString().trim().isEmpty) return 0;
    try {
      DateTime dt;
      if (dateInput is DateTime) {
        dt = dateInput.toLocal();
      } else {
        dt = DateTime.parse(dateInput.toString()).toLocal();
      }
      final now = DateTime.now();
      final difference = now.difference(dt);
      return difference.inDays;
    } catch (e) {
      return 0;
    }
  }

  static String getDaysElapsedText(dynamic dateInput) {
    final days = getDaysElapsed(dateInput);
    if (days == 0) return 'Today';
    if (days == 1) return '1 day ago';
    return '$days days ago';
  }
}

