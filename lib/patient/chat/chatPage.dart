import 'package:flutter/material.dart';
import 'package:first/services/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Import for the File class
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class ChatPage extends StatefulWidget {
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorPhoto;

  ChatPage({
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhoto,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead(); // Mark messages as read when the chat is opened
  }



  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Call _uploadImage to upload the picked image
      _uploadImage(File(pickedFile.path));
    }
  }

  // Function to upload the image to Firebase Storage and send it as a message
  Future<void> _uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last; // Get file name from the path
      final storageRef = FirebaseStorage.instance.ref().child('chat_images/$fileName');

      // Upload image to Firebase Storage
      await storageRef.putFile(imageFile);

      // Get the file URL after upload
      final fileUrl = await storageRef.getDownloadURL();

      // Send the message with the file URL (including any text entered in the controller)
      _sendMessage(_messageController.text.trim(), fileUrl: fileUrl);
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _markMessagesAsRead() async {
    final List<String> users = [widget.patientId, widget.doctorId];
    users.sort();
    final String chatRoomID = users.join("_");

    final unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .where('receiverId', isEqualTo: widget.patientId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unreadMessages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  void _sendMessage(String message, {String? fileUrl}) {
    if (message.isNotEmpty || fileUrl != null) {
      _chatService.sendMessage(
        senderId: widget.patientId,
        receiverId: widget.doctorId,
        message: message,
        fileUrl: fileUrl,
        isRead: false,
      );
      _messageController.clear();
    }
  }


  Stream<List<Map<String, dynamic>>> _getMessages() {
    final List<String> users = [widget.patientId, widget.doctorId];
    users.sort();
    final String chatRoomID = users.join("_");

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'messageId': doc.id,
          'message': data['message'] ?? '',
          'fileUrl': data['fileUrl'],
          'senderId': data['senderId'],
          'timestamp': data['timestamp'],
          'isRead': data['isRead'] ?? true,
          'status': data['status'] ?? 'sent',
        };
      }).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web layout (larger view, possibly horizontal layout)
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff414370),
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(widget.doctorPhoto),
                radius: 20,
              ),
              SizedBox(width: 10),
              Text('${widget.doctorName}',style: TextStyle(color: Colors.white70),),
            ],
          ),
        ),
        body: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/chatBack.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    // Chat message list
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _getMessages(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No messages yet.'));
                          } else {
                            final messages = snapshot.data!;
                            return ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isSender = message['senderId'] == widget.patientId;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                                  child: ListTile(
                                    title: Align(
                                      alignment: isSender
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: isSender
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isSender
                                                  ? Color(0xff414370)
                                                  : Colors.grey[300],
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: message['fileUrl'] != null
                                                ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (message['message'].isNotEmpty)
                                                  Text(
                                                    message['message'],
                                                    style: TextStyle(
                                                      color: isSender ? Colors.white : Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                SizedBox(height: 8),
                                                Image.network(
                                                  message['fileUrl'], // Display the image
                                                  height: 200, // Adjust as needed
                                                  width: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                              ],
                                            )
                                                : Text(
                                              message['message'],
                                              style: TextStyle(
                                                color: isSender ? Colors.white : Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (!isSender)
                                            Text(
                                              message['isRead'] ? 'Read' : 'Unread',
                                              style: TextStyle(
                                                color: message['isRead'] ? Colors.grey : Colors.red,
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          SizedBox(height: 5),

                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                    // Message input area
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white70,
                                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              ),
                              onSubmitted: (value) => _sendMessage(value),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.image),
                            title: Text('Pick Image'),
                            onTap: () {
                              Navigator.pop(context); // Close the bottom sheet
                              _pickImage();  // Trigger the image picker
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () => _sendMessage(_messageController.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return  Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff414370),
          title: Row(
            children: [
              CircleAvatar(
                 backgroundImage: widget.doctorPhoto.isNotEmpty
                    ? AssetImage(widget.doctorPhoto)
                    : null,
                child: widget.doctorPhoto.isEmpty
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 10),
              Text('${widget.doctorName}',style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/chatBack.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _getMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No messages yet.'));
                    } else {
                      final messages = snapshot.data!;
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isSender = message['senderId'] == widget.patientId;

                          return ListTile(
                            title: Align(
                              alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSender ? Color(0xff414370) : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: message['fileUrl'] != null
                                        ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (message['message'].isNotEmpty)
                                          Text(
                                            message['message'],
                                            style: TextStyle(
                                              color: isSender ? Colors.white : Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        SizedBox(height: 8),
                                        Image.network(
                                          message['fileUrl'], // Display the image
                                          height: 200, // Adjust as needed
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    )
                                        : Text(
                                      message['message'],
                                      style: TextStyle(
                                        color: isSender ? Colors.white : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    message['status'] ?? 'sent',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );

                        },
                      );
                    }
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
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.attach_file),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.image),
                                        title: Text('Pick Image'),
                                        onTap: () {
                                          Navigator.pop(context); // Close the bottom sheet
                                          _pickImage();  // Trigger the image picker
                                        },
                                      ),
                                      // Add other file options if needed here
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        _sendMessage(_messageController.text.trim());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
