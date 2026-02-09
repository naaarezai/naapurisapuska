import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';
import '../utils/error_helper.dart';
import '../l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserProfileImageUrl;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserProfileImageUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _messagesSubscription;
  UserModel? _otherUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOtherUser();

    // 1. Initial mark as read
    _chatService.markMessagesAsRead(widget.otherUserId);

    // Clear iOS badge when chat opens
    NotificationService().clearBadge();

    // 2. Listen for NEW incoming messages while screen is open
    // This fixes the issue where receiving a message while in chat leaves the badge on
    _messagesSubscription =
        _chatService.getChatMessages(widget.otherUserId).listen((messages) {
      final hasUnreadFromOther =
          messages.any((m) => !m.isRead && m.senderId == widget.otherUserId);

      if (hasUnreadFromOther) {
        _chatService.markMessagesAsRead(widget.otherUserId);
      }
    });
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOtherUser() async {
    try {
      final user = await _userService.getUserById(widget.otherUserId);
      setState(() {
        _otherUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await _chatService.sendMessage(widget.otherUserId, text);
      _messageController.clear();

      // Scrollaa alaspäin uuden viestin jälkeen
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = ErrorHelper.getUserFriendlyErrorMessage(
            e, AppLocalizations.of(context)!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.messageSendError(errorMessage)),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  String _formatTime(DateTime timestamp) {
    // Note: Simple localization for "Yesterday", otherwise specific formatting requires DateFormat with locale
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '${l10n.yesterday} ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('d.M.yyyy HH:mm').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;
    final otherUserName =
        _otherUser?.name ?? widget.otherUserName ?? l10n.unknown;
    final otherUserProfileImageUrl =
        _otherUser?.profileImageUrl ?? widget.otherUserProfileImageUrl;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: otherUserProfileImageUrl != null
                  ? CachedNetworkImageProvider(otherUserProfileImageUrl)
                  : null,
              child: otherUserProfileImageUrl == null
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_isLoading)
                    Text(
                      l10n.loading,
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Viestilista
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getChatMessages(widget.otherUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.errorLoadingMessages,
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            ErrorHelper.getUserFriendlyErrorMessage(
                                snapshot.error, AppLocalizations.of(context)!),
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retryButton),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noMessagesYet,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.startConversation,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors
                                        .blue // Explicit strong blue for own messages
                                    : Theme.of(context).cardTheme.color ??
                                        Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: isMe
                                      ? const Radius.circular(18)
                                      : const Radius.circular(4),
                                  bottomRight: isMe
                                      ? const Radius.circular(4)
                                      : const Radius.circular(18),
                                ),
                              ),
                              child: Text(
                                message.text,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white // Explicit white text
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Viestin syöttökenttä
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: l10n.writeMessage,
                          hintStyle:
                              TextStyle(color: Theme.of(context).hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor ??
                              Theme.of(context).cardTheme.color,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: Icon(Icons.send,
                            color: Theme.of(context).colorScheme.onPrimary),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
