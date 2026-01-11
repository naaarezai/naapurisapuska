import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Lisätty StreamControlleria varten

/// Chat-viestin malli
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderProfileImageUrl;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderProfileImageUrl,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderProfileImageUrl': senderProfileImageUrl,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      senderProfileImageUrl: map['senderProfileImageUrl'] as String?,
      text: map['text'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}

/// Chat-palvelu viestien hallintaan
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// 1. UUSI METODI: Laske kaikkien lukemattomien viestien määrä
  Stream<int> getTotalUnreadCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    // Kuunnellaan kaikkia chatteja, joissa käyttäjä on mukana
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      int totalUnread = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Haetaan käyttäjäkohtainen lukemattomien määrä
        // Kentän nimi on esim: "unreadCount_USERID"
        final count = (data['unreadCount_${currentUser.uid}'] as num?)?.toInt() ?? 0;
        totalUnread += count;
      }
      return totalUnread;
    });
  }

  Stream<List<ChatMessage>> getChatMessages(String otherUserId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    final chatId = _getChatId(currentUser.uid, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return ChatMessage.fromMap(doc.data(), doc.id);
            } catch (e) {
              return null;
            }
          })
          .whereType<ChatMessage>()
          .toList();
    });
  }

  Future<void> sendMessage(String otherUserId, String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Käyttäjä ei ole kirjautunut');
    if (text.trim().isEmpty) throw Exception('Viesti ei voi olla tyhjä');

    final chatId = _getChatId(currentUser.uid, otherUserId);
    final now = DateTime.now();

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
    final userData = userDoc.data();
    final userName = userData?['name'] as String? ?? 'Tuntematon';
    final userProfileImageUrl = userData?['profileImageUrl'] as String?;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUser.uid,
      'senderName': userName,
      'senderProfileImageUrl': userProfileImageUrl,
      'text': text.trim(),
      'timestamp': Timestamp.fromDate(now),
      'isRead': false,
    });

    // 2. PÄIVITETTY: Kasvatetaan vastaanottajan lukemattomien laskuria
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [currentUser.uid, otherUserId],
      'lastMessage': text.trim(),
      'lastMessageTime': Timestamp.fromDate(now),
      'lastMessageSenderId': currentUser.uid,
      'updatedAt': Timestamp.fromDate(now),
      // TÄMÄ ON UUSI RIVI: Kasvata vastaanottajan (otherUserId) unread-laskuria yhdellä
      'unreadCount_$otherUserId': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final chatId = _getChatId(currentUser.uid, otherUserId);

    // Merkitään yksittäiset viestit luetuiksi (kuten ennenkin)
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();
    
    final otherUserMessages = unreadMessages.docs
        .where((doc) => doc.data()['senderId'] != currentUser.uid)
        .toList();

    if (otherUserMessages.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in otherUserMessages) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      // 3. PÄIVITETTY: Nollataan käyttäjän oma unread-laskuri tässä chatissa
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.set(chatRef, {
        'unreadCount_${currentUser.uid}': 0,
      }, SetOptions(merge: true));

      await batch.commit();
    }
  }

  Stream<List<Map<String, dynamic>>> getUserChats() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final otherUserId = participants.firstWhere(
          (id) => id != currentUser.uid,
          orElse: () => '',
        );
        
        // Luetaan myös chatin lukemattomat tässä, jos haluat näyttää listassa
        final unreadCount = (data['unreadCount_${currentUser.uid}'] as num?)?.toInt() ?? 0;

        return {
          'chatId': doc.id,
          'otherUserId': otherUserId,
          'lastMessage': data['lastMessage'] as String? ?? '',
          'lastMessageTime': data['lastMessageTime'] as Timestamp?,
          'lastMessageSenderId': data['lastMessageSenderId'] as String?,
          'unreadCount': unreadCount, // Voi käyttää ChatListScreenissä
        };
      }).toList();
      
      chats.sort((a, b) {
        final timeA = a['lastMessageTime'] as Timestamp?;
        final timeB = b['lastMessageTime'] as Timestamp?;
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeB.compareTo(timeA);
      });
      
      return chats;
    });
  }
}