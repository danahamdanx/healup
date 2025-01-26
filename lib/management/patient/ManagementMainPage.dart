import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'patientDetailPage.dart';  // تأكد من استيراد صفحة التفاصيل
import '../doctor/doctorList.dart';
import '../medication/medicationList.dart';
import '../order/orderList.dart';
import '../managements/managementList.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class ManagementMainPage extends StatefulWidget {
  @override
  _ManagementMainPageState createState() => _ManagementMainPageState();
}

class _ManagementMainPageState extends State<ManagementMainPage> {
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];  // قائمة المرضى المفلترة
  int _currentIndex = 0; // الفهرس الحالي لـ BottomNavigationBar
  String _searchText = ''; // النص المدخل في مربع البحث

  Future<void> fetchPatients() async {
    if(kIsWeb){
      try {
        final response = await http.get(
            Uri.parse("http://localhost:5000/api/healup/patients/"));
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            List<dynamic> data = responseData['data'];
            setState(() {
              patients = data.map((patient) {
                String dob = patient['DOB'];
                int birthYear = int.parse(dob.split('-')[0]);
                int currentYear = DateTime.now().year;
                int age = currentYear - birthYear;

                return {
                  'id': patient['_id'],
                  'name': patient['username'],
                  'details': patient['medical_history'] ?? 'No details provided',
                  'age': age,
                  'pic': patient['pic'] ?? 'images/default_patient.png',
                };
              }).toList();
              filteredPatients = List.from(patients); // نسخ القائمة الأصلية إلى المفلترة
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch patients: ${response.reasonPhrase}")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }
    else{
      try {
        final response = await http.get(
            Uri.parse("http://10.0.2.2:5000/api/healup/patients/"));
        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            List<dynamic> data = responseData['data'];
            setState(() {
              patients = data.map((patient) {
                String dob = patient['DOB'];
                int birthYear = int.parse(dob.split('-')[0]);
                int currentYear = DateTime.now().year;
                int age = currentYear - birthYear;

                return {
                  'id': patient['_id'],
                  'name': patient['username'],
                  'details': patient['medical_history'] ?? 'No details provided',
                  'age': age,
                  'pic': patient['pic'] ?? 'images/default_patient.png',
                };
              }).toList();
              filteredPatients = List.from(patients); // نسخ القائمة الأصلية إلى المفلترة
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch patients: ${response.reasonPhrase}")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }

  }

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation here based on the selected index
    if (index == 1) {
      // Navigate to Doctor List page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorListPage(),
        ),
      );
    } else if (index == 2) {
      //Navigate to Medication page (assuming you have one)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationListPage(),
        ),
      );
    } else if (index == 3) {
      //Navigate to Order page (assuming you have one)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderListPage(),
        ),
      );
    } else if (index == 4) {
     // Navigate to Management page (if necessary)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManagementListPage(),
        ),
      );
    }
  }

  void _filterPatients() {
    setState(() {
      if (_searchText.isEmpty) {
        filteredPatients = List.from(patients);
      } else {
        filteredPatients = patients.where((patient) {
          return patient['name']
              .toLowerCase()
              .contains(_searchText.toLowerCase());
        }).toList();
      }
    });
  }

  void _deletePatient(String patientId) async {
    if(kIsWeb){
      try {
        final response = await http.delete(
          Uri.parse("http://localhost:5000/api/healup/patients/delete/$patientId"),
        );
        if (response.statusCode == 200) {
          setState(() {
            filteredPatients.removeWhere((patient) => patient['id'] == patientId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Patient deleted successfully.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete patient: ${response.reasonPhrase}")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }
    else{
      try {
        final response = await http.delete(
          Uri.parse("http://10.0.2.2:5000/api/healup/patients/delete/$patientId"),
        );
        if (response.statusCode == 200) {
          setState(() {
            filteredPatients.removeWhere((patient) => patient['id'] == patientId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Patient deleted successfully.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete patient: ${response.reasonPhrase}")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }

  }

  void _showDeleteDialog(String patientId, String patientName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete $patientName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff414370),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70), // تغيير لون الكتابة
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                _deletePatient(patientId); // Delete patient
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff414370),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white70), // تغيير لون الكتابة
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,  // لإزالة سهم التراجع
          title: const Text(
            "Patient List",
            style: TextStyle(
                fontSize: 28,  // زيادة حجم الخط
                color: Colors.white70,
                fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xff414370),
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
                onTabTapped(index); // استدعاء الدالة لتحديث الواجهة
              },
              backgroundColor: const Color(0xff414370),
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: const IconThemeData(color: Colors.black54),
              selectedLabelTextStyle: const TextStyle(color: Colors.white),
              unselectedLabelTextStyle: const TextStyle(color: Colors.black54),
              extended: true, // لتوسيع القائمة وعرض النص بجانب الأيقونة
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text("Patient List"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.medical_services),
                  label: Text("Doctor List"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.local_pharmacy),
                  label: Text("Medication List"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: Text("Order List"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.admin_panel_settings),
                  label: Text("Management List"),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1), // خط فاصل بين القائمة والمحتوى
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                        _filterPatients(); // تحديث الفلاتر عند تغيير النص
                      },
                      decoration: InputDecoration(
                        hintText: "Search for patient",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  patients.isEmpty
                      ? const Center(
                    child: Text(
                      "No patients found.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  )
                      : Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 3 / 2.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PatientDetailsPage(patientId: patient['id']),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            color: Color(0xffd4dcee), // تغيير لون الكارد هنا

                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: AssetImage(patient['pic']),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    "${patient['name']}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Age: ${patient['age']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showDeleteDialog(patient['id'], patient['name']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    else{
      return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,  // لإزالة سهم التراجع
          title: const Text(
            "Patient List",
            style: TextStyle(
                fontSize: 28,  // زيادة حجم الخط
                color: Colors.white70,
                fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xff414370),
         ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xfff3efd9), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                      _filterPatients(); // تحديث الفلاتر عند تغيير النص
                    },
                    decoration: InputDecoration(
                      hintText: "Search for patient",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                patients.isEmpty
                    ? const Center(
                  child: Text(
                    "No patients found.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PatientDetailsPage(patientId: patient['id']),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: Color(0xffd4dcee), // تغيير لون الكارد هنا

                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage: AssetImage(patient['pic']),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${patient['name']}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Age: ${patient['age']}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteDialog(patient['id'], patient['name']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: onTabTapped,  // Handle navigation here
          backgroundColor: const Color(0xff414370),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black54,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Patient",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: "Doctor",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy),
              label: "Medication",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Order",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: "Management",
            ),
          ],
        ),
      );

    }

  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'patientDetailPage.dart';  // تأكد من استيراد صفحة التفاصيل
// import 'doctorList.dart';
//
// class ManagementMainPage extends StatefulWidget {
//   @override
//   _ManagementMainPageState createState() => _ManagementMainPageState();
// }
//
// class _ManagementMainPageState extends State<ManagementMainPage> {
//   List<Map<String, dynamic>> patients = [];
//   List<Map<String, dynamic>> filteredPatients = [];  // قائمة المرضى المفلترة
//   int _currentIndex = 0; // الفهرس الحالي لـ BottomNavigationBar
//   String _searchText = ''; // النص المدخل في مربع البحث
//
//   Future<void> fetchPatients() async {
//     try {
//       final response = await http.get(
//           Uri.parse("http://10.0.2.2:5000/api/healup/patients/"));
//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = jsonDecode(response.body);
//         if (responseData['success'] == true) {
//           List<dynamic> data = responseData['data'];
//           setState(() {
//             patients = data.map((patient) {
//               String dob = patient['DOB'];
//               int birthYear = int.parse(dob.split('-')[0]);
//               int currentYear = DateTime.now().year;
//               int age = currentYear - birthYear;
//
//               return {
//                 'id': patient['_id'],
//                 'name': patient['username'],
//                 'details': patient['medical_history'] ?? 'No details provided',
//                 'age': age,
//                 'pic': patient['pic'] ?? 'images/default_patient.png',
//               };
//             }).toList();
//             filteredPatients = List.from(patients); // نسخ القائمة الأصلية إلى المفلترة
//           });
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to fetch patients: ${response.reasonPhrase}")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $error")),
//       );
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPatients();
//   }
//
//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   void _filterPatients() {
//     setState(() {
//       if (_searchText.isEmpty) {
//         filteredPatients = List.from(patients);
//       } else {
//         filteredPatients = patients.where((patient) {
//           return patient['name']
//               .toLowerCase()
//               .contains(_searchText.toLowerCase());
//         }).toList();
//       }
//     });
//   }
//
//   // وظيفة لحذف المريض
//   void _deletePatient(String patientId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse("http://10.0.2.2:5000/api/healup/patients/delete/$patientId"),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           filteredPatients.removeWhere((patient) => patient['id'] == patientId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Patient deleted successfully.")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to delete patient: ${response.reasonPhrase}")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $error")),
//       );
//     }
//   }
//
//   // عرض الـ AlertDialog لتأكيد الحذف
//   void _showDeleteDialog(String patientId, String patientName) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm Delete"),
//           content: Text("Are you sure you want to delete $patientName?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: const Color(0xff2f9a8f), // Set the color for the text of the button
//               ),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close the dialog
//                 _deletePatient(patientId); // Delete patient
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xff2f9a8f), // Set the button color
//               ),
//               child: const Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Patient List"),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('images/back.jpg'),
//                 fit: BoxFit.cover,
//                 colorFilter: ColorFilter.mode(
//                   Colors.black.withOpacity(0.3),
//                   BlendMode.darken,
//                 ),
//               ),
//             ),
//           ),
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: TextField(
//                   onChanged: (value) {
//                     setState(() {
//                       _searchText = value;
//                     });
//                     _filterPatients(); // تحديث الفلاتر عند تغيير النص
//                   },
//                   decoration: InputDecoration(
//                     hintText: "Search for patient",
//                     prefixIcon: const Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ),
//               patients.isEmpty
//                   ? const Center(
//                 child: Text(
//                   "No patients found.",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               )
//                   : Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredPatients.length,
//                   itemBuilder: (context, index) {
//                     final patient = filteredPatients[index];
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 PatientDetailsPage(patientId: patient['id']),
//                           ),
//                         );
//                       },
//                       child: Card(
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 8.0, horizontal: 16.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.0),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 35,
//                                 backgroundImage: NetworkImage(patient['pic']),
//                               ),
//                               const SizedBox(width: 16.0),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "${patient['name']}",
//                                       style: const TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       "Age: ${patient['age']}",
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () {
//                                   _showDeleteDialog(patient['id'], patient['name']);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         onTap: onTabTapped,
//         backgroundColor: const Color(0xff2f9a8f),
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.black54,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Patient",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.medical_services),
//             label: "Doctor",
//               // Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (context) =>
//               //         PatientDetailsPage(patientId: patient['id']),
//               //   ),
//               // );
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_pharmacy),
//             label: "Medication",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: "Order",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: "Management",
//           ),
//         ],
//       ),
//     );
//   }
// }
