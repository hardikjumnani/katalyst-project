import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/main.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/sheets/create_moment_sheet.dart';

class PersonSummaryWidget extends StatefulWidget {
  final User user;
  final String? caption;

  const PersonSummaryWidget({
    super.key,
    required this.user,
    this.caption,
  });

  @override
  State<PersonSummaryWidget> createState() => _PersonSummaryWidgetState();
}

class _PersonSummaryWidgetState extends State<PersonSummaryWidget> {
  final apiClient = ApiClient();
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus(); // Check on widget load
  }

  Future<void> _checkFollowStatus() async {
    try {
      final response = await apiClient.get(
        '${ApiClient.baseBackendUrl}/users/${widget.user.id}/followers/',
        auth: true,
      );
      final List followers = response['data'];
      final currentUserId = await secureStorage.read(key: 'user_id');
      print('Logged in user id: $currentUserId');

      setState(() {
        isFollowing = followers.any((u) => u['id'].toString() == currentUserId);
      });
    } catch (e) {
      // Handle silently or log
      print('error (fetching follow status): $e');
    }
  }

  Future<void> _toggleFollow() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (isFollowing) {
        await apiClient.post(
          '${ApiClient.baseBackendUrl}/users/unfollow/', 
          'json',
          {
            'followee': widget.user.id
          },
          auth: true
        );
      } else {
        await apiClient.post(
          '${ApiClient.baseBackendUrl}/users/follow/', 
          'json',
          {
            'followee': widget.user.id
          },
          auth: true
        );
      }

      setState(() {
        isFollowing = !isFollowing;
      });
    } catch (e) {
      // Optionally show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        color: Color(0xff2a2a2a),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final user_id = await secureStorage.read(key: 'user_id');
                
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    if (user_id == widget.user.id) return MainApp(recPrivateUserMode: true,);
                    return MainApp(showUser: widget.user);
                  }),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xffa393eb).withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty
                            ? '${ApiClient.baseBackendUrl}${widget.user.profileImage}'
                            : 'assets/images/empty_dp.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xffa393eb),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/empty_dp.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // User name
                    Text(
                      widget.user.name!.length > 20
                        ? '${widget.user.name!.substring(0, 20)}...'
                        : widget.user.name ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 4),
                    
                    // Caption
                    if (widget.caption != null && widget.caption!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.zero,
                        child: Text(
                          widget.caption!.length > 43
                            ? "${widget.caption!.substring(0, 43)}..."
                            : widget.caption!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Follow Button
          Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: isLoading ? null : _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing 
                    ? const Color(0x339E9E9E)
                    : Color(0xffa393eb),
                  foregroundColor: isFollowing ? Colors.grey : Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isFollowing ? Colors.grey : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                ),
                child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isFollowing ? Colors.grey : Colors.white,
                      ),
                    )
                  : Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
              ),
            ),
          )
        ],
      ),
    );
  }
}