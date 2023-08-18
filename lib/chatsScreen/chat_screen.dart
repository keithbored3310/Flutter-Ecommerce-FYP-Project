import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late String _currentUserUid;
  late TextEditingController _messageController;
  List<QueryDocumentSnapshot> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUserUid = _auth.currentUser!.uid;
    _messageController = TextEditingController();
  }

  // Future<Map<String, dynamic>> _fetchChatParticipantInfo() async {
  //   final chatDoc =
  //       await _firestore.collection('chats').doc(widget.chatId).get();

  //   if (chatDoc.exists) {
  //     final sellerShopName = chatDoc['sellerShopName'];
  //     final sellerImageUrl = chatDoc['sellerImageUrl'];

  //     return {
  //       'sellerShopName': sellerShopName,
  //       'sellerImageUrl': sellerImageUrl,
  //     };
  //   }

  //   return {
  //     'sellerShopName': 'Unknown Seller',
  //     'sellerImageUrl': '',
  //   };
  // }

  Future<void> _fetchMoreMessages() async {
    if (_messages.isEmpty) return;

    final lastMessage = _messages.last;

    setState(() {
      _isLoading = true;
    });

    final newMessages = await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastMessage)
        .limit(10) // Fetch the next 10 messages
        .get()
        .then((querySnapshot) => querySnapshot.docs);

    setState(() {
      _isLoading = false;
      _messages.addAll(newMessages);
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty)
      return; // Replace userUsername with the actual variable holding the user's username

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderUid': _currentUserUid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _updateLastMessage(text);

    setState(() {
      _messageController.clear();
    });
  }

  Future<void> _updateLastMessage(String text) async {
    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': text,
    });
  }

  Future<void> _sendImage(String imagePath) async {
    final Reference ref = _storage
        .ref()
        .child('chat_images/${DateTime.now().millisecondsSinceEpoch}');
    final UploadTask uploadTask = ref.putFile(File(imagePath));
    final TaskSnapshot taskSnapshot = await uploadTask;

    final imageUrl = await taskSnapshot.ref.getDownloadURL();

    // Add the image message to the messages subcollection
    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderUid': _currentUserUid,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the lastMessage in the chat document
    await _updateLastMessage('Image sent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (!_isLoading &&
                    notification is ScrollEndNotification &&
                    notification.metrics.extentAfter == 0) {
                  // User has reached the end of the list, fetch more messages
                  _fetchMoreMessages();
                }
                return false;
              },
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp')
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final messages = snapshot.data!.docs;
                  _messages = messages;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index].data();
                      final bool isCurrentUser =
                          message['senderUid'] == _currentUserUid;

                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blue
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (message['imageUrl'] != null)
                                Image.network(
                                  message['imageUrl'],
                                  height: 150, // Adjust the height as needed
                                ),
                              if (message['text'] != null)
                                Text(
                                  message['text'],
                                  style: const TextStyle(color: Colors.black),
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final imagePicker = ImagePicker();
                    final pickedImage = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );

                    if (pickedImage != null) {
                      _sendImage(pickedImage.path);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () async {
                    final imagePicker = ImagePicker();
                    final pickedImage = await imagePicker.pickImage(
                        source: ImageSource.gallery);

                    if (pickedImage != null) {
                      _sendImage(pickedImage.path);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
