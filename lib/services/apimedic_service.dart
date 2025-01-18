import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiMedicService {
  final String _authUrl = 'https://authservice.priaid.ch/login'; // Authentication URL
  final String _baseUrl = 'https://healthservice.priaid.ch'; // Base URL
  final String _username = 'Bi96G_GMAIL_COM_AUT'; // Replace with your username
  final String _password = 't6LTd53Kaj8RQk24G'; // Replace with your password

  String? _token;

  // Authenticate with the API and retrieve a token
  Future<void> authenticate() async {
    try {
      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Username': _username,
          'Password': _password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['Token']; // Save the token
        print('Authentication successful. Token: $_token');
      } else {
        print('Authentication failed. Response: ${response.body}');
        throw Exception('Authentication failed: ${response.body}');
      }
    } catch (e) {
      print('Error during authentication: $e');
      throw Exception('Error during authentication: $e');
    }
  }


  // Fetch the list of symptoms
  Future<List<dynamic>> fetchSymptoms() async {
    // Authenticate if the token is null
    if (_token == null) {
      await authenticate();
    }

    final url = Uri.parse('$_baseUrl/symptoms?token=$_token&language=en-gb');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse and return the list of symptoms
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch symptoms: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching symptoms: $e');
    }
  }

  // Fetch diagnosis based on selected symptoms, gender, and year of birth
  Future<List<dynamic>> getDiagnosis(
      List<int> symptomIds, String gender, int yearOfBirth) async {
    // Authenticate if the token is null
    if (_token == null) {
      await authenticate();
    }

    // Construct the URL for the diagnosis endpoint
    final url = Uri.parse(
      '$_baseUrl/diagnosis?symptoms=${jsonEncode(symptomIds)}&gender=$gender&year_of_birth=$yearOfBirth&token=$_token&language=en-gb',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse and return the diagnosis result
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch diagnosis: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching diagnosis: $e');
    }
  }
}
