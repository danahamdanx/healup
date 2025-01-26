import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'medicine.dart';
import 'dart:io';
import 'cart.dart';
import 'MedicineDetailPage.dart';
import 'medicine.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

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
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  @override
  void initState() {
    super.initState();
    _fetchOTCMedications();
  }
  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }

  Future<void> _fetchOTCMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/healup/medication/otcmedication'),
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
  Future<void> _scanImage({File? uploadedImage}) async {
    try {
      File imageFile;

      if (uploadedImage != null) {
        // Use the uploaded file
        imageFile = uploadedImage;
      } else {
        // Pick from gallery if no file is provided
        final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

        if (pickedFile == null) {
          throw 'No image selected';
        }

        imageFile = File(pickedFile.path);
      }

      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String extractedText = recognizedText.text;
      extractedText = extractedText.split('\n').first.trim(); // Use the first line of text






      setState(() {
        _searchText = extractedText; // Auto-fill search bar with recognized text
      });

      // Call `_filterMedicines()` to update the list of filtered medicines
      _filterMedicines();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan the image: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        Uri.parse('${getBaseUrl()}/api/healup/cart/medication-id/$medicationName'),
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
          Uri.parse('${getBaseUrl()}/api/healup/cart/update/$cartId'),
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
          Uri.parse('${getBaseUrl()}/api/healup/cart/add'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'medication_id': medicine.id,
            'medication_name': medicine.medication_name,
            'image': medicine.image,
            'final_price': medicine.final_price,
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
                            backgroundColor: const Color(0xff414370),
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
                            backgroundColor: const Color(0xff414370),
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
if(kIsWeb){
  return Scaffold(
    appBar: AppBar(
      title: const Text("Search Medicine",style: TextStyle(color: Colors.white70),),
      backgroundColor: const Color(0xff414370),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart,color: Colors.white70,),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CartPage(cart: cart, patientId: widget.patientId),
              ),
            );
          },
        ),
      ],
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
                controller: TextEditingController(text: _searchText),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search for medicine",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt,color: Color(0xff414370)),
                    onPressed: _scanImage,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                ),
              ),
            ),

            // Horizontal scrollable category filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enables horizontal scroll
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
                  color: isSelected ? Colors.white : const Color(
                      0xff414370),
                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(
                  color: const Color(0xff414370), width: 2),
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

            // Loader or grid of medicines
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 4; // More columns for large screens
                  } else if (constraints.maxWidth > 800) {
                    crossAxisCount = 3; // Middle-sized screens
                  }

                  return GridView.builder(
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      Medicine medicine = filteredMedicines[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineDetailPage(
                                medicine: medicine,
                                cart: cart,
                                patientId: widget.patientId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color:  Color(0xffb8e1f1), // Set the card's background color
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: medicine.image.isNotEmpty
                                      ? Image.asset(
                                    medicine.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                      : Image.asset(
                                    'images/default_medicine.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                medicine.medication_name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                "₪${medicine.final_price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff800020),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              ElevatedButton(
                                onPressed: () => _selectQuantity(medicine),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff414370),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                ),
                                child: const Text(
                                  "Add",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
  else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Search Medicine",style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xff414370),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart,color: Colors.white70,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CartPage(
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
                    controller: TextEditingController(text: _searchText),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search for medicine",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.camera_alt,color: Color(0xff414370)),
                        onPressed: _scanImage,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),

                // Category filter bar
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
                            color: isSelected ? Colors.white : const Color(
                                0xff414370),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xff414370), width: 2),
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
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Adjust the number of columns
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.75, // Adjust the aspect ratio
                    ),
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      Medicine medicine = filteredMedicines[index];
                      return GestureDetector(
                        onTap: () {
                          // الانتقال إلى صفحة تفاصيل الدواء عند الضغط على الصورة أو الاسم
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MedicineDetailPage(
                                    medicine: medicine,
                                    cart: cart, // Pass the cart here
                                    patientId: widget
                                        .patientId, // Pass patientId
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color:  Color(0xffb8e1f1), // Set the card's background color
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: medicine.image.isNotEmpty
                                      ? Image.asset(
                                    medicine.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                      : Image.asset(
                                    'images/default_medicine.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                medicine.medication_name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff414370),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                "₪${medicine.final_price.toStringAsFixed(2)}",
                                // عرض final_price بدلاً من price

                                //"₪${medicine.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff800020),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              ElevatedButton(
                                onPressed: () => _selectQuantity(medicine),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff414370),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                ),
                                child: const Text(
                                  "Add",
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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
}
