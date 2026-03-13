import 'package:flutter/material.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/config/theme/app_pallet.dart';

class TrackReportBottomSheet extends StatefulWidget {
  final int caseId;
  final String caseNo;

  const TrackReportBottomSheet({
    Key? key,
    required this.caseId,
    required this.caseNo,
  }) : super(key: key);

  @override
  State<TrackReportBottomSheet> createState() => _TrackReportBottomSheetState();
}

class _TrackReportBottomSheetState extends State<TrackReportBottomSheet> {
  final HTTP _apiService = HTTP();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _trackingData = [];

  @override
  void initState() {
    super.initState();
    _fetchTrackingData();
  }

  Future<void> _fetchTrackingData() async {
    try {
      final response = await _apiService.get(
        url: '/pothole/citizen-case-track',
        queryParameters: {'case_id': widget.caseId},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        if (mounted) {
          setState(() {
            _trackingData = response.data['data'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                response.data['message'] ?? 'Failed to load tracking info';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'An error occurred while loading tracking information.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Track Report',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppPallet.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Report ID: ${widget.caseNo}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppPallet.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(
                                color: AppPallet.primaryColor,
                              ),
                            ),
                          )
                        else if (_errorMessage != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else if (_trackingData.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tracking updates found for this report yet.',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          _buildTimeline(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _trackingData.length,
      itemBuilder: (context, index) {
        final item = _trackingData[index];
        final isLast = index == _trackingData.length - 1;
        final isFirst = index == 0;

        // Determine icons and colors based on task/status
        final task = item['task']?.toString() ?? '';
        final status = item['case_status']?.toString() ?? '';

        IconData iconData = Icons.circle;
        Color iconColor = AppPallet.primaryColor;

        if (task.toLowerCase().contains('rejected')) {
          iconData = Icons.cancel;
          iconColor = Colors.red;
        } else if (task.toLowerCase().contains('closed') ||
            status.toLowerCase() == 'completed') {
          iconData = Icons.check_circle;
          iconColor = Colors.green;
        } else if (task.toLowerCase().contains('submitted')) {
          iconData = Icons.publish;
          iconColor = Colors.blue;
        } else {
          iconData = Icons.pending;
          iconColor = Colors.orange;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and icon
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    // Top line
                    if (!isFirst)
                      Container(width: 2, height: 20, color: Colors.grey[300])
                    else
                      const SizedBox(height: 20),

                    // Icon
                    Icon(iconData, color: iconColor, size: 24),

                    // Bottom line
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2, color: Colors.grey[300]),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.isNotEmpty ? task : "Status Update",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppPallet.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (item['remarks'] != null &&
                          item['remarks'].toString().isNotEmpty &&
                          item['remarks'].toString() != "null")
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            item['remarks'].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppPallet.textSecondary,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(item['created_at']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (item['user_designation'] != null &&
                              item['user_designation'].toString() !=
                                  "null") ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['user_designation'].toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString.toString()).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.toString();
    }
  }
}
