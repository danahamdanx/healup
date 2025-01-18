import 'package:flutter/material.dart';
import 'package:first/services/apimedic_service.dart';

class DiagnosisScreen extends StatefulWidget {
  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final ApiMedicService _apiService = ApiMedicService();
  List<int> selectedSymptoms = [];
  String gender = 'male'; // or 'female'
  int yearOfBirth = 1990;

  Future<void> getDiagnosis() async {
    try {
      final diagnosis = await _apiService.getDiagnosis(selectedSymptoms, gender, yearOfBirth);
      print('Diagnosis: $diagnosis');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Get Diagnosis')),
      body: Column(
        children: [
          // Gender selection
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
          ),
          // Year of birth input
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Year of Birth'),
            onChanged: (value) {
              yearOfBirth = int.tryParse(value) ?? 1990;
            },
          ),
          ElevatedButton(
            onPressed: () async {
              await getDiagnosis(); // Fetch diagnosis
            },
            child: Text('Get Diagnosis'),
          ),
        ],
      ),
    );
  }
}
