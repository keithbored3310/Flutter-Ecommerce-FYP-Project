import 'package:ecommerce/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/chatsScreen/chat_screen.dart';

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
    // _markAllChatsAsRead(); // Mark all chats as read when the screen is loaded
  }

// Mark a chat as read
  Future<void> markChatAsRead(String chatId) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'unreadMessage': 0,
    });
  }

// // Mark all chats as read
//   // Mark all chats as read
//   Future<void> _markAllChatsAsRead() async {
//     final chatDocs = await FirebaseFirestore.instance
//         .collection('chats')
//         .where('sender', isEqualTo: currentUserUid)
//         .get();

//     for (final chatDoc in chatDocs.docs) {
//       if (chatDoc.data()['newMessage'] == true) {
//         // If new messages are present in the chat, don't mark it as read
//         continue;
//       }

//       await chatDoc.reference.update({
//         'isRead': true,
//       });
//     }

//     TabsScreen.chatStatusCount = 0;
//   }

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
              final isRead = chatData['isRead'] ?? false;

              return Dismissible(
                key: Key(chatId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
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
                  onTap: () async {
                    await markChatAsRead(chatId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                        ),
                      ),
                    );
                  },
                  tileColor: isRead ? null : Colors.grey[200],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteChat(String chatId, BuildContext context) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .delete()
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat deleted.'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {});
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting chat.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
