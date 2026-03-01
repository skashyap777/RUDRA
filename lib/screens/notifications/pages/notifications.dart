import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/screens/notifications/models/notifiction_model.dart';
import 'package:rudra/screens/notifications/provider/notification_provider.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  final void Function(String filter)? onNavigateToReports;
  const Notifications({super.key, this.onNavigateToReports});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications();
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
          'Notifications',
          style: TextStyle(
            color: AppPallet.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppPallet.primaryColor),
              );
            }

            // Error state — server returned an error
            if (provider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: Colors.red.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Failed to load notifications",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppPallet.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.red[700],
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "This is a server-side issue.\nPlease try again later.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.fetchNotifications();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallet.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No notifications found",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Filter notifications
            List<Data> filteredNotifications = _filterNotifications(
              provider.notifications,
            );

            // Group notifications by date
            Map<String, List<Data>> groupedNotifications =
                _groupNotificationsByDate(filteredNotifications);

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
                          'All',
                          _getNotificationCount(provider.notifications, 'All'),
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          'Unread',
                          _getNotificationCount(
                            provider.notifications,
                            'Unread',
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildFilterChip(
                          'Read',
                          _getNotificationCount(provider.notifications, 'Read'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Notifications list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedNotifications.keys.length,
                    itemBuilder: (context, index) {
                      String dateKey = groupedNotifications.keys.elementAt(
                        index,
                      );
                      List<Data> dayNotifications =
                          groupedNotifications[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                              top: 8,
                              left: 4,
                            ),
                            child: Text(
                              dateKey,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppPallet.textSecondary,
                              ),
                            ),
                          ),

                          // Notifications for this date
                          ...dayNotifications
                              .map(
                                (notification) => Dismissible(
                                  key: Key(notification.id.toString()),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  onDismissed: (direction) async {
                                    final success = await Provider.of<NotificationProvider>(context, listen: false).deleteNotification(notification.id!);
                                    if (!success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to delete notification')),
                                      );
                                      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
                                    }
                                  },
                                  child: _buildNotificationCard(
                                    context,
                                    notification,
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
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

  Widget _buildNotificationCard(BuildContext context, Data notification) {
    bool isUnread = !(notification.feedBackProvided ?? true);
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
            final status = notification.caseStatus?.toLowerCase().trim() ?? '';
            // Map caseStatus to ReportProvider filter strings
            String? filter;
            if (status == 'in_progress' || status == 'in progress') {
              filter = 'In progress';
            } else if (status == 'completed' || status == 'complete') {
              filter = 'Completed';
            } else if (status == 'rejected' || status == 'reject') {
              filter = 'Rejected';
            } else if (status == 'submitted' || status == 'submit') {
              filter = 'Submitted';
            }
            // Navigate to reports only for known statuses
            if (filter != null) {
              widget.onNavigateToReports?.call(filter);
            }
            // For others (null/unknown status) — do nothing, stay on notifications
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppPallet.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type ?? ''),
                    color: AppPallet.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    isUnread
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                color: AppPallet.textPrimary,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppPallet.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt ?? ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),

                      // Show feedback button for completed repairs
                      if (!(notification.feedBackProvided ?? false) &&
                          notification.type != "rejected")
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return FeedbackForm(
                                      caseId: "${notification.caseId}",
                                      onSubmitted: () {
                                        print(
                                          'Feedback submitted successfully',
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppPallet.primaryColor,
                                side: const BorderSide(
                                  color: AppPallet.primaryColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Give Feedback',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Data> _filterNotifications(List<Data> notifications) {
    if (selectedFilter == 'All') return notifications;
    if (selectedFilter == 'Unread') {
      return notifications.where((n) => !(n.feedBackProvided ?? true)).toList();
    }
    if (selectedFilter == 'Read') {
      return notifications.where((n) => n.feedBackProvided ?? false).toList();
    }
    return notifications;
  }

  int _getNotificationCount(List<Data> notifications, String filter) {
    if (filter == 'All') return notifications.length;
    if (filter == 'Unread') {
      return notifications.where((n) => !(n.feedBackProvided ?? true)).length;
    }
    if (filter == 'Read') {
      return notifications.where((n) => n.feedBackProvided ?? false).length;
    }
    return 0;
  }

  Map<String, List<Data>> _groupNotificationsByDate(List<Data> notifications) {
    Map<String, List<Data>> grouped = {};
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    for (var notification in notifications) {
      DateTime? notificationDate = DateTime.tryParse(
        notification.createdAt ?? '',
      );
      if (notificationDate != null) {
        DateTime dateOnly = DateTime(
          notificationDate.year,
          notificationDate.month,
          notificationDate.day,
        );
        String dateKey;

        if (dateOnly == today) {
          dateKey = 'Today';
        } else if (dateOnly == yesterday) {
          dateKey = 'Yesterday';
        } else {
          dateKey = '${dateOnly.day}/${dateOnly.month}/${dateOnly.year}';
        }

        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(notification);
      }
    }

    return grouped;
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'report':
        return Icons.description_outlined;
      case 'repair':
        return Icons.build_outlined;
      case 'verification':
        return Icons.verified_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(String dateTimeString) {
    DateTime? dateTime = DateTime.tryParse(dateTimeString);
    if (dateTime == null) return '';

    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} day ago';
    }
  }
}

class FeedbackForm extends StatefulWidget {
  final String caseId;
  final VoidCallback? onSubmitted;

  const FeedbackForm({Key? key, required this.caseId, this.onSubmitted})
    : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String? selectedRating;
  final TextEditingController _feedbackController = TextEditingController();

  final List<Map<String, dynamic>> ratings = [
    {'label': 'Bad',     'emoji': '😞', 'value': 'Bad'},
    {'label': 'Okay',    'emoji': '😐', 'value': 'Okay'},
    {'label': 'Good',    'emoji': '😊', 'value': 'Good'},
    {'label': 'Amazing', 'emoji': '😁', 'value': 'Amazing'},
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    HapticFeedback.mediumImpact();
    if (selectedRating != null) {
      Provider.of<NotificationProvider>(context, listen: false).submitFeedback(
        int.parse(widget.caseId.split('-').last),
        selectedRating!,
        _feedbackController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSubmitted?.call();
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Bouncing header icon ──────────────────────
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.4, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF34C759), Color(0xFF248A3D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF34C759).withOpacity(0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🛣️', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ─────────────────────────────────────
                  const Text(
                    'Rate the Repair',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'How well was the pothole fixed?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // ── Animated emoji rating row ─────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ratings.map((rating) {
                      final isSelected = selectedRating == rating['value'];
                      return _AnimatedEmojiOption(
                        emoji: rating['emoji'],
                        label: rating['label'],
                        isSelected: isSelected,
                        onTap: () =>
                            setState(() => selectedRating = rating['value']),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 26),

                  // ── Submit button — activates on selection ────
                  GestureDetector(
                    onTap: _submitFeedback,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: selectedRating != null
                            ? const LinearGradient(
                                colors: [Color(0xFF34C759), Color(0xFF248A3D)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade200,
                                  Colors.grey.shade200,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: selectedRating != null
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF34C759).withOpacity(0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          'Submit Feedback',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedRating != null
                                ? Colors.white
                                : Colors.grey.shade400,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Cancel link ───────────────────────────────
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated emoji rating option ─────────────────────────────────────────────
class _AnimatedEmojiOption extends StatefulWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedEmojiOption({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedEmojiOption> createState() => _AnimatedEmojiOptionState();
}

class _AnimatedEmojiOptionState extends State<_AnimatedEmojiOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_AnimatedEmojiOption old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward(from: 0);
    } else if (!widget.isSelected && old.isSelected) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? const Color(0xFF34C759).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF34C759)
                : Colors.grey.shade200,
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            ScaleTransition(
              scale: _scale,
              child: Text(widget.emoji, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.isSelected
                    ? const Color(0xFF34C759)
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Usage example - How to show the feedback form
class FeedbackExample extends StatelessWidget {
  const FeedbackExample({Key? key}) : super(key: key);

  void _showFeedbackDialog(BuildContext context, String caseId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FeedbackForm(
          caseId: caseId,
          onSubmitted: () {
            print('Feedback submitted successfully');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Example')),
      body: Center(
        child: ElevatedButton(
          onPressed:
              () => _showFeedbackDialog(context, 'IN1-AST-KA19-213-00164'),
          child: const Text('Show Feedback Form'),
        ),
      ),
    );
  }
}
