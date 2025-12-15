import 'package:flutter/material.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/screens/notifications/pages/notifications.dart';
import 'package:pothole/screens/reports/models/report_model.dart';
import 'package:pothole/screens/reports/provider/report_provider.dart';
import 'package:provider/provider.dart';

// class Report extends StatelessWidget {
//   const Report({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => ReportProvider()..getReports(),
//       child: const MyReportsScaffold(),
//     );
//   }
// }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppPallet.primaryColor,
        elevation: 0,

        title: const Text(
          'My Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        'All',
                        provider.reportCounts?.all ?? 0,
                        provider.selectedFilter == 'All',
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        'Submitted',
                        provider.reportCounts?.submitted ?? 0,
                        provider.selectedFilter == 'Submitted',
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        'In progress',
                        provider.reportCounts?.inProgress ?? 0,
                        provider.selectedFilter == 'In progress',
                        provider,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        'Completed',
                        provider.reportCounts?.completed ?? 0,
                        provider.selectedFilter == 'Completed',
                        provider,
                      ),
                      const SizedBox(width: 8),
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
                            color: Color(0xFF4CAF50),
                          ),
                        )
                        : provider.reports.isEmpty
                        ? const Center(
                          child: Text(
                            'No reports found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                        : RefreshIndicator(
                          color: const Color(0xFF4CAF50),
                          onRefresh: () => provider.fetchReports(),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC107) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Data report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location header
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Pothole Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location details
          Text(
            _buildLocationString(report),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Status and Date section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(report.status ?? ''),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatStatus(report.status ?? ''),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Date column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date Reported',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(report.createdAt ?? ''),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Severity and Last Updated section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Severity column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Severity',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.severity ?? 'Medium',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Last Updated column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Updated',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.updatedAt != null
                          ? _formatDateTime(report.updatedAt!)
                          : '--:--',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // View Image button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44, // keep height consistent
                  child: ElevatedButton.icon(
                    onPressed: () => _showImageViewer(context, report),
                    icon: const Icon(
                      Icons.image,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'View Image',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (report.feedBackProvided == false &&
                  report.status != 'Rejected')
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
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
                      icon: const Icon(
                        Icons.feedback,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
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
