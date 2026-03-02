import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rudra/config/constants/api_constants.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/assets.dart';
import 'package:rudra/config/utils/local_storage.dart';
import 'package:rudra/screens/profile/pages/info_screen.dart';
import 'package:rudra/screens/profile/provider/profile_provider.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).getProfileData();
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
          "Profile",
          style: TextStyle(
            color: AppPallet.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final profile = profileProvider.profile?.data?.profile;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppPallet.primaryColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: profile?.profilePhotoLink != null && profile?.profilePhotoLink != 'null'
                            ? Image.network(
                                "${ApiConstants.imageBaseUrl}${profile?.profilePhotoLink}",
                                fit: BoxFit.cover,
                                width: 70,
                                height: 70,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    Assets.profile,
                                    fit: BoxFit.cover,
                                    width: 70,
                                    height: 70,
                                  );
                                },
                              )
                            : Image.asset(
                                Assets.profile,
                                fit: BoxFit.cover,
                                width: 70,
                                height: 70,
                              ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.name ?? "User",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppPallet.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile?.address ?? "No address provided",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppPallet.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Settings
                _buildSectionHeader("Account"),
                Container(
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
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.edit_outlined,
                        title: "Edit Profile",
                        onTap: () => context.push("/editProfile"),
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () async {
                          await TokenHandler.clear();
                          context.go("/enableLocation");
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Support & Info
                _buildSectionHeader("Support & Info"),
                Container(
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
                  child: Column(
                    children: [
                      _buildListTile(
                        icon: Icons.info_outline_rounded,
                        title: "About PWD Assam Initiative",
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (_) => const AboutPWDScreen()));
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.description_outlined,
                        title: "Terms & Conditions",
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (_) => const TermsAndConditionsScreen()));
                        },
                      ),
                      _buildDivider(),
                      _buildListTile(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppPallet.textSecondary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppPallet.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppPallet.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? AppPallet.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.05),
      indent: 60,
    );
  }
}
