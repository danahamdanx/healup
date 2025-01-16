import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DoctorDetailsPage extends StatefulWidget {
  final String doctorId;

  DoctorDetailsPage({required this.doctorId});

  @override
  _DoctorDetailsPageState createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  Map<String, dynamic> doctorDetails = {};

  Future<void> fetchDoctorDetails() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/healup/doctors/doctor/${widget.doctorId}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          doctorDetails = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch doctor details")),
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
    fetchDoctorDetails();
  }

  Widget _buildTextField(String label, dynamic value, {bool isEmail = false}) {
    // تحويل القيم التي من نوع int أو double إلى String
    String displayValue = value is double
        ? value.toStringAsFixed(2)  // تحويل double إلى String مع منزلتين عشريتين
        : value is int ? value.toString() : value ?? "N/A";  // تحويل int إلى String

    return TextFormField(
      initialValue: displayValue,
      readOnly: true, // Ensure the field is read-only for doctor details
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
          "Doctor Details",
          style: TextStyle(
            fontSize: 24,  // زيادة حجم الخط
            //fontWeight: FontWeight.bold,  // جعل الخط عريض
          ),
        ),
        backgroundColor: const Color(0xff2f9a8f),
      ),
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
        child: doctorDetails.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // صورة الطبيب بشكل دائري
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                    doctorDetails['photo'] ?? 'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg',
                  ),
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
              _buildTextField("Name", doctorDetails['name']),
              const SizedBox(height: 10),
              _buildTextField("Username", doctorDetails['username']),
              const SizedBox(height: 10),
              _buildTextField("Email", doctorDetails['email'], isEmail: true),
              const SizedBox(height: 10),
              _buildTextField("Specialization", doctorDetails['specialization']),
              const SizedBox(height: 10),
              _buildTextField("Phone", doctorDetails['phone']),
              const SizedBox(height: 10),
              _buildTextField("Address", doctorDetails['address']),
              const SizedBox(height: 10),
              _buildTextField("Hospital", doctorDetails['hospital']),
              const SizedBox(height: 10),
              _buildTextField("Experience", doctorDetails['yearExperience']),
              const SizedBox(height: 10),
              _buildTextField("Price Per Hour", doctorDetails['pricePerHour']),
              const SizedBox(height: 10),
              _buildTextField("Rating", doctorDetails['rating']),
              const SizedBox(height: 10),
              _buildTextField("Availability", doctorDetails['availability']),
              const SizedBox(height: 10),
              _buildTextField("Reviews", doctorDetails['reviews']),
              const SizedBox(height: 10),
              _buildTextField("Seal", doctorDetails['seal']),
            ],
          ),
        ),
      ),
    );
  }
}
