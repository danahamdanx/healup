import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PatientDetailsPage extends StatefulWidget {
  final String patientId;

  PatientDetailsPage({required this.patientId});

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  Map<String, dynamic> patientDetails = {};

  Future<void> fetchPatientDetails() async {
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
            color: Color(0xff2f9a8f),
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Color(0xff2f9a8f),
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xff2f9a8f), width: 3),
        ),
        fillColor: Colors.white.withOpacity(0.8),
        filled: true,
      ),
      style: TextStyle(
        color: Color(0xff2f9a8f),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,  // لإزالة سهم التراجع
        title: const Text(
          "Patient Details",
          style: TextStyle(
            fontSize: 24,  // زيادة حجم الخط
            //fontWeight: FontWeight.bold,  // جعل الخط عريض
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      // appBar: AppBar(
      //   title: Text("Patient Details"),
      //   backgroundColor: Color(0xff2f9a8f),
      // ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/pat.jpg'),

            //image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
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
                color: Colors.white, // تحديد اللون الأبيض للخط
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