import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/pages/chat_page.dart';
import 'package:shakala/services/api_client.dart';

class ConversationSummaryWidget extends StatelessWidget {
  final User user;
  final String messagePreview;
  final String? latestMessageDate;

  const ConversationSummaryWidget({
    super.key,
    required this.user,
    required this.messagePreview,
    this.latestMessageDate,
  });

  @override
  Widget build(BuildContext context) {
    final hasProfileImage = user.profileImage != null && user.profileImage!.isNotEmpty;
    final profileImageUrl = hasProfileImage
        ? '${ApiClient.baseBackendUrl}${user.profileImage}'
        : null;

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(user: user),
            ),
          );
        },
        child: Container(
          color: const Color(0xff2a2a2a),
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipOval(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: hasProfileImage
                        ? CachedNetworkImage(
                            imageUrl: profileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) {
                              return Image.asset(
                                'assets/images/empty_dp.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/empty_dp.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      messagePreview,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (latestMessageDate != null)
                Text(
                  latestMessageDate!.length > 30
                    ? '${latestMessageDate!.substring(0, 30)}...'
                    : latestMessageDate ?? "",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}