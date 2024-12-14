import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first/patient/login&signUP/signUp.dart';
import 'package:flutter/material.dart';
import 'patient/PatientPage.dart';
import 'package:provider/provider.dart';
import 'patient/profile/ThemeNotifier.dart';
import 'homepage.dart';
import 'patient/login&signUP/login.dart'; // Import the ThemeNotifier class
import 'patient/login&signUP/ResetPasswordPage.dart';
import 'Doctors/DoctorLoginPage.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await NotificationService.initialize(); // Initialize notifications


  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  void retrieveAndSendToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      // Send this token to your backend for the user
      // Example: sendTokenToBackend(token);
    }
  }



  @override
  void initState() {
    retrieveAndSendToken();

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: themeNotifier.currentTheme, // Apply the current theme
          home:  WelcomePage(),
          routes: {
            "welcomePage":(context) => const WelcomePage(),
            "signup": (context) => const PatSignUpPage(),
            "login": (context) =>  PatLoginPage(),
            '/reset-password': (context) => ResetPasswordPage(token: 'some_token'),
            "homepage": (context) => const PatientPage(),
            "WelcomePage": (context) => const WelcomePage(),
            "Doctor_login":(context) =>  DoctorLoginPage()
          }, // Your home page
        );
      },
    );
  }
}
