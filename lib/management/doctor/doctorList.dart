import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'doctorDetailPage.dart';
import '../patient/managementMainPage.dart';
import 'AddDoctorPage.dart';  // استيراد الصفحة الجديدة لإضافة الطبيب

class DoctorListPage extends StatefulWidget {
  @override
  _DoctorListPageState createState() => _DoctorListPageState();
}
 
class _DoctorListPageState extends State<DoctorListPage> {
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> filteredDoctors = [];
  int _currentIndex = 1;
  String _searchText = '';

  Future<void> fetchDoctors() async {
    try {
      final response = await http.get(
          Uri.parse("http://10.0.2.2:5000/api/healup/doctors/doctors"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          doctors = data.map((doctor) {
            return {
              'id': doctor['_id'],
              'name': doctor['name'],
              'specialization': doctor['specialization'] ?? 'Not provided',
              'rating': doctor['rating'] ?? 'No rating',
              'pic': doctor['photo'] ?? 'images/default_doctor.png',
            };
          }).toList();
          filteredDoctors = List.from(doctors);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch doctors: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate based on index
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManagementMainPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorListPage()),
      );
    }
  }

  void _filterDoctors() {
    setState(() {
      if (_searchText.isEmpty) {
        filteredDoctors = List.from(doctors);
      } else {
        filteredDoctors = doctors.where((doctor) {
          return doctor['name']
              .toLowerCase()
              .contains(_searchText.toLowerCase());
        }).toList();
      }
    });
  }


    void _deleteDoctor(String doctorId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:5000/api/healup/doctors/delete/$doctorId"),
      );
      if (response.statusCode == 200) {
        setState(() {
          filteredDoctors.removeWhere((doctor) => doctor['id'] == doctorId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Doctor deleted successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete doctor: ${response.reasonPhrase}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  void _showDeleteDialog(String doctorId, String doctorName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete Dr. $doctorName?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f),
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                _deleteDoctor(doctorId); // Delete doctor
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor List"),
        backgroundColor: const Color(0xff2f9a8f),
        automaticallyImplyLeading: false,  // منع السلوك الافتراضي
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ManagementMainPage()),  // الانتقال إلى صفحة ManagementMainPage
            );
          },
        ),
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("Doctor List"),
    //     backgroundColor: const Color(0xff2f9a8f),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDoctorPage(),  // الانتقال لصفحة إضافة الطبيب
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  _filterDoctors();
                },
                decoration: InputDecoration(
                  hintText: "Search for doctor",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            doctors.isEmpty
                ? const Center(
              child: Text(
                "No doctors found.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorDetailsPage(doctorId: doctor['id']),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(doctor['pic']),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Specialization: ${doctor['specialization']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "Rating: ${doctor['rating']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteDialog(doctor['id'], doctor['name']);
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: onTabTapped,  // Handle navigation here
        backgroundColor: const Color(0xff2f9a8f),
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
            icon: Icon(Icons.settings),
            label: "Management",
          ),
        ],
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'doctorDetailPage.dart';  // تأكد من استيراد صفحة التفاصيل
// import 'managementMainPage.dart'; // تأكد من استيراد صفحة ManagementMainPage
//
// class DoctorListPage extends StatefulWidget {
//   @override
//   _DoctorListPageState createState() => _DoctorListPageState();
// }
//
// class _DoctorListPageState extends State<DoctorListPage> {
//   List<Map<String, dynamic>> doctors = [];
//   List<Map<String, dynamic>> filteredDoctors = [];  // قائمة الأطباء المفلترة
//   int _currentIndex = 1; // الفهرس الحالي لـ BottomNavigationBar
//   String _searchText = ''; // النص المدخل في مربع البحث
//
//   Future<void> fetchDoctors() async {
//     try {
//       final response = await http.get(
//           Uri.parse("http://10.0.2.2:5000/api/healup/doctors/doctors"));
//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           doctors = data.map((doctor) {
//             return {
//               'id': doctor['_id'],
//               'name': doctor['name'],
//               'specialization': doctor['specialization'] ?? 'Not provided',
//               'rating': doctor['rating'] ?? 'No rating',
//               'pic': doctor['photo'] ?? 'images/default_doctor.png',
//             };
//           }).toList();
//           filteredDoctors = List.from(doctors); // نسخ القائمة الأصلية إلى المفلترة
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to fetch doctors: ${response.reasonPhrase}")),
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
//     fetchDoctors();
//   }
//
//   void onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//
//     // Handle navigation based on the selected index
//     if (index == 0) {
//       // Navigate to ManagementMainPage
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => ManagementMainPage()),
//       );
//     } else if (index == 1) {
//       // Navigate to Doctor List page
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => DoctorListPage()),
//       );
//     }
//     // إضافة الأكواد لبقية الصفحات حسب الحاجة
//   }
//
//   void _filterDoctors() {
//     setState(() {
//       if (_searchText.isEmpty) {
//         filteredDoctors = List.from(doctors);
//       } else {
//         filteredDoctors = doctors.where((doctor) {
//           return doctor['name']
//               .toLowerCase()
//               .contains(_searchText.toLowerCase());
//         }).toList();
//       }
//     });
//   }
//
//   void _deleteDoctor(String doctorId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse("http://10.0.2.2:5000/api/healup/doctors/delete/$doctorId"),
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           filteredDoctors.removeWhere((doctor) => doctor['id'] == doctorId);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Doctor deleted successfully.")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to delete doctor: ${response.reasonPhrase}")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred: $error")),
//       );
//     }
//   }
//
//   void _showDeleteDialog(String doctorId, String doctorName) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Confirm Delete"),
//           content: Text("Are you sure you want to delete Dr. $doctorName?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               style: TextButton.styleFrom(
//                 backgroundColor: const Color(0xff2f9a8f),
//               ),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.of(context).pop(); // Close the dialog
//                 _deleteDoctor(doctorId); // Delete doctor
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xff2f9a8f),
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
//         title: const Text("Doctor List"),
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
//                     _filterDoctors(); // تحديث الفلاتر عند تغيير النص
//                   },
//                   decoration: InputDecoration(
//                     hintText: "Search for doctor",
//                     prefixIcon: const Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(25.0),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white.withOpacity(0.7),
//                   ),
//                 ),
//               ),
//               doctors.isEmpty
//                   ? const Center(
//                 child: Text(
//                   "No doctors found.",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               )
//                   : Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredDoctors.length,
//                   itemBuilder: (context, index) {
//                     final doctor = filteredDoctors[index];
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 DoctorDetailsPage(doctorId: doctor['id']),
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
//                                 backgroundImage: NetworkImage(doctor['pic']),
//                               ),
//                               const SizedBox(width: 16.0),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       doctor['name'],
//                                       style: const TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       "Specialization: ${doctor['specialization']}",
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                     Text(
//                                       "Rating: ${doctor['rating']}",
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () {
//                                   _showDeleteDialog(doctor['id'], doctor['name']);
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
//         onTap: onTabTapped,  // Handle navigation here
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
//
