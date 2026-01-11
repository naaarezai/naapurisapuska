import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viestit'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Virhe viestien lataamisessa',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Ei keskusteluja',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aloita keskustelu ilmoituksen jakajan kanssa',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ChatListItem(chatData: chat);
            },
          );
        },
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final Map<String, dynamic> chatData;

  const ChatListItem({super.key, required this.chatData});

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (diff.inDays < 7) {
      return DateFormat('E').format(date); // Viikonpäivä
    } else {
      return DateFormat('d.M.').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    final currentUser = FirebaseAuth.instance.currentUser;
    final otherUserId = chatData['otherUserId'];
    final lastMessage = chatData['lastMessage'] ?? '';
    final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;
    final lastMessageSenderId = chatData['lastMessageSenderId'] as String?;
    final isUnread = lastMessageSenderId != null && 
                     lastMessageSenderId != currentUser?.uid;

    return FutureBuilder<UserModel?>(
      future: userService.getUserById(otherUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? 'Tuntematon käyttäjä';
        final profileImage = user?.profileImageUrl;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profileImage != null
                ? CachedNetworkImageProvider(profileImage)
                : null,
            child: profileImage == null ? const Icon(Icons.person) : null,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          trailing: Text(
            _formatTime(lastMessageTime),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            // Avaa keskustelu
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  otherUserId: otherUserId,
                  otherUserName: name,
                  otherUserProfileImageUrl: profileImage,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
