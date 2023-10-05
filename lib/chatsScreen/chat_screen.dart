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
  // bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentUserUid = _auth.currentUser!.uid;
    _messageController = TextEditingController();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {}
    });
  }

//Display the enlarged image
  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Create a reference to the chat document
    final chatDoc = _firestore.collection('chats').doc(widget.chatId);

    // Use a batch to update multiple fields atomically
    final batch = _firestore.batch();

    // Update the 'unreadMessage' field for both sender and receiver
    batch.update(chatDoc, {
      'unreadMessage': FieldValue.increment(1),
    });

    // Add the message to the collection
    batch.set(chatDoc.collection('messages').doc(), {
      'senderUid': _currentUserUid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Commit the batch
    await batch.commit();

    await _updateLastMessage(text);

    setState(() {
      _messageController.clear();
    });

    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

// Update the last message in the chat
  Future<void> _updateLastMessage(String text) async {
    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': text,
    });
  }

// Send an image
  Future<void> _sendImage(String imagePath) async {
    final Reference ref = _storage
        .ref()
        .child('chat_images/${DateTime.now().millisecondsSinceEpoch}');
    final UploadTask uploadTask = ref.putFile(File(imagePath));
    final TaskSnapshot taskSnapshot = await uploadTask;

    final imageUrl = await taskSnapshot.ref.getDownloadURL();

    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderUid': _currentUserUid,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _updateLastMessage('Image sent');
    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                _messages = messages;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Display new messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index]
                        .data(); // Reverse the order
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
                              GestureDetector(
                                onTap: () {
                                  _showEnlargedImage(
                                      context, message['imageUrl']);
                                },
                                child: Image.network(
                                  message['imageUrl'],
                                  height: 150,
                                ),
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
