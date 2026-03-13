import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/screens/profile/provider/profile_provider.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // ── Step 1: Show warning / confirmation popup
  Future<void> _onSubmitTapped() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.heavyImpact();
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => _ConfirmationDialog(
        phoneNumber: _phoneController.text.trim(),
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () {
          Navigator.of(ctx).pop();
          _submitDeletionRequest();
        },
      ),
    );
  }

  // ── Step 2: Call API
  Future<void> _submitDeletionRequest() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      final result = await provider.requestAccountDeletion(
        mobileNumber: _phoneController.text.trim(),
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      switch (result) {
        case DeletionRequestResult.success:
          _showSuccessDialog();
          break;
        case DeletionRequestResult.alreadySubmitted:
          _showAlreadySubmittedDialog();
          break;
        case DeletionRequestResult.failed:
          _showErrorSnackBar('Failed to submit your request. Please try again.');
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      }
    }
  }

  // ── Step 3: Success popup → auto sign out
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => _SuccessDialog(
        onSignOut: () async {
          await TokenHandler.clear();
          if (mounted) context.go('/enableLocation');
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAlreadySubmittedDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => _AlreadySubmittedDialog(
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallet.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallet.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppPallet.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Account Deletion',
          style: TextStyle(
            color: AppPallet.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Warning Banner
                _WarningBanner(),
                const SizedBox(height: 28),

                // ── Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deletion Request Form',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppPallet.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Please enter your registered mobile number and an optional reason.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppPallet.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Phone Number Field
                      _buildLabel('Registered Mobile Number *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppPallet.textPrimary,
                          letterSpacing: 1.2,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Enter 10-digit mobile number',
                          prefixIcon: const Icon(Icons.phone_android_rounded,
                              color: AppPallet.primaryColor, size: 20),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mobile number is required';
                          }
                          if (value.trim().length != 10) {
                            return 'Enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Reason Field
                      _buildLabel('Reason for Deletion (Optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        maxLength: 500,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppPallet.textPrimary,
                          height: 1.5,
                        ),
                        decoration: _inputDecoration(
                          hint:
                              'Briefly describe why you want to delete your account…',
                          prefixIcon: null,
                          counterText: null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── What gets deleted section
                _WhatGetsDeletedCard(),
                const SizedBox(height: 32),

                // ── Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: _isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _onSubmitTapped,
                          icon: const Icon(Icons.delete_forever_rounded,
                              size: 22),
                          label: const Text(
                            'Request Account Deletion',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // ── Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPallet.textSecondary,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppPallet.textSecondary,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required Widget? prefixIcon,
    required String? counterText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade400,
      ),
      prefixIcon: prefixIcon,
      counterText: counterText ?? '',
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppPallet.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Warning Banner
// ─────────────────────────────────────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded,
                color: Colors.red.shade700, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Deletion is Permanent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Once your account deletion request is submitted, your account and all associated data will be permanently removed within 7–15 working days. This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// What Gets Deleted Card
// ─────────────────────────────────────────────────────────────────────────────

class _WhatGetsDeletedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Colors.orange.shade600, size: 18),
              const SizedBox(width: 8),
              const Text(
                'What will be deleted',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPallet.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDeletionItem(
              Icons.person_outline_rounded,
              'Your profile information and account data',
              Colors.red.shade400),
          _buildDeletionItem(
              Icons.phone_android_rounded,
              'Your registered mobile number association',
              Colors.red.shade400),
          _buildDeletionItem(
              Icons.report_outlined,
              'All pothole reports submitted by you',
              Colors.red.shade400),
          _buildDeletionItem(
              Icons.location_on_outlined,
              'Location history linked to your reports',
              Colors.red.shade400),
          const Divider(height: 24),
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  color: Colors.green.shade600, size: 18),
              const SizedBox(width: 8),
              const Text(
                'What is retained',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPallet.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDeletionItem(
              Icons.gavel_rounded,
              'Records required under government laws (up to 90 days)',
              Colors.green.shade500),
          _buildDeletionItem(
              Icons.receipt_long_rounded,
              'Audit logs retained for compliance purposes',
              Colors.green.shade500),
        ],
      ),
    );
  }

  Widget _buildDeletionItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppPallet.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirmation Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmationDialog extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmationDialog({
    required this.phoneNumber,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_forever_rounded,
                  color: Colors.red.shade600, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Confirm Account Deletion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppPallet.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You are about to request the permanent deletion of your RUDRA account associated with:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_android_rounded,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '+91 $phoneNumber',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppPallet.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Consequences list
            _ConsequenceItem(
                icon: Icons.timer_outlined,
                text: 'Account will be deleted within 7–15 working days'),
            _ConsequenceItem(
                icon: Icons.report_off_outlined,
                text: 'All your reports will be permanently removed'),
            _ConsequenceItem(
                icon: Icons.no_accounts_outlined,
                text: 'You will be logged out immediately'),
            _ConsequenceItem(
                icon: Icons.warning_amber_rounded,
                text: 'This action CANNOT be undone',
                isRed: true),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPallet.textSecondary,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Yes, Delete',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsequenceItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isRed;

  const _ConsequenceItem({
    required this.icon,
    required this.text,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 15,
              color: isRed ? Colors.red.shade600 : Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: isRed ? Colors.red.shade700 : Colors.grey.shade700,
                height: 1.4,
                fontWeight:
                    isRed ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success Dialog  (auto-signs out after 4-second countdown)
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessDialog extends StatefulWidget {
  final Future<void> Function() onSignOut;

  const _SuccessDialog({required this.onSignOut});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  int _secondsLeft = 4;
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();

    // Smooth ring animation (full circle in 4 s)
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    // Tick every second and sign out when done
    _tick();
  }

  Future<void> _tick() async {
    for (int i = _secondsLeft; i >= 1; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _secondsLeft = i - 1);
    }
    // Time's up — pop dialog then sign out
    if (mounted) Navigator.of(context).pop();
    await widget.onSignOut();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Countdown ring with check icon
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (_, __) => CircularProgressIndicator(
                      value: _ringController.value,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppPallet.primaryColor),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppPallet.primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppPallet.primaryColor,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Request Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppPallet.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your account deletion request has been received.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppPallet.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            // 7-15 days info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FBF7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppPallet.primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPallet.primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hourglass_bottom_rounded,
                        color: AppPallet.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Your account will be permanently deleted within 7–15 working days.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppPallet.textPrimary,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Auto sign-out countdown
            Text(
              'Signing you out in $_secondsLeft second${_secondsLeft == 1 ? '' : 's'}…',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Already Submitted Dialog  (409 response)
// ─────────────────────────────────────────────────────────────────────────────

class _AlreadySubmittedDialog extends StatelessWidget {
  final VoidCallback onClose;

  const _AlreadySubmittedDialog({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.78;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.amber.shade700,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Request Already Submitted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppPallet.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A deletion request for this mobile number has already been received and is currently being processed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.timer_outlined,
                        color: Colors.amber.shade700,
                        text: 'Your account will be deleted within 7–15 working days.',
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.block_rounded,
                        color: Colors.amber.shade700,
                        text: 'You cannot submit another request while one is pending.',
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.support_agent_rounded,
                        color: Colors.amber.shade700,
                        text:
                            'Contact PWD Assam support at pwddev2025@gmail.com for further assistance.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.amber.shade900,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
