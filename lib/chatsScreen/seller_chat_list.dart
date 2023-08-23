import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/chatsScreen/chat_screen.dart'; // Import the chat screen if needed

class SellerChatListScreen extends StatefulWidget {
  final String sellerId;
  const SellerChatListScreen({super.key, required this.sellerId});
  @override
  State<SellerChatListScreen> createState() => _SellerChatListScreenState();
}

class _SellerChatListScreenState extends State<SellerChatListScreen> {
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
            .where('receiver', isEqualTo: widget.sellerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final chatDocs = snapshot.data?.docs ?? [];
          if (chatDocs.isEmpty) {
            return const Center(child: Text('No chats available.'));
          }

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final chatId = chatDocs[index].id;
              final username = chatData['userUsername'];
              final lastMessage = chatData['lastMessage'];
              final userImageUrl = chatData['userImageUrl'];

              // You can build your chat list tile UI here
              return ListTile(
                leading: userImageUrl != null && userImageUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(userImageUrl),
                      )
                    : const CircleAvatar(child: Icon(Icons.store)),
                title: Text(username ?? ''),
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
