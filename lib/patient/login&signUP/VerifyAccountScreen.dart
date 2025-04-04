import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../PatientPage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class VerifyEmailPage extends StatefulWidget {
  final String token;

  const VerifyEmailPage({Key? key, required this.token}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isLoading = false;
  bool verificationSuccess = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    verifyEmail();
  }

  Future<void> verifyEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/healup/patients/verify/${widget.token}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          verificationSuccess = true;
          message = data['message'];
        });

        // Redirect to patient page after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PatientPage()),
          );
        });
      } else {
        final data = json.decode(response.body);
        setState(() {
          verificationSuccess = false;
          message = data['message'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      setState(() {
        verificationSuccess = false;
        message = 'Error connecting to server';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web-specific layout
      return Scaffold(
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                verificationSuccess ? Icons.check_circle : Icons.error,
                color: verificationSuccess ? Colors.green : Colors.red,
                size: 100, // Larger size for web
              ),
              const SizedBox(height: 30),
              Text(
                message,
                style: const TextStyle(fontSize: 24), // Larger font for web
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              verificationSuccess
                  ? const SizedBox.shrink() // No button if success
                  : ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    else {
      return Scaffold(
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                verificationSuccess ? Icons.check_circle : Icons.error,
                color: verificationSuccess ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              verificationSuccess
                  ? const SizedBox.shrink()
                  : ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
