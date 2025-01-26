import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../doctor/doctorList.dart';

import '../managements/managementList.dart';
import '../medication/medicationList.dart';
import '../order/orderList.dart';
class PatientDetailsPage extends StatefulWidget {
  final String patientId;

  PatientDetailsPage({required this.patientId});

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  Map<String, dynamic> patientDetails = {};
  int _currentIndex = 0; // العنصر الحالي في القائمة الجانبية



  Future<void> fetchPatientDetails() async {
    if(kIsWeb){
      try {
        final response = await http.get(Uri.parse("http://localhost:5000/api/healup/patients/getPatientById/${widget.patientId}"));
        if (response.statusCode == 200) {
          setState(() {
            patientDetails = jsonDecode(response.body);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch patient details")),
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
        final response = await http.get(Uri.parse("http://10.0.2.2:5000/api/healup/patients/getPatientById/${widget.patientId}"));
        if (response.statusCode == 200) {
          setState(() {
            patientDetails = jsonDecode(response.body);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch patient details")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }

  }



  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation here based on the selected index
    if (index == 1) {
      // Navigate to Doctor List page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorListPage(),
        ),
      );
    } else if (index == 2) {
      //Navigate to Medication page (assuming you have one)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationListPage(),
        ),
      );
    } else if (index == 3) {
      //Navigate to Order page (assuming you have one)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderListPage(),
        ),
      );
    } else if (index == 4) {
      // Navigate to Management page (if necessary)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManagementListPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  Widget _buildTextField(String label, String value, {bool isEmail = false}) {
    return TextFormField(
      initialValue: value,
      readOnly: true, // Ensure the field is read-only for patient details
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
          borderSide: BorderSide(color: Color(0xff414370), width: 3),
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
            "Patient Details ",
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
                child: patientDetails.isEmpty
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
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage(
                              patientDetails['pic'] ??
                                  'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(height: 2, color:Color(0xff414370)),
                          const SizedBox(height: 20),
                          _buildTextField("Name", patientDetails['username']),
                          const SizedBox(height: 12),
                          _buildTextField("Email",
                              patientDetails['email'], isEmail: true),
                          const SizedBox(height: 12),
                          _buildTextField("Gender", patientDetails['gender']),
                          const SizedBox(height: 12),
                          _buildTextField("DOB", patientDetails['dob']),
                          const SizedBox(height: 12),
                          _buildTextField("Phone", patientDetails['phone']),
                          const SizedBox(height: 12),
                          _buildTextField("Address", patientDetails['address']),
                          const SizedBox(height: 12),
                          _buildTextField("Medical History",
                              patientDetails['medical_history']),
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
    else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Patient Details ",
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

          child: patientDetails.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // صورة المريض بشكل دائري
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(patientDetails['pic'] ?? 'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg'),
                  ),
                ),
                const SizedBox(height: 14),

                // إضافة خط أبيض تحت الصورة
                Container(
                  height: 3,
                  color: Color(0xff414370), // تحديد اللون الأبيض للخط
                ),
                const SizedBox(height: 20),

                // عرض المعلومات في مربعات النص بنفس التنسيق
                _buildTextField("Name", patientDetails['username']),
                const SizedBox(height: 10),
                _buildTextField("Email", patientDetails['email'], isEmail: true),
                const SizedBox(height: 10),
                _buildTextField("Gender", patientDetails['gender']),
                const SizedBox(height: 10),
                _buildTextField("DOB", patientDetails['dob']),
                const SizedBox(height: 10),
                _buildTextField("Phone", patientDetails['phone']),
                const SizedBox(height: 10),
                _buildTextField("Address", patientDetails['address']),
                const SizedBox(height: 10),
                _buildTextField("Medical History", patientDetails['medical_history']),
              ],
            ),
          ),
        ),
      );

    }


  }
}