import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data'; // For MemoryImage (web)
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // For encoding image to base64
import 'ThemeNotifier.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker


class PatProfile extends StatefulWidget {
  final String patientId; // Pass the patient ID to this widget

  const PatProfile({super.key, required this.patientId});

  @override
  _PatProfileState createState() => _PatProfileState();
}

class _PatProfileState extends State<PatProfile> {
  int _currentRating = 0; // This will hold the current star rating

  final _storage = FlutterSecureStorage();
  File? _profileImage; // Store the selected profile image
  ImageProvider? _profileImageProvider; // Store the selected image as ImageProvider (for web)
  Map<String, dynamic>? _patientData; // Store patient data
  bool _isLoading = true; // Track loading state
  bool _isUpdating = false; // Track if data is being updated

  // Controllers for editable fields
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _medicalHistoryController;

  bool _notificationsEnabled = true; // Track notification status

  @override
  void initState() {
    super.initState();
    _fetchPatientData(widget.patientId); // Fetch patient data on widget load
  }

  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

// Function to show confirmation dialog for turning off dark mode or any setting change
  void _showConfirmationDialog(BuildContext context, String message,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
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
                onConfirm(); // Execute the action when confirmed
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to fetch patient data from the backend
  Future<void> _fetchPatientData(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${getBaseUrl()}/api/healup/patients/getPatientById/$patientId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _patientData = data;
          _usernameController = TextEditingController(text: data['username']);
          _emailController = TextEditingController(text: data['email']);
          _addressController = TextEditingController(text: data['address']);
          _dobController = TextEditingController(text: data['dob']);
          _phoneController = TextEditingController(text: data['phone']);
          _medicalHistoryController =
              TextEditingController(text: data['medical_history']);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load patient data');
      }
    } catch (e) {
      print('Error fetching patient data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Function to pick an image from the gallery (for web and mobile)
  Future<void> _pickImage() async {
    FilePickerResult? result;

    // Use file picker to select an image (works for both web and mobile)
    result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      PlatformFile file = result.files.single;

      setState(() {
        // Set the selected image depending on the platform
        if (kIsWeb) {
          _profileImageProvider = MemoryImage(Uint8List.fromList(file.bytes!));
          _profileImage = null;
        } else {
          // Convert PlatformFile to File
          _profileImage = File(file.path!);
          _profileImageProvider = null;
        }
      });
      // Check if the image file is too large (5 MB limit)
      if (_profileImage!.lengthSync() > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              'Image is too large. Please select a smaller image.')),
        );
        return; // Return early to prevent further processing
      }
      // After selecting the image, call the update method
      await _updatePatientData(_profileImage); // Pass the File object
    } else {
      print('No image selected.');
    }
  }

