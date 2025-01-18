import 'package:flutter/material.dart';
import 'package:first/services/apimedic_service.dart';

class SymptomScreen extends StatefulWidget {
  @override
  _SymptomScreenState createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final ApiMedicService _apiService = ApiMedicService();
  late Future<List<dynamic>> _symptomsFuture;

  @override
  void initState() {
    super.initState();
    _symptomsFuture = _apiService.fetchSymptoms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Symptom Checker')),
      body: FutureBuilder<List<dynamic>>(
        future: _symptomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final symptoms = snapshot.data!;
            return ListView.builder(
              itemCount: symptoms.length,
              itemBuilder: (context, index) {
                final symptom = symptoms[index];
                return ListTile(
                  title: Text(symptom['Name']),
                  onTap: () {
                    print('Selected symptom ID: ${symptom['ID']}');
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
