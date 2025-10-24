import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/main.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/sheets/comment_sheet.dart';
import 'package:shakala/sheets/create_moment_sheet.dart';

class MomentWidget extends StatefulWidget {
  final String momentId;
  final User user;
  final String? title;
  final String description;
  final String? attachedImg;
  final DateTime publishTime;
  // final DateTime? disposeTime;
  int reactionCount;
  bool hasReacted;

  MomentWidget({
    super.key,
    required this.momentId,
    required this.user,
    this.title,
    required this.description,
    this.attachedImg,
    required this.publishTime,
    // this.disposeTime,
    this.reactionCount = 0,
    this.hasReacted = false,
  });

  @override
  State<MomentWidget> createState() => _MomentWidgetState();
}

class _MomentWidgetState extends State<MomentWidget> {
  final GlobalKey _menuKey = GlobalKey();

  late String _personalUserId;

  bool isFollowing = true;
  bool isFollowLoading = false;
  bool showFollowedTick = false;

  bool _isExpanded = false;
  late bool hasReacted;
  bool _shouldShowMore = false;

  @override
  void initState() {
    super.initState();
    hasReacted = widget.hasReacted;
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserId();
    await checkFollowStatus();
  }

  Future<void> checkFollowStatus() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(
        '${ApiClient.baseBackendUrl}/users/$_personalUserId/following/',
        auth: true,
      );
      final List followers = response['data'];

      setState(() {
        isFollowing =
            followers.any((u) => u['id'].toString() == widget.user.id) ||
            widget.user.id == _personalUserId;
      });
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _loadUserId() async {
    final id = await secureStorage.read(key: 'user_id');
    if (!mounted) return;

    setState(() {
      _personalUserId = id ?? '';
    });
  }

