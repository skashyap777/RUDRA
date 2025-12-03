import 'package:flutter/material.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/screens/notifications/models/notifiction_model.dart';

class NotificationProvider extends ChangeNotifier {
  final apiService = HTTP();

  List<Data> notifications = [];

  bool loading = false;

  Future<void> fetchNotifications() async {
    loading = true;
    notifyListeners();
    try {
      final response = await apiService.get(
        url: '/pothole/notifications?page=1&limit=20',
      );
      if (response.statusCode == 200) {
        final data = NotificationModel.fromJson(response.data);
        notifications = data.data ?? [];
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      loading = false;
      notifyListeners();
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
