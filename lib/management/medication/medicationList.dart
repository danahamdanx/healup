import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../patient/managementMainPage.dart';
import 'AddMedicationPage.dart'; // Import the new page to add medication
import '../doctor/doctorList.dart';
import '../order/orderList.dart';
import '../managements/managementList.dart';
import 'EditMedicationPage.dart';
import 'medicationDetailPage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb


class MedicationListPage extends StatefulWidget {
  @override
  _MedicationListPageState createState() => _MedicationListPageState();
}
class _MedicationListPageState extends State<MedicationListPage> {
  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> filteredMedications = [];
  String _searchText = '';
  String _selectedCategory = "All";
  String _selectedOtcType = "All"; // Default selected OTC type
  int _currentIndex = 2; // Define the initial index for BottomNavigationBar


  final List<String> categories = [
    "All",
    "OTC Medication",
    "Discount List"
  ];

  final List<String> otcTypes = [
    "All",
    "ALLERGY & CONGESTION",
    "ANTACIDS & ACID REDUCERS",
    "ANTIBACTERIALS, TOPICAL",
    "COUGH & COLD",
    "DIABETES - INSULINS",
    "DIABETES - SUPPLIES",
    "EYE CARE",
    "GAS RELIEVERS, LAXATIVES & STOOL SOFTENERS",
    "ANTIDIARRHEALS",
    "ANTIEMETIC",
    "ANTIFUNGALS, TOPICAL",
    "ANTIFUNGALS, VAGINAL",
    "ANTI-ITCH LOTIONS & CREAMS",
    "CONTRACEPTIVES",
    "CONTRACEPTIVES - EMERGENCY",
    "MEDICAL SUPPLIES",
    "OVERACTIVE BLADDER",
    "PAIN & INFLAMMATION",
    "TOPICAL, MISCELLANEOUS",
    "VITAMINS/MINERALS",
    "MISCELLANEOUS"
  ];


