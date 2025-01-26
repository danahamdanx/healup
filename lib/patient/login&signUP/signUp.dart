import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb

import 'VerifyAccountScreen.dart';

class PatSignUpPage extends StatefulWidget {
  const PatSignUpPage({Key? key}) : super(key: key);

  @override
  _PatSignUpPageState createState() => _PatSignUpPageState();
}

class _PatSignUpPageState extends State<PatSignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> cities = [
    'Ramallah', 'Gaza', 'Hebron', 'Nablus', 'Jenin', 'Bethlehem', 'Jericho',
    'Tulkarm', 'Qalqilya', 'Rafah', 'Khan Younis', 'Beit Lahia', 'Beit Hanoun',
    'Deir al-Balah', 'Salfit', 'Tubas', 'Bani Na\'im', 'Yatta'
  ];

  final List<String> diseases = [
    'None', 'Diabetes', 'Hypertension', 'Heart Disease', 'Asthma',
    'Chronic Kidney Disease', 'Cancer', 'Liver Disease', 'Others'
  ];

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String selectedCity = 'Ramallah';
  String selectedGender = 'Male';
  String selectedDisease = 'None';
  DateTime? selectedDate;
  bool isLoading = false;

  final RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');

  Future<void> signUp() async {
    setState(() => isLoading = true);

    final signUpData = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'DOB': selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '',
      'gender': selectedGender,
      'phone': '+970${_phoneController.text}',
      'address': selectedCity,
      'medical_history': selectedDisease,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/healup/patients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signUpData),
      );

      if (response.statusCode == 201) {
        // Inform the user to check their email
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Verify Email',
          desc: 'A verification email has been sent. Please verify your email before logging in.',
          btnOkOnPress: () {
            final token = json.decode(response.body)['token'];
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => VerifyEmailPage(token: token)),
            );


          },
        ).show();
      } else {
        final errorData = json.decode(response.body);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Sign Up Failed',
          desc: errorData['message'] ?? 'An error occurred. Please try again.',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'Could not connect to the server. Check your internet connection.',
        btnOkOnPress: () {},
      ).show();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
          child: Stack(
            children: [
              // Background image
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff6bc9ee), Color(0xfff3efd9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Center(
                      child: Container(
                        width: 450,
                        // Web layout width constraint
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color(0xff2f9a8f).withOpacity(0.2), // Semi-transparent background
                          borderRadius: BorderRadius.circular(25), // Rounded corners for the frame
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5), // Light border color
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xff414370), size: 30),
                              onPressed: () => Navigator.pop(context),
                            ),
                            // Title
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: const Text(
                                  'Create a New Account',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xff414370),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Form fields
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                } else if (!emailRegExp.hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            IntlPhoneField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              initialCountryCode: 'PS',
                            ),
                            GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                height: 50.0,
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  selectedDate != null
                                      ? DateFormat('yyyy/MM/dd').format(selectedDate!)
                                      : 'Select Date of Birth',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: selectedDate != null
                                        ? Colors.black87
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: selectedGender,
                              onChanged: (value) {
                                setState(() => selectedGender = value!);
                              },
                              items: ['Male', 'Female']
                                  .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: selectedCity,
                              onChanged: (value) {
                                setState(() => selectedCity = value!);
                              },
                              items: cities
                                  .map((city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ))
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: 'City',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: selectedDisease,
                              onChanged: (value) {
                                setState(() => selectedDisease = value!);
                              },
                              items: diseases
                                  .map((disease) => DropdownMenuItem(
                                value: disease,
                                child: Text(disease),
                              ))
                                  .toList(),
                              decoration: InputDecoration(
                                labelText: 'Chronic Disease (if any)',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),  // Added fillColor for all fields
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Sign Up Button
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:  Color(0xff414370),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (selectedDate == null) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        title: 'Date of Birth Missing',
                                        desc: 'Please select your date of birth.',
                                        btnOkOnPress: () {},
                                      ).show();
                                    } else if (_phoneController.text.isEmpty) {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.warning,
                                        title: 'Phone Number Missing',
                                        desc: 'Please enter your phone number.',
                                        btnOkOnPress: () {},
                                      ).show();
                                    } else {
                                      signUp();
                                    }
                                  }
                                },
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }


  else {
      // If the platform is mobile, return the mobile layout
      return Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff6bc9ee), Color(0xfff3efd9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon:  Icon(Icons.arrow_back, color: Color(0xff414370), size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Create a New Account',
                              style: TextStyle(
                                  fontSize: 30, color: Color(0xff414370),fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            } else if (!emailRegExp.hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        IntlPhoneField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialCountryCode: 'PS',
                        ),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            height: 50.0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedDate != null
                                  ? DateFormat('yyyy/MM/dd').format(
                                  selectedDate!)
                                  : 'Select Date of Birth',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: selectedDate != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          onChanged: (value) {
                            setState(() => selectedGender = value!);
                          },
                          items: ['Male', 'Female']
                              .map((gender) =>
                              DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: selectedCity,
                          onChanged: (value) {
                            setState(() => selectedCity = value!);
                          },
                          items: cities
                              .map((city) =>
                              DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'City',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: selectedDisease,
                          onChanged: (value) {
                            setState(() => selectedDisease = value!);
                          },
                          items: diseases
                              .map((disease) =>
                              DropdownMenuItem(
                                value: disease,
                                child: Text(disease),
                              ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'Chronic Disease (if any)',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
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
                            onPressed: isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                if (selectedDate == null) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    title: 'Date of Birth Missing',
                                    desc: 'Please select your date of birth.',
                                    btnOkOnPress: () {},
                                  ).show();
                                } else if (_phoneController.text.isEmpty) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    title: 'Phone Number Missing',
                                    desc: 'Please enter your phone number.',
                                    btnOkOnPress: () {},
                                  ).show();
                                } else {
                                  signUp();
                                }
                              }
                            },
                            child: isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text('Sign Up', style: TextStyle(
                                fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
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

    Widget _buildTextFormField(
      TextEditingController controller,
      String labelText,
      TextInputType keyboardType,
      RegExp? validatorPattern,
      String requiredErrorMessage,
      String? additionalErrorMessage, {
        bool obscureText = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return requiredErrorMessage;
          } else if (validatorPattern != null && !validatorPattern.hasMatch(value)) {
            return additionalErrorMessage ?? 'Invalid input';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return IntlPhoneField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      initialCountryCode: 'PS',
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 10),
            Text(selectedDate == null
                ? 'Select Date of Birth'
                : DateFormat('yyyy-MM-dd').format(selectedDate!)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String selectedValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }
}
