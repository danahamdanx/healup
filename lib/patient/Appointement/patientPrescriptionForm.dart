import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw; // For PDF generation
import 'dart:io'; // For file operations
import 'package:path_provider/path_provider.dart'; // To save files
import 'package:permission_handler/permission_handler.dart';
import 'payment_option.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




class PrescriptionPage extends StatefulWidget {
  final String appointmentId; // New field for appointmentId
  final String doctorSpecialization;
  final String doctorName;
  final String doctorPhone;
  final String doctorHospital;
  final String patientName;
  final String patientAge;
  final String date;
  final String patientId;

  final List<Map<String, String>> medications;

  PrescriptionPage({
    required this.appointmentId, // Add appointmentId to constructor
    required this.doctorSpecialization,
    required this.doctorName,
    required this.doctorPhone,
    required this.doctorHospital,
    required this.patientName,
    required this.patientAge,
    required this.date,
    required this.medications,
    required this.patientId,

  });

  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isDenied) {
        // Request Manage External Storage Permission
        await Permission.manageExternalStorage.request();
      }
    }
  }

  Future<void> savePrescriptionAsPdf() async {
    final pdf = pw.Document();

    // Build PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                "Prescription Details",
                style: pw.TextStyle(
                  fontSize: 40, // Increased font size for title
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20), // Space after title
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Doctor's Details
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Doctor Information", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Text("Doctor Name: ${widget.doctorName}", style: pw.TextStyle(fontSize: 22)),
                        pw.Text('Specialization: ${widget.doctorSpecialization}', style: pw.TextStyle(fontSize: 22)),
                        pw.Text('Phone: ${widget.doctorPhone}', style: pw.TextStyle(fontSize: 22)),
                        pw.Text('Hospital: ${widget.doctorHospital}', style: pw.TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  // Patient's Details
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Patient Information", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Text('Patient Name: ${widget.patientName}', style: pw.TextStyle(fontSize: 22)),
                        pw.Text("Age: ${widget.patientAge}", style: pw.TextStyle(fontSize: 22)),
                        pw.Text('Prescription Date: ${widget.date}', style: pw.TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                ],
              ),
              // Doctor and Patient Information Section (Two Columns)

              pw.SizedBox(height: 20), // Space between sections

              // Medications Section
              pw.Text(
                "Medications:",
                style: pw.TextStyle(
                  fontSize: 24, // Increased font size for label
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              ...widget.medications.map((med) {
                return pw.Text(
                  "${med['name']}, Dosage: ${med['dosage']}, Quantity: ${med['quantity']}",
                  style: pw.TextStyle(fontSize: 20),
                );
              }).toList(),
            ],
          );
        },
      ),
    );




    // Request Storage Permission
    await requestStoragePermission();

    if (await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted) {
      try {
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          await directory.create(recursive: true);
        }

        final file = File("${directory.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.pdf");
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✔ Prescription saved Successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save PDF: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission is required to save the file.")),
      );
    }
  }

// دالة لتحليل نص الوصفة الطبية
  // دالة لتحليل نص الوصفة الطبية
  // دالة لتحليل نص الوصفة الطبية
  List<Map<String, String>> parseMedications(String prescriptionText) {
    List<Map<String, String>> medications = [];

    // Split the prescription text into lines
    List<String> lines = prescriptionText.split('\n');

    // Find the section containing medications
    bool isMedicationsSection = false;

    for (String line in lines) {
      if (line.startsWith('Medications:')) {
        isMedicationsSection = true; // Start capturing medications
        continue; // Skip this line as it is just a label
      }

      // Capture medications after the "Medications:" header
      if (isMedicationsSection) {
        if (line.trim().isEmpty) {
          continue; // Skip empty lines
        }

        // Match the medication using the regex
        final regex = RegExp(r"- ID: (\S+), Name: ([^,]+), Quantity: (\d+), Dosage: ([^,]+)");
        final match = regex.firstMatch(line);

        if (match != null) {
          String id = match.group(1)!;
          String name = match.group(2)!;
          String quantity = match.group(3)!;
          String dosage = match.group(4)!;

          // Add medication to the list
          medications.add({
            'id': id,
            'name': name,
            'quantity': quantity,
            'dosage': dosage,
          });
        }
      }
    }

    return medications;
  }

  Future<void> getPrescriptionByAppointmentId() async {
    final url = 'http://10.0.2.2:5000/api/healup/prescriptions/appointment/${widget.appointmentId}'; // Ensure URL is correct
    // Function to retrieve prescription by appointmentId

    double totalPrice = 0.0; // Variable to store the total price of medications

    try {
      // Send HTTP GET request
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Convert the response from JSON to Dart objects
        final data = json.decode(response.body);

        if (data['message'] == 'Prescription retrieved successfully') {
          final prescription = data['prescription'];

          final patientId = prescription['patient_id']['_id'] ?? ''; // Ensure non-null value
          final prescriptionId = prescription['_id'] ?? ''; // Prescription ID

          print('Prescription ID: $prescriptionId');
          print('Patient ID: $patientId');

          // Print prescription details
          print('Appointment ID: ${widget.appointmentId}');
          print('Prescription ID: ${prescription['_id']}');

          // Print doctor and patient information
          print('Doctor Information:');
          print('Name: ${prescription['doctor_id']['name'] ?? 'Unknown'}');
          print('Specialization: ${prescription['doctor_id']['specialization'] ?? 'Unknown'}');
          print('Phone: ${prescription['doctor_id']['phone'] ?? 'Unknown'}');
          print('Hospital: ${prescription['doctor_id']['hospital'] ?? 'Unknown'}');

          print('Patient Information:');
          print('Name: ${prescription['patient_id']['username'] ?? 'Unknown'}');
          print('DOB: ${prescription['patient_id']['DOB'] ?? 'Unknown'}');

          print('Appointment Date: ${prescription['appointment_id']['app_date'] ?? 'Unknown'}');

          // Parse medications from prescription text
          final medications = parseMedications(prescription['prescription_text']);

          // Print medications and calculate total price
          print('Medications:');
          for (var med in medications) {
            // Extract values, providing defaults for null
            String medId = med['id'] ?? 'Unknown ID'; // Default 'Unknown ID' if null
            String name = med['name'] ?? 'Unknown Name'; // Default 'Unknown Name' if null
            String dosage = med['dosage'] ?? 'Unknown Dosage'; // Default 'Unknown Dosage' if null
            String quantityStr = med['quantity'] ?? '0'; // Default '0' if quantity is null

            print('Medication ID: $medId');
            print('Name: $name');
            print('Dosage: $dosage');
            print('Quantity: $quantityStr');

            // Convert quantity to int safely
            int quantity = int.tryParse(quantityStr) ?? 0;

            // Make HTTP request to get medication price by ID
            final medicationUrl = 'http://10.0.2.2:5000/api/healup/medication/$medId';
            final medResponse = await http.get(Uri.parse(medicationUrl));

            if (medResponse.statusCode == 200) {
              final medData = json.decode(medResponse.body);

              if (medData != null && medData['price'] != null) {
                double price = double.tryParse(medData['price'].toString()) ?? 0.0;
                double totalMedicationPrice = price * quantity;

                totalPrice += totalMedicationPrice; // Add to total price

                print('Price per unit: \$${price}');
                print('Total price for $name: \$${totalMedicationPrice}');
              } else {
                print('Price information not found for $name');
              }
            } else {
              print('Failed to fetch medication price for $medId');
            }

            print('---------------------------');
          }

          // Print the total price of all medications
          print('Total Price for all Medications: \$${totalPrice}');

          print('Patient ID: ${widget.patientId}');

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentOptions(
                totalPrice: totalPrice,
                patientId: patientId,
                prescriptionId: prescriptionId,  // Pass prescriptionId
              ),
            ),
          );

        } else {
          print('Prescription not found.');
        }
      } else {
        print('Failed to retrieve prescription. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching prescription: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription Details"),
        backgroundColor: const Color(0xff6be4d7),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: savePrescriptionAsPdf,
          ),
        ],
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
                // Doctor's Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Doctor Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Doctor Name: ${widget.doctorName}", style: TextStyle(fontSize: 16)),
                      Text('Specialization: ${widget.doctorSpecialization}', style: TextStyle(fontSize: 16)),
                      Text('Phone: ${widget.doctorPhone}', style: TextStyle(fontSize: 16)),
                      Text('Hospital: ${widget.doctorHospital}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Patient's Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Patient Name: ${widget.patientName}', style: TextStyle(fontSize: 16)),
                      Text("Age: ${widget.patientAge}", style: TextStyle(fontSize: 16)),
                      Text('Prescription Date: ${widget.date}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(color: Colors.black, thickness: 2),
            SizedBox(height: 20),
            Text("Medications:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...widget.medications.map((med) {
              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    "Name: ${med['name']}\nQuantity: ${med['quantity']}\nDosage: ${med['dosage']}",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),
            Spacer(),
            // زر "Add Order by Prescription"
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    getPrescriptionByAppointmentId();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff6be4d7), // لون الزر
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(
                    "Add Order by Prescription",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
