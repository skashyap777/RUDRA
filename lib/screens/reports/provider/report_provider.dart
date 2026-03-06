import 'package:flutter/material.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/screens/reports/models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final apiService = HTTP();
  List<Data> reports = [];
  Counts? reportCounts;
  bool isLoading = false;
  String selectedFilter = 'All';

  Future<void> fetchReports({String status = 'all'}) async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch both reports and the status counts concurrently
      final responses = await Future.wait([
        apiService.get(url: '/pothole/my-reports'),
        apiService.get(url: '/pothole/status-counts'),
      ]);

      final reportResponse = responses[0];
      final countResponse = responses[1];

      if (reportResponse.statusCode == 200) {
        final reportModel = ReportModel.fromJson(reportResponse.data);
        reports = reportModel.data ?? [];
      }

      if (countResponse.statusCode == 200 && countResponse.data['status'] == 'success') {
        reportCounts = Counts.fromJson(countResponse.data['data']);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error fetching reports: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();

    // Fetch reports based on filter
    String apiStatus = filter.toLowerCase().replaceAll(' ', '_');
    if (filter == 'All') apiStatus = 'all';
    fetchReports(status: apiStatus);
  }

  List<Data> get filteredReports {
    if (selectedFilter == 'All') return reports;
    
    // Normalize selectedFilter to match server status (Submitted, In progress, Completed, Rejected)
    String searchStatus = selectedFilter.toLowerCase().trim();
    if (searchStatus == 'in progress') searchStatus = 'in_progress';
    
    return reports.where((report) {
      final reportStatus = report.status?.toLowerCase().trim() ?? '';
      
      if (searchStatus == 'in_progress') {
        return reportStatus == 'in_progress' || reportStatus == 'in progress';
      }
      if (searchStatus == 'completed') {
        return reportStatus == 'completed' || reportStatus == 'complete';
      }
      if (searchStatus == 'rejected') {
        return reportStatus == 'rejected' || reportStatus == 'reject';
      }
      if (searchStatus == 'submitted') {
        return reportStatus == 'submitted' || reportStatus == 'submit';
      }
      
      return reportStatus == searchStatus;
    }).toList();
  }
}
