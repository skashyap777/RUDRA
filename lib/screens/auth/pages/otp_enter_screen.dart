import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:rudra/config/theme/app_pallet.dart';
import 'package:rudra/config/utils/assets.dart';
import 'package:rudra/screens/auth/provider/auth_provide.dart';
import 'package:rudra/screens/home/provider/home_provider.dart';
import 'package:provider/provider.dart';

class OtpEnterScreen extends StatefulWidget {
  final String mobileNumber;
  const OtpEnterScreen({super.key, required this.mobileNumber});

  @override
  State<OtpEnterScreen> createState() => _OtpEnterScreenState();
}

class _OtpEnterScreenState extends State<OtpEnterScreen> {
  final _otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, store, child) {
        return Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Assets.logintwo, height: 180),
                const SizedBox(height: 32),
                const Text(
                  'OTP Verification',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Enter the OTP send to +91 ${widget.mobileNumber}',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Pinput(length: 6, controller: _otpController),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive OTP? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final res = await store.resendOtp(widget.mobileNumber);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(res ? 'OTP Resent Successfully!' : 'Failed to resend OTP.'),
                             backgroundColor: res ? Colors.green : Colors.red,
                           ),
                          );
                        }
                      },
                      child: const Text(
                        "RESEND",
                        style: TextStyle(
                          color: AppPallet.buttonColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (_otpController.text.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid 6-digit OTP'),
                        ),
                      );
                      return;
                    }
                    final res = await store.verifyOtp(
                      widget.mobileNumber,
                      _otpController.text,
                    );
                    if (res) {
                      final res = await store.getProfileData();
                      if (res) {
                        // Refresh HomeProvider before navigating so Dashboard is ready
                        if (context.mounted) {
                          Provider.of<HomeProvider>(context, listen: false).getUserDetails();
                        }
                        if (store.profile!.data!.profile!.name != null &&
                            store.profile!.data!.profile!.name!.isNotEmpty) {
                          context.push("/home");
                        } else {
                          context.push("/completeProfile");
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to fetch profile data'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OTP verification failed'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallet.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Verify & Continue',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),

                SizedBox(height: 20),
                Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("-------------------------"),
                    Text("or Sign in using"),
                    Text("-------------------------"),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push("/completeProfile");
                    },
                    icon: Image.asset("assets/img/google.png", height: 20),
                    label: const Text(
                      'Google',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
