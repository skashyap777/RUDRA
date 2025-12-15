import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pothole/config/utils/app_functions.dart';
import 'package:pothole/config/utils/assets.dart';
import 'package:pothole/screens/profile/provider/profile_provider.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _profileImage;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Function to show image picker bottom sheet
  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _buildImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget for image picker options
  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Function to pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      Navigator.pop(context); // Close bottom sheet

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        // Upload the image
        final profileProvider = Provider.of<ProfileProvider>(
          context,
          listen: false,
        );
        final res = await profileProvider.updateProfilePhoto(_profileImage!);

        if (res) {
          AppFunctions.showCustomSnackBar(
            context,
            "Profile photo updated successfully!",
          );
        } else {
          AppFunctions.showCustomSnackBar(
            context,
            "Failed to update profile photo.",
          );
        }
      }
    } catch (e) {
      AppFunctions.showCustomSnackBar(
        context,
        "Error picking image: ${e.toString()}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        _nameController.text =
            profileProvider.profile?.data?.profile?.name ?? "";
        _locationController.text =
            profileProvider.profile?.data?.profile?.address ?? "";
        return Scaffold(
          appBar: AppBar(title: const Text("Edit Profile")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile image with edit indicator
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerBottomSheet,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                            _profileImage != null
                                ? FileImage(_profileImage!)
                                : (profileProvider
                                                .profile
                                                ?.data
                                                ?.profile
                                                ?.profilePhotoLink !=
                                            null
                                        ? NetworkImage(
                                          "${Constants.baseUrl}${profileProvider.profile?.data?.profile?.profilePhotoLink}",
                                        )
                                        : null)
                                    as ImageProvider?,
                        child:
                            _profileImage == null &&
                                    profileProvider
                                            .profile
                                            ?.data
                                            ?.profile
                                            ?.profilePhotoLink ==
                                        null
                                ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.black54,
                                )
                                : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePickerBottomSheet,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 0.1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 0.1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 0.1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Location field
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 0.1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 0.1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 0.1),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: () async {
                    final res = await profileProvider.updateUserName(
                      _nameController.text,
                    );
                    if (res) {
                      AppFunctions.showCustomSnackBar(
                        context,
                        "Profile updated successfully!",
                      );
                    } else {
                      AppFunctions.showCustomSnackBar(
                        context,
                        "Failed to update profile.",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Save Profile"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
