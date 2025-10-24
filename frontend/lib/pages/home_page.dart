import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shakala/app_classes/moment.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/widgets/moment_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Random random = Random();
  late final ScrollController scrollController;
  late Future<List<Moment>> momentsFuture;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    momentsFuture = fetchMoments();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<List<Moment>> fetchMoments() async {
    final apiClient = ApiClient();
    final response = await apiClient.get(
      '${ApiClient.baseBackendUrl}/moments/list/',
      auth: true,
    );

    if (response is Map && response.containsKey('data')) {
      final dataList = List<Map<String, dynamic>>.from(response['data']);
      return dataList.map((json) => Moment.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff111111),
      child: FutureBuilder<List<Moment>>(
        future: momentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading moments: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No moments found. Start sharing!', style: TextStyle(color: Colors.white),));
          } else {
            final moments = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                final newData = await fetchMoments();
                setState(() {
                  momentsFuture = Future.value(newData);
                });
              },
              child: ListView.builder(
                controller: scrollController,
                itemCount: moments.length + 1, // +1 for the "end of moments" text
                itemBuilder: (context, index) {
                  if (index == moments.length) {
                    // End message
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'This is the end of moments. Start sharing yours!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
              
                  final moment = moments[index];
                  final user = moment.user;
              
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                    child: MomentWidget(
                      key: ValueKey(moment.momentId),
                      momentId: moment.momentId ?? '',
                      user: user!,
                      title: moment.title ?? '',
                      description: moment.description ?? '',
                      attachedImg: moment.imageUrl,
                      publishTime: DateTime.tryParse(moment.createdAt ?? '') ?? DateTime.now(),
                      reactionCount: moment.reactionCount,
                      hasReacted: moment.hasReacted,
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}