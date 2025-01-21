import 'package:flutter/material.dart';
import 'package:first/services/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Import for the File class
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:first/services/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Import for the File class
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class docChat extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;
  final String receiverPhoto;

  docChat({
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhoto,
  });

  @override
  _docChatState createState() => _docChatState();
}

class _docChatState extends State<docChat> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ImagePicker _imagePicker = ImagePicker();

  // Function to pick an image from the gallery
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

  // Function to send a message
  void _sendMessage(String message, {String? fileUrl}) {
    if (message.isNotEmpty || fileUrl != null) {
      _chatService.sendMessage(
        senderId: widget.senderId,
        receiverId: widget.receiverId,
        message: message,
        fileUrl: fileUrl,
      );
      _messageController.clear();
    }
  }

  // Stream for fetching messages
  Stream<List<Map<String, dynamic>>> _getMessages() {
    final List<String> users = [widget.senderId, widget.receiverId];
    users.sort(); // Ensure consistent chat room ID
    final String chatRoomID = users.join("_");

    return _chatService.getMessages(chatRoomID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.receiverPhoto.isNotEmpty
                  ? AssetImage(widget.receiverPhoto)
                  : null,
              child: widget.receiverPhoto.isEmpty
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10),
            Text('${widget.receiverName}'),
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
                        final isSender = message['senderId'] == widget.senderId;

                        return ListTile(
                          title: Align(
                            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSender ? Color(0xff2f9a8f) : Colors.grey[300],
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

