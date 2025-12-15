import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pothole/config/theme/app_pallet.dart';
import 'package:pothole/config/utils/assets.dart';
import 'package:pothole/screens/auth/provider/auth_provide.dart';
import 'package:provider/provider.dart';

class LoginWithMobileScreen extends StatelessWidget {
  final TextEditingController _phoneController = TextEditingController();

  LoginWithMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, store, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(Assets.loginone, height: 180),
                  const SizedBox(height: 32),

                  const Text(
                    'Login with Mobile Number',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'We will send you the 4 digit verification code',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Text(
                          "+91",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      hintText: "Enter 10 digit mobile number",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final phone = _phoneController.text.trim();

                        // Validation
                        if (phone.isEmpty ||
                            phone.length != 10 ||
                            !RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid 10-digit mobile number',
                              ),
                            ),
                          );
                          return;
                        }

                        final res = await store.generateOtp(phone);
                        if (res) {
                          context.push("/enterOtp", extra: phone);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallet.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Generate OTP',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: const [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "or Sign in using",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {},
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
          ),
        );
      },
    );
  }
}
