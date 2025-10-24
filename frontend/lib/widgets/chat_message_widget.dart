import 'package:flutter/material.dart';

class ChatMessageWidget extends StatelessWidget {
  final String message;
  final bool isOpponent; // false: user, true: other user
  final bool sent;       // false: sending, true: sent
  final String sentAt;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isOpponent,
    required this.sent,
    required this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.7;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isOpponent ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isOpponent
            ? [
                // Opponent's colored side bar
                Container(
                  color: Color(0xff7e68e3),
                  width: 4,
                  height: 40,
                ),
                SizedBox(width: 8),

                // Message bubble
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xff7e68e3),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          style: const TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          sentAt,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            : [
                // Message bubble
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: sent ? Colors.grey.shade800 : Colors.grey.shade900,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          style: const TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          sentAt,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // User's colored side bar
                Container(
                  color: sent ? Colors.grey.shade800 : Colors.grey.shade900,
                  width: 4,
                  height: 40,
                ),
              ],
      ),
    );
  }
}
