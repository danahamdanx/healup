import 'package:flutter/material.dart';
import 'package:first/services/apimedic_service.dart';

class SymptomChatScreen extends StatefulWidget {
  @override
  _SymptomChatScreenState createState() => _SymptomChatScreenState();
}

class _SymptomChatScreenState extends State<SymptomChatScreen> {
  final ApiMedicService _apiService = ApiMedicService();
  late Future<List<dynamic>> _symptomsFuture;
  List<int> selectedSymptoms = [];
  String gender = 'male';
  int yearOfBirth = 1990;
  List<Map<String, String>> messages = [];
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _symptomsFuture = _apiService.fetchSymptoms(); // Fetch symptoms
    messages.add({"role": "bot", "text": "Hi! Let's start diagnosing your symptoms. What's troubling you today?"});
  }

  void _addMessage(String role, String text) {
    setState(() {
      messages.add({"role": role, "text": text});
    });
  }

  void _processInput(String input) {
    // Add user's message to the chat
    _addMessage("user", input.toLowerCase());

    if (input.toLowerCase() == "no" || input.toLowerCase() == "done") {
      // Stop symptom entry and proceed to diagnosis
      _addMessage("bot", "Thanks! Let me analyze your symptoms...");
      _getDiagnosisAndSpecializations();
    } else if (input.toLowerCase() == "yes") {
      // Prompt for additional symptoms
      _addMessage("bot", "Sure! Please tell me another symptom.");
    } else {
      // Assume the user provided a symptom
      // (Here, you'd match the input to known symptoms in a real implementation)
      _addMessage("bot", "Got it! Any other symptoms?");
      // Optionally add the symptom to selectedSymptoms (for simulation purposes)
      selectedSymptoms.add(input.hashCode); // Replace with real symptom matching
    }
  }

  Future<void> _getDiagnosisAndSpecializations() async {
    try {
      final diagnosis = await _apiService.getDiagnosis(selectedSymptoms, gender, yearOfBirth);
      _addMessage(
        "bot",
        "Based on your symptoms, here are some possible conditions: ${diagnosis.map((d) => d['Issue']['Name']).join(", ")}",
      );

      final specializations = await _apiService.fetchSpecializations(selectedSymptoms, gender, yearOfBirth);
      _addMessage(
        "bot",
        "You may need to consult these specializations: ${specializations.map((s) => s['Name']).join(", ")}.",
      );
    } catch (e) {
      _addMessage("bot", "Something went wrong. Please try again.");
    }
  }

  Widget _buildChatBubble(String role, String text) {
    final isBot = role == "bot";
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isBot ? Colors.grey[200] : Colors.blue[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Type your symptom...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _processInput(value);
                  _textController.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                _processInput(_textController.text);
                _textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Symptom Checker Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildChatBubble(message['role']!, message['text']!);
              },
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: _symptomsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error fetching symptoms');
              } else {
                return _buildInputField();
              }
            },
          ),
        ],
      ),
    );
  }
}
