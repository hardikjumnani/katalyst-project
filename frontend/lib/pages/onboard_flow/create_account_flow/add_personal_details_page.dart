import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/pages/onboard_flow/create_account_flow/account_created_info_page.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/services/wrappers.dart';

class AddPersonalDetailsPage extends StatefulWidget {
  final User data;

  const AddPersonalDetailsPage({super.key, required this.data});

  @override
  State<AddPersonalDetailsPage> createState() => _AddPersonalDetailsPageState();
}

class _AddPersonalDetailsPageState extends State<AddPersonalDetailsPage> {
  final secureStorage = FlutterSecureStorage();

  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _headlineController;
  late final TextEditingController _emailController;
  late final TextEditingController _countryCodeController;
  late final TextEditingController _phoneNoController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;

  String? _selectedGender;
  bool _isLoading = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Rather not say'
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    if (pickedFile != null) {
      safeSetState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _profileImageFile = (widget.data.profileImage != null &&
            widget.data.profileImage!.isNotEmpty)
        ? File(widget.data.profileImage!)
        : null;

    _nameController = TextEditingController(text: widget.data.name ?? "");
    _headlineController = TextEditingController(text: widget.data.headline ?? "");
    _emailController = TextEditingController(text: widget.data.email ?? "");
    // _countryCodeController = TextEditingController(text: widget.data.countryCode ?? "+91");
    _phoneNoController = TextEditingController(text: widget.data.phoneNo ?? "");
    _cityController = TextEditingController(text: widget.data.city ?? "");
    _stateController = TextEditingController(text: widget.data.state ?? "");
    _countryController = TextEditingController(text: widget.data.country ?? "");
    _selectedGender = (widget.data.gender != null)
        ? toCapitalCase(widget.data.gender!)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2a2a2a),
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _handleBackNavigation(),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                  Text(
                    'Personal Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(width: 24),
                ],
              ),
            ),
          ),
          Divider(color: Colors.white12, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your personal information to complete your account',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Profile Image
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3a3a3a),
                                border: Border.all(
                                  color: const Color(0xffa393eb),
                                  width: 2,
                                ),
                              ),
                              child: _profileImageFile != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _profileImageFile!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white54,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xffa393eb),
                                    border: Border.all(
                                      color: const Color(0xff2a2a2a),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Profile Picture',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Bio Section
                  Text(
                    'Bio Information',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Full Name*',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(_nameController, 'Enter your full name',
                      maxLines: 1, maxlen: 64),

                  const SizedBox(height: 16),
                  Text(
                    'Headline',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(_headlineController,
                      'e.g. Software Engineer at Company',
                      maxLines: 1, maxlen: 128),

                  const SizedBox(height: 16),
                  Text(
                    'Gender*',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildGenderDropdown(),

                  const SizedBox(height: 32),
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Email Address*',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(_emailController,
                      'your.email@example.com',
                      maxLines: 1,
                      maxlen: 256,
                      icon: Icons.email_outlined),

                  const SizedBox(height: 16),
                  Text(
                    'Phone Number*',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Country code field
                      SizedBox(
                        width: 100,
                        child: _buildTextField(
                          _countryCodeController,
                          '+91',
                          maxLines: 1,
                          maxlen: 4,
                          icon: Icons.flag_outlined,
                          type: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Phone no
                      Expanded(
                        child: _buildTextField(_phoneNoController, '1234567890',
                            maxLines: 1,
                            maxlen: 13,
                            icon: Icons.phone_outlined,
                            type: TextInputType.phone),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'Location',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
/*
                  CSCPicker(
                    layout: Layout.horizontal,
                    flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,

                    onCountryChanged: (country) {
                      safeSetState(() {
                        _countryController.text = country;
                      });
                    },
                    onStateChanged: (state) {
                      safeSetState(() {
                        _stateController.text = state ?? "";
                      });
                    },
                    onCityChanged: (city) {
                      safeSetState(() {
                        _cityController.text = city ?? "";
                      });
                    },
                    dropdownDialogRadius: 12.0,
                    searchBarRadius: 12.0,
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      color: const Color(0xFF3a3a3a),
                    ),
                    disabledDropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      color: const Color.fromARGB(255, 30, 30, 30),
                    ),
                    selectedItemStyle: TextStyle(color: Colors.white, fontSize: 14),
                    
                    // defaultCountry: CscCountry.values.firstWhere(
                    //   (e) => e.name.toLowerCase() == (widget.data.country?.toLowerCase() ?? ''),
                    //   orElse: () => CscCountry.India,
                    // ),
                  ),
*/
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createAccount,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xffa393eb),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBackNavigation() {
    widget.data.profileImage =
        _profileImageFile != null ? _profileImageFile!.path : widget.data.profileImage;
    widget.data.name = _nameController.text.trim();
    widget.data.headline = _headlineController.text.trim();
    widget.data.gender = _selectedGender?.toLowerCase().replaceAll(' ', '_');
    widget.data.email = _emailController.text.toLowerCase().trim();
    // widget.data.countryCode = _countryCodeController.text;
    widget.data.phoneNo = _phoneNoController.text;
    widget.data.city = _cityController.text;
    widget.data.state = _stateController.text;
    widget.data.country = _countryController.text;

    Navigator.pop(context, widget.data);
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1,
      int maxlen = 32,
      IconData? icon,
      TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxlen,
        keyboardType: type,
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xffa393eb), width: 1),
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.white54,
                  size: 20,
                )
              : null,
        ),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF3a3a3a),
          value: _selectedGender,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select Gender',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          iconEnabledColor: Colors.white54,
          icon: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.arrow_drop_down),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          isExpanded: true,
          onChanged: (String? newValue) {
            safeSetState(() {
              _selectedGender = newValue;
            });
          },
          items: _genderOptions
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _createAccount() async {
    if (!isValidEmail(_emailController.text)) {
      _showErrorDialog("Invalid email format");
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog("Please enter your Full Name");
      return;
    } else if (_selectedGender == null) {
      _showErrorDialog("Please select your Gender");
      return;
    } else if (_phoneNoController.text.trim().isEmpty) {
      _showErrorDialog("Please enter your Phone Number");
      return;
    } else if (_countryController.text.trim().isEmpty) {
      _showErrorDialog("Please enter your Country");
      return;
    }

    // Assign to widget.data
    widget.data.profileImage =
        _profileImageFile != null ? _profileImageFile!.path : widget.data.profileImage;
    widget.data.name = _nameController.text.trim();
    widget.data.headline = _headlineController.text.trim();
    widget.data.gender =
        _selectedGender!.toLowerCase().replaceAll(' ', '_');
    widget.data.email = _emailController.text.toLowerCase().trim();
    // widget.data.countryCode = _countryCodeController.text;
    widget.data.phoneNo = _phoneNoController.text;
    widget.data.city = _cityController.text;
    widget.data.state = _stateController.text;
    widget.data.country = _countryController.text;

    safeSetState(() {
      _isLoading = true;
    });

    final dio = Dio();
    try {
      final formData = FormData.fromMap({
        // "username": widget.data.username,
        "email": widget.data.email,
        "password": widget.data.password,
        "password2": widget.data.password2,
        "name": widget.data.name,
        "gender": widget.data.gender,
        "headline": widget.data.headline,
        // "phone_no": widget.data.countryCode! + widget.data.phoneNo!,
        "city": widget.data.city,
        "state": widget.data.state,
        "country": widget.data.country,
        // "fcm_token": await FirebaseMessaging.instance.getToken(),
        if (_profileImageFile != null)
          "profile_image": await MultipartFile.fromFile(
            _profileImageFile!.path,
            filename: "profile_image.jpg",
          ),
      });

      final response = await dio.post(
        '${ApiClient.baseBackendUrl}/users/register/',
        data: formData,
      );

      await secureStorage.write(
          key: 'access_token', value: response.data["access_token"]);
      await secureStorage.write(
          key: 'refresh_token', value: response.data["refresh_token"]);
      await secureStorage.write(
          key: 'user_id', value: response.data["user"]["id"].toString());

      await secureStorage.write(key: 'explain_cw_page', value: 'true');
      await secureStorage.write(key: 'explain_thoughts_page', value: 'true');
      await secureStorage.write(key: 'explain_special_search_sheet', value: 'true');
      await secureStorage.write(key: 'explain_moments_sheet', value: 'true');

      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccountCreatedInfoPage(),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });

      String errorMessage = "Registration failed. Please try again.";
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data.containsKey("email")) {
            final emailErrors = data["email"];
            Navigator.pop(context, widget.data);
            errorMessage = "Email Error: ${emailErrors.join(", ")}";
          } else if (data.containsKey("password")) {
            final passwordErrors = data["password"];
            Navigator.pop(context, widget.data);
            errorMessage = "Password Error: ${passwordErrors.join(", ")}";
          } else if (data.containsKey("phone_no")) {
            final phoneNoErrors = data["phone_no"];
            errorMessage = "Phone Number Error: ${phoneNoErrors.join(", ")}";
          } else if (data.containsKey("username")) {
            final usernameErrors = data["username"];
            errorMessage = "Username Error: ${usernameErrors.join(", ")}";
          }
        }
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
      });
      _showErrorDialog("An unexpected error occurred");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a2a2a),
        title: const Text(
          "Warning",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: Text(
              "OK",
              style: TextStyle(color: const Color(0xffa393eb)),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String toCapitalCase(String input) {
    return input
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _phoneNoController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}
