import 'package:flutter/material.dart';
import 'DoctorAppointmentManagement.dart';
import 'DoctorProfilePage.dart';
import 'search_screen.dart';
import 'displayPatDoc.dart'; // Import your chat page
import 'package:flutter/foundation.dart'; // For kIsWeb

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedPageIndex = 0;

  // Define page options
  final List<Widget> _pages = [
    AppointmentManagementPage(),
    SearchScreen(),
    DisplayPatDoc(), // Add your chat page here
    DoctorProfilePage(),
  ];

  // Function to switch pages
  void _onPageSelected(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }



  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: _pages[_selectedPageIndex], // Display the selected page
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPageIndex, // Highlight the selected index
          onTap: _onPageSelected, // Handle tap on the bottom navigation items
          selectedItemColor: Color(0xff414370),  // Set selected item icon color to white
          unselectedItemColor: Colors.grey[500],  // Set unselected item icon color to grey
          backgroundColor: Color(0xff414370),  // Set the background color here

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today,size: 25,),
              label: "Appointments",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search,size: 25,),
              label: "EHR Search",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat,size: 25,), // Chat icon
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person,size: 25,),
              label: "Profile",
            ),
          ],
        ),
      );

    }
    else{
      return Scaffold(
        body: _pages[_selectedPageIndex], // Display the selected page
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Color(0xff414370), // Set the background color here
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedPageIndex, // Highlight the selected index
            onTap: _onPageSelected, // Handle tap on the bottom navigation items
            selectedItemColor: Colors.white,  // Set selected item icon color to white
            unselectedItemColor: Colors.grey[500],  // Set unselected item icon color to grey
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today,size: 25,),
                label: "Appointments",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search,size: 25,),
                label: "EHR Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat,size: 25,), // Chat icon
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person,size: 25,),
                label: "Profile",
              ),
            ],
          ),
        ),
      );
    }
    }
}
