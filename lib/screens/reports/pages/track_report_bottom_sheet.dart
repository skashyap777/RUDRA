import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rudra/config/network/dio.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/app_functions.dart';
import 'package:rudra/screens/reports/provider/report_provider.dart';

class TrackReportBottomSheet extends StatefulWidget {
  final int caseId;
  final String caseNo;
  final String? createdAt;
  final String? pendingAt;
  final String? status;

  const TrackReportBottomSheet({
    Key? key,
    required this.caseId,
    required this.caseNo,
    this.createdAt,
    this.pendingAt,
    this.status,
  }) : super(key: key);

  @override
  State<TrackReportBottomSheet> createState() => _TrackReportBottomSheetState();
}

class _TrackReportBottomSheetState extends State<TrackReportBottomSheet> {
  final HTTP _apiService = HTTP();
  bool _isLoading = true;
  bool _isSendingReminder = false;
  String? _errorMessage;
  List<dynamic> _trackingData = [];
  bool _reminderSent = false;
  String? _reminderFeedback;

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
            _trackingData = List.from(response.data['data'] ?? []);
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

  Future<void> _handleSendFormalReminder() async {
    setState(() {
      _isSendingReminder = true;
    });

    final provider = Provider.of<ReportProvider>(context, listen: false);
    final result = await provider.sendFormalReminder(
      caseId: widget.caseId,
      caseNo: widget.caseNo,
    );

    if (mounted) {
      setState(() {
        _isSendingReminder = false;
        _reminderSent = true;
        _reminderFeedback = result['message'];

        // Inject dynamic reminder node into local timeline view for immediate visual feedback
        _trackingData.add({
          'task': 'Formal Reminder Sent to DLP Contractor & JE',
          'case_status': widget.status ?? 'in_progress',
          'remarks': 'Urgent escalation notification issued for delayed repair execution.',
          'created_at': DateTime.now().toIso8601String(),
          'user_designation': 'Citizen / Authority',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Formal reminder sent!'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  int _getCurrentStageIndex() {
    if (_trackingData.isEmpty) {
      final st = widget.status?.toLowerCase() ?? '';
      if (st.contains('complet') || st.contains('closed')) return 4;
      if (st.contains('progress')) return 3;
      return 1;
    }

    // Examine latest track tasks
    bool hasSubmitted = false;
    bool hasAssigned = false;
    bool hasContractorInformed = false;
    bool hasInProgress = false;
    bool hasCompleted = false;

    for (var item in _trackingData) {
      final task = (item['task'] ?? '').toString().toLowerCase();
      final status = (item['case_status'] ?? '').toString().toLowerCase();
      final desig = (item['user_designation'] ?? '').toString().toLowerCase();

      if (task.contains('submitted') || task.contains('reported')) hasSubmitted = true;
      if (task.contains('assigned') || desig.contains('engineer') || task.contains('je')) hasAssigned = true;
      if (task.contains('contractor') || task.contains('work order') || task.contains('informed')) hasContractorInformed = true;
      if (task.contains('progress') || status.contains('progress') || task.contains('inspection')) hasInProgress = true;
      if (task.contains('closed') || status.contains('complet') || task.contains('resolved')) hasCompleted = true;
    }

    if (hasCompleted) return 4;
    if (hasInProgress) return 3;
    if (hasContractorInformed) return 2;
    if (hasAssigned) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate elapsed time from initial submission or props
    String firstDateStr = widget.createdAt ?? '';
    if (firstDateStr.isEmpty && _trackingData.isNotEmpty) {
      firstDateStr = _trackingData.first['created_at']?.toString() ?? '';
    }
    final int elapsedDays = AppFunctions.getDaysElapsed(firstDateStr);
    final String elapsedText = AppFunctions.getDaysElapsedText(firstDateStr);

    final bool isCompleted = widget.status?.toLowerCase() == 'completed' ||
        widget.status?.toLowerCase() == 'complete';
    final bool isOverdue = !isCompleted && elapsedDays >= 7;

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
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Report ID Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '100% Complaint Tracking',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppPallet.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Report ID: ${widget.caseNo}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppPallet.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            // Days elapsed chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? Colors.red[50]
                                    : AppPallet.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isOverdue
                                      ? Colors.red[300]!
                                      : AppPallet.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isOverdue ? Icons.warning_amber_rounded : Icons.timer_outlined,
                                    size: 14,
                                    color: isOverdue ? Colors.red[700] : AppPallet.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    elapsedText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isOverdue ? Colors.red[700] : AppPallet.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Multi-stage tracker visual bar
                        _buildStageProgressBar(_getCurrentStageIndex()),

                        const SizedBox(height: 16),

                        // Accountability Banner (Pending with JE vs DLP Contractor)
                        if (widget.pendingAt != null || isOverdue)
                          _buildAccountabilityCard(isOverdue, elapsedDays),

                        const SizedBox(height: 16),

                        // Formal Reminder Action Button for Citizens/Engineers if delayed
                        if (!isCompleted)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ElevatedButton.icon(
                              onPressed: _isSendingReminder ? null : _handleSendFormalReminder,
                              icon: _isSendingReminder
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      _reminderSent ? Icons.check : Icons.notification_important_rounded,
                                      size: 18,
                                    ),
                              label: Text(
                                _reminderSent
                                    ? 'Formal Reminder Sent'
                                    : 'Send Formal Reminder to Contractor & JE',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _reminderSent ? Colors.green[700] : Colors.orange[800],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),

                        const Text(
                          'Stage Audit History',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppPallet.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

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
                              padding: const EdgeInsets.all(30),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else if (_trackingData.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No tracking updates found for this report yet.',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 15,
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

  Widget _buildStageProgressBar(int currentStage) {
    final stages = [
      'Reported',
      'Assigned (JE)',
      'Informed Contractor',
      'In Progress',
      'Fixed',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complaint Stage Progress',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppPallet.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(stages.length, (index) {
              final isPassed = index <= currentStage;
              final isCurrent = index == currentStage;
              final isLast = index == stages.length - 1;

              return Expanded(
                child: Row(
                  children: [
                    // Dot
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPassed
                            ? (isCurrent ? AppPallet.primaryColor : Colors.green[600])
                            : Colors.grey[300],
                        border: isCurrent
                            ? Border.all(color: AppPallet.primaryColor.withOpacity(0.3), width: 3)
                            : null,
                      ),
                      child: Center(
                        child: isPassed
                            ? Icon(
                                isCurrent ? Icons.circle : Icons.check,
                                size: isCurrent ? 8 : 12,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    // Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: index < currentStage ? Colors.green[600] : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(stages.length, (index) {
              final isPassed = index <= currentStage;
              return Expanded(
                child: Text(
                  stages[index],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isPassed ? FontWeight.bold : FontWeight.normal,
                    color: isPassed ? AppPallet.textPrimary : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountabilityCard(bool isOverdue, int elapsedDays) {
    final pendingRole = widget.pendingAt ?? 'DLP Contractor / Joint Engineer';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.amber[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOverdue ? Colors.amber[400]! : Colors.blue[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.error_outline : Icons.account_tree_outlined,
            color: isOverdue ? Colors.amber[900] : Colors.blue[800],
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? 'Responsibility & SLA Warning' : 'Current Stage Responsibility',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.amber[900] : Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    text: 'Currently Pending At: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.amber[900] : Colors.blue[900],
                    ),
                    children: [
                      TextSpan(
                        text: pendingRole,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOverdue)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Unresolved for $elapsedDays days! DLP Contractor or JE needs to expedite action.',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.amber[900],
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
        } else if (task.toLowerCase().contains('submitted') ||
            task.toLowerCase().contains('reported')) {
          iconData = Icons.publish;
          iconColor = Colors.blue;
        } else if (task.toLowerCase().contains('reminder') ||
            task.toLowerCase().contains('escalat')) {
          iconData = Icons.notification_important;
          iconColor = Colors.orange[800]!;
        } else {
          iconData = Icons.pending_actions;
          iconColor = Colors.orange;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and icon
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    // Top line
                    if (!isFirst)
                      Container(width: 2, height: 16, color: Colors.grey[300])
                    else
                      const SizedBox(height: 16),

                    // Icon
                    Icon(iconData, color: iconColor, size: 22),

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
                  padding: const EdgeInsets.only(bottom: 20, top: 12, left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.isNotEmpty ? task : "Status Update",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppPallet.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (item['remarks'] != null &&
                          item['remarks'].toString().isNotEmpty &&
                          item['remarks'].toString() != "null")
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            item['remarks'].toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppPallet.textSecondary,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppFunctions.formatIndianDateTime(item['created_at']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item['user_designation'] != null &&
                              item['user_designation'].toString() !=
                                  "null") ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.badge_outlined,
                              size: 13,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['user_designation'].toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
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
}

