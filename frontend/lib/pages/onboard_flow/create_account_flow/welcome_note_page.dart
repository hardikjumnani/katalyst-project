import 'package:flutter/material.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/pages/onboard_flow/create_account_flow/add_username_password_page.dart';

class WelcomeNotePage extends StatelessWidget {
  const WelcomeNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2a2a2a),
      appBar: AppBar(
        backgroundColor: Color(0xff2a2a2a),
        iconTheme: IconThemeData(color: Colors.white),
        // title: Text('Educations', style: TextStyle(color: Colors.white)),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Welcome note
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                  child: Image.asset(
                    'assets/images/logo_shakala_nobg.png',
                    width: 400,
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Katalyst is a platform that helps catalyze connections, enabling you to find future co-founders, business partners, and project teammates.\n\n\nMeet. Collaborate. Grow.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Bottom Buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Next Button
                    FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 0.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddUsernamePasswordPage(data: User()),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xffa393eb),
                            backgroundColor: Color(0xffa393eb),
                            overlayColor: Color(0xaaffffff),
                            side: BorderSide(
                              color: Color(0xffa393eb),
                              width: 2.0,
                            ),
                            padding: EdgeInsets.all(0),
                            minimumSize: Size(0, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
    );
  }
}