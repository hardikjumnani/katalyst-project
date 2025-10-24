import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shakala/services/api_client.dart';

class EditProfileDetailsSheet extends StatefulWidget {
  final String name;
  final String headline;
  final String profileImage;

  const EditProfileDetailsSheet({
    super.key,
    required this.name,
    required this.headline,
    required this.profileImage,
  });

  @override
  State<EditProfileDetailsSheet> createState() => _EditProfileDetailsSheetState();
}

class _EditProfileDetailsSheetState extends State<EditProfileDetailsSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _headlineController;
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _headlineController = TextEditingController(text: widget.headline);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 30);

    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xff222222),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Top bar with close button
            Padding(
              padding: EdgeInsets.fromLTRB(15, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Personal Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),
            
            // Card Form
            Row(
              children: [
                // Profile Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(20.0,),
                        child: Builder(
                          builder: (_) {
                            if (_profileImageFile != null) {
                              return Image.file(
                                _profileImageFile!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            } else if (widget.profileImage.isNotEmpty) {
                              return CachedNetworkImage(
                                imageUrl: '${ApiClient.baseBackendUrl}${widget.profileImage}',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 100,
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => Image.asset(
                                  'assets/images/empty_dp.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              return Image.asset(
                                'assets/images/empty_dp.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt, size: 20, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      
                // Profile Details
                Expanded(
                  child: Container(
                    height: 180,
                    padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: Color(0xff111111),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: TextField(
                                maxLines: 1,
                                maxLength: 64,
                                controller: _nameController,
                                keyboardType: TextInputType.multiline,
                                expands: false,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Full Name',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: Color(0xff111111),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: TextField(
                                maxLines: 2,
                                maxLength: 128,
                                controller: _headlineController,
                                keyboardType: TextInputType.multiline,
                                expands: false,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Headline',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          
            // Save Button
            SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                height: 45,
                width: 180,
                child: SizedBox(
                  child: ElevatedButton(
                    onPressed: () async {
                      final newName = _nameController.text.trim();
                      final newHeadline = _headlineController.text.trim();
      
                      if (newName.isEmpty || newHeadline.isEmpty) {
                        showInfoDialog(context, "Please fill all the fields.");
                        return;
                      }
      
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );
      
                      try {
                        final formData = FormData();
      
                        formData.fields.addAll([
                          MapEntry('name', newName),
                          MapEntry('headline', newHeadline),
                        ]);
      
                        // Only include profile_image if a new one is picked
                        if (_profileImageFile != null) {
                          final multipartFile = await MultipartFile.fromFile(
                            _profileImageFile!.path,
                            filename: "profile_image.jpg",
                          );
                          formData.files.add(MapEntry('profile_image', multipartFile));
                        }
      
                        final apiClient = ApiClient();
                        final response = await apiClient.patch(
                          '${ApiClient.baseBackendUrl}/users/me/',
                          formData,
                          auth: true,
                        );
      
                        Navigator.pop(context); // Close loading dialog
      
                        if (response != null) {
                          Navigator.pop(context, true); // Success
                        } else {
                          showInfoDialog(context, 'Failed to update details');
                        }
                      } catch (e) {
                        Navigator.pop(context); // Close loading dialog on error
                        showInfoDialog(context, 'Error occurred: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xffffffff),
                      backgroundColor: Color(0xffa393eb),
                      side: BorderSide(color: Color(0xffa393eb), width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('Save'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showInfoDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Warning"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
