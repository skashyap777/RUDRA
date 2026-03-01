import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rudra/config/router/routes.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/screens/auth/provider/auth_provide.dart';
import 'package:rudra/screens/home/provider/home_provider.dart';
import 'package:rudra/screens/notifications/provider/notification_provider.dart';
import 'package:rudra/screens/profile/provider/profile_provider.dart';
import 'package:rudra/screens/reports/provider/report_provider.dart';
import 'package:rudra/config/services/firebase_messaging_service.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Push Notifications
  await FirebaseMessagingService().initNotifications();

  // iOS-style status bar (light icons on dark AppBar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            title: 'RUDRA',
            theme: ThemeData(
              // ── iOS-style global scroll physics ──────────────
              platform: TargetPlatform.iOS,

              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                  backgroundColor: AppPallet.buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // iOS-style radius
                  ),
                  elevation: 0, // iOS buttons are flat
                ),
              ),

              // ── Input decoration ──────────────────────────────
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF2F2F7), // iOS system gray 6
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppPallet.primaryColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),

              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,

              appBarTheme: const AppBarTheme(
                backgroundColor: AppPallet.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true, // iOS centers titles
                titleTextStyle: TextStyle(
                  fontSize: 17, // iOS standard AppBar title size
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              // ── Adaptive progress indicator ───────────────────
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: AppPallet.primaryColor,
              ),
            ),
            routerConfig: Routes.router,
          ),
        );
      },
    );
  }
}

