import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../PatientPage.dart';
import 'ResetPasswordPage.dart';
import 'signUp.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/foundation.dart'; // for kIsWeb

class PatLoginPage extends StatefulWidget {
  @override
  _PatLoginPageState createState() => _PatLoginPageState();
}

class _PatLoginPageState extends State<PatLoginPage> {
  late StreamSubscription _sub;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  late RegExp emailRegExp;
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    emailRegExp = RegExp(emailPattern);
  }



  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      // Dynamically choose the API URL based on platform (Web or Mobile)
      final String apiUrl = kIsWeb
          ? 'http://localhost:5000/api/healup/patients/login' // Use localhost for Web
          : 'http://10.0.2.2:5000/api/healup/patients/login'; // Use 10.0.2.2 for Mobile

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'password': password}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['_id'] != null) {
            await _storage.write(key: 'auth_token', value: responseData['_id']);
            await _storage.write(key: 'patient_name', value: responseData['name']);
            await _storage.write(key: 'patient_id', value: responseData['_id']);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PatientPage()),
            );
          } else {
            _showErrorDialog('Invalid credentials. Please try again.');
          }
        } else {
          final responseData = json.decode(response.body);
          _showErrorDialog(responseData['message'] ?? 'An error occurred');
        }
      } catch (e) {
        _showErrorDialog('An error occurred. Please try again later.');
      }
    }
  }


  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    )
      ..show();
  }

  void _showSuccessDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {},
    )
      ..show();
  }

  void _forgotPassword(String email) {
    if (email.isNotEmpty && emailRegExp.hasMatch(email)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Reset Password'),
            content: Text('Would you like to reset the password for $email?'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  _sendResetPasswordRequest(email);
                  Navigator.of(context).pop();
                },
                child: Text('Send Reset Link'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } else {
      _showErrorDialog('Please enter a valid email address.');
    }
  }


  Future<void> _sendResetPasswordRequest(String email) async {
    try {
      // Dynamically choose the API URL based on platform (Web or Mobile)
      final String apiUrl = kIsWeb
          ? 'http://localhost:5000/api/healup/patients/forgotPassword' // Use localhost for Web
          : 'http://10.0.2.2:5000/api/healup/patients/forgotPassword'; // Use 10.0.2.2 for Mobile

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('Password reset link has been sent to your email.');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Reset Password',
          desc: 'Password reset link has been sent to your email.',
          btnOkOnPress: () {
            final token = json.decode(response.body)['token'];
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(token: token),)
            );


          },
        ).show();

      } else {
        final responseData = json.decode(response.body);
        _showErrorDialog(responseData['message'] ?? 'An error occurred.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again later.');
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image container

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Web layout (larger screen)
                  return _WebLayout();
                } else {
                  // Mobile layout (smaller screen)
                  return _MobileLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _MobileLayout() {
    return SafeArea(
      child: Stack(
        children: [
          // Background image, set to cover the whole screen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff6bc9ee), Color(0xfff3efd9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Semi-transparent overlay to improve readability of the text and form
          Container(
            color: Colors.white.withOpacity(0.00006), // Semi-transparent overlay
          ),
          // The rest of the content goes on top of the background
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // Center the login form vertically
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                        Icons.arrow_back, color: Color(0xff414370), size: 30),
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed("welcomePage"),
                  ),
                ),
                const SizedBox(height: 40), // Add space above the form
                const Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('images/img_7.png'),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>  LinearGradient(
                            colors: [
                              Color(0xffb25dcc), // Soft teal (primary color)
                              Color(0xfff08486), // Soft blue (secondary color)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            tileMode: TileMode.clamp,
                          ).createShader(bounds),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 55,
                              fontFamily: 'Hello Valentina',
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Use white for better contrast with the gradient
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),
                        // Email TextField
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else if (!emailRegExp.hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password TextField
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Forgot Password Button (Aligned to the left)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              String email = _emailController.text.trim();
                              _forgotPassword(email);
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Login Button (Centered)
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff414370),
                            padding: const EdgeInsets.symmetric(horizontal: 40,
                                vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Create Account Button (Centered under the login button)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PatSignUpPage()), // Navigate to the sign-up page
                            );
                          },
                          child: const Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _WebLayout() {
    return Scaffold(
      body: Container(
        color: Colors.white.withOpacity(0.1), // Background with slight opacity
        child: SafeArea(
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
              // Foreground content with frame
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // Center content vertically
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xff414370),
                          size: 30,
                        ),
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed("welcomePage"),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0,0.0,30,0.30),
                      child: Container(
                        width: 420,
                        height: 650,// Adjust the width for web layout
                        child: Form(
                          key: _formKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xff414370).withOpacity(0.2), // Semi-transparent background
                              borderRadius: BorderRadius.circular(20), // Rounded corners
                              border: Border.all(
                                color: const Color(0xff414370), // Frame border color
                                width: 2, // Border width
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10, // Shadow blur radius
                                  offset: const Offset(0, 5), // Shadow offset
                                ),
                              ],
                            ),

                            padding: const EdgeInsets.all(20), // Padding inside the frame
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 40),
                                const Center(
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundImage: AssetImage('images/img_7.png'),
                                  ),
                                ),
                                const SizedBox(height: 25),

                                ShaderMask(
                                  shaderCallback: (bounds) =>  LinearGradient(
                                    colors: [
                                      Color(0xffb25dcc), // Soft teal (primary color)
                                      Color(0xfff08486), // Soft blue (secondary color)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    tileMode: TileMode.clamp,
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 55,
                                      fontFamily: 'Hello Valentina',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Use white for better contrast with the gradient
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 70),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(
                                        color: Colors.grey[700]),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    } else if (!emailRegExp.hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                        color: Colors.grey[700]),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      String email = _emailController.text.trim();
                                      _forgotPassword(email);
                                    },
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:  Color(0xff414370),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // Create Account Button (Centered under the login button)
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => PatSignUpPage()), // Navigate to the sign-up page
                                    );
                                  },
                                  child: const Text(
                                    "Don't have an account? Sign up",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}