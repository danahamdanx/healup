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
  Map<String, int> symptomMap = {};

  @override
  void initState() {
    super.initState();
    _symptomsFuture = _fetchSymptoms();
    messages.add({
      "role": "bot",
      "text": "Hi! Let's start diagnosing your symptoms. What's troubling you today?"
    });
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

  void _addMessage(String role, String text) {
    setState(() {
      messages.add({"role": role, "text": text});
    });
  }

  void _processInput(String input) {
    _addMessage("user", input);

    if (input.toLowerCase() == "no" || input.toLowerCase() == "done") {
      _addMessage("bot", "Thanks! Let me analyze your symptoms...");
      _getDiagnosisAndSpecializations();
      return;
    }

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
      final diagnosis = await _apiService.getDiagnosis(selectedSymptoms, gender, yearOfBirth);
      if (diagnosis.isNotEmpty) {
        _addMessage(
          "bot",
          "Based on your symptoms, here are some possible conditions: ${diagnosis.map((d) => d['Issue']['Name']).join(", ")}",
        );
      } else {
        _addMessage("bot", "No conditions could be identified based on your symptoms.");
      }

      final specializations = await _apiService.fetchSpecializations(selectedSymptoms, gender, yearOfBirth);
      if (specializations.isNotEmpty) {
        _addMessage(
          "bot",
          "You may need to consult these specializations: ${specializations.map((s) => s['Name']).join(", ")}.",
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
          color: isBot ? Colors.grey[200] : Color(0xff2f9a8f),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
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
            backgroundColor: Color(0xff2f9a8f),
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
            icon: Icon(Icons.arrow_drop_down, color: Color(0xff2f9a8f)),
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
        title: Text('Symptom Checker Chat'),
        backgroundColor: Color(0xff2f9a8f),
      ),
      body: FutureBuilder<List<dynamic>>(
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
    );
  }
}
