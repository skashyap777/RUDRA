import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:pothole/config/utils/app_functions.dart';
import 'package:pothole/screens/auth/provider/auth_provide.dart';
import 'package:provider/provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  File? profilePhoto;
  bool isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _uploadPhoto() async {
    profilePhoto = await AppFunctions.uploadFromDevice();
    setState(() {});
  }

  void _deletePhoto() {
    setState(() {
      profilePhoto = null;
    });
  }

  void _continue() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      final formData = FormData.fromMap({
        'name': _nameController.text,
        'com_address': _addressController.text,
        'profile_photo': await MultipartFile.fromFile(
          profilePhoto!.path,
          filename: profilePhoto!.path.split("/").last,
          contentType: DioMediaType('image', 'png'),
        ),
      });
      final res = await provider.createProfile(formData);
      if (res) {
        context.push("/welcome");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please provide your name and photo before continuing.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Name Field
              const Text(
                'Enter Name*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Address Field
              RichText(
                text: const TextSpan(
                  text: 'Enter Address for Communication',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Photo Section
              const Text(
                'Photo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Upload a clear photo of yourself for identification.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Photo Upload Section
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child:
                        profilePhoto != null
                            ? ClipOval(
                              child: Image.file(
                                profilePhoto!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                            : ClipOval(
                              child: Image.asset(
                                'assets/default_avatar.png', // Add a default avatar image
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _uploadPhoto,
                        icon: const Icon(
                          Icons.upload,
                          size: 16,
                          color: Colors.blue,
                        ),
                        label: const Text(
                          'Upload',
                          style: TextStyle(color: Colors.blue),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: profilePhoto != null ? _deletePhoto : null,
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color:
                                profilePhoto != null ? Colors.red : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700), // Golden yellow
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                          : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // Footer
              const Center(
                child: Text(
                  'Powered by PWD Assam • v1.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
