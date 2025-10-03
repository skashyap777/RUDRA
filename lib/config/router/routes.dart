import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:rudra/screens/auth/pages/complete_profile.dart';
import 'package:rudra/screens/auth/pages/enable_location.dart';
import 'package:rudra/screens/auth/pages/login.dart';
import 'package:rudra/screens/auth/pages/onboarding.dart';
import 'package:rudra/screens/auth/pages/otp_enter_screen.dart';
import 'package:rudra/screens/auth/pages/splash.dart';
import 'package:rudra/screens/auth/pages/welcome.dart';
import 'package:rudra/screens/home/pages/home.dart';
import 'package:rudra/screens/home/pages/pothole_detected_screen.dart';
import 'package:rudra/screens/home/pages/pothole_scanner.dart';
import 'package:rudra/screens/home/pages/scan_pothhole.dart';
import 'package:rudra/screens/home/pages/no_pothole_detected_screen.dart';
import 'package:rudra/screens/profile/pages/edit_profile.dart';

class Routes {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => Splash()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingScreen(),
      ),
      GoRoute(
        path: '/enableLocation',
        builder: (context, state) => EnableLocation(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => LoginWithMobileScreen(),
      ),
      GoRoute(
        path: '/enterOtp',
        builder: (context, state) {
          final mobileNumber = state.extra as String;
          return OtpEnterScreen(mobileNumber: mobileNumber);
        },
      ),
      GoRoute(
        path: '/completeProfile',
        builder: (context, state) => CompleteProfileScreen(),
      ),

      GoRoute(path: '/welcome', builder: (context, state) => WelcomeScreen()),
      GoRoute(path: '/home', builder: (context, state) => Home()),
      GoRoute(
        path: '/scanpothole',
        builder: (context, state) => ScanPothhole(file: state.extra as File),
      ),
      GoRoute(
        path: '/potholeDetected',
        builder:
            (context, state) =>
                PotholeDetectedScreen(file: state.extra as File),
      ),
      GoRoute(
        path: '/noPotholeDetected',
        builder:
            (context, state) =>
                NoPotholeDetectedScreen(file: state.extra as File),
      ),
      GoRoute(path: '/addPothole', builder: (context, state) => AddPothole()),

      // Profile routes
      GoRoute(path: '/editProfile', builder: (context, state) => EditProfile()),
    ],
  );
}
