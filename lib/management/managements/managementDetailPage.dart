import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb


class ManagementDetailsPage extends StatefulWidget {
  final String managementId;

  ManagementDetailsPage({required this.managementId});

  @override
  _ManagementDetailsPageState createState() => _ManagementDetailsPageState();
}

class _ManagementDetailsPageState extends State<ManagementDetailsPage> {
  Map<String, dynamic> managementDetails = {};

  Future<void> fetchManagementDetails() async {
    if(kIsWeb){
      try {
        final response = await http.get(
          Uri.parse("http://localhost:5000/api/healup/management/${widget.managementId}"),
        );
        if (response.statusCode == 200) {
          setState(() {
            managementDetails = jsonDecode(response.body);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch management details")),
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
          Uri.parse("http://10.0.2.2:5000/api/healup/management/${widget.managementId}"),
        );
        if (response.statusCode == 200) {
          setState(() {
            managementDetails = jsonDecode(response.body);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch management details")),
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
    fetchManagementDetails();
  }

  Widget _buildTextField(String label, dynamic value) {
    // Convert int or double values to String
    String displayValue = value is double
        ? value.toStringAsFixed(2)  // Convert double to String with two decimal points
        : value is int ? value.toString() : value ?? "N/A";  // Convert int to String

    return TextFormField(
      initialValue: displayValue,
      readOnly: true, // Ensure the field is read-only for management details
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
        color:Color(0xff414370),
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
            "Management Details ",
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
                child: managementDetails.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
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
                          // صورة الإدارة أو الأيقونة
                          IconButton(
                            icon: const Icon(
                              Icons.admin_panel_settings,
                              color: Color(0xff414370),
                              size: 80,
                            ),
                            onPressed: () {
                              // _showDeleteDialog(order['id'], order['patient']);
                            },
                          ),
                          const SizedBox(height: 14),

                          // فاصل أبيض
                          Container(
                            height: 3,
                            color: Color(0xff414370),
                          ),
                          const SizedBox(height: 20),

                          // عرض تفاصيل الإدارة في حقول النص
                          _buildTextField("Name", managementDetails['name']),
                          const SizedBox(height: 10),
                          _buildTextField("Gender", managementDetails['gender']),
                          const SizedBox(height: 10),
                          _buildTextField("Phone", managementDetails['phone']),
                          const SizedBox(height: 10),
                          _buildTextField("Email", managementDetails['email']),
                          const SizedBox(height: 10),
                          _buildTextField("Address", managementDetails['address']),
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
            "Management Details ",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
            //  fontWeight: FontWeight.bold,
              backgroundColor: Color(0xff414370),
            ),
          ),
          backgroundColor: const Color(0xff414370),
          iconTheme: const IconThemeData(
            color: Colors.white70,  // تغيير لون سهم التراجع
          ),
        ),

        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff3efd9), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: managementDetails.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Display a placeholder image or profile image
                Center(
                  child:
                  IconButton(
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xff414370),
                      size: 80,  // يمكنك تغيير هذا الرقم حسب الحجم المطلوب
                    ),
                    onPressed: () {
                      // _showDeleteDialog(order['id'], order['patient']);
                    },
                  ),

                ),
                const SizedBox(height: 14),

                //White line separator
                Container(
                  height: 3,
                  color: Color(0xff414370),
                ),
                const SizedBox(height: 20),

                // Display management details in text fields
                // _buildTextField("ID", managementDetails['id']),
                // const SizedBox(height: 10),
                _buildTextField("Name", managementDetails['name']),
                const SizedBox(height: 10),
                _buildTextField("Gender", managementDetails['gender']),
                const SizedBox(height: 10),
                _buildTextField("Phone", managementDetails['phone']),
                const SizedBox(height: 10),
                _buildTextField("Email", managementDetails['email']),
                const SizedBox(height: 10),
                _buildTextField("Address", managementDetails['address']),
              ],
            ),
          ),
        ),
      );
    }
  }

}

