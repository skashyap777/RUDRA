import 'package:flutter/material.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/screens/notifications/models/notifiction_model.dart';
import 'package:pothole/screens/notifications/provider/notification_provider.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppPallet.primaryColor,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildFilterChip(
                      'All',
                      _getNotificationCount(provider.notifications, 'All'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Unread',
                      _getNotificationCount(provider.notifications, 'Unread'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Read',
                      _getNotificationCount(provider.notifications, 'Read'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Mark all as read functionality
                      },
                      child: const Text(
                        'Mark as all read',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Notifications list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: groupedNotifications.keys.length,
                  itemBuilder: (context, index) {
                    String dateKey = groupedNotifications.keys.elementAt(index);
                    List<Data> dayNotifications =
                        groupedNotifications[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            dateKey,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Notifications for this date
                        ...dayNotifications
                            .map(
                              (notification) =>
                                  _buildNotificationCard(context, notification),
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

  Widget _buildNotificationCard(BuildContext context, Data notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.type ?? ''),
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Notification content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _formatTime(notification.createdAt ?? ''),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),

                // Show feedback button for completed repairs
                if (!(notification.feedBackProvided ?? false) &&
                    notification.type != "rejected")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                          width: 100,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return FeedbackForm(
                                    caseId: "${notification.caseId}",
                                    onSubmitted: () {
                                      print('Feedback submitted successfully');
                                    },
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallet.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Give Feedback',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
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
        return Icons.description;
      case 'repair':
        return Icons.build;
      case 'verification':
        return Icons.verified;
      default:
        return Icons.notifications;
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
  int? selectedRating;
  final TextEditingController _feedbackController = TextEditingController();

  final List<Map<String, dynamic>> ratings = [
    {'label': 'Bad', 'emoji': '😞', 'value': 1},
    {'label': 'Okay', 'emoji': '😐', 'value': 2},
    {'label': 'Good', 'emoji': '😊', 'value': 3},
    {'label': 'Amazing', 'emoji': '😁', 'value': 4},
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (selectedRating != null) {
      // Here you would typically send the feedback to your backend
      print('Rating: $selectedRating');
      print('Feedback: ${_feedbackController.text}');
      print('Case ID: ${widget.caseId}');
      Provider.of<NotificationProvider>(context, listen: false).submitFeedback(
        int.parse(widget.caseId.split('-').last),
        ratings.firstWhere((r) => r['value'] == selectedRating)['label'],
        _feedbackController.text,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );

      // Call the callback if provided
      if (widget.onSubmitted != null) {
        widget.onSubmitted!();
      }

      // Close the dialog
      Navigator.of(context).pop();
    } else {
      // Show error message if no rating selected
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with thumbs up icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.thumb_up, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Rate the Repair',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'Let us know how well the repair was done. Your feedback helps improve road safety.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 30),

            // Rating options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  ratings.map((rating) {
                    bool isSelected = selectedRating == rating['value'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = rating['value'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.green.withOpacity(0.1) : null,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? Colors.green : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              rating['emoji'],
                              style: TextStyle(
                                fontSize: 32,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              rating['label'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 30),

            // Optional feedback text
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: 'Tell us more '),
                    TextSpan(
                      text: '(Optional)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Feedback text field
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
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
