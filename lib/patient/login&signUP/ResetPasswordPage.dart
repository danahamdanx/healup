import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class ResetPasswordPage extends StatefulWidget {
  final String token;

  ResetPasswordPage({required this.token});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      String newPassword = _newPasswordController.text;

      try {
        final response = await http.patch(
          Uri.parse('${getBaseUrl()}/api/healup/patients/resetPassword/${widget.token}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'password': newPassword}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          _showSuccessDialog(responseData['message'] ?? 'Password reset successful.');
        } else {
          final responseData = json.decode(response.body);
          _showErrorDialog(responseData['message'] ?? 'Failed to reset password.');
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
    )..show();
  }

  void _showSuccessDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: 'Success',
      desc: message,
      btnOkOnPress: () {
        Navigator.of(context).pushReplacementNamed("PatLoginPage");
      },
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password',style: TextStyle(color: Colors.white70),),
        backgroundColor: const Color(0xff414370),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff414370),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xff414370)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xff414370)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff414370),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 18,color: Colors.white70),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed("login"),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
