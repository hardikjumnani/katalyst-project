import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shakala/services/api_client.dart';
// import 'package:shakala/sheets/dispose_time_sheet.dart';

final secureStorage = FlutterSecureStorage();
final dio = Dio();
class CreateMomentSheet extends StatefulWidget {
  const CreateMomentSheet({super.key});

  @override
  State<CreateMomentSheet> createState() => _CreateMomentSheetState();
}

class _CreateMomentSheetState extends State<CreateMomentSheet> {
  final apiClient = ApiClient();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xff2a2a2a),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar with close button
                      Padding(
                        padding: EdgeInsets.fromLTRB(15, 20, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Create Moment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
            
                      // Title Field
                      Column(
                        children: [
                          TextField(
                            maxLines: 1,
                            maxLength: 128,
                            controller: _titleController,
                            decoration: InputDecoration(
                              counterText: '',
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xff7e68e3),
                                  width: 1.0,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(8),
                              hint: Text(
                                'Wanna give it any title ...?',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            style: TextStyle(
                              height: 1.0,
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
      
                          // Description Field
                          TextField(
                            maxLines: null,
                            minLines: 20,
                            maxLength: 2048,
                            controller: _descriptionController,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            scrollPhysics: BouncingScrollPhysics(),
                            decoration: InputDecoration(
                              counterText: '',
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xff7e68e3),
                                  width: 1.0,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(6),
                              hint: Text(
                                'Description',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                            style: TextStyle(height: 1.0, color: Colors.white),
                          ),
                          _selectedImage != null
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(_selectedImage!, height: 400,),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
            
                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Select Image
                        IconButton(
                          icon: Icon(Icons.image, color: Colors.white, size: 35),
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 30,
                            );
            
                            if (image != null) {
                              setState(() {
                                _selectedImage = File(image.path);
                                _selectedImagePath = image.path;
                              });
                            }
                          },
                        ),
            
                        // Publish Button
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                          height: 50,
                          width: 180,
                          child: SizedBox(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () async {
                                  String description = _descriptionController.text.trim();
                                  if (description.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Error"),
                                          content: Text("Please enter a description."),
                                          actions: [
                                            TextButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {
                                    await apiClient.post(
                                      '${ApiClient.baseBackendUrl}/moments/create/',
                                      'from',
                                      buildFormData,
                                      auth: true,
                                    );

                                    if (!mounted) return;

                                    setState(() {
                                      isLoading = false;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Swipe down to refresh. New moments found."),
                                        backgroundColor: Color(0xffa393eb),
                                      ),
                                    );

                                    Navigator.pop(context);
                                  } catch (e) {
                                    if (!mounted) return;

                                    setState(() {
                                      isLoading = false;
                                    });

                                    String errorMessage = "Something went wrong. Please try again.";

                                    if (e is DioException && e.response != null) {
                                      final data = e.response?.data;
                                      if (data is Map && data.containsKey("detail")) {
                                        errorMessage = "Error: ${data["detail"]}";
                                      } else if (data is Map && data.isNotEmpty) {
                                        // Try to show any field-level error if available
                                        final firstError = data.values.first;
                                        errorMessage = firstError is List ? firstError.first.toString() : firstError.toString();
                                      }
                                    }

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Error"),
                                          content: Text(errorMessage),
                                          actions: [
                                            TextButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                /*
                                onPressed: () async {
                                  try {
                                    if (_descriptionController.text.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Description field can't be empty.",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                        
                                    setState(() {
                                      isLoading = true;
                                    });
                                        
                                    // Map<String, dynamic> formDataMap = {
                                    //   "title": _titleController.text.trim(),
                                    //   "description": _descriptionController.text.trim(),
                                    // };
                                        
                                    // if (_selectedImagePath != null) {
                                    //   formDataMap["image"] =
                                    //       await MultipartFile.fromFile(
                                    //         _selectedImagePath!,
                                    //         filename: basename(
                                    //           _selectedImagePath!,
                                    //         ), // Extract just the file name
                                    //       );
                                    // }
                                    final dio = Dio();
                                    final secureStorage = FlutterSecureStorage();
                                    final response = await dio.post(
                                      '${ApiClient.baseBackendUrl}/moments/create/',
                                      data: buildFormData(),
                                      options: Options(
                                        headers: {
                                          'Authorization':
                                              'Bearer ${await secureStorage.read(key: "access_token")}',
                                          'Content-Type':
                                              'multipart/form-data', // if you're sending form data
                                        },
                                      ),
                                    );
                                        
                                    _titleController.text = '';
                                    _descriptionController.text = '';
                                    _selectedImage = null;
                                        
                                    if (!mounted) return;
                                    setState(() {
                                      isLoading = false;
                                    });
                                        
                                    print(response.data);
                                        
                                    // Navigator.pop(context);
                                  } on DioException catch (e) {
                                    if (!mounted) return;
                                    setState(() {
                                      isLoading = false;
                                    });
                                        
                                    if (e.response != null) {
                                      final data = e.response!.data;
                                      print(e.response);
                                        
                                      if (data is Map) {
                                        if (data.containsKey("detail")) {
                                          final error = data["detail"];
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Error: ${error}"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } else {
                                          // Fallback for other server-side validation errors
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Registration failed. Please check your input.",
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        // Response is not a Map, can't handle it safely
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Unexpected server response.",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      // No response (e.g. network failure)
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Network error. Please try again.",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                */
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Color(0xffffffff),
                                  backgroundColor: Color(0xffa393eb),
                                  side: BorderSide(
                                    color: Color(0xffa393eb),
                                    width: 2.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  minimumSize: Size(0, 40),
                                ),
                                child: isLoading == true
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('Publish'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FormData buildFormData() {
    Map<String, dynamic> formDataMap = {
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
    };

    if (_selectedImagePath != null) {
      formDataMap["image"] = MultipartFile.fromFileSync(
        _selectedImagePath!,
        filename: basename(_selectedImagePath!),
      );
    }

    return FormData.fromMap(formDataMap);
  }

  /*
  Future<void> refreshRun(String url, String type, Map<String, dynamic> data) async {
    bool refreshed = await refreshToken();
    if (refreshed) {
      String? newAccessToken = await secureStorage.read(key: 'access_token');

      if (newAccessToken == null) {
        print('Access token is null after refresh');
        // Handle missing token, e.g., force logout
        return;
      }

      try {
        String contentType;
        switch (type) {
          case 'json':
            contentType = 'application/json';
            break;
          case 'form':
            contentType = 'multipart/form-data';
            break;
          default:
            contentType = 'application/json';
        }
        final retryResponse = await dio.post(
          url,
          data: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $newAccessToken',
              'Content-Type': contentType,
            },
          ),
        );

        print('Request successful after token refresh: ${retryResponse.data}');
      } catch (e) {
        print('Request failed after token refresh: $e');
        // Optionally handle request failure here
      }
    } else {
      print('Failed to refresh token');
      // Redirect to login or show an error
    }
  }

  Future<void> createMoment() async {
    try {
      // Get the access token
      String? accessToken = await secureStorage.read(key: 'access_token');
    
      final response = await dio.post(
        '${ApiClient.baseBackendUrl}/moments/create/',
        data: buildFormData(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('Moment created successfully: ${response.data}');
    } on DioException catch (e) {
      // If access token is expired (401), try to refresh it
      if (e.response?.statusCode == 401) {
        
      } else {
        // Other errors
        print('Request failed: ${e.message}');
      }
    }
  }
  */

  // void _showDisposeTimeSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) => const DisposeTimeSheet(),
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //   );
  // }
}
