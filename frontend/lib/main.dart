import 'package:flutter/material.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/pages/conversations_page.dart';
import 'package:shakala/pages/onboard_flow/welcome_page.dart';

import 'package:shakala/sheets/create_moment_sheet.dart';
import 'package:shakala/pages/explore_connections_page.dart';
import 'package:shakala/pages/home_page.dart';
import 'package:shakala/pages/show_account_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    ),
  );
}

class MainApp extends StatefulWidget {
  final User? showUser;
  final bool? recPrivateUserMode;

  const MainApp({
    super.key,
    this.showUser,
    this.recPrivateUserMode = false,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int navIndex = 0;
  bool get publicUserMode => widget.showUser != null;

  @override
  void initState() {
    super.initState();

    // If user is passed, default to Account page
    if (publicUserMode || widget.recPrivateUserMode == true) {
      navIndex = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a2a2a),
        automaticallyImplyLeading: publicUserMode, // Show back button
        leading: publicUserMode
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
        title: Image.asset('assets/images/logo_shakala_nobg.png', width: 150),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConversationsPage()),
                );
              },
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),

      body: switch (navIndex) {
        0 => HomePage(),
        1 => Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xff2a2a2a),
            child: const Text('Open Create Moment Page', style: TextStyle(color: Colors.white)),
          ),
        2 => ExploreConnectionsPage(),
        3 => ShowAccountPage(publicUser: widget.showUser),
        _ => const Center(child: Text('Page not found')),
      },

      // 👇 Hide bottom nav bar if public user profile is passed
      bottomNavigationBar: publicUserMode
          ? null
          : Container(
              color: const Color(0xFF2a2a2a),
              child: SafeArea(
                child: NavigationBarTheme(
                  data: NavigationBarThemeData(
                    height: 60,
                  ),
                  child: NavigationBar(
                    backgroundColor: const Color(0x00000000),
                    indicatorColor: const Color(0x00000000),
                    // indicatorColor: const Color(0xff7e68e3),
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                    labelTextStyle: WidgetStateProperty.all(TextStyle(color: Colors.white)),
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_sharp, color: Colors.white, size: 35),
                        selectedIcon: Icon(Icons.home_sharp, color: Color(0xff7e68e3), size: 35),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.add_box_rounded, color: Colors.white, size: 35),
                        selectedIcon: Icon(Icons.add_box_rounded, color: Color(0xff7e68e3), size: 35),
                        label: 'Moment',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.saved_search, color: Colors.white, size: 36),
                        selectedIcon: Icon(Icons.saved_search, color: Color(0xff7e68e3), size: 36),
                        label: 'Search',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.account_circle, color: Colors.white, size: 33),
                        selectedIcon: Icon(Icons.account_circle, color: Color(0xff7e68e3), size: 33),
                        label: 'Account',
                      ),
                    ],
                    onDestinationSelected: (int value) {
                      if (value == 1) {
                        _showCreateMomentSheet(context);
                        return;
                      }
                  
                      setState(() {
                        navIndex = value;
                      });
                    },
                    selectedIndex: navIndex == 1 ? navIndex - 1 : navIndex,
                  ),
                ),
              ),
            ),
    );
  }

  void _showCreateMomentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateMomentSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}