import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shakala/services/api_client.dart';

class CommentWidget extends StatefulWidget {
  final String commentId;
  final String? userProfileImg; // Can be null
  final String userName;
  final String userHeadline;
  final String? headline;
  final String body;
  final DateTime publishTime;
  final int reactionCount;
  final bool hasReacted;

  const CommentWidget({
    super.key,
    required this.commentId,
    required this.userProfileImg,
    required this.userName,
    required this.userHeadline,
    this.headline,
    required this.body,
    required this.publishTime,
    required this.reactionCount,
    this.hasReacted = false,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final GlobalKey _menuKey = GlobalKey();

  bool _hasReacted = false;
  bool _isExpanded = false;
  late int _reactionCount;

  @override
  void initState() {
    super.initState();
    _hasReacted = widget.hasReacted;
    _reactionCount = widget.reactionCount;
  }

  void toggleReaction() async {
    setState(() {
      _hasReacted = !_hasReacted;
      _reactionCount += _hasReacted ? 1 : -1;
    });

    final apiClient = ApiClient();
    final endpoint = '${ApiClient.baseBackendUrl}/moments/comment-reactions/toggle/';

    final payload = {
      "comment": widget.commentId,
      "reaction": "LIKE",
    };

    try {
      await apiClient.post(endpoint, 'json', payload, auth: true);
    } catch (e) {
      // Rollback on error
      setState(() {
        _hasReacted = !_hasReacted;
        _reactionCount += _hasReacted ? 1 : -1;
      });
      print("Failed to toggle reaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff2a2a2a),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image with border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xffa393eb).withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: widget.userProfileImg != null && widget.userProfileImg!.isNotEmpty
                        ? Image.network(
                            widget.userProfileImg!,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 45,
                              height: 45,
                              color: Colors.grey.shade800,
                              child: Icon(Icons.person, color: Colors.grey.shade500, size: 24),
                            ),
                          )
                        : Image.asset(
                            'assets/images/empty_dp.png',
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(width: 12),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName.length > 25
                          ? '${widget.userName.substring(0, 25)}...'
                          : widget.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        widget.userHeadline.length > 35
                          ? '${widget.userHeadline.substring(0, 35)}...'
                          : widget.userHeadline,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // More options button
                IconButton(
                  key: _menuKey,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    Icons.more_vert_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () async {
                    final RenderBox button = _menuKey.currentContext!.findRenderObject() as RenderBox;
                    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

                    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
                    final Size buttonSize = button.size;

                    final selected = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        buttonPosition.dx,
                        buttonPosition.dy + buttonSize.height,
                        buttonPosition.dx + buttonSize.width,
                        buttonPosition.dy,
                      ),
                      color: Color(0xff3a3a3a),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      items: [
                        const PopupMenuItem<String>(
                          value: 'report',
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Report',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );

                    if (selected == 'report') {
                      try {
                        final apiClient = ApiClient();
                        final response = await apiClient.post(
                          '${ApiClient.baseBackendUrl}/reports/create/',
                          'json',
                          {
                            'comment': widget.commentId,
                          },
                          auth: true,
                        );

                        if (response != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Comment reported successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to report comment"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } on DioException catch (e) {
                        print('POST failed: ${e.message}');
                        print('RESPONSE DATA: ${e.response?.data}');
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          // Content Text Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final span = TextSpan(
                  text: widget.body,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 15,
                    height: 1.4,
                  ),
                );

                final tp = TextPainter(
                  text: span,
                  maxLines: 3,
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);

                final exceedsMaxLines = tp.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.body,
                      softWrap: true,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (exceedsMaxLines)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _isExpanded ? "Show less" : "Show more",
                            style: TextStyle(
                              color: Color(0xffa393eb),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          // Reactions Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like button and count
                GestureDetector(
                  onTap: toggleReaction,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _hasReacted
                          ? Color(0x33a393eb)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hasReacted ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                          color: _hasReacted ? Color(0xffa393eb) : Colors.grey.shade400,
                          size: 25,
                        ),
                        SizedBox(width: 6),
                        Text(
                          _reactionCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Timestamp
                Text(
                  _formatTimeAgo(widget.publishTime),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}