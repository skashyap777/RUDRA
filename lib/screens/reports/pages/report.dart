import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/screens/notifications/pages/notifications.dart';
import 'package:rudra/screens/reports/models/report_model.dart';
import 'package:rudra/screens/reports/provider/report_provider.dart';
import 'package:rudra/screens/reports/pages/track_report_bottom_sheet.dart';
import 'package:provider/provider.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchReports();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
          // 1. All reports matching the search query (to calculate filter counts)
          final matchedReports =
              provider.reports.where((report) {
                if (_searchQuery.isEmpty) return true;
                return report.caseNo?.toString().toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false;
              }).toList();

          // 2. The actually displayed reports
          final displayedReports =
              provider.isSearchMode
                  ? provider.searchResults
                  : provider.filteredReports;

          // 3. Dynamic counts depending on search state
          int allCount = provider.reportCounts?.all ?? 0;
          int submittedCount = provider.reportCounts?.submitted ?? 0;
          int inProgressCount = provider.reportCounts?.inProgress ?? 0;
          int completedCount = provider.reportCounts?.completed ?? 0;
          int rejectedCount = provider.reportCounts?.rejected ?? 0;

          if (_searchQuery.isNotEmpty) {
            allCount = matchedReports.length;
            submittedCount =
                matchedReports
                    .where(
                      (r) =>
                          r.status?.toLowerCase() == 'submitted' ||
                          r.status?.toLowerCase() == 'submit',
                    )
                    .length;
            inProgressCount =
                matchedReports
                    .where(
                      (r) =>
                          r.status?.toLowerCase() == 'in_progress' ||
                          r.status?.toLowerCase() == 'in progress',
                    )
                    .length;
            completedCount =
                matchedReports
                    .where(
                      (r) =>
                          r.status?.toLowerCase() == 'completed' ||
                          r.status?.toLowerCase() == 'complete',
                    )
                    .length;
            rejectedCount =
                matchedReports
                    .where(
                      (r) =>
                          r.status?.toLowerCase() == 'rejected' ||
                          r.status?.toLowerCase() == 'reject',
                    )
                    .length;
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Report ID',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppPallet.primaryColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      Provider.of<ReportProvider>(
                        context,
                        listen: false,
                      ).searchReports(value);
                    });
                  },
                ),
              ),
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
                        allCount,
                        provider.selectedFilter == 'All',
                        provider,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'Submitted',
                        submittedCount,
                        provider.selectedFilter == 'Submitted',
                        provider,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'In progress',
                        inProgressCount,
                        provider.selectedFilter == 'In progress',
                        provider,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'Completed',
                        completedCount,
                        provider.selectedFilter == 'Completed',
                        provider,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        context,
                        'Rejected',
                        rejectedCount,
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
                          child: CircularProgressIndicator.adaptive(),
                        )
                        : provider.isSearchLoading
                        ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                        : displayedReports.isEmpty
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
                            itemCount: displayedReports.length,
                            itemBuilder: (context, index) {
                              final report = displayedReports[index];
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
      onTap: () {
        HapticFeedback.selectionClick();
        provider.updateFilter(label);
      },
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
                      _formatDateTime(
                        report.caseCreatedAt ?? report.createdAt ?? '',
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppPallet.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location and Report ID
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _buildLocationString(report),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppPallet.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              text: 'Report ID: ',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppPallet.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: report.caseNo ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppPallet.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Footer: Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                  top: MediaQuery.of(context).size.height * 0.2,
                                ),
                                child: TrackReportBottomSheet(
                                  caseId: report.id ?? 0,
                                  caseNo: report.caseNo ?? '',
                                ),
                              ),
                        );
                      },
                      icon: const Icon(Icons.timeline_outlined, size: 18),
                      label: const Text("Track Report"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppPallet.primaryColor,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        final isCompleted =
                            report.status?.toLowerCase() == 'completed' ||
                            report.status?.toLowerCase() == 'complete';
                        _showImageViewer(
                          context,
                          report,
                          showAfterFix: isCompleted,
                        );
                      },
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text("View Image"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppPallet.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (report.feedBackProvided == false &&
                    (report.status?.toLowerCase() == 'completed' ||
                        report.status?.toLowerCase() == 'complete')) ...[
                  const Divider(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return FeedbackForm(
                              caseId: report.id ?? 0,
                              onSubmitted: () {},
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
    if (report.areaDetails != null && report.areaDetails!.isNotEmpty)
      return report.areaDetails!;
    if (report.roadName != null && report.roadName!.isNotEmpty)
      return report.roadName!;
    if (report.districtName != null && report.districtName!.isNotEmpty)
      return report.districtName!;
    return 'Location not specified';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'submit':
        return const Color(0xFF2196F3);
      case 'in_progress':
      case 'in progress':
        return const Color(0xFFFF9800);
      case 'completed':
      case 'complete':
        return const Color(0xFF4CAF50);
      case 'rejected':
      case 'reject':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      case 'submitted':
      case 'submit':
        return 'Submitted';
      case 'completed':
      case 'complete':
        return 'Completed';
      case 'rejected':
      case 'reject':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
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

  String _getFullImageUrl(String imageUrl) {
    // If the URL is already complete, return it as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    // Otherwise, prepend the base URL
    const String baseUrl = 'https://rudra.assam.gov.in';
    // Remove leading slash if present to avoid double slashes
    final String cleanPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return '$baseUrl$cleanPath';
  }

  void _showImageViewer(
    BuildContext context,
    Data report, {
    bool showAfterFix = false,
  }) {
    // Collect after-fix photos from all officer reports
    final afterFixUrls = <String>[];
    if (showAfterFix && report.officerReports != null) {
      for (final officer in report.officerReports!) {
        if (officer.afterFixPhotos != null) {
          for (final photo in officer.afterFixPhotos!) {
            if (photo.photoUrl != null && photo.photoUrl!.isNotEmpty) {
              afterFixUrls.add(_getFullImageUrl(photo.photoUrl!));
            }
          }
        }
      }
    }

    // Citizen-submitted photos
    final citizenUrls =
        (report.images ?? [])
            .where((img) => img.imageUrl != null && img.imageUrl!.isNotEmpty)
            .map((img) => _getFullImageUrl(img.imageUrl!))
            .toList();

    // Decide what to show
    final bool hasAfterFix = afterFixUrls.isNotEmpty;
    final List<String> displayUrls =
        showAfterFix && hasAfterFix ? afterFixUrls : citizenUrls;
    final String title =
        showAfterFix && hasAfterFix
            ? 'After Fix Photos'
            : showAfterFix
            ? 'Submitted Photos (After fix not available yet)'
            : 'Submitted Photos';

    if (displayUrls.isEmpty) {
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
            height: 420,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
                    itemCount: displayUrls.length,
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
                            displayUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  color: AppPallet.primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Counter + label
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    displayUrls.length > 1
                        ? '${displayUrls.length} photos'
                        : '1 photo',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),

                // For completed: also offer to view citizen photos
                if (showAfterFix && hasAfterFix && citizenUrls.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showImageViewer(context, report, showAfterFix: false);
                    },
                    child: const Text('View original submitted photo'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
