import 'package:flutter/material.dart';
import 'package:pothole/config/network/dio.dart';
import 'package:pothole/screens/reports/models/report_model.dart';

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
      final response = await apiService.get(url: '/pothole/my-reports');
      if (response.statusCode == 200) {
        final reportModel = ReportModel.fromJson(response.data);
        reports = reportModel.data ?? [];
        reportCounts = reportModel.counts;
        notifyListeners();
      }
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
    return reports
        .where(
          (report) =>
              report.status?.toLowerCase() ==
              selectedFilter.toLowerCase().replaceAll(' ', '_'),
        )
        .toList();
  }
}
