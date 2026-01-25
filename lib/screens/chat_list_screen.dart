import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../l10n/app_localizations.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.messages)),
        body: Center(child: Text(l10n.login)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messages),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getUserChats().map((event) => event),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(AppLocalizations.of(context)!
                    .errorGenericWithDetails(snapshot.error.toString())));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(l10n.noMessagesYet,
                      style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat['otherUserId'] as String;
              final lastMessage = chat['lastMessage'] as String;
              final unreadCount = chat['unreadCount'] as int;

              return FutureBuilder<UserModel?>(
                future: _userService.getUserById(otherUserId),
                builder: (context, userSnapshot) {
                  final otherUser = userSnapshot.data;
                  final otherUserName = otherUser?.name ?? l10n.unknown;
                  final otherUserProfileImageUrl = otherUser?.profileImageUrl;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: otherUserProfileImageUrl != null
                          ? NetworkImage(otherUserProfileImageUrl)
                          : null,
                      child: otherUserProfileImageUrl == null
                          ? Text(otherUserName.isNotEmpty
                              ? otherUserName[0].toUpperCase()
                              : '?')
                          : null,
                    ),
                    title: Text(
                      otherUserName,
                      style: TextStyle(
                        fontWeight: unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: unreadCount > 0
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: unreadCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            otherUserId: otherUserId,
                            otherUserName: otherUserName,
                            otherUserProfileImageUrl: otherUserProfileImageUrl,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
