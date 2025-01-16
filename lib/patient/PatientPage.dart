import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'homeTab.dart'; // Ensure this file defines HomeTab
import 'medication/searchTab.dart';
import 'profile/patProfile.dart';
import 'chatBot/chatBot.dart';
import 'Appointement/ScheduleScreen.dart';
import 'package:first/patient/chat/displayDoctorChat.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  int _selectedIndex = 0;
  List<Widget>? _pages; // Use nullable List until data is initialized
  final List<Map<String, dynamic>> appointments = [];
  String userName = "";
  String patientId = ""; // Add a variable to store the patient ID
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Declare the storage instance


  /// Fetch userName and patientId, then initialize the pages
  @override
  void initState() {
    super.initState();
    _getPatientId();
    _getUserName();
  }

  Future<void> _getPatientId() async {
    String? id = await _storage.read(key: 'patient_id');
    debugPrint("Fetched patient ID from storage: $id");
    setState(() {
      patientId = id ?? "";
      _pages = [
        HomeTab(
          userName: userName,
          onAppointmentBooked: _onAppointmentBooked,
          onAppointmentCanceled: _onAppointmentCanceled,
          onPatientIdReceived: _onPatientIdReceived,
        ),
        DoctorsPage(),
        SearchMedicinePage(patientId: patientId), // Pass patientId here
        ScheduleScreen(), // Pass patientId to ScheduleScreen
        PatProfile(patientId: patientId),
      ];
    });
  }





  Future<void> _getUserName() async {
    String? name = await _storage.read(key: 'patient_name');
    setState(() {
      userName = name ?? "Patient"; // Use default "Patient" if name is null
    });
  }


  void _onAppointmentBooked(Map<String, dynamic> newAppointment) {
    setState(() {
      appointments.add(newAppointment);
    });
  }

  void _onAppointmentCanceled(Map<String, dynamic> appointment) {
    setState(() {
      appointments.remove(appointment);
    });
  }

  void _onPatientIdReceived(String id) {
    setState(() {
      patientId = id;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until `_pages` is initialized
    if (_pages == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.lightBlue, Colors.lightGreen],
              tileMode: TileMode.clamp,
            ).createShader(bounds),
            child: const Text(
              'HealUp',
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'Hello Valentina',
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
          ),
          backgroundColor: const Color(0xff6be4d7), // App bar background color
        ),
        body: Row(
          children: [
            // Left Sidebar for Web navigation
            Container(
              width: 250, // Width of the sidebar
              color: const Color(0xff6be4d7), // Background color for the rail
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.chat),
                    label: Text('Chat'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.search), // Added search icon
                    label: Text('Search'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today),
                    label: Text('Calendar'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    label: Text('Profile'),
                  ),
                ],
                backgroundColor: const Color(0xff6be4d7), // Same background color for the rail
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.white, // White text for selected label
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: const TextStyle(color: Colors.grey), // Lighter color for unselected labels
                selectedIconTheme: const IconThemeData(color: Colors.white),
                unselectedIconTheme: const IconThemeData(color: Colors.grey), // Lighter color for unselected icons
                extended: true, // Make the rail extended for better visibility
              ),
            ),
            // Main page content area with padding and slight shadow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _pages![_selectedIndex],
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
        body: _pages![_selectedIndex],
        bottomNavigationBar: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.home, size: 35),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.chat, size: 30),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox.shrink(),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.calendar_today, size: 30),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.account_circle_outlined, size: 32),
                  ),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              backgroundColor: const Color(0xff6be4d7),
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            ),
            Positioned(
              bottom: 5,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 2; // Switch to Search screen
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  height: 70,
                  width: 70,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                        Icons.search, size: 35, color: Color(0xff6be4d7)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
