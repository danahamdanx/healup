import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'patient/PatientPage.dart';
import 'patient/login&signUP/signUp.dart';
import 'patient/login&signUP/login.dart';
import 'patient/login&signUP/ResetPasswordPage.dart';
import 'Doctors/DoctorLoginPage.dart';
import 'patient/Appointement/ScheduleScreen.dart';
import 'homepage.dart';
import 'patient/profile/ThemeNotifier.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase before running the app


  // Initialize Firebase Messaging
FirebaseMessaging.instance.getToken().then((value){
    print('Firebase Messaging Token: $value');

  });
  // Handle notification when app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in the foreground: ${message.notification?.title}');
      // Handle notification and navigate to ScheduleScreen
      _navigateToScreen(message);

  });

  // Handle notification click when app is opened from a background state
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification clicked, navigating to ScheduleScreen');
    _navigateToScreen(message);
  });

  // Handle notification when app is launched from a terminated state
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null && message.data['screen'] == 'ScheduleScreen') {
      _navigateToScreen(message);
    }
  });

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle the background message here, for example:
  if (message.data['screen'] == 'ScheduleScreen') {
    // Perform background navigation or other actions
  }
}


// Function to navigate to ScheduleScreen
void _navigateToScreen(RemoteMessage message) {
  final navigator = navigatorKey.currentState;
  if (navigator != null) {
    MaterialPageRoute(
      builder: (context) => ScheduleScreen(),
    );}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: themeNotifier.currentTheme, // Apply the current theme
          home: const WelcomePage(),
          navigatorKey: navigatorKey, // Set navigator key for global navigation
          routes: {
            "welcomePage": (context) => const WelcomePage(),
            "signup": (context) => const PatSignUpPage(),
            "login": (context) =>  PatLoginPage(),
            '/reset-password': (context) => ResetPasswordPage(token: 'some_token'),
            "homepage": (context) => const PatientPage(),
            "WelcomePage": (context) => const WelcomePage(),
            "Doctor_login": (context) =>  DoctorLoginPage(),
            "ScheduleScreen": (context) =>  ScheduleScreen()
          },
        );
      },
    );
  }
}