  // Fetch medications from the API
  Future<void> fetchMedications() async {
    if(kIsWeb){
      try {
        final response = await http.get(
          Uri.parse("http://localhost:5000/api/healup/medication/"),
        );

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          // Modify this section in the 'fetchMedications' method
          setState(() {
            medications = data.map((medication) {
              return {
                'id': medication['_id'],
                'name': medication['scientific_name'] ?? 'No name provided',
                'medication_name': medication['medication_name'] ?? 'No name provided',
                'stock_quantity': medication['stock_quantity'].toString(), // Ensure it's a string
                'type': medication['type'] ?? 'All',
                'pic': medication['image'] ?? 'images/default_medication.png', // Default if no image

                //'pic': medication['photo'] ?? 'images/default_medication.png',
              };
            }).toList();
            filteredMedications = List.from(medications);
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch medications: ${response.reasonPhrase}")),
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
          Uri.parse("http://10.0.2.2:5000/api/healup/medication/"),
        );

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          // Modify this section in the 'fetchMedications' method
          setState(() {
            medications = data.map((medication) {
              return {
                'id': medication['_id'],
                'name': medication['scientific_name'] ?? 'No name provided',
                'medication_name': medication['medication_name'] ?? 'No name provided',
                'stock_quantity': medication['stock_quantity'].toString(), // Ensure it's a string
                'type': medication['type'] ?? 'All',
                'pic': medication['image'] ?? 'images/default_medication.png', // Default if no image

                //'pic': medication['photo'] ?? 'images/default_medication.png',
              };
            }).toList();
            filteredMedications = List.from(medications);
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch medications: ${response.reasonPhrase}")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }

  }
  Future<void> fetchOTCMedications() async {
    if(kIsWeb){
      try {
        final response = await http.get(
          Uri.parse("http://localhost:5000/api/healup/medication/otcmedication"),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          List<dynamic> medicationsData = data['medications'];
          setState(() {
            medications = medicationsData.map((medication) {
              return {
                'id': medication['_id'],
                'name': medication['scientific_name'] ?? 'No name provided',
                'medication_name': medication['medication_name'] ?? 'No name provided',
                'type': medication['type'] ?? 'Miscellaneous',
                'stock_quantity': medication['stock_quantity'].toString(),
                'pic': medication['image'] ?? 'images/default_medication.png',
              };
            }).toList();
            filteredMedications = List.from(medications);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch OTC medications")),
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
          Uri.parse("http://10.0.2.2:5000/api/healup/medication/otcmedication"),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          List<dynamic> medicationsData = data['medications'];
          setState(() {
            medications = medicationsData.map((medication) {
              return {
                'id': medication['_id'],
                'name': medication['scientific_name'] ?? 'No name provided',
                'medication_name': medication['medication_name'] ?? 'No name provided',
                'type': medication['type'] ?? 'Miscellaneous',
                'stock_quantity': medication['stock_quantity'].toString(),
                'pic': medication['image'] ?? 'images/default_medication.png',
              };
            }).toList();
            filteredMedications = List.from(medications);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch OTC medications")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }
  }



  // Fetch discounted medications from the API
  Future<void> fetchDiscountedMedications() async {
    if(kIsWeb){
      try {
        final response = await http.get(
          Uri.parse("http://localhost:5000/api/healup/medication/discounted"),
        );

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          // Modify this section to handle discounted medications
          setState(() {
            medications = data.map((medication) {
              return {
                'id': medication['_id'],
                'name': medication['scientific_name'] ?? 'No name provided',
                'medication_name': medication['medication_name'] ?? 'No name provided',
                'stock_quantity': medication['stock_quantity'].toString(),
                'type': medication['type'] ?? 'All',
                'pic': medication['image'] ?? 'images/default_medication.png', // Default if no image
                'discount_percentage': medication['discount_percentage'] ?? 0, // Discount information
              };
            }).toList();
            filteredMedications = List.from(medications);
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch discounted medications: ${response.reasonPhrase}")),
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
          Uri.parse("http://10.0.2.2:5000/api/healup/medication/discounted"),
        );

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          // Modify this section to handle discounted medications
          setState(() {
            medications = data.map((medication) {
              return {
                'id': medication['_id'],
                'name': medication['scientific_name'] ?? 'No name provided',
                'medication_name': medication['medication_name'] ?? 'No name provided',
                'stock_quantity': medication['stock_quantity'].toString(),
                'type': medication['type'] ?? 'All',
                'pic': medication['image'] ?? 'images/default_medication.png', // Default if no image
                'discount_percentage': medication['discount_percentage'] ?? 0, // Discount information
              };
            }).toList();
            filteredMedications = List.from(medications);
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch discounted medications: ${response.reasonPhrase}")),
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
    fetchMedications();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      // Navigate to Doctor List page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManagementMainPage(),
        ),
      );
    }
    // Handle navigation here based on the selected index
    else if (index == 1) {
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

  void _filterMedications() {
    setState(() {
      // تصفية الأدوية بناءً على الفئة المحددة
      if (_selectedCategory == "All") {
        filteredMedications = medications;
      } else if (_selectedCategory == "Discount List") {
        filteredMedications = medications
            .where((med) => med['discount'] > 0)
            .toList();
      } else if (_selectedCategory == "OTC Medication") {
        if (_selectedOtcType == "All") {
          filteredMedications = medications;
        } else {
          filteredMedications = medications
              .where((med) => med['type'] == _selectedOtcType)
              .toList();
        }
      }

      // تطبيق البحث بناءً على النص المكتوب في مربع البحث
      if (_searchText.isNotEmpty) {
        filteredMedications = filteredMedications.where((med) {
          final medicationName = med['medication_name']
              .toLowerCase(); // اسم الدواء
          final searchText = _searchText
              .toLowerCase(); // النص المكتوب في مربع البحث
          return medicationName.contains(searchText);
        }).toList();
      }
      });
  }

  void _deleteMedication(String medicationId) async {
    if(kIsWeb){
      try {
        final response = await http.delete(
          Uri.parse("http://localhost:5000/api/healup/medication/delete/$medicationId"),
        );

        if (response.statusCode == 200) {
          setState(() {
            filteredMedications.removeWhere((medication) => medication['id'] == medicationId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Medication deleted successfully.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete medication: ${response.reasonPhrase}")),
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
          Uri.parse("http://10.0.2.2:5000/api/healup/medication/delete/$medicationId"),
        );

        if (response.statusCode == 200) {
          setState(() {
            filteredMedications.removeWhere((medication) => medication['id'] == medicationId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Medication deleted successfully.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete medication: ${response.reasonPhrase}")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }

  }

  void _showDeleteDialog(String medicationId, String medicationName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete $medicationName?"),
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
                _deleteMedication(medicationId); // Delete medication
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
  void _showDiscountDialog(String medicationId, String medicationName) {
    TextEditingController discountController = TextEditingController();

    // Fetch the medication details from the API
    _fetchMedicationDetails(medicationId).then((medication) {
      if (medication != null) {
        // Get the discount percentage from the medication data
        dynamic discountValue = medication['discount_percentage'];
        double discountPercentage = (discountValue is int)
            ? (discountValue as int).toDouble()
            : (discountValue is double)
            ? discountValue as double
            : 0.0;  // Default to 0.0 if the value is null or incorrect

        // Debug log to ensure the value is correct
        print("Fetched Discount: $discountPercentage");

        // Pre-fill the discount field with the current discount percentage
        discountController.text = discountPercentage.toStringAsFixed(2); // Ensure two decimal points for clarity

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Change Discount for Medication"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the current discount percentage
                  Text("Current Discount: ${discountPercentage.toStringAsFixed(0)}%"),
                  SizedBox(height: 10),
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Discount percentage (0 to 100)"),
                  ),
                ],
              ),
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
                    String discountStr = discountController.text;
                    double discountPercentage = double.tryParse(discountStr) ?? 0.0;

                    // Debug log to ensure the input is correct
                    print("Confirmed Discount: $discountPercentage");

                    // Ensure the discount percentage is within a valid range
                    if (discountPercentage < 0 || discountPercentage > 100) {
                      _showErrorDialog("Discount percentage must be between 0 and 100.");
                    } else {
                      // Call the function to update the discount
                      _updateDiscount(medicationId, discountPercentage);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff414370),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white70), // تغيير لون الكتابة
                  ),
                ),
              ],
            );
          },
        );
      } else {
        _showErrorDialog("Unable to fetch medication details.");
      }
    });
  }

  Future<Map<String, dynamic>?> _fetchMedicationDetails(String medicationId) async {
    if(kIsWeb){
      final url = Uri.parse("http://localhost:5000/api/healup/medication/$medicationId");

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          // Debugging the entire response body
          print("Response Body: ${response.body}");

          // If the request was successful, parse the response and return the medication details
          return json.decode(response.body)['medication'];
        } else {
          throw Exception("Failed to load medication details");
        }
      } catch (e) {
        _showErrorDialog("An error occurred while fetching medication details: $e");
        return null;
      }

    }
    else{
      final url = Uri.parse("http://10.0.2.2:5000/api/healup/medication/$medicationId");

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          // Debugging the entire response body
          print("Response Body: ${response.body}");

          // If the request was successful, parse the response and return the medication details
          return json.decode(response.body)['medication'];
        } else {
          throw Exception("Failed to load medication details");
        }
      } catch (e) {
        _showErrorDialog("An error occurred while fetching medication details: $e");
        return null;
      }

    }
  }


  void _updateDiscount(String medicationId, double discountPercentage) async {
    if(kIsWeb){
      final url = Uri.parse("http://localhost:5000/api/healup/medication/discount/$medicationId");

      try {
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'discount_percentage': discountPercentage,
          }),
        );

        if (response.statusCode == 200) {
          // Successfully updated the discount
          final updatedMedication = json.decode(response.body);
          // You can update the UI based on the updated medication
          print("Discount updated successfully: $updatedMedication");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Discount updated successfully.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update discount")),
          );
          throw Exception("Failed to update discount");

        }
      } catch (e) {
        //_showErrorDialog("An error occurred while updating the discount: $e");
      }

    }
    else{
      final url = Uri.parse("http://10.0.2.2:5000/api/healup/medication/discount/$medicationId");

      try {
        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'discount_percentage': discountPercentage,
          }),
        );

        if (response.statusCode == 200) {
          // Successfully updated the discount
          final updatedMedication = json.decode(response.body);
          // You can update the UI based on the updated medication
          print("Discount updated successfully: $updatedMedication");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Discount updated successfully.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update discount")),
          );
          throw Exception("Failed to update discount");

        }
      } catch (e) {
        //_showErrorDialog("An error occurred while updating the discount: $e");
      }

    }

  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f),
              ),
              child: const Text("OK"),
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
            "Medication List ",
            style: TextStyle(
              fontSize: 28,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              backgroundColor: const Color(0xff414370),
            ),
          ),
          backgroundColor: const Color(0xff414370),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              color: Colors.white70,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMedicationPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Row(
          children: [
            // القائمة الجانبية
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
            const VerticalDivider(thickness: 1, width: 1), // خط فاصل
            // الجزء الرئيسي للمحتوى
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfff3efd9), Colors.white],  // التدرج اللوني
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                          _filterMedications();
                        },
                        decoration: InputDecoration(
                          hintText: "Search for medication",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    // Category Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,  // تمكين التمرير الأفقي
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,  // محاذاة الأزرار للبداية
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = 'All';
                                });
                                fetchMedications(); // جلب الأدوية بناءً على الفئة
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedCategory == 'All'
                                    ? Colors.white
                                    : const Color(0xff414370),
                                foregroundColor: _selectedCategory == 'All'
                                    ? Colors.black
                                    : Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(
                                    color: _selectedCategory == 'All'
                                        ? const Color(0xff414370)
                                        : Colors.transparent,
                                    width: 4.0,
                                  ),
                                ),
                                minimumSize: Size(130, 60),
                              ),
                              child: const Text(
                                'All',
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4), // مسافة صغيرة بين الأزرار
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = 'OTC Medication';
                                });
                                fetchOTCMedications(); // جلب الأدوية الـ OTC
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedCategory == 'OTC Medication'
                                    ? Colors.white
                                    : const Color(0xff414370),
                                foregroundColor: _selectedCategory == 'OTC Medication'
                                    ? Colors.black
                                    : Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(
                                    color: _selectedCategory == 'OTC Medication'
                                        ? const Color(0xff414370)
                                        : Colors.transparent,
                                    width: 4.0,
                                  ),
                                ),
                                minimumSize: Size(130, 60),
                              ),
                              child: const Text(
                                'OTC Medication',
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4), // مسافة صغيرة بين الأزرار
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = 'Discount List';
                                });
                                fetchDiscountedMedications(); // جلب الأدوية المخفضة
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedCategory == 'Discount List'
                                    ? Colors.white
                                    : const Color(0xff414370),
                                foregroundColor: _selectedCategory == 'Discount List'
                                    ? Colors.black
                                    : Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: BorderSide(
                                    color: _selectedCategory == 'Discount List'
                                        ? const Color(0xff414370)
                                        : Colors.transparent,
                                    width: 4.0,
                                  ),
                                ),
                                minimumSize: Size(130, 60),
                              ),
                              child: const Text(
                                'Discount List',
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // OTC Types (if OTC category is selected)
                    if (_selectedCategory == "OTC Medication")
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: otcTypes.map((type) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0), // إضافة فراغ بين الكبسات
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedOtcType = type;
                                    });
                                    _filterMedications(); // تصفية الأدوية حسب النوع المحدد
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedOtcType == type
                                        ? Colors.white
                                        : const Color(0xff414370),
                                    foregroundColor: _selectedOtcType == type
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 18, // حجم الخط تم زيادته هنا
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                    // Medication List
                    Expanded(
                      child: medications.isEmpty
                          ? Center(child: Text("No medications found."))
                          : ListView.builder(
                        itemCount: filteredMedications.length,
                        itemBuilder: (context, index) {
                          final medication = filteredMedications[index];
                          return GestureDetector(
                            onTap: () {
                              // التوجه إلى صفحة التفاصيل عند الضغط
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MedicationDetailsPage(
                                    medicationId: medication['id'], // تمرير ID الدواء
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              color: Color(0xffd4dcee), // تغيير لون الكارد هنا

                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // عرض صورة الدواء بدلاً من الأيقونة
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundImage: AssetImage(medication['pic']),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medication['name'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Medication: ${medication['medication_name']}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.yellowAccent),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditMedicationPage(
                                              medicationId: medication['id'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _showDeleteDialog(medication['id'], medication['name']);
                                      },
                                    ),
                                    // Discount Icon
                                    IconButton(
                                      icon: const Icon(Icons.discount, color: Colors.green),
                                      onPressed: () {
                                        _showDiscountDialog(medication['id'], medication['name']);
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
            "Medication List ",
            style: TextStyle(
              fontSize: 28,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              backgroundColor: const Color(0xff414370),
            ),
          ),
          backgroundColor: const Color(0xff414370),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              color: Colors.white70,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMedicationPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff3efd9), Colors.white],  // التدرج اللوني
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                    _filterMedications();
                  },
                  decoration: InputDecoration(
                    hintText: "Search for medication",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              // Category Buttons
              // Category Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,  // تمكين التمرير الأفقي
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,  // محاذاة الأزرار للبداية
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'All';
                          });
                          fetchMedications(); // جلب الأدوية بناءً على الفئة
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCategory == 'All'
                              ? Colors.white
                              : const Color(0xff414370),
                          foregroundColor: _selectedCategory == 'All'
                              ? Colors.black
                              : Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                              color: _selectedCategory == 'All'
                                  ? const Color(0xff414370)
                                  : Colors.transparent,
                              width: 4.0,
                            ),
                          ),
                          minimumSize: Size(130, 60),
                        ),
                        child: const Text(
                          'All',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4), // مسافة صغيرة بين الأزرار
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'OTC Medication';
                          });
                          fetchOTCMedications(); // جلب الأدوية الـ OTC
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCategory == 'OTC Medication'
                              ? Colors.white
                              : const Color(0xff414370),
                          foregroundColor: _selectedCategory == 'OTC Medication'
                              ? Colors.black
                              : Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                              color: _selectedCategory == 'OTC Medication'
                                  ? const Color(0xff414370)
                                  : Colors.transparent,
                              width: 4.0,
                            ),
                          ),
                          minimumSize: Size(130, 60),
                        ),
                        child: const Text(
                          'OTC Medication',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4), // مسافة صغيرة بين الأزرار
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'Discount List';
                          });
                          fetchDiscountedMedications(); // جلب الأدوية المخفضة
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCategory == 'Discount List'
                              ? Colors.white
                              : const Color(0xff414370),
                          foregroundColor: _selectedCategory == 'Discount List'
                              ? Colors.black
                              : Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(
                              color: _selectedCategory == 'Discount List'
                                  ? const Color(0xff414370)
                                  : Colors.transparent,
                              width: 4.0,
                            ),
                          ),
                          minimumSize: Size(130, 60),
                        ),
                        child: const Text(
                          'Discount List',
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

// OTC Types (if OTC category is selected)
              if (_selectedCategory == "OTC Medication")
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: otcTypes.map((type) {
                        return Padding(
                            padding: const EdgeInsets.only(right: 8.0), // إضافة فراغ بين الكبسات
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedOtcType = type;
                            });
                            _filterMedications(); // تصفية الأدوية حسب النوع المحدد
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedOtcType == type
                                ? Colors.white
                                : const Color(0xff414370),
                            foregroundColor: _selectedOtcType == type
                                ? Colors.black
                                : Colors.white,
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 18, // حجم الخط تم زيادته هنا
                            ),
                          ),
                        ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              // Medication List
              Expanded(
                child: medications.isEmpty
                    ? Center(child: Text("No medications found."))
                    : ListView.builder(
                  itemCount: filteredMedications.length,
                  itemBuilder: (context, index) {
                    final medication = filteredMedications[index];
                    return GestureDetector(
                      onTap: () {
                        // التوجه إلى صفحة التفاصيل عند الضغط
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MedicationDetailsPage(
                              medicationId: medication['id'], // تمرير ID الدواء
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: Color(0xffd4dcee), // تغيير لون الكارد هنا

                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // عرض صورة الدواء بدلاً من الأيقونة
                              CircleAvatar(
                                radius: 35,
                                backgroundImage:
                                AssetImage(medication['pic']),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medication['name'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Medication: ${medication['medication_name']}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.yellowAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditMedicationPage(
                                            medicationId:
                                            medication['id'],
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () {
                                  _showDeleteDialog(
                                      medication['id'],
                                      medication['name']);
                                },
                              ),
                              // Discount Icon
                              IconButton(
                                icon: const Icon(Icons.discount,
                                    color: Colors.green),
                                onPressed: () {
                                  _showDiscountDialog(
                                      medication['id'],
                                      medication['name']);
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
          onTap: onTabTapped,
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


