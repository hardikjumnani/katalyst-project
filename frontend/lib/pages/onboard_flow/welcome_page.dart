import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/main.dart';
import 'package:shakala/pages/onboard_flow/create_account_flow/add_username_password_page.dart';
import 'package:shakala/pages/onboard_flow/login_flow/login_page.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/services/wrappers.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccessToken();
  }

  Future<void> _checkAccessToken() async {
    final token = await _secureStorage.read(key: 'access_token');
    final apiClient = ApiClient();

    if (token != null && token.isNotEmpty && (await apiClient.refreshToken())) {
      // Token found, redirect to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainApp()),
      );
    } else {
      // No token, show welcome screen
      // await secureStorage.deleteAll();
      
      safeSetState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // loading indicator while checking token
      return const Scaffold(
        backgroundColor: Color(0xff2a2a2a),
        body: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xaaa393eb),)
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Color(0xff2a2a2a),
      body: Column(
        children: [
          // Header with close button (consistent with edit sheet)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // Empty container to maintain spacing symmetry
                  Container(width: 40),
                ],
              ),
            ),
          ),
          
          // Divider
          Divider(color: Colors.white12, height: 1),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  
                  // Logo Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                    child: Image.asset(
                      'assets/images/logo_shakala_nobg.png',
                      width: 280,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  SizedBox(height: 60),
                  
                  // Welcome message
                  Text(
                    'Get Started with Katalyst',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Join our community to connect and grow together',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 80),
                  
                  // Buttons Section
                  Column(
                    children: [
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xffa393eb),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              // MaterialPageRoute(builder: (context) => WelcomeNotePage()),
                              MaterialPageRoute(builder: (context) => AddUsernamePasswordPage(data: User())),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xffa393eb),
                            side: BorderSide(color: Color(0xffa393eb), width: 2),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Additional info text
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}