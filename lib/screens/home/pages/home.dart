import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/assets.dart';
import 'package:rudra/screens/home/pages/dashboard.dart';
import 'package:rudra/screens/notifications/pages/notifications.dart';
import 'package:rudra/screens/profile/pages/profile.dart';
import 'package:rudra/screens/reports/pages/report.dart';
import 'package:rudra/screens/reports/provider/report_provider.dart';
import 'package:sizer/sizer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  PageController pageController = PageController();

  final List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      icon: Image.asset(Assets.home, height: 2.h, width: 2.h),
      activeIcon: Image.asset(
        Assets.home,
        height: 2.h,
        width: 2.h,
        color: AppPallet.primaryColor,
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(Assets.report, height: 2.h, width: 2.h),
      activeIcon: Image.asset(
        Assets.report,
        height: 2.h,
        width: 2.h,
        color: AppPallet.primaryColor,
      ),
      label: 'Report',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(Assets.notification, height: 2.h, width: 2.h),
      activeIcon: Image.asset(
        Assets.notification,
        height: 2.h,
        width: 2.h,
        color: AppPallet.primaryColor,
      ),
      label: 'Notification',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(Assets.profile, height: 2.h, width: 2.h),
      activeIcon: Image.asset(
        Assets.profile,
        height: 2.h,
        width: 2.h,
        color: AppPallet.primaryColor,
      ),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    getOutsideCategory();
    getEmployeeCategory();
  }

  Future<void> getOutsideCategory() async {
    // final provider = Provider.of<HomeProvider>(context, listen: false);
    // provider.getOutsideCategory();
  }

  Future<void> getEmployeeCategory() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          Dashboard(
            onViewAllReports: () {
              pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          Report(),
          Notifications(
            onNavigateToReports: (String filter) {
              // Set the filter on ReportProvider then jump to Reports tab
              Provider.of<ReportProvider>(context, listen: false)
                  .updateFilter(filter);
              pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          Profile()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: AppPallet.primaryColor),
        currentIndex: _currentIndex,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        items: _items,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppPallet.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          HapticFeedback.selectionClick(); // iOS-style haptic on tab switch
          pageController.jumpToPage(index); // instant switch — iOS style
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
