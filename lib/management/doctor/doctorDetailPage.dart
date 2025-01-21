import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../managements/managementList.dart';
import '../medication/medicationList.dart';
import '../order/orderList.dart';
import 'doctorList.dart'; // For kIsWeb

class DoctorDetailsPage extends StatefulWidget {
  final String doctorId;

  DoctorDetailsPage({required this.doctorId});

  @override
  _DoctorDetailsPageState createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  Map<String, dynamic> doctorDetails = {};
  int _currentIndex = 0; // العنصر الحالي في القائمة الجانبية

  Future<void> fetchDoctorDetails() async {
    if(kIsWeb){
      try {
        final response = await http.get(
          Uri.parse("http://localhost:5000/api/healup/doctors/doctor/${widget.doctorId}"),
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
    else{
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
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Doctor Details ",
            style: TextStyle(fontSize: 28),
          ),
          backgroundColor: const Color(0xff2f9a8f),
        ),
        body: Row(
          children: [
            // // القائمة الجانبية
            // NavigationRail(
            //   selectedIndex: _currentIndex,
            //   onDestinationSelected: (int index) {
            //     setState(() {
            //       _currentIndex = index;
            //     });
            //     onTabTapped(index); // استدعاء الدالة للتنقل بين الصفحات
            //   },
            //   extended: true,
            //   backgroundColor: const Color(0xff2f9a8f),
            //   selectedIconTheme: const IconThemeData(color: Colors.white),
            //   unselectedIconTheme: const IconThemeData(color: Colors.black54),
            //   selectedLabelTextStyle: const TextStyle(color: Colors.white),
            //   unselectedLabelTextStyle: const TextStyle(color: Colors.black54),
            //   destinations: const [
            //     NavigationRailDestination(
            //       icon: Icon(Icons.person),
            //       label: Text("Patient List"),
            //     ),
            //     NavigationRailDestination(
            //       icon: Icon(Icons.medical_services),
            //       label: Text("Doctor List"),
            //     ),
            //     NavigationRailDestination(
            //       icon: Icon(Icons.local_pharmacy),
            //       label: Text("Medication List"),
            //     ),
            //     NavigationRailDestination(
            //       icon: Icon(Icons.shopping_cart),
            //       label: Text("Order List"),
            //     ),
            //     NavigationRailDestination(
            //       icon: Icon(Icons.admin_panel_settings),
            //       label: Text("Management List"),
            //     ),
            //   ],
            // ),
            // const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/pat.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: doctorDetails.isEmpty
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
                          // صورة الطبيب بشكل دائري
                          CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage(
                              doctorDetails['photo'] ??
                                  'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(height: 2, color: Colors.grey),
                          const SizedBox(height: 20),
                          _buildTextField("Name", doctorDetails['name']),
                          const SizedBox(height: 12),
                          _buildTextField("Username", doctorDetails['username']),
                          const SizedBox(height: 12),
                          _buildTextField("Email", doctorDetails['email'], isEmail: true),
                          const SizedBox(height: 12),
                          _buildTextField("Specialization", doctorDetails['specialization']),
                          const SizedBox(height: 12),
                          _buildTextField("Phone", doctorDetails['phone']),
                          const SizedBox(height: 12),
                          _buildTextField("Address", doctorDetails['address']),
                          const SizedBox(height: 12),
                          _buildTextField("Hospital", doctorDetails['hospital']),
                          const SizedBox(height: 12),
                          _buildTextField("Experience", doctorDetails['yearExperience']),
                          const SizedBox(height: 12),
                          _buildTextField("Price Per Hour", doctorDetails['pricePerHour']),
                          const SizedBox(height: 12),
                          _buildTextField("Rating", doctorDetails['rating']),
                          const SizedBox(height: 12),
                          _buildTextField("Availability", doctorDetails['availability']),
                          const SizedBox(height: 12),
                          _buildTextField("Duration", doctorDetails['duration']),
                          const SizedBox(height: 12),
                          _buildTextField("Reviews", doctorDetails['reviews']),
                          const SizedBox(height: 12),
                          _buildTextField("Seal", doctorDetails['seal']),
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
                _buildTextField("Duration", doctorDetails['duration']),
                const SizedBox(height: 12),
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
}
