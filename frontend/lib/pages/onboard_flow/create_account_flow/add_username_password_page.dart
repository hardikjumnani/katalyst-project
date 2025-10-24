import 'package:flutter/material.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/pages/onboard_flow/create_account_flow/add_personal_details_page.dart';
import 'package:shakala/services/wrappers.dart';

class AddUsernamePasswordPage extends StatefulWidget {
  final User data;

  const AddUsernamePasswordPage({super.key, required this.data});

  @override
  State<AddUsernamePasswordPage> createState() => _AddUsernamePasswordPageState();
}

class _AddUsernamePasswordPageState extends State<AddUsernamePasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePassword2 = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2a2a2a),
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white54,
                      size: 24,
                    ),
                  ),
                  Text(
                    'Authentication',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(width: 24), // For symmetrical spacing
                ],
              ),
            ),
          ),

          // Divider
          Divider(color: Colors.white12, height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Create Your Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Choose a username and secure password',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Username Field
                  Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildTextField(
                    _usernameController, 
                    'Enter your username', 
                    maxLines: 1, 
                    maxlen: 32,
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '3-32 characters, letters, numbers, . and _ only',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Password Field
                  Text(
                    'Password',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildPasswordField(
                    _passwordController,
                    'Create password (min. 8 characters)',
                    _obscurePassword,
                    () {
                      safeSetState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Confirm Password Field
                  Text(
                    'Confirm Password',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildPasswordField(
                    _password2Controller,
                    'Repeat your password',
                    _obscurePassword2,
                    () {
                      safeSetState(() {
                        _obscurePassword2 = !_obscurePassword2;
                      });
                    },
                  ),
                  
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Next Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleNext(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xffa393eb),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Next',
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

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1, int maxlen = 32, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxlen,
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white54),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xffa393eb), width: 1),
          ),
          prefixIcon: icon != null ? Icon(
            icon,
            color: Colors.white54,
            size: 20,
          ) : null,
        ),
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hintText,
    bool obscureText,
    VoidCallback onToggleVisibility,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLength: 32,
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white54),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xffa393eb), width: 1),
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.white54,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  void _handleNext() async {
    if (!isValidUsername(_usernameController.text)) {
      _showErrorDialog("Invalid username. Use 3-32 characters with letters, numbers, . and _ only");
      return;
    }

    if (_passwordController.text.length < 8) {
      _showErrorDialog("Password must be at least 8 characters long");
      return;
    }

    if (_passwordController.text != _password2Controller.text) {
      _showErrorDialog("Passwords do not match");
      _passwordController.clear();
      _password2Controller.clear();
      return;
    }

    safeSetState(() {
      _isLoading = true;
    });

    // Simulate processing delay
    await Future.delayed(Duration(milliseconds: 500));

    widget.data.username = _usernameController.text.toLowerCase();
    widget.data.password = _passwordController.text;
    widget.data.password2 = _password2Controller.text;

    safeSetState(() {
      _isLoading = false;
    });
      
    final User? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPersonalDetailsPage(data: widget.data),
      ),
    );

    if (result != null) {
      safeSetState(() {
        widget.data.profileImage = result.profileImage;
        widget.data.name = result.name;
        widget.data.headline = result.headline;
        widget.data.gender = result.gender;
        widget.data.email = result.email;
        widget.data.countryCode = result.countryCode;
        widget.data.phoneNo = result.phoneNo;
        widget.data.city = result.city;
        widget.data.state = result.state;
        widget.data.country = result.country;
      });
      
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2a2a2a),
        title: Text(
          "Warning",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: Text(
              "OK",
              style: TextStyle(color: Color(0xffa393eb)),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,32}$');
    return usernameRegex.hasMatch(username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }
}