// Function to update patient data
  Future<void> _updatePatientData(File? imageFile) async {
    setState(() {
      _isUpdating = true; // Show loading spinner
    });

    try {
      final uri = Uri.parse(
          '${getBaseUrl()}/api/healup/patients/updatePatient/${widget
              .patientId}');
      final headers = {
        'Content-Type': 'application/json',
      };

      String? base64Image;
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        base64Image = 'data:image/png;base64,' + base64Encode(bytes);
      }

      final body = jsonEncode({
        'username': _usernameController.text,
        'address': _addressController.text,
        'DOB': _dobController.text,
        'phone': _phoneController.text,
        'medical_history': _medicalHistoryController.text,
        'pic': "images/manar.jpg", // Ensure base64 string is valid
      });


      final response = await http.put(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body);
        setState(() {
          _patientData = updatedData['data']; // Update local data
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        // Log the response body for debugging
        print('Response body: ${response.body}');
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print('Error updating patient data: $e'); // Log error details
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
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

  // Function to show settings menu with notification toggle
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
                    color: themeNotifier.isDarkMode ? Colors.white : Color(0xff414370),
                  ),
                  title: const Text("Dark Mode",style: TextStyle(color: Color(0xff414370)),),
                  trailing: Switch(
                    value: themeNotifier.isDarkMode,
                    onChanged: (value) {
                      // Show confirmation dialog if turning off dark mode
                      if (themeNotifier.isDarkMode && !value) {
                        _showConfirmationDialog(
                            context, 'Turn off Dark Mode?', () {
                          themeNotifier.toggleTheme();
                          Navigator.of(context).pop(); // Close the dialog
                        });
                      } else {
                        themeNotifier.toggleTheme();
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info,color: Color(0xff414370)),
                  title: const Text("About",style: TextStyle(color: Color(0xff414370)),),
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
                  leading: const Icon(Icons.star,color: Color(0xff414370)),
                  title: const Text("Rate the App",style: TextStyle(color: Color(0xff414370)),),
                  onTap: () {
                    _showRatingDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock,color: Color(0xff414370)),
                  title: const Text("Privacy Policy",style: TextStyle(color: Color(0xff414370)),),
                  onTap: () {
                    _showPrivacyPolicyDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app,color: Color(0xff414370)),
                  title: const Text("Log Out",style: TextStyle(color: Color(0xff414370)),),
                  onTap: () async {
                    // Clear the secure storage
                    await _storage.deleteAll();
                    // Navigate back to login screen
                    Navigator.of(context).pushReplacementNamed('login');
                  },
                ),
              ],
            ),
          ),
          // Adjust the width of the AlertDialog
          contentPadding: EdgeInsets.all(16.0),
          // Optional: Add padding to the content
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if(kIsWeb){ return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Profile"),
        backgroundColor: const Color(0xff414370),
        actions: [
          Stack(
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
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  _showSettingsMenu(context, themeNotifier);
                },
              ),
              if (_notificationsEnabled)
                Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: const Text(
                      '!',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patientData == null
          ? const Center(child: Text("Failed to load patient data"))
          : Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _profileImage != null
                        ? _profileImageProvider!
                        : AssetImage(_patientData!['pic'])
                    as ImageProvider,
                    child: _profileImage == null
                        ? Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white.withOpacity(0.8),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Editable Fields
                _buildInputField("Username", _usernameController),
                const SizedBox(height: 15),
                _buildInputField("Email", _emailController,
                    readOnly: true),
                const SizedBox(height: 15),
                _buildInputField("Address", _addressController),
                const SizedBox(height: 15),
                _buildInputField("Date of Birth", _dobController),
                const SizedBox(height: 15),
                _buildInputField("Phone", _phoneController),
                const SizedBox(height: 15),
                _buildInputField(
                    "Medical History", _medicalHistoryController),
                const SizedBox(height: 30),

                // Save Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff414370),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isUpdating
                      ? null
                      : () {
                    _updatePatientData(_profileImage);
                  },
                  child: _isUpdating
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                        fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    }else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Patient Profile",style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xff414370),

          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings,color: Colors.white70,size: 30,),
                  onPressed: () {
                    _showSettingsMenu(context, themeNotifier);
                  },
                ),
                if (_notificationsEnabled)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: const Text(
                        '!',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _patientData == null
            ? const Center(child: Text("Failed to load patient data"))
            : Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xfff3efd9), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Profile Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _profileImage != null
                              ? (kIsWeb
                              ? _profileImageProvider!
                              : FileImage(_profileImage!))
                              : AssetImage(
                              _patientData!['pic']) as ImageProvider,
                          child: _profileImage == null
                              ? Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Colors.white.withOpacity(0.8),
                          )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Editable Fields
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      readOnly: true, // Email is not editable
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: "Address"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                          labelText: "Date of Birth"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: "Phone"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _medicalHistoryController,
                      decoration: const InputDecoration(
                          labelText: "Medical History"),
                    ),
                    const SizedBox(height: 20),
                    // Save Button
                    // Update the save button callback
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  Color(0xff414370),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _isUpdating
                            ? null
                            : () {
                          _updatePatientData(
                              _profileImage); // Pass the _profileImage to the update method
                        },
                        child: _isUpdating
                            ?  CircularProgressIndicator(
                            color: Colors.deepPurple[400])
                            : const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Reusable Input Field Widget
  Widget _buildInputField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Rate the App",style: TextStyle(color: Color(0xff414370)),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please rate our app:",style: TextStyle(color: Color(0xff414370)),),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _currentRating = index + 1; // Update rating immediately
                      });
                    },
                    icon: Icon(
                      index < _currentRating ? Icons.star : Icons.star_border, // Show filled stars based on _currentRating
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog after submission
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("You rated this app $_currentRating stars."), // Show the rating in the snackbar
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





}

void _showPrivacyPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Privacy Policy",style: TextStyle(color: Color(0xff414370)),),
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