  Future<void> _toggleFollow() async {
    setState(() {
      isFollowLoading = true;
      showFollowedTick = false; // Reset
    });

    try {
      final apiClient = ApiClient();
      final endpoint = isFollowing ? 'unfollow' : 'follow';
      await apiClient.post(
        '${ApiClient.baseBackendUrl}/users/$endpoint/',
        'json',
        {'followee': widget.user.id},
        auth: true,
      );

      setState(() {
        isFollowing = !isFollowing;
        isFollowLoading = false;
        showFollowedTick = true;
      });

      // After 3 seconds, fade out tick
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showFollowedTick = false;
          });
        }
      });
    } catch (e) {
      print('Follow/unfollow error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Something went wrong.')));
        setState(() {
          isFollowLoading = false;
        });
      }
    }
  }

  void toggleReaction() async {
    setState(() {
      hasReacted = !hasReacted;
      widget.reactionCount += hasReacted ? 1 : -1;
    });

    final apiClient = ApiClient();
    final endpoint = '${ApiClient.baseBackendUrl}/moments/reactions/toggle/';

    final payload = {"moment": widget.momentId, "reaction": "LIKE"};

    try {
      await apiClient.post(endpoint, 'json', payload, auth: true);
    } catch (e) {
      // Rollback on error
      setState(() {
        hasReacted = !hasReacted;
        widget.reactionCount += hasReacted ? 1 : -1; // Rollback
      });
      print("Failed to toggle reaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // final double disposeValue =
    //     1 -
    //     (DateTime.now().difference(publishTime).inMinutes) /
    //         (disposeTime.difference(publishTime).inMinutes);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DefaultTextStyle(
            style: TextStyle(color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFF2a2a2a), Color(0xFF333333)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // User Profile
                          InkWell(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    if (_personalUserId == widget.user.id)
                                      return MainApp(recPrivateUserMode: true);
                                    return MainApp(showUser: widget.user);
                                  },
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                // User Image
                                ClipOval(
                                  child:
                                      widget.user.profileImage != null &&
                                          widget.user.profileImage!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: widget.user.profileImage!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                width: 50,
                                                height: 50,
                                                alignment: Alignment.center,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                                'assets/images/empty_dp.png',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                        )
                                      : Image.asset(
                                          'assets/images/empty_dp.png',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Container(
                                  // color: Colors.lightBlueAccent,
                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.user.name!.length > 25
                                            ? '${widget.user.name!.substring(0, 25)}...'
                                            : widget.user.name ?? "",
                                        style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        widget.user.headline!.length > 30
                                            ? '${widget.user.headline!.substring(0, 30)}...'
                                            : widget.user.headline ?? "",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // More button
                          Row(
                            children: [
                              if (isFollowLoading)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xffa393eb),
                                  ),
                                )
                              else if (showFollowedTick)
                                AnimatedOpacity(
                                  opacity: 1.0,
                                  duration: Duration(milliseconds: 300),
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.task_alt_rounded,
                                      color: Color(0xffa393eb),
                                    ),
                                  ),
                                )
                              else if (!isFollowing)
                                IconButton(
                                  onPressed: _toggleFollow,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: Color(0xffa393eb),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              IconButton(
                                key: _menuKey,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  Icons.more_vert_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  final RenderBox button =
                                      _menuKey.currentContext!
                                              .findRenderObject()
                                          as RenderBox;
                                  final RenderBox overlay =
                                      Overlay.of(
                                            context,
                                          ).context.findRenderObject()
                                          as RenderBox;

                                  final Offset buttonPosition = button
                                      .localToGlobal(
                                        Offset.zero,
                                        ancestor: overlay,
                                      );
                                  final Size buttonSize = button.size;

                                  final selected = await showMenu(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      buttonPosition.dx,
                                      buttonPosition.dy + buttonSize.height,
                                      buttonPosition.dx + buttonSize.width,
                                      buttonPosition.dy,
                                    ),
                                    color: Colors.grey.shade700,
                                    items: [
                                      PopupMenuItem(
                                        value: 'report',
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          'Report',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      if (_personalUserId == widget.user.id)
                                        PopupMenuItem(
                                          value: 'delete',
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                    ],
                                  );

                                  if (selected == 'delete') {
                                    try {
                                      final apiClient = ApiClient();
                                      final response = await apiClient.patch(
                                        '${ApiClient.baseBackendUrl}/moments/disable/',
                                        {'moment_id': widget.momentId},
                                        auth: true,
                                      );

                                      if (response != null) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Moment deleted successfully.',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to delete moment.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } on DioException catch (e) {
                                      print('POST failed: ${e.message}');
                                      print(
                                        'RESPONSE DATA: ${e.response?.data}',
                                      );
                                      return null;
                                    }
                                  } else if (selected == 'report') {
                                    try {
                                      final apiClient = ApiClient();
                                      final response = await apiClient.post(
                                        '${ApiClient.baseBackendUrl}/reports/create/',
                                        'json',
                                        {'moment': widget.momentId},
                                        auth: true,
                                      );

                                      if (response != null) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Moment reported successfully.',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to report moment.',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } on DioException catch (e) {
                                      print('POST failed: ${e.message}');
                                      print(
                                        'RESPONSE DATA: ${e.response?.data}',
                                      );
                                      return null;
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Content Text Body
                    Container(
                      padding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                      child: Column(
                        children: [
                          if (widget.title != null)
                            Padding(
                              padding: EdgeInsets.fromLTRB(4, 0, 5, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.title ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                          /// Description Text with "Show more" detection
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final span = TextSpan(
                                text: widget.description,
                                style: DefaultTextStyle.of(context).style,
                              );

                              final tp = TextPainter(
                                text: span,
                                maxLines: 3,
                                textDirection: TextDirection.ltr,
                              )..layout(maxWidth: constraints.maxWidth);

                              _shouldShowMore = tp.didExceedMaxLines;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        widget.description,
                                        softWrap: true,
                                        maxLines: _isExpanded ? null : 3,
                                        overflow: _isExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    if (_shouldShowMore)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isExpanded = !_isExpanded;
                                          });
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Text(
                                            _isExpanded
                                                ? "Show less"
                                                : "Show more",
                                            style: TextStyle(
                                              color: Color(0xffa393eb),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Content Image
                    if (widget.attachedImg != null &&
                        widget.attachedImg!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 400,
                              minWidth: double.infinity,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: widget.attachedImg!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 400,
                                width: double.infinity,
                                color: Colors.black26,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 400,
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Image could not be loaded',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Reactions Footer
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      // color: Colors.indigo,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: toggleReaction,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: hasReacted
                                        ? Color(0x33a393eb)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        hasReacted
                                            ? Icons.thumb_up
                                            : Icons.thumb_up_alt_outlined,
                                        color: hasReacted
                                            ? Color(0xffa393eb)
                                            : Colors.grey.shade400,
                                        size: 25,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        widget.reactionCount.toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Comment button
                          GestureDetector(
                            onTap: () {
                              _showCommentSheet(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.comment_outlined,
                                color: Colors.grey.shade400,
                                size: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /*
                    // Dispose Moment Bar
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 2,
                            child: LinearProgressIndicator(
                              // value: 1 - disposeValue,
                              value: 0.5,
                              color: Color(0xFF000000),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 2,
                            child: LinearProgressIndicator(
                              // value: disposeValue,
                              value: 0.5,
                              backgroundColor: Color(0xFF000000),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    */

                    // // Add Comment Box
                    // Container(
                    //   margin: EdgeInsets.fromLTRB(14, 0, 14, 5),
                    //   child: TextField(
                    //     style: TextStyle(color: Colors.white),
                    //     decoration: InputDecoration(
                    //       hintText: 'Add comment',
                    //       isDense: true,
                    //       contentPadding: EdgeInsets.symmetric(
                    //         vertical: 6.0,
                    //         horizontal: 12.0,
                    //       ),
                    //       border: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(24.0),
                    //         borderSide: BorderSide(
                    //           color: Colors.blue, // Border color
                    //           width: 2.0, // Border thickness
                    //         ),
                    //       ),
                    //       suffixIcon: Icon(Icons.send_rounded, color: Colors.white,),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CommentSheet(momentId: widget.momentId),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}
