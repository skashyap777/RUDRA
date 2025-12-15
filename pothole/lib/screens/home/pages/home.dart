import 'package:flutter/material.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/config/utils/assets.dart';
import 'package:pothole/screens/home/pages/dashboard.dart';
import 'package:pothole/screens/notifications/pages/notifications.dart';
import 'package:pothole/screens/profile/pages/profile.dart';
import 'package:pothole/screens/reports/pages/report.dart';
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
        children: [Dashboard(), Report(), Notifications(), Profile()],
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
          pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
          setState(() {});
        },
      ),
    );
  }
}
