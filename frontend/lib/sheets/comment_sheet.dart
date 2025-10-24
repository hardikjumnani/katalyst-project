import 'package:flutter/material.dart';
import 'package:shakala/app_classes/comment.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/widgets/comment_widget.dart';

class CommentSheet extends StatefulWidget {
  final String momentId;

  const CommentSheet({super.key, required this.momentId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final apiClient = ApiClient();

    try {
      final response = await apiClient.get(
        '${ApiClient.baseBackendUrl}/moments/comments/',
        auth: true,
        queryParams: {'moment_id': widget.momentId},
      );

      if (response is Map<String, dynamic> && response['data'] is List) {
        final dataList = List<Map<String, dynamic>>.from(response['data']);
        final comments = dataList.map((json) => Comment.fromJson(json)).toList();
        setState(() {
          _comments = [];
        });
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      } else {
        print("Unexpected response format: $response");
        setState(() {
          _comments = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Failed to fetch comments: $e");
      setState(() {
        _comments = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(

                    maxLength: 512,
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isUploading ? null : _postComment,
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),

          // Comment heading
          Row(
            children: [
              const Text('Comments', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Text('(${_comments.length})', style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),

          const SizedBox(height: 10),

          // Comments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(child: Text("No comments yet.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          final user = comment.user;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: CommentWidget(
                              key: ValueKey(comment.commentId),
                              commentId: comment.commentId,
                              userProfileImg: user.profileImage ?? 'assets/images/empty_dp.png',
                              userName: user.name ?? 'Unknown',
                              userHeadline: user.headline ?? '',
                              body: comment.description,
                              publishTime: comment.createdAt,
                              reactionCount: comment.reactionCount,
                              hasReacted: comment.hasReacted,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    final apiClient = ApiClient();
    final payload = {
      "moment": widget.momentId,
      "description": _commentController.text.trim(),
    };

    await apiClient.post('${ApiClient.baseBackendUrl}/moments/comments/create/', 'json', payload, auth: true);

    _commentController.clear();

    setState(() {
      _isUploading = false;
    });

    _fetchComments(); // Refresh after post
  }
}
