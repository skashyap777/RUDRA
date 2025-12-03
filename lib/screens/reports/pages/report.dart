import 'package:flutter/material.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/screens/notifications/pages/notifications.dart';
import 'package:rudra/screens/reports/models/report_model.dart';
import 'package:rudra/screens/reports/provider/report_provider.dart';
import 'package:provider/provider.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallet.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallet.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Reports',
          style: TextStyle(
            color: AppPallet.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        'All',
                        provider.reportCounts?.all ?? 0,
                        provider.selectedFilter == 'All',
                        provider,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'Submitted',
                        provider.reportCounts?.submitted ?? 0,
                        provider.selectedFilter == 'Submitted',
                        provider,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'In progress',
                        provider.reportCounts?.inProgress ?? 0,
                        provider.selectedFilter == 'In progress',
                        provider,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'Completed',
                        provider.reportCounts?.completed ?? 0,
                        provider.selectedFilter == 'Completed',
                        provider,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'Rejected',
                        provider.reportCounts?.rejected ?? 0,
                        provider.selectedFilter == 'Rejected',
                        provider,
                      ),
                    ],
                  ),
                ),
              ),

              // Reports list
              Expanded(
                child:
                    provider.isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppPallet.primaryColor,
                          ),
                        )
                        : provider.reports.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey.withOpacity(0.4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No reports found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                        : RefreshIndicator(
                          color: AppPallet.primaryColor,
                          onRefresh: () => provider.fetchReports(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = provider.filteredReports[index];
                              return _buildReportCard(context, report);
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    int count,
    bool isSelected,
    ReportProvider provider,
  ) {
    return GestureDetector(
      onTap: () => provider.updateFilter(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppPallet.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected
                    ? AppPallet.primaryColor
                    : Colors.grey.withOpacity(0.2),
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppPallet.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppPallet.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppPallet.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Data report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to details if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Status and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          report.status ?? '',
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatStatus(report.status ?? ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(report.status ?? ''),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _formatDateTime(report.createdAt ?? ''),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppPallet.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppPallet.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _buildLocationString(report),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppPallet.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Footer: Severity and Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: AppPallet.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            report.severity ?? 'Medium',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppPallet.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showImageViewer(context, report),
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text("View Image"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppPallet.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (report.feedBackProvided == false &&
                    report.status != 'Rejected') ...[
                  const Divider(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return FeedbackForm(
                              caseId: "${report.caseNo}",
                              onSubmitted: () {
                                print('Feedback submitted successfully');
                              },
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.feedback_outlined, size: 18),
                      label: const Text('Give Feedback'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppPallet.primaryColor,
                        side: const BorderSide(color: AppPallet.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildLocationString(Data report) {
    List<String> locationParts = [];

    if (report.roadName != null) locationParts.add(report.roadName!);
    if (report.subdivisionName != null)
      locationParts.add(report.subdivisionName!);
    if (report.divisionName != null) locationParts.add(report.divisionName!);
    if (report.districtName != null) locationParts.add(report.districtName!);
    if (report.stateName != null) locationParts.add(report.stateName!);

    if (locationParts.isEmpty && report.areaDetails != null) {
      return report.areaDetails!;
    }

    String location = locationParts.join(', ');
    if (report.landmark != null && report.landmark!.isNotEmpty) {
      location += ', ${report.landmark}';
    }

    return location.isNotEmpty ? location : 'Location not specified';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return const Color(0xFF2196F3);
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'rejected':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'submitted':
        return 'Submitted';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${_formatTime(dateTime)}';
    } catch (e) {
      return '--:--';
    }
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showImageViewer(BuildContext context, Data report) {
    if (report.images == null || report.images!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No images available for this report'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            height: 400,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Report Images',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Images
                Expanded(
                  child: PageView.builder(
                    itemCount: report.images!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            report.images![index].imageUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Image counter
                if (report.images!.length > 1)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${report.images!.length} images',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
