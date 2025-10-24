import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shakala/main.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/services/wrappers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final secureStorage = FlutterSecureStorage();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2a2a2a),
      body: Column(
        children: [
          // Header - Matches AddSkillsPage design
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
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
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Sign in to your account',
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
                  
                  SizedBox(height: 16),
                  
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
                  _buildPasswordField(),
                  
                  SizedBox(height: 32),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _login(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xffa393eb),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // // Forgot Password Link
                  // Center(
                  //   child: TextButton(
                  //     onPressed: () {
                  //       // Add forgot password functionality
                  //       _showErrorDialog("Forgot password feature coming soon");
                  //     },
                  //     child: Text(
                  //       'Forgot your password?',
                  //       style: TextStyle(
                  //         color: Color(0xffa393eb),
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  
                  SizedBox(height: 40),
                ],
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
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.white54,
                  size: 20,
                )
              : null,
        ),
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF3a3a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        maxLines: 1,
        maxLength: 64,
        decoration: InputDecoration(
          counterText: '',
          hintText: 'Enter your password',
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
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
              size: 20,
            ),
            onPressed: () {
              safeSetState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Future<void> _login() async {
    String usernameStr = _usernameController.text.trim().toLowerCase();
    String passwordStr = _passwordController.text.toString();

    // Validation
    if (usernameStr.isEmpty) {
      _showErrorDialog("Please enter your username");
      return;
    }
    if (!isValidUsername(usernameStr)) {
      _showErrorDialog("Please enter a valid username");
      return;
    }
    if (passwordStr.isEmpty) {
      _showErrorDialog("Please enter your password");
      return;
    }
    if (passwordStr.length < 8) {
      _showErrorDialog("Invalid username or password");
      return;
    }

    safeSetState(() {
      isLoading = true;
    });

    final dio = Dio();
    try {
      final response = await dio.post(
        '${ApiClient.baseBackendUrl}/users/login/',
        data: {
          "username": usernameStr, 
          "password": passwordStr,
          // "fcm_token": await FirebaseMessaging.instance.getToken(),
        },
      );
      
      await secureStorage.write(key: 'access_token', value: response.data["access_token"]);
      await secureStorage.write(key: 'refresh_token', value: response.data["refresh_token"]);
      await secureStorage.write(key: 'user_id', value: response.data["user"]["id"]);

      await secureStorage.write(key: 'explain_cw_page', value: 'true');
      await secureStorage.write(key: 'explain_thoughts_page', value: 'true');
      await secureStorage.write(key: 'explain_special_search_sheet', value: 'true');
      await secureStorage.write(key: 'explain_moments_sheet', value: 'true');

      if (!mounted) return;
      safeSetState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainApp(showUser: null,)),
        (Route<dynamic> route) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      safeSetState(() {
        isLoading = false;
      });

      String errorMessage = "Login failed. Please try again.";
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data.containsKey("detail")) {
            errorMessage = "Invalid username or password.";
          } else if (data.containsKey("username")) {
            final usernameErrors = data["username"];
            errorMessage = "Username Error: ${usernameErrors.join(", ")}";
          } else if (data.containsKey("password")) {
            final passwordErrors = data["password"];
            errorMessage = "Password Error: ${passwordErrors.join(", ")}";
          }
        }
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        isLoading = false;
      });
      _showErrorDialog("An unexpected error occurred");
    }
  }

  bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]{3,32}$');
    return usernameRegex.hasMatch(username);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2a2a2a),
        title: Text(
          "Error",
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
}