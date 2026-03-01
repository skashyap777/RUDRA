import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/screens/notifications/models/notifiction_model.dart';

class NotificationProvider extends ChangeNotifier {
  final apiService = HTTP();

  List<Data> notifications = [];

  bool loading = false;
  String? errorMessage;

  Future<void> fetchNotifications() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await apiService.get(
        url: '/admin/notifications',
      );
      if (response.statusCode == 200) {
        final data = NotificationModel.fromJson(response.data);
        notifications = data.data ?? [];
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      // Extract server message if available
      if (e is DioException && e.response?.data != null) {
        final body = e.response!.data;
        if (body is Map && body.containsKey('message')) {
          errorMessage = '${body['message']} (${e.response!.statusCode})';
        } else {
          errorMessage = 'Server error (${e.response?.statusCode ?? "unknown"})';
        }
      } else {
        errorMessage = 'Connection error: $e';
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNotification(int id) async {
    try {
      final response = await apiService.delete(
        url: '/admin/notifications/$id',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Remove locally from the list
        notifications.removeWhere((notification) => notification.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      return false;
    }
  }

  Future<void> submitFeedback(
    int caseId,
    String fedbackHead,
    String feedback,
  ) async {
    final response = await apiService.post(
      url: '/pothole/give-feedback',
      data: {
        "case_id": caseId,
        "feedback_head": fedbackHead,
        "feedback_text": feedback,
      },
    );
    if (response.statusCode == 200) {
      final data = NotificationModel.fromJson(response.data);
      notifications = data.data ?? [];
      notifyListeners();
    }
  }
}
