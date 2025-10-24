import 'package:flutter/material.dart';

class Snippets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Reloading Page
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    // Login Buttons
    FractionallySizedBox(
      widthFactor: 0.7,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 0.0),
        child: OutlinedButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => AddEmailPasswordPage(data: User()),
            //   ),
            // );
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
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Next',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );

    // Input Fields
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: Color(0xff222222),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), //
        child: TextField(
          maxLines: 1,
          maxLength: 256,                                            //
          // controller: _emailController,
          keyboardType: TextInputType.multiline,
          expands: false,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            counterText: '',                                         //
            hintText: 'Email',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
    // sized box height 12

    return Container();
  }
}