import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:first/patient/profile/ThemeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb


class DoctorProfilePage extends StatefulWidget {
  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage>
    with SingleTickerProviderStateMixin {
  final _storage = FlutterSecureStorage();
  int _currentRating = 0; // This will hold the current star rating

  Map<String, dynamic>? doctorData;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _specializationController =
  TextEditingController();
  final TextEditingController _availabilityController = TextEditingController(); // Add this
  final TextEditingController _durationController = TextEditingController(); // Add this
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _yearExperienceController =
  TextEditingController();
  Color? sectionBorderColor = Color(0xff414370);
  Color _borderColor = Color(0xff414370);

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      String? doctorId = await _storage.read(key: 'doctor_id');
      if (doctorId == null) {
        throw Exception("Doctor ID not found in storage.");
      }

      final response = await http.get(
        Uri.parse(
            kIsWeb ? 'http://localhost:5000/api/healup/doctors/doctor/$doctorId'
                : 'http://10.0.2.2:5000/api/healup/doctors/doctor/$doctorId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          doctorData = json.decode(response.body);
          isLoading = false;
        });

        _populateFields(); // Populate fields, including duration
      } else {
        throw Exception("Failed to load doctor details.");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("An error occurred while loading doctor details.");
    }
  }

  Future<void> _updateDoctorProfile() async {
    if(kIsWeb){
      if (_formKey.currentState!.validate()) {
        try {
          String? doctorId = await _storage.read(key: 'doctor_id');
          final response = await http.put(
            Uri.parse('http://localhost:5000/api/healup/doctors/$doctorId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': _nameController.text,
              'username': _usernameController.text,
              'specialization': _specializationController.text,
              'phone': _phoneController.text,
              'email': _emailController.text,
              'address': _addressController.text,
              'hospital': _hospitalController.text,
              'pricePerHour': _priceController.text,
              'yearExperience': _yearExperienceController.text,
            }),
          );

          if (response.statusCode == 200) {
            final updatedDoctor = json.decode(response.body);
            setState(() {
              doctorData = updatedDoctor; // Update the doctor data
            });
            _showSuccessDialog("Profile updated successfully.");
          } else {
            throw Exception("Failed to update doctor details.");
          }
        } catch (error) {
          _showErrorDialog("An error occurred while updating the profile.");
        }
      }

    }
    else{
      if (_formKey.currentState!.validate()) {
        try {
          String? doctorId = await _storage.read(key: 'doctor_id');
          final response = await http.put(
            Uri.parse('http://10.0.2.2:5000/api/healup/doctors/$doctorId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': _nameController.text,
              'username': _usernameController.text,
              'specialization': _specializationController.text,
              'phone': _phoneController.text,
              'email': _emailController.text,
              'address': _addressController.text,
              'hospital': _hospitalController.text,
              'pricePerHour': _priceController.text,
               'availability':_availabilityController.text,
              'yearExperience': _yearExperienceController.text,
              'duration':_durationController.text,
            }),
          );

          if (response.statusCode == 200) {
            final updatedDoctor = json.decode(response.body);
            setState(() {
              doctorData = updatedDoctor; // Update the doctor data
            });
            _showSuccessDialog("Profile updated successfully.");
          } else {
            throw Exception("Failed to update doctor details.");
          }
        } catch (error) {
          _showErrorDialog("An error occurred while updating the profile.");
        }
      }

    }

  }

  void _populateFields() {
    if (doctorData != null) {
      _nameController.text = doctorData!['name'] ?? '';
      _usernameController.text = doctorData!['username'] ?? '';
      _specializationController.text = doctorData!['specialization'] ?? '';
      _phoneController.text = doctorData!['phone'] ?? '';
      _emailController.text = doctorData!['email'] ?? '';
      _addressController.text = doctorData!['address'] ?? '';
      _hospitalController.text = doctorData!['hospital'] ?? '';
      _priceController.text = doctorData!['pricePerHour'].toString() ?? '';
      _yearExperienceController.text =
          doctorData!['yearExperience'].toString() ?? '';
      _durationController.text = doctorData!['duration']?.toString() ?? ''; // Populate duration field
      _availabilityController.text=doctorData!['availability'];
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: Text("Success"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }


  // Function to show confirmation dialog for turning off notifications
  void _showTurnOffNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Turn off Notifications"),
          content: const Text(
              "Are you sure you want to turn off notifications?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                setState(() {
                  _notificationsEnabled = false;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }




  Widget _buildSectionDivider({Color color = const Color(0xff414370)}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      height: 2,
      color: color,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      readOnly: isEmail, // Set the email field as read-only
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Color(0xff414370), // Label text color
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto, // Label floats above the input field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
          borderSide: BorderSide(
            color: Color(0xff414370), // Border color
            width: 2, // Border thickness
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Color(0xff414370), // Border color when enabled
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Color(0xff414370), // Border color when focused
            width: 2,
          ),
        ),
        fillColor: Color(0xffd4dcee), // Fill color of the text field
        filled: true, // Enable fill color
      ),
      style: TextStyle(
        color: Color(0xff414370), // Text color
        fontWeight: FontWeight.bold,
        fontSize: 18, // Font size for input text
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if(kIsWeb){
      final themeNotifier = Provider.of<ThemeNotifier>(context);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,  // لإزالة سهم التراجع

          title: Text(
            "Doctor Profile",
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff414370),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white70),
              onPressed: () => _showSettingsMenu(context, themeNotifier),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xfff3efd9), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: doctorData!['photo'] != null
                              ? doctorData!['photo'].startsWith('http')
                              ? NetworkImage(
                              doctorData!['photo']) // Load from network
                              : AssetImage(
                              doctorData!['photo']) as ImageProvider // Load from assets
                              : AssetImage('assets/doctor.jpg') // Default image
                          as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildSectionDivider(),
                      SizedBox(height: 20),
                      ..._buildFields(),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _updateDoctorProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff414370),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Update Profile',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

    }
    else{
      final themeNotifier = Provider.of<ThemeNotifier>(context);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,  // لإزالة سهم التراجع

          title: Text(
            "Doctor Profile",
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xff414370),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white70),
              onPressed: () => _showSettingsMenu(context, themeNotifier),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xfff3efd9), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: doctorData!['photo'] != null
                              ? doctorData!['photo'].startsWith('http')
                              ? NetworkImage(
                              doctorData!['photo']) // Load from network
                              : AssetImage(
                              doctorData!['photo']) as ImageProvider // Load from assets
                              : AssetImage('assets/doctor.jpg') // Default image

                          as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildSectionDivider(),
                      SizedBox(height: 20),
                      ..._buildFields(),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _updateDoctorProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff414370),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Update Profile',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

    }

  }

  List<Widget> _buildFields() {
    return [
      _buildTextField("Name", _nameController),
      SizedBox(height: 20),
      _buildTextField("Username", _usernameController),
      SizedBox(height: 20),
      _buildTextField("Specialization", _specializationController),
      SizedBox(height: 20),
      _buildTextField("Phone", _phoneController),
      SizedBox(height: 20),
      _buildTextField("Email", _emailController, isEmail: true),
      // Make email read-only
      SizedBox(height: 20),
      _buildTextField("Address", _addressController),
      SizedBox(height: 20),
      _buildTextField("Hospital", _hospitalController),
      SizedBox(height: 20),
      _buildTextField("Price per hour", _priceController),
      SizedBox(height: 20),
      _buildTextField("Years of Experience", _yearExperienceController),
      SizedBox(height: 20),
      _buildTextField("Availability", _availabilityController),
      SizedBox(height: 20),
      _buildTextField("Duration", _durationController),
      SizedBox(height: 20),
    ];
  }


  void _showSettingsMenu(BuildContext context, ThemeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Settings"),
          content: Container(
            width: 300, // Set the desired width for the dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    themeNotifier.isDarkMode
                        ? Icons.nightlight_round
                        : Icons.wb_sunny,
                    color: themeNotifier.isDarkMode ? Colors.white : Colors
                        .black,
                  ),
                  title: const Text("Dark Mode"),
                  trailing: Switch(
                    value: themeNotifier.isDarkMode,
                    onChanged: (value) {
                      themeNotifier.toggleTheme();
                    },
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("About"),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Health App",
                      applicationVersion: "1.0.0",
                      applicationLegalese: "© 2024 Health Co.",
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text("Rate the App"),
                  onTap: () {
                    _showRatingDialog();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Privacy Policy"),
                  onTap: () {
                    _showPrivacyPolicyDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text("Log Out"),
                  onTap: () async {
                    // Clear the secure storage
                    await _storage.deleteAll();
                    // Navigate back to login screen
                    Navigator.of(context).pushReplacementNamed('Doctor_login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Rate the App"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please rate our app:"),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _currentRating = index + 1; // Update the rating
                      });
                    },
                    icon: Icon(
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: Colors.amber, // Color of the star
                      size: 40, // Star size
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("You rated this app $_currentRating stars."),
                  ),
                );
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }



  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Privacy Policy"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Privacy Policy",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  "We take your privacy seriously. Below are some details on how we handle your data:\n\n"
                      "1. **Data Collection**: We collect information to provide a better user experience. "
                      "This may include your profile details, app usage data, and feedback.\n\n"
                      "2. **Data Usage**: The data collected is used for analytics, improving app performance, "
                      "and offering personalized services.\n\n"
                      "3. **Third-Party Sharing**: We do not share your data with third parties except as required "
                      "to provide services (e.g., payment processors) or comply with legal obligations.\n\n"
                      "4. **Security**: We use industry-standard practices to protect your data. However, no method "
                      "of transmission over the internet is 100% secure.\n\n"
                      "For more information, please contact us at privacy@healthco.com.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

}
