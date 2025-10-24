import 'package:flutter/material.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/widgets/conversation_summary_widget.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  late Future<List<Map<String, dynamic>>> connectionsFuture;

  @override
  void initState() {
    super.initState();
    connectionsFuture = fetchConnections();
  }

  Future<List<Map<String, dynamic>>> fetchConnections() async {
    final apiClient = ApiClient();
    final response = await apiClient.get(
      '${ApiClient.baseBackendUrl}/users/connections/',
      auth: true,
    );

    if (response is Map && response.containsKey('data')) {
      final List<dynamic> dataList = response['data'];
      return List<Map<String, dynamic>>.from(dataList);
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff111111),
      appBar: AppBar(
        backgroundColor: const Color(0xff2a2a2a),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Conversations',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: connectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading connections: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No conversations found.\nFollow each other to start messaging',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            final connections = snapshot.data!;
            return ListView.builder(
              itemCount: connections.length,
              itemBuilder: (context, index) {
                final connection = connections[index];
                final user = User.fromJson(connection);

                return ConversationSummaryWidget(
                  user: user,
                  // latestMessageDate: 'Just now', // Placeholder until real messages are fetched
                  messagePreview: user.headline ?? "", // Optional placeholder preview
                );
              },
            );
          }
        },
      ),
    );
  }
}