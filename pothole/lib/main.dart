import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pothole/config/router/routes.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/screens/auth/provider/auth_provide.dart';
import 'package:pothole/screens/home/provider/home_provider.dart';
import 'package:pothole/screens/notifications/provider/notification_provider.dart';
import 'package:pothole/screens/profile/provider/profile_provider.dart';
import 'package:pothole/screens/reports/provider/report_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => HomeProvider()),
            ChangeNotifierProvider(create: (context) => AuthProvider()),
            ChangeNotifierProvider(create: (context) => ProfileProvider()),
            ChangeNotifierProvider(create: (context) => ReportProvider()),
            ChangeNotifierProvider(create: (context) => NotificationProvider()),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Rely Gate',
            theme: ThemeData(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                  backgroundColor: AppPallet.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: AppPallet.primaryColor,
                foregroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            routerConfig: Routes.router,
          ),
        );
      },
    );
  }
}
