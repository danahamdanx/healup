import 'package:flutter/material.dart';

class PrescriptionPage extends StatelessWidget {
  final String doctorSpecialization;
  final String doctorName;
  final String doctorPhone;
  final String doctorHospital;
  final String patientName;
  final String patientAge;
  final String date;
  final List<Map<String, String>> medications;

  PrescriptionPage({
    required this.doctorSpecialization,
    required this.doctorName,
    required this.doctorPhone,
    required this.doctorHospital,
    required this.patientName,
    required this.patientAge,
    required this.date,
    required this.medications,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription Details"),
        backgroundColor: const Color(0xff6be4d7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor and Patient Information Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor's Details (Left Side)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Doctor Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Doctor Name: $doctorName", style: TextStyle(fontSize: 16)),
                      Text('Specialization: $doctorSpecialization', style: TextStyle(fontSize: 16)),
                      Text('Phone: $doctorPhone', style: TextStyle(fontSize: 16)),
                      Text('Hospital: $doctorHospital', style: TextStyle(fontSize: 16)),


                    ],
                  ),
                ),
                const SizedBox(width: 16), // Space between the columns

                // Patient Info (Right Side)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Patient Name: $patientName', style: TextStyle(fontSize: 16)),
                      Text("Age: $patientAge", style: TextStyle(fontSize: 16)),
                      Text('Prescription Date: $date', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20), // Adds space after the row
            Divider(color: Colors.black, thickness: 2,), // Divider for separation

            // Medications Section
            const SizedBox(height: 20),
            Text("Medications:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...medications.map((med) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(
                      "Name: ${med['name']}\nQuantity: ${med['quantity']}\nDosage: ${med['dosage']}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
