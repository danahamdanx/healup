import 'package:flutter/material.dart';
import 'package:first/services/apimedic_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb

class SymptomChatScreen extends StatefulWidget {
  @override
  _SymptomChatScreenState createState() => _SymptomChatScreenState();
}

class _SymptomChatScreenState extends State<SymptomChatScreen> {
  final ApiMedicService _apiService = ApiMedicService();
  late Future<List<dynamic>> _symptomsFuture;
  List<int> selectedSymptoms = [];
  String gender = 'female'; // Default gender
  int yearOfBirth = 2002;  // Default year of birth
  String userName = "";  // Default empty userName
  List<Map<String, dynamic>> messages = [];
  TextEditingController _textController = TextEditingController();
  Map<String, int> symptomMap = {};
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Declare the storage instance

  // Flag to check if user data is loaded
  bool isUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _getUserNameID(); // Call the method to fetch user info and symptoms
    _fetchChatHistory(); // Fetch the chat history
    _symptomsFuture = _fetchSymptoms();
  }
  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }

  Future<void> _fetchChatHistory() async {
    String? patientId = await _storage.read(key: 'patient_id'); // Get patient ID from secure storage

    if (patientId != null) {
      try {
        final response = await http.get(
          Uri.parse('${getBaseUrl()}/api/healup/chatBot/history?patientId=$patientId'), // Backend API
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // Parse the response body
          final responseBody = json.decode(response.body);

          // Check for 'messages' key in the response
          if (responseBody is Map<String, dynamic> && responseBody['messages'] != null) {
            List<dynamic> chatHistory = responseBody['messages'];

            // Convert the chat history to the appropriate format
            setState(() {
              messages = chatHistory.map((message) {
                return {
                  'role': message['role'] ?? 'unknown', // Default to 'unknown' if 'role' is missing
                  'text': message['text'] ?? 'No text available', // Default to 'No text available' if 'text' is missing
                };
              }).toList();
            });
            print('Chat history fetched successfully');
          } else {
            print('Invalid response structure: "messages" key not found');
          }
        } else {
          print('Failed to fetch chat history. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error fetching chat history: $e');
      }
    } else {
      print('Patient ID not found in secure storage');
    }
  }



  // Remove the call to _sendMessageToBackend from here
  void _addMessage(String role, String text) {
    setState(() {
      messages.add({"role": role, "text": text}); // Add message to chat
    });
  }



// Update this function to save the whole conversation at once
  Future<void> _saveConversationToBackend() async {
    String? patientId = await _storage.read(key: 'patient_id'); // Get patient ID from secure storage

    if (patientId != null) {
      print('Messages: $messages'); // Debug statement to check messages before sending
      try {
        final response = await http.post(
          Uri.parse('${getBaseUrl()}/api/healup/chatBot/save'), // Backend API
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'patientId': patientId,
            'messages': messages, // Send the whole conversation
          }),
        );

        if (response.statusCode == 200) {
          print('Conversation saved to MongoDB');
        } else {
          print('Failed to save conversation. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error saving conversation to backend: $e');
      }
    } else {
      print('Patient ID not found in secure storage');
    }
  }




  Future<void> _getUserNameID() async {
    String? id = await _storage.read(key: 'patient_id');
    String? name = await _storage.read(key: 'patient_name');
    String? storedGender = await _storage.read(key: 'patient_gender');
    String? storedYearOfBirth = await _storage.read(key: 'patient_birth_year');

    setState(() {
      userName = name ?? "Patient"; // Default "Patient"
      gender = storedGender ?? "female"; // Default "female"
      yearOfBirth = int.tryParse(storedYearOfBirth ?? "2002") ?? 2002; // Default 2002
// Default to 2002 if year is not found
      isUserLoaded = true; // Mark user as loaded
    });

    // Add greeting message once the user is loaded
    if (isUserLoaded) {
      _addMessage("bot", "Hi $userName! Let's start diagnosing your symptoms. What's troubling you today?");
    }
  }

  Future<List<dynamic>> _fetchSymptoms() async {
    try {
      final symptoms = await _apiService.fetchSymptoms();
      symptomMap = {for (var s in symptoms) s['Name'].toLowerCase(): s['ID']};
      return symptoms;
    } catch (e) {
      throw Exception('Failed to fetch symptoms: $e');
    }
  }

  // Add new message to the chat



  void _processInput(String input) {
    _addMessage("user", input);  // Add user message to the chat

    // If the user indicates they're done
    if (input.toLowerCase() == "no" || input.toLowerCase() == "done") {
      _addMessage("bot", "Thanks! Let me analyze your symptoms...");
      _getDiagnosisAndSpecializations();

      // Save the entire conversation when done
      _saveConversationToBackend();

      return;
    }

    // Handle symptom selection
    final symptomId = symptomMap[input.toLowerCase()];
    if (symptomId != null) {
      selectedSymptoms.add(symptomId);
      _addMessage("bot", "Got it! Any other symptoms?");
    } else {
      _addMessage("bot", "I couldn't recognize that symptom. Please try again.");
    }

  }




  Future<void> _getDiagnosisAndSpecializations() async {
    try {
      // Fetch the diagnosis results
      final diagnosis = await _apiService.getDiagnosis(selectedSymptoms, gender, yearOfBirth);
      if (diagnosis.isNotEmpty) {
        _addMessage(
          "bot",
          "Based on your symptoms, here are some possible conditions:\n" +
              diagnosis.map((d) => "- ${d['Issue']['Name']}").join("\n"),
        );
      } else {
        _addMessage("bot", "No conditions could be identified based on your symptoms.");
      }

      // Fetch the specialization results
      final specializations = await _apiService.fetchSpecializations(selectedSymptoms, gender, yearOfBirth);
      if (specializations.isNotEmpty) {
        _addMessage(
          "bot",
          "You may need to consult these specializations:\n" +
              specializations.map((s) => "- ${s['Name']}").join("\n"),
        );
      } else {
        _addMessage("bot", "No specializations could be recommended based on your symptoms.");
      }
    } catch (e) {
      _addMessage("bot", "Something went wrong while analyzing your symptoms. Please try again.");
    }
  }


  Widget _buildChatBubble(String role, String text) {
    final isBot = role == "bot";
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey[200] : Color(0xff414370),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(isBot ? 0 : 12),
            bottomRight: Radius.circular(isBot ? 12 : 0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isBot ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildChatUI() {
    return Expanded(
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/chatBack.jpg', // Replace with your image path
              fit: BoxFit.cover,           // Ensures the image covers the container
            ),
          ),
          // Chat Bubbles
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100]?.withOpacity(0.000009), // Optional overlay for better text visibility
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildChatBubble(message["role"]!, message["text"]!);
              },
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Type your symptom...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _processInput(value);
                  _textController.clear();
                }
              },
            ),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xff414370),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _processInput(_textController.text);
                  _textController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoForm() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          DropdownButton<String>(
            value: gender,
            items: [
              DropdownMenuItem(child: Text('Male'), value: 'male'),
              DropdownMenuItem(child: Text('Female'), value: 'female'),
            ],
            onChanged: (value) {
              setState(() {
                gender = value!;
              });
            },
            underline: Container(),
            icon: Icon(Icons.arrow_drop_down, color: Color(0xff414370)),
            style: TextStyle(fontSize: 16, color: Colors.black),
            dropdownColor: Colors.white,
          ),
          SizedBox(width: 15),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Year of Birth',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  yearOfBirth = int.tryParse(value) ?? 1990;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Symptom Checker Chat',style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold,fontSize: 25),),
        backgroundColor: Color(0xff414370),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/chatBack.jpg', // Path to your image
              fit: BoxFit.cover,       // Ensure the image covers the entire screen
            ),
          ),

          // Foreground Content
          FutureBuilder<List<dynamic>>(
            future: _symptomsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _symptomsFuture = _fetchSymptoms();
                          });
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No symptoms found.'));
              } else {
                return Column(
                  children: [
                    _buildPatientInfoForm(),
                    _buildChatUI(),
                    _buildInputField(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

}
