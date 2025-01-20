import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


Future<void> _sendMessageToBackend(String role, String text) async {
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Declare the storage instance

  String? patientId = await _storage.read(key: 'patient_id'); // Get patient ID from secure storage

  if (patientId != null) {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/healup/chat/save'), // Backend API
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'role': role,
          'text': text,
          'patientId': patientId,
        }),
      );

      if (response.statusCode == 200) {
        print('Message saved to MongoDB');
      } else {
        print('Failed to save message');
      }
    } catch (e) {
      print('Error saving message to backend: $e');
    }
  } else {
    print('Patient ID not found in secure storage');
  }
}
