import 'package:flutter/material.dart';
import 'package:pothole/config/network/dio.dart';
import 'package:pothole/screens/notifications/models/notifiction_model.dart';

class NotificationProvider extends ChangeNotifier {
  final apiService = HTTP();

  List<Data> notifications = [];

  Future<void> fetchNotifications() async {
    final response = await apiService.get(
      url: '/admin/notifications?page=1&limit=20',
    );
    if (response.statusCode == 200) {
      final data = NotificationModel.fromJson(response.data);
      notifications = data.data ?? [];
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
