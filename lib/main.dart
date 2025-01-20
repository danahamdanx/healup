import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:first/patient/medication/stripe_keys.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'patient/PatientPage.dart';
import 'patient/login&signUP/signUp.dart';
import 'patient/login&signUP/login.dart';
import 'patient/login&signUP/ResetPasswordPage.dart';
import 'Doctors/login/DoctorLoginPage.dart';
import 'patient/Appointement/ScheduleScreen.dart';
import 'homepage.dart';
import 'patient/profile/ThemeNotifier.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Firebase Web SDK config
const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyD93aSL0-kHJGH9y4ooGR9Ywito51-6BmM",
    authDomain: "healup-e4c79.firebaseapp.com",
    projectId: "healup-e4c79",
    storageBucket: "healup-e4c79.firebasestorage.app",
    messagingSenderId: "150878429110",
    appId: "1:150878429110:web:6260088a8b9211d3386b17",
    measurementId: "G-64L6E1VK62"
);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Check if Firebase is initialized already, if not, initialize it
  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    // If Firebase is already initialized, catch the error and do nothing
    print("Firebase already initialized: $e");
  }

  // Initialize Firebase Messaging (only if it's not a web platform)
  if (!kIsWeb) {
    FirebaseMessaging.instance.getToken().then((value) {
      print('Firebase Messaging Token: $value');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground: ${message.notification?.title}');
      _navigateToScreen(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked, navigating to ScheduleScreen');
      _navigateToScreen(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _navigateToScreen(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Initialize Stripe (ensure it's only done on non-web platforms)
  if (!kIsWeb) {
    Stripe.publishableKey = ApiKeys.publishableKey;
  }



  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

// Background message handler for Firebase
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.notification?.title}");
  if (message.data['screen'] == 'ScheduleScreen') {
    _navigateToScreen(message);
  }
}

// Function to navigate to ScheduleScreen
void _navigateToScreen(RemoteMessage message) {
  final navigator = navigatorKey.currentState;
  if (navigator != null) {
    if (message.data['screen'] == 'ScheduleScreen') {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ScheduleScreen()),
            (route) => false, // This will remove all previous routes
      );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: themeNotifier.currentTheme, // Apply the current theme
          home: const WelcomePage(), // Ensure WelcomePage exists
          navigatorKey: navigatorKey, // Set navigator key for global navigation
          routes: {
            "welcomePage": (context) => const WelcomePage(),
            "signup": (context) => const PatSignUpPage(),
            "login": (context) => PatLoginPage(),
            '/reset-password': (context) => ResetPasswordPage(token: 'some_token'),
            "homepage": (context) => const PatientPage(),
            "Doctor_login": (context) => DoctorLoginPage(),
            "ScheduleScreen": (context) => ScheduleScreen(),
          },
        );
      },
    );
  }
}
