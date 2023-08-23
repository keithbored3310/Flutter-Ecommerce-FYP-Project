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
          if (chatDocs.isEmpty) {
            return const Center(child: Text('No chats available.'));
          }

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final chatId = chatDocs[index].id;
              final sellerShopName = chatData['sellerShopName'];
              final lastMessage = chatData['lastMessage'];
              final sellerImageUrl = chatData['sellerImageUrl'];

              return Dismissible(
                key: Key(chatId), // Unique key for each chat item
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red, // Background color when swiped
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  // Handle chat deletion here
                  _deleteChat(chatId, context);
                },
                child: ListTile(
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteChat(String chatId, BuildContext context) {
    // Delete the chat document from Firestore
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .delete()
        .then((value) {
      // Show a SnackBar to indicate that the chat has been deleted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat deleted.'),
          duration: Duration(seconds: 2), // You can adjust the duration
        ),
      );

      // Update the state to trigger a rebuild of the chat list
      setState(() {});
    }).catchError((error) {
      // Handle any errors that may occur during deletion.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting chat.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
