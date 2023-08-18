import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/chatsScreen/chat_screen.dart'; // Import the chat screen if needed

class UserChatListScreen extends StatefulWidget {
  const UserChatListScreen({super.key});

  @override
  State<UserChatListScreen> createState() => _UserChatListScreenState();
}

class _UserChatListScreenState extends State<UserChatListScreen> {
  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserUid = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Chats'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('sender', isEqualTo: currentUserUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final chatDocs = snapshot.data?.docs ?? [];
          print('how many chatDocs: ${chatDocs.length}');
          if (chatDocs.isEmpty) {
            return const Center(child: Text('No chats available.'));
          }

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final chatId = chatDocs[index].id;
              final sender = chatData['sender'];
              final receiver = chatData['receiver'];
              final sellerShopName = chatData['sellerShopName'];
              final lastMessage = chatData['lastMessage'];
              final sellerImageUrl = chatData['sellerImageUrl'];

              print('chatData: $chatData');

              // You can build your chat list tile UI here
              return ListTile(
                leading: sellerImageUrl != null && sellerImageUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(sellerImageUrl),
                      )
                    : const CircleAvatar(child: Icon(Icons.store)),
                title: Text(sellerShopName ?? ''),
                subtitle: Text(lastMessage ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                      ),
                    ),
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
