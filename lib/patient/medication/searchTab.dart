import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'medicine.dart';
import 'cart.dart';
import 'MedicineDetailPage.dart';
import 'medicine.dart';

class SearchMedicinePage extends StatefulWidget {
  final String patientId; // Added patientId

  const SearchMedicinePage({super.key, required this.patientId}); // Receive patientId

  @override
  _SearchMedicinePageState createState() => _SearchMedicinePageState();
}

class _SearchMedicinePageState extends State<SearchMedicinePage> {
  String _searchText = "";
  String _selectedCategory = "All";
  List<Medicine> medicines = [];
  bool _isLoading = false;

  static List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    _fetchOTCMedications();
  }

  Future<void> _fetchOTCMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/healup/medication/otcmedication'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          medicines = (data['medications'] as List)
              .map((medicine) => Medicine.fromJson(medicine))
              .toList();
        });
      } else {
        throw Exception('Failed to load medications');
      }
    } catch (error) {
      print("Error fetching OTC medications: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Medicine> _filterMedicines() {
    List<Medicine> filteredList = medicines;

    if (_searchText.isNotEmpty) {
      filteredList = filteredList.where((medicine) {
        return medicine.medication_name
            .toLowerCase()
            .contains(_searchText.toLowerCase());
      }).toList();
    }

    if (_selectedCategory.isNotEmpty && _selectedCategory != "All") {
      filteredList = filteredList.where((medicine) {
        return medicine.type == _selectedCategory;
      }).toList();
    }

    return filteredList;
  }

  Future<void> _addToCart(Medicine medicine, int quantity) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // خطوة 1: تحقق مما إذا كان الدواء موجوداً في العربة
      final medicationName = medicine.medication_name;

      final getIdResponse = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/healup/cart/medication-id/$medicationName'),
      );

      if (getIdResponse.statusCode == 200) {
        // الدواء موجود في العربة، جلب cartId و quantity الحالي
        final responseJson = json.decode(getIdResponse.body);
        final cartId = responseJson['cartId'];
        final existingQuantity = responseJson['quantity'] ?? 0;

        // إضافة الكمية الجديدة إلى الكمية الحالية
        final newQuantity = existingQuantity + quantity;

        // تحديث العربة باستخدام cartId
        final updateResponse = await http.put(
          Uri.parse('http://10.0.2.2:5000/api/healup/cart/update/$cartId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'quantity': newQuantity,
          }),
        );

        if (updateResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The medicine quantity has been updated in the cart'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update medicine: ${updateResponse.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // إذا لم يكن الدواء موجودًا في العربة، قم بإضافته
        final addResponse = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/healup/cart/add'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'medication_id': medicine.id,
            'medication_name': medicine.medication_name,
            'image': medicine.image,
            'price': medicine.price,
            'quantity': quantity,
          }),
        );

        if (addResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The medicine has been successfully added to the cart'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add medicine: ${addResponse.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while adding. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _selectQuantity(Medicine medicine) {
    int _quantity = 1;  // تحديد الكمية المبدئية بـ 1

    // عرض Dialog عند الضغط على زر "Add"
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,  // تغيير لون الخلفية إلى الأبيض الصافي
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 300,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Select quantity for ${medicine.medication_name}",
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (_quantity > 1) _quantity--;
                            });
                          },
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);  // إغلاق Dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0C969C),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);  // إغلاق Dialog
                            _addToCart(medicine, _quantity);  // إضافة الدواء للعربة مع الكمية
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0C969C),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  // void _selectQuantity(Medicine medicine) {
  //   int _quantity = 1;  // تحديد الكمية المبدئية بـ 1
  //
  //   // عرض Dialog عند الضغط على زر "Add"
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white.withOpacity(0.7),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             return SizedBox(
  //               width: 300,
  //               height: 200,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     "Select quantity for ${medicine.medication_name}",
  //                     style: const TextStyle(fontSize: 18),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                   const SizedBox(height: 20),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       IconButton(
  //                         icon: const Icon(Icons.remove),
  //                         onPressed: () {
  //                           setState(() {
  //                             if (_quantity > 1) _quantity--;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         '$_quantity',
  //                         style: const TextStyle(
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.add),
  //                         onPressed: () {
  //                           setState(() {
  //                             _quantity++;
  //                           });
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 20),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       ElevatedButton(
  //                         onPressed: () {
  //                           Navigator.pop(context);  // إغلاق Dialog
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: const Color(0xff0C969C),
  //                         ),
  //                         child: const Text(
  //                           'Cancel',
  //                           style: TextStyle(color: Colors.white),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 10),
  //                       ElevatedButton(
  //                         onPressed: () {
  //                           Navigator.pop(context);  // إغلاق Dialog
  //                           _addToCart(medicine, _quantity);  // إضافة الدواء للعربة مع الكمية
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: const Color(0xff0C969C),
  //                         ),
  //                         child: const Text(
  //                           'Add to Cart',
  //                           style: TextStyle(color: Colors.white),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    List<Medicine> filteredMedicines = _filterMedicines();

    List<String> types = [
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Medicine"),
        backgroundColor: const Color(0xff6be4d7),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cart: cart,
                    patientId: widget.patientId, // Pass patientId
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/pat.jpg'),
                fit: BoxFit.cover,
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
                  },
                  decoration: InputDecoration(
                    hintText: "Search for medicine",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: types.map((type) {
                    bool isSelected = type == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = type;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : const Color(0xff2f9a8f),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xff2f9a8f), width: 2),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: filteredMedicines.length,
                  itemBuilder: (context, index) {
                    Medicine medicine = filteredMedicines[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineDetailPage(
                                medicine: medicine,
                                cart: cart, // Pass the cart here
                                patientId: widget.patientId, // Pass patientId
                              ),
                            ),
                          );
                        },
                        leading: medicine.image.isNotEmpty
                            ? Image.asset(
                          medicine.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'images/default_medicine.png',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          medicine.medication_name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "₪${medicine.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _selectQuantity(medicine),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0C969C),
                          ),
                          child: const Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
