import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:pothole/config/utils/app_functions.dart';
import 'package:pothole/config/utils/assets.dart';
import 'package:pothole/screens/auth/provider/auth_provide.dart';
import 'package:provider/provider.dart';

class EnableLocation extends StatefulWidget {
  const EnableLocation({super.key});

  @override
  State<EnableLocation> createState() => _EnableLocationState();
}

class _EnableLocationState extends State<EnableLocation> {
  final TextEditingController _pincodeController = TextEditingController();
  bool loading = false;
  Position? position;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      loading = true;
    });
    position = await AppFunctions.requestLocationPermission();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, store, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child:
                  loading
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Assets.location, height: 150),
                          const SizedBox(height: 32),

                          const Text(
                            'Check Your Area',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            "Let's confirm your location is within PWD Assam's jurisdiction",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 32),

                          OutlinedButton.icon(
                            onPressed: () async {
                              if (position != null) {
                                final res = await store.checkLocation(
                                  position!.latitude,
                                  position!.latitude,
                                );
                                if (res) {
                                  AppFunctions.showCustomSnackBar(
                                    context,
                                    "${store.checkLocationData?.message}",
                                    backgroundColor: Colors.black,
                                  );
                                } else {}
                              }
                            },
                            icon:
                                store.loading
                                    ? null
                                    : const Icon(
                                      Icons.my_location,
                                      color: Colors.green,
                                    ),
                            label:
                                store.loading
                                    ? SizedBox(
                                      height: 10,
                                      width: 10,
                                      child: CircularProgressIndicator(
                                        color: Colors.green,
                                      ),
                                    )
                                    : const Text(
                                      'Use my current location',
                                      style: TextStyle(color: Colors.green),
                                    ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'or',
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 24),

                          TextField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(7),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter your area Pincode',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                final pincode = _pincodeController.text.trim();
                                if (pincode.isEmpty || pincode.length < 6) {
                                  AppFunctions.showCustomSnackBar(
                                    context,
                                    "Please Enter 7-digit Pincode",
                                    backgroundColor: Colors.red,
                                  );
                                  return;
                                }
                                final res = await store.checkLocationWithpin(
                                  int.parse(pincode),
                                );
                                if (res) {
                                  context.go("/login");
                                } else {
                                  AppFunctions.showCustomSnackBar(
                                    context,
                                    "Service not available in your area",
                                    backgroundColor: Colors.red,
                                  );
                                }
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Verify My Location',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
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
