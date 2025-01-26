import 'package:flutter/material.dart';
import 'patient/login&signUP/login.dart'; // Import the LoginSignupPage
import 'Doctors/DoctorLoginPage.dart';
import 'management/ManagementLogin.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'services/animation.dart';
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web-specific layout
      return Scaffold(
        body: Stack(
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
            // Transparent overlay
            Container(
              color: Colors.black.withOpacity(0.1),
            ),
            // SafeArea for content
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800), // Center content on large screens
                  child: Container(
                    // Frame around the entire content
                    decoration: BoxDecoration(
                      color: Color(0xff2f9a8f).withOpacity(0.4), // Semi-transparent background
                      borderRadius: BorderRadius.circular(25), // Rounded corners
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5), // Light border color
                        width: 2, // Border width
                      ),
                    ),
                    padding: const EdgeInsets.all(24), // Adjust padding for smaller height
                    height: 600, // Set a specific height for the content container
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 70, // Adjust logo size
                          backgroundImage: AssetImage('images/img_7.png'),
                        ),
                        const SizedBox(height: 20), // Reduce space below logo
                        Center(
                          child: SizedBox(
                            width: 300, // Constrain the width of the HandwrittenText
                            height: 100, // Constrain the height of the HandwrittenText
                            child: HandwrittenText(
                              text: 'Welcome to HealUp',
                              duration: Duration(milliseconds: 1800), // Adjust the duration as needed
                            ),
                          ),
                        ),
                        Text(
                          'Please select your role to get started.',
                          style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30), // Reduce space between buttons
                        buildSignUpButton(context, 'A Doctor', Icons.local_hospital),
                        buildSignUpButton(context, 'Patient', Icons.person),
                        buildSignUpButton(
                            context, 'Management', Icons.admin_panel_settings),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }



  else {
      return Scaffold(
        body: Stack(
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

            // Transparent overlay
            Container(
              color:
              Colors.black.withOpacity(0.1), // Semi-transparent black overlay
            ),
            // SafeArea for content

            SingleChildScrollView(

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),

                  // Circular logo image at the top of the column
                  const Center(

                    child: CircleAvatar(

                      radius: 73, // Adjust size as needed
                      backgroundImage: AssetImage(
                          'images/img_7.png'), // Replace with your logo image path
                    ),
                  ),
                  const SizedBox(height: 80),
                  SlideTransition(
                    position: _offsetAnimation!,
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 300, // Constrain the width of the HandwrittenText
                            height: 100, // Constrain the height of the HandwrittenText
                            child: HandwrittenText(
                              text: 'Welcome to HealUp',
                              duration: Duration(milliseconds: 1000), // Adjust the duration as needed
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: 8), // Space between the two sentences
                        Text(
                          'Please select your role to get started.',
                          style: TextStyle(fontSize: 18, color: Colors
                              .grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _offsetAnimation!,
                    child: buildSignUpButton(
                        context, 'A Doctor', Icons.local_hospital),
                  ),
                  SlideTransition(
                    position: _offsetAnimation!,
                    child: buildSignUpButton(context, 'Patient', Icons.person),
                  ),
                  SlideTransition(
                    position: _offsetAnimation!,
                    child: buildSignUpButton(
                        context, 'Management', Icons.admin_panel_settings),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget buildSignUpButton(BuildContext context, String role, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        onPressed: () {
          if (role == 'Patient') {
            Navigator.of(context).pushReplacementNamed("login");

          }  else if (role == 'A Doctor') {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DoctorLoginPage(), // Navigates to DoctorLoginPage
            ));
          }
          else if (role == 'Management') {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ManagementLoginPage(), // Navigates to DoctorLoginPage
            ));}

        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          "I'm $role",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff414370),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                30), // Increased borderRadius for a rounded shape
          ),
        ),
      ),
    );
  }
}

