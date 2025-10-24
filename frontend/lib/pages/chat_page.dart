import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:shakala/widgets/chat_message_widget.dart';
import 'package:shakala/services/api_client.dart';

class ChatPage extends StatefulWidget {
  final User user;

  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late WebSocketChannel _channel;
  late String _accessToken;
  late String _userId;

  String? _threadId;
  bool _isLoading = true;
  bool _isSending = false;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<_ChatMessageData> _messages = [];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    // 1. Get tokens and user id from secure storage
    _accessToken = (await _storage.read(key: 'access_token')) ?? '';
    _userId = (await _storage.read(key: 'user_id')) ?? '';

    if (_accessToken.isEmpty || _userId.isEmpty) {
      // Handle unauthorized state or redirect to login
      // For now just pop
      Navigator.of(context).pop();
      return;
    }

    try {
      // 2. Get or create thread
      final threadResponse = await apiClient.post(
        '${ApiClient.baseBackendUrl}/chat/thread/',
        'json',
        {'target_user_id': widget.user.id},
        auth: true,
      );

      _threadId = threadResponse['data']['id'];

      // 3. Fetch chat history
      final messagesResponse = await apiClient.get(
        '${ApiClient.baseBackendUrl}/chat/messages/$_threadId/',
        auth: true,
      );

      final dataList = messagesResponse['data'] as List<dynamic>;

      List<_ChatMessageData> loadedMessages = [];

      for (var msg in dataList) {
        final sender = msg['sender'];
        final senderId = sender['id'];

        bool isOpponent = senderId != _userId;

        loadedMessages.add(
          _ChatMessageData(
            message: msg['content'],
            sent: true,
            isOpponent: isOpponent,
            sentAt: _formatTimestamp(msg['timestamp']),
          ),
        );
      }

      setState(() {
        _messages = loadedMessages;
        _isLoading = false;
      });

      // Connect websocket
      _connectWebSocket();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
      
    } catch (e) {
      // Handle errors here
      print('Error initializing chat: $e');
      // Optionally show dialog or toast
    }
  }

  void _connectWebSocket() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    final uri = Uri.parse(
      '${ApiClient.socketBackendUrl}/ws/chat/$_threadId/?token=$_accessToken',
    );

    print('Access token: $_accessToken');
    print('Thread ID: $_threadId');
    print('User ID: $_userId');
    print('Connecting to: $uri');

    try {
      // Attempt to connect to websocket
      _channel = WebSocketChannel.connect(uri);

      // If successful, dismiss loading dialog
      Navigator.pop(context);

      _channel.stream.listen((event) {
        final data = jsonDecode(event);
        print("DATA: $data");

        if (data['type'] == 'chat_message') {
          final sender = data['sender'];
          if (sender == null) {
            print('Warning: sender is null in websocket message');
            return;
          }

          final senderId = sender['id'];
          if (senderId == null || senderId is! String) {
            print('Warning: senderId is null or not string');
            return;
          }

          final isOpponent = senderId != _userId;

          final content = data['message'] ?? '';
          final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();

          final newMsg = _ChatMessageData(
            message: content,
            isOpponent: isOpponent,
            sent: true,
            sentAt: _formatTimestamp(timestamp),
          );

          if (isOpponent) {
            setState(() {
              _messages.add(newMsg);
            });
            _scrollToBottom();
          }
        }
      }, onError: (error) {
        print("WebSocket error: $error");
        // Optionally show an error to user
      }, onDone: () {
        print("WebSocket connection closed");
      });

    } catch (e) {
      // Connection failed, dismiss loading dialog and handle error
      Navigator.pop(context);
      print("Failed to connect websocket: $e");

      // Optionally show error dialog/snackbar here
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Connection Error'),
          content: Text('Failed to connect to chat server. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  String _formatTimestamp(String isoString) {
    final dt = DateTime.parse(isoString).toLocal();
    // Example: 10:15 AM
    return "${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending || _threadId == null) return;

    final msgData = jsonEncode({'message': text});

    try {
      _channel.sink.add(msgData);

      // Optimistic UI update
      setState(() {
        _messages.add(
          _ChatMessageData(
            message: text,
            isOpponent: false,
            sent: true,
            sentAt: _formatTimestamp(DateTime.now().toIso8601String()),
          ),
        );
        _controller.clear();
      });

      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2a2a2a),
      appBar: AppBar(
        backgroundColor: const Color(0xff2a2a2a),
        iconTheme: const IconThemeData(color: Colors.white),

        // Header
        title: Row(
          children: [
            // User Profile Image
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ClipOval(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: '${ApiClient.baseBackendUrl}${widget.user.profileImage}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/empty_dp.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/empty_dp.png',
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            ),

            // User name and online status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.user.headline != null)
                  Text(
                    widget.user.headline!.length > 30
                      ? '${widget.user.headline!.substring(0, 30)}...'
                      : widget.user.headline ?? "",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return ChatMessageWidget(
                        message: msg.message,
                        isOpponent: msg.isOpponent,
                        sent: msg.sent,
                        sentAt: msg.sentAt,
                      );
                    },
                  ),
                ),

                // Chat input box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  color: Colors.grey.shade900,
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 512,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              counterText: '',
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChatMessageData {
  final String message;
  final bool isOpponent;
  final bool sent;
  final String sentAt;

  _ChatMessageData({
    required this.message,
    required this.isOpponent,
    required this.sent,
    required this.sentAt,
  });
}
