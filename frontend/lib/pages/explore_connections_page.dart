import 'package:flutter/material.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/sheets/create_moment_sheet.dart';
import 'package:shakala/sheets/special_explore_sheet.dart';

import 'package:shakala/widgets/person_summary_widget.dart';

class ExploreConnectionsPage extends StatefulWidget {
  const ExploreConnectionsPage({super.key});

  @override
  State<ExploreConnectionsPage> createState() => _ExploreConnectionsPageState();
}

class _ExploreConnectionsPageState extends State<ExploreConnectionsPage> {
  late final ScrollController scrollController;
  late Future<List<User>> usersFuture;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    usersFuture = fetchAllUsers();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<List<User>> fetchAllUsers() async {
    final currentUserId = await secureStorage.read(key: 'user_id');
    final apiClient = ApiClient();
    final response = await apiClient.get(
      '${ApiClient.baseBackendUrl}/users/list/',
      auth: true,
    );

    if (response is Map && response.containsKey('data')) {
      final dataList = List<Map<String, dynamic>>.from(response['data']);
      final filteredList = dataList.where((user) => user['id'].toString() != currentUserId).toList();
      return filteredList.map((json) => User.fromJson(json)).toList();
      
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff111111), // background (optional)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search Box
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x88a393eb),
                      Color(0x887e68e3),
                    ], // Background gradient
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextButton(
                  onPressed: () {
                    _showSpecialExploreSheet(context);
                  },
                  style: TextButton.styleFrom(
                    // padding: EdgeInsets.zero, // No internal padding
                    minimumSize: Size.zero, // Remove default size constraints
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrinks touch area
                  ),
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey.shade200,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Search',
                        style: TextStyle(color: Colors.grey.shade200),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Suggestions
          Expanded(
            child: Container(
              color: const Color(0xff111111),
              padding: EdgeInsets.all(10.0),
              child: FutureBuilder<List<User>>(
                future: usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading users: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No users found. Invite your friends!'));
                  } else {
                    final users = snapshot.data!;
                    final int rowCount = (users.length + 1) ~/ 2;

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: rowCount,
                      itemBuilder: (context, rowIndex) {
                        // First user in the row
                        final user1 = users[rowIndex * 2];
                        // final profileImageUrl1 = (user1.profileImage != null && user1.profileImage!.isNotEmpty)
                        //     ? user1.profileImage!
                        //     : 'assets/images/empty_dp.png';

                        // Check if second user exists for this row
                        final hasSecondUser = (rowIndex * 2 + 1) < users.length;
                        final user2 = hasSecondUser ? users[rowIndex * 2 + 1] : null;
                        // final profileImageUrl2 = (user2 != null && user2.profileImage != null && user2.profileImage!.isNotEmpty)
                        //     ? user2.profileImage!
                        //     : 'assets/images/empty_dp.png';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: hasSecondUser
                                ? [
                                    Expanded(
                                      child: PersonSummaryWidget(
                                        user: user1,
                                        caption: 'CAPTION',
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: PersonSummaryWidget(
                                        user: user2!,
                                        caption: 'CAPTION',
                                      ),
                                    ),
                                  ]
                                : [
                                    PersonSummaryWidget(
                                      user: user1,
                                      caption: 'Caption',
                                    ),
                                  ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          )

          
        ],
      ),
    );
  }

  void _showSpecialExploreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const SpecialExploreSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}
