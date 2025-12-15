import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/config/utils/assets.dart';
import 'package:pothole/config/utils/local_storage.dart';
import 'package:pothole/screens/profile/provider/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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
      appBar: AppBar(title: Text("Profile"), automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Consumer<ProfileProvider>(
                    builder: (context, profileProvider, child) {
                      if (profileProvider.profile != null) {
                        return Row(
                          spacing: 10,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                "${Constants.baseUrl}${profileProvider.profile?.data?.profile?.profilePhotoLink}",
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    Assets.profile,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  profileProvider
                                          .profile
                                          ?.data
                                          ?.profile
                                          ?.name ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  profileProvider
                                          .profile
                                          ?.data
                                          ?.profile
                                          ?.address ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ],
              ),
            ),

            ListTile(
              onTap: () => context.push("/editProfile"),
              leading: Icon(Icons.edit, color: AppPallet.primaryColor),
              title: Text(
                "Edit Profile",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right, size: 16),
            ),
            Divider(endIndent: 2.h, indent: 2.h),
            // ListTile(
            //   leading: Icon(
            //     Icons.notifications_outlined,
            //     color: AppPallet.primaryColor,
            //   ),
            //   title: Text(
            //     "Notification Settings",
            //     style: TextStyle(fontWeight: FontWeight.w600),
            //   ),
            //   trailing: Switch(value: false, onChanged: (val) {}),
            // ),
            // Divider(endIndent: 2.h, indent: 2.h),
            ListTile(
              leading: Image.asset(Assets.terms, height: 20, width: 20),
              title: Text(
                "Terms & Conditions",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right, size: 16),
            ),
            Divider(endIndent: 2.h, indent: 2.h),
            ListTile(
              leading: Image.asset(Assets.privecy, height: 20, width: 20),
              title: Text(
                "Privacy Policy",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right, size: 16),
            ),
            Divider(endIndent: 2.h, indent: 2.h),
            ListTile(
              leading: Icon(Icons.call, color: AppPallet.primaryColor),
              title: Text(
                "Contact Support",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right, size: 16),
            ),
            Divider(endIndent: 2.h, indent: 2.h),
            ListTile(
              leading: Image.asset(Assets.version, height: 20, width: 20),
              title: Text(
                "App Version 1.0.5",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right, size: 16),
            ),
            Divider(endIndent: 2.h, indent: 2.h),
            ListTile(
              leading: Image.asset(Assets.logo, height: 20, width: 20),
              title: Text(
                "About PWD Assam Initiative",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right, size: 16),
            ),
            Divider(endIndent: 2.h, indent: 2.h),
            ListTile(
              onTap: () async {
                await TokenHandler.clear();
                context.go("/enableLocation");
              },
              leading: Icon(
                Icons.logout_outlined,
                color: AppPallet.primaryColor,
              ),
              title: Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(Icons.chevron_right, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
