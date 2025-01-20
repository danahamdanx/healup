import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiMedicService {
  final String _authUrl = 'https://authservice.priaid.ch/login'; // Authentication URL
  final String _baseUrl = 'https://healthservice.priaid.ch'; // Base URL
  final String _username = 'Bi96G_GMAIL_COM_AUT'; // Replace with your username
  final String _password = 't6LTd53Kaj8RQk24G'; // Replace with your password

  String? _token;

  // Authenticate with the API and retrieve a token



  // Fetch the list of symptoms
  Future<List<dynamic>> fetchSymptoms() async {
    // Authenticate if the token is null


    final url = Uri.parse(
      'https://healthservice.priaid.ch/symptoms?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6ImRhbmEyOTQ1NEBnbWFpbC5jb20iLCJyb2xlIjoiVXNlciIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL3NpZCI6IjExNzY3IiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy92ZXJzaW9uIjoiMTA5IiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9saW1pdCI6IjEwMCIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcCI6IkJhc2ljIiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9sYW5ndWFnZSI6ImVuLWdiIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9leHBpcmF0aW9uIjoiMjA5OS0xMi0zMSIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcHN0YXJ0IjoiMjAyNS0wMS0xOCIsImlzcyI6Imh0dHBzOi8vYXV0aHNlcnZpY2UucHJpYWlkLmNoIiwiYXVkIjoiaHR0cHM6Ly9oZWFsdGhzZXJ2aWNlLnByaWFpZC5jaCIsImV4cCI6MTczNzQwNDMwNywibmJmIjoxNzM3Mzk3MTA3fQ.xpBo9J3n7LVNvchCGobZZ44nsedI6Z-MgZtcO68UdPM&format=json&language=en-gb'
    );
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
    }

    // Construct the URL for the diagnosis endpoint
    final url = Uri.parse(
     'https://healthservice.priaid.ch/diagnosis?symptoms=$symptomIds&gender=$gender&year_of_birth=$yearOfBirth&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6ImRhbmEyOTQ1NEBnbWFpbC5jb20iLCJyb2xlIjoiVXNlciIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL3NpZCI6IjExNzY3IiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy92ZXJzaW9uIjoiMTA5IiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9saW1pdCI6IjEwMCIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcCI6IkJhc2ljIiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9sYW5ndWFnZSI6ImVuLWdiIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9leHBpcmF0aW9uIjoiMjA5OS0xMi0zMSIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcHN0YXJ0IjoiMjAyNS0wMS0xOCIsImlzcyI6Imh0dHBzOi8vYXV0aHNlcnZpY2UucHJpYWlkLmNoIiwiYXVkIjoiaHR0cHM6Ly9oZWFsdGhzZXJ2aWNlLnByaWFpZC5jaCIsImV4cCI6MTczNzM5NTMzOSwibmJmIjoxNzM3Mzg4MTM5fQ.zGafrnfUb7NZj-f_VKR_AvZKerylx6jYXu5TMJ69OdU&format=json&language=en-gb'
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

  // Fetch the list of specializations
  Future<List<dynamic>> fetchSpecializations(
      List<int> symptomIds, String gender, int yearOfBirth) async {
    // Authenticate if the token is null
    if (_token == null) {
      // Add code here to authenticate and retrieve the token
    }

    // Construct the URL for the specializations endpoint
    final url = Uri.parse(
      'https://healthservice.priaid.ch/diagnosis/specialisations?symptoms=$symptomIds&gender=$gender&year_of_birth=$yearOfBirth&token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6ImRhbmEyOTQ1NEBnbWFpbC5jb20iLCJyb2xlIjoiVXNlciIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL3NpZCI6IjExNzY3IiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy92ZXJzaW9uIjoiMTA5IiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9saW1pdCI6IjEwMCIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcCI6IkJhc2ljIiwiaHR0cDovL2V4YW1wbGUub3JnL2NsYWltcy9sYW5ndWFnZSI6ImVuLWdiIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9leHBpcmF0aW9uIjoiMjA5OS0xMi0zMSIsImh0dHA6Ly9leGFtcGxlLm9yZy9jbGFpbXMvbWVtYmVyc2hpcHN0YXJ0IjoiMjAyNS0wMS0xOCIsImlzcyI6Imh0dHBzOi8vYXV0aHNlcnZpY2UucHJpYWlkLmNoIiwiYXVkIjoiaHR0cHM6Ly9oZWFsdGhzZXJ2aWNlLnByaWFpZC5jaCIsImV4cCI6MTczNzM5NTQxNiwibmJmIjoxNzM3Mzg4MjE2fQ.S-1dneE88IggPzOO1u0OIF5gPwS8_J0D6FKqA5gm4_0&format=json&language=en-gb'
    );
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse and return the list of specializations
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch specializations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching specializations: $e');
    }
  }

}