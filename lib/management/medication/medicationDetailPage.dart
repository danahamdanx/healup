import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb

class MedicationDetailsPage extends StatefulWidget {
  final String medicationId;

  MedicationDetailsPage({required this.medicationId});

  @override
  _MedicationDetailsPageState createState() => _MedicationDetailsPageState();
}

class _MedicationDetailsPageState extends State<MedicationDetailsPage> {
  Map<String, dynamic> medicationDetails = {};

  Future<void> fetchMedicationDetails() async {
    if(kIsWeb){
      try {
        final response = await http.get(
          Uri.parse("http://localhost:5000/api/healup/medication/${widget.medicationId}"),
        );
        if (response.statusCode == 200) {
          setState(() {
            // الوصول إلى المفتاح medication
            medicationDetails = jsonDecode(response.body)['medication'];
          });

          // طباعة المعلومات المستلمة
          print("++++++++++++++++++++++++++++");
          print("Medication Details: $medicationDetails");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch medication details")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }
    else{
      try {
        final response = await http.get(
          Uri.parse("http://10.0.2.2:5000/api/healup/medication/${widget.medicationId}"),
        );
        if (response.statusCode == 200) {
          setState(() {
            // الوصول إلى المفتاح medication
            medicationDetails = jsonDecode(response.body)['medication'];
          });

          // طباعة المعلومات المستلمة
          print("++++++++++++++++++++++++++++");
          print("Medication Details: $medicationDetails");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch medication details")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }

  }



  @override
  void initState() {
    super.initState();
    fetchMedicationDetails();
  }

  Widget _buildTextField(String label, dynamic value) {
    // Convert int or double to String
    String displayValue = value is double
        ? value.toStringAsFixed(2)  // Convert double to String with two decimal points
        : value is int ? value.toString() : value ?? "N/A";  // Convert int to String

    return TextFormField(
      initialValue: displayValue,
      readOnly: true, // Make the field read-only
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[900],
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Color(0xff414370),
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Color(0xff414370),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xff414370),width: 3),
        ),
        fillColor: Colors.white.withOpacity(0.8),
        filled: true,
      ),
      style: TextStyle(
        color: Color(0xff414370),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Medication Details ",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
              //fontWeight: FontWeight.bold,
              backgroundColor: Color(0xff414370),
            ),
          ),
          backgroundColor: const Color(0xff414370),
          iconTheme: const IconThemeData(
            color: Colors.white70,  // تغيير لون سهم التراجع
          ),
        ),
        body: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfff3efd9), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: medicationDetails.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: 600,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // صورة الدواء بشكل دائري
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 250,
                              width: 250,
                              child: Image.asset(
                                medicationDetails['image'] ?? 'images/default-image.jpg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(height: 2, color: Colors.grey),
                          const SizedBox(height: 30),
                          _buildTextField("Medication Name", medicationDetails['medication_name']),
                          const SizedBox(height: 12),
                          _buildTextField("Scientific Name", medicationDetails['scientific_name']),
                          const SizedBox(height: 12),
                          _buildTextField("Stock Quantity", medicationDetails['stock_quantity']),
                          const SizedBox(height: 12),
                          _buildTextField("Expiration Date", medicationDetails['expiration_date']),
                          const SizedBox(height: 12),
                          _buildTextField("Description", medicationDetails['description']),
                          const SizedBox(height: 12),
                          _buildTextField("Type", medicationDetails['type']),
                          const SizedBox(height: 10),
                          _buildTextField("Dosage", medicationDetails['dosage']),
                          const SizedBox(height: 12),
                          _buildTextField("Price", medicationDetails['price']),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Medication Details ",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
              //fontWeight: FontWeight.bold,
              backgroundColor: Color(0xff414370),
            ),
          ),
          backgroundColor: const Color(0xff414370),
          iconTheme: const IconThemeData(
            color: Colors.white70,  // تغيير لون سهم التراجع
          ),
        ),
        body:
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff3efd9), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: medicationDetails.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Medication image
                // Medication image
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),  // التأثير نفسه مع الزوايا المدورة
                    child: SizedBox(
                      height: 200,  // تحديد الارتفاع للمربع
                      width: 200,   // تحديد العرض للمربع
                      child: Image.asset(
                        medicationDetails['image'] ?? 'images/default-image.jpg',
                        fit: BoxFit.contain,  // تصغير الصورة داخل المربع دون القص
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // White line under image
                Container(
                  height: 3,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),

                // Display medication information in text fields
                _buildTextField("Medication Name", medicationDetails['medication_name']),
                const SizedBox(height: 20),
                _buildTextField("Scientific Name", medicationDetails['scientific_name']),
                const SizedBox(height: 20),
                _buildTextField("Stock Quantity", medicationDetails['stock_quantity']),
                const SizedBox(height: 20),
                _buildTextField("Expiration Date", medicationDetails['expiration_date']),
                const SizedBox(height: 20),
                _buildTextField("Description", medicationDetails['description']),
                const SizedBox(height: 20),
                _buildTextField("Type", medicationDetails['type']),
                const SizedBox(height: 20),
                _buildTextField("Dosage", medicationDetails['dosage']),
                const SizedBox(height: 20),
                _buildTextField("Price", medicationDetails['price']),
              ],
            ),
          ),
        ),
      );

    }

  }
}
