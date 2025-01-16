import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'medicationList.dart';

class AddMedicationPage extends StatefulWidget {
  @override
  _AddMedicationPageState createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _scientificNameController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountPercentageController = TextEditingController();

  // Image Picker
  File? _imageFile;
  String? _imageName;
  final ImagePicker _picker = ImagePicker();

  Future<void> _addMedication() async {
    // التأكد من أن جميع الحقول المطلوبة مملوءة
    if (_medicationNameController.text.isEmpty ||
        _scientificNameController.text.isEmpty ||
        _stockQuantityController.text.isEmpty ||
        _expirationDateController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the required fields')),
      );
      return;
    }

    // إزالة المسافات غير المرئية من الحقول
    String medicationName = _medicationNameController.text.trim();
    String scientificName = _scientificNameController.text.trim();
    String stockQuantity = _stockQuantityController.text.trim();
    String expirationDate = _expirationDateController.text.trim();
    String type = _typeController.text.trim();
    String price = _priceController.text.trim();

    // التحقق من تنسيق تاريخ الانتهاء (YYYY-MM-DD)
    if (expirationDate.isEmpty || expirationDate.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid expiration date (YYYY-MM-DD)')),
      );
      return;
    }

    // التحقق من أن السعر وكمية المخزون أرقام صحيحة
    if (int.tryParse(stockQuantity) == null || double.tryParse(price) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide valid numeric values for stock quantity and price')),
      );
      return;
    }

    // إضافة نسبة الخصم إذا كانت موجودة
    String discountPercentage = _discountPercentageController.text.trim();
    if (discountPercentage.isNotEmpty && double.tryParse(discountPercentage) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a valid numeric value for discount percentage')),
      );
      return;
    }

    // عرض الحقول المرسلة (سجلات)
    print('Medication Name: $medicationName');
    print('Scientific Name: $scientificName');
    print('Stock Quantity: $stockQuantity');
    print('Expiration Date: $expirationDate');
    print('Type: $type');
    print('Price: $price');
    print('Discount Percentage: $discountPercentage');

    final url = 'http://10.0.2.2:5000/api/healup/medication/add';
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['medication_name'] = medicationName;
    request.fields['scientific_name'] = scientificName;
    request.fields['stock_quantity'] = stockQuantity;
    request.fields['expiration_date'] = expirationDate;
    request.fields['type'] = type;
    request.fields['price'] = price;

    if (discountPercentage.isNotEmpty) {
      request.fields['discount_percentage'] = discountPercentage;
    }

// أضف الصورة بشكل صحيح إذا كانت موجودة
    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      request.fields['image'] = "data:image/png;base64,$base64Image";  // إضافة الصورة المحولة إلى Base64
      request.fields['image_name'] = _imageName ?? 'image.png';  // اسم الصورة
    }


    try {
      final sendResponse = await request.send();

      if (sendResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication added successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MedicationListPage()),
        );
      } else {
        // التعامل مع الاستجابة في حالة الفشل
        final responseBody = await sendResponse.stream.bytesToString();
        print("Failed to add medication: $responseBody");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add medication: $responseBody')),
        );
      }
    } catch (error) {
      // التعامل مع الأخطاء
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $error')),
      );
    }
  }




  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    // Check if the widget is still mounted before calling setState
    if (pickedFile != null && mounted) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageName = pickedFile.name;
      });
      // Print the image name
      print(_imageName);
    }
  }


  @override
  void dispose() {
    _medicationNameController.dispose();
    _scientificNameController.dispose();
    _stockQuantityController.dispose();
    _expirationDateController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _discountPercentageController.dispose();  // إضافة هنا
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Medication",
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Image Selection (Circle Avatar with Camera Icon)
              GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      child: _imageFile == null
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.black)
                          : ClipOval(child: Image.file(_imageFile!, fit: BoxFit.cover)),
                    ),
                    SizedBox(height: 8),
                    if (_imageName != null) Text(_imageName!, style: TextStyle(fontSize: 16, color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Medication Name
              _buildTextField(
                controller: _medicationNameController,
                label: 'Medication Name',
                icon: Icons.medication,
                validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
              ),
              // Scientific Name
              _buildTextField(
                controller: _scientificNameController,
                label: 'Scientific Name',
                icon: Icons.science,
                validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
              ),
              // Stock Quantity
              _buildTextField(
                controller: _stockQuantityController,
                label: 'Stock Quantity',
                icon: Icons.numbers,
                validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
                keyboardType: TextInputType.number,
              ),
              // Expiration Date
              _buildTextField(
                controller: _expirationDateController,
                label: 'Expiration Date',
                icon: Icons.calendar_today,
                validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
              ),
              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                validator: (value) => value!.isEmpty ? 'Please enter description' : null,
              ),
              // Type
              _buildTextField(
                controller: _typeController,
                label: 'Type',
                icon: Icons.category,
                validator: (value) => value!.isEmpty ? 'Please enter type' : null,
              ),
              // Price
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.monetization_on,
                validator: (value) => value!.isEmpty ? 'Please enter price' : null,
                keyboardType: TextInputType.number,
              ),
              // حقل نسبة العرض (اختياري)
              _buildTextField(
                controller: _discountPercentageController,
                label: 'Discount Percentage (Optional)',
                icon: Icons.percent,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final double? percentage = double.tryParse(value);
                    if (percentage == null || percentage < 0 || percentage > 100) {
                      return 'Please enter a valid percentage between 0 and 100';
                    }
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              // Add Medication Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addMedication();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2f9a8f),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Add Medication',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom text field builder with icon and validation
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87),
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 2),
          ),
        ),
        style: TextStyle(color: Colors.black, fontSize: 18),
        validator: validator,
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'medicationList.dart';
//
// class AddMedicationPage extends StatefulWidget {
//   @override
//   _AddMedicationPageState createState() => _AddMedicationPageState();
// }
//
// class _AddMedicationPageState extends State<AddMedicationPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Controllers
//   final TextEditingController _medicationNameController = TextEditingController();
//   final TextEditingController _scientificNameController = TextEditingController();
//   final TextEditingController _stockQuantityController = TextEditingController();
//   final TextEditingController _expirationDateController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//
//   // Image Picker
//   File? _imageFile;
//   final ImagePicker _picker = ImagePicker();
//
//   // Add Medication function
//   Future<void> _addMedication() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/add';
//     final request = http.MultipartRequest('POST', Uri.parse(url));
//
//     if (_imageFile != null) {
//       request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
//     }
//
//     request.fields['medication_name'] = _medicationNameController.text;
//     request.fields['scientific_name'] = _scientificNameController.text;
//     request.fields['stock_quantity'] = _stockQuantityController.text;
//     request.fields['expiration_date'] = _expirationDateController.text;
//     request.fields['description'] = _descriptionController.text;
//     request.fields['type'] = _typeController.text;
//     request.fields['price'] = _priceController.text;
//
//     final response = await request.send();
//
//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Medication added successfully')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MedicationListPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add medication')),
//       );
//     }
//   }
//
//   // Function to pick an image from the gallery
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.getImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Add New Medication",
//           style: TextStyle(fontSize: 24),
//         ),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               // Medication Name
//               _buildTextField(
//                 controller: _medicationNameController,
//                 label: 'Medication Name',
//                 icon: Icons.medication,
//                 validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
//               ),
//               // Scientific Name
//               _buildTextField(
//                 controller: _scientificNameController,
//                 label: 'Scientific Name',
//                 icon: Icons.science,
//                 validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
//               ),
//               // Stock Quantity
//               _buildTextField(
//                 controller: _stockQuantityController,
//                 label: 'Stock Quantity',
//                 icon: Icons.numbers,
//                 validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
//                 keyboardType: TextInputType.number,
//               ),
//               // Expiration Date
//               _buildTextField(
//                 controller: _expirationDateController,
//                 label: 'Expiration Date',
//                 icon: Icons.calendar_today,
//                 validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
//               ),
//               // Description
//               _buildTextField(
//                 controller: _descriptionController,
//                 label: 'Description',
//                 icon: Icons.description,
//                 validator: (value) => value!.isEmpty ? 'Please enter description' : null,
//               ),
//               // Type
//               _buildTextField(
//                 controller: _typeController,
//                 label: 'Type',
//                 icon: Icons.category,
//                 validator: (value) => value!.isEmpty ? 'Please enter type' : null,
//               ),
//               // Price
//               _buildTextField(
//                 controller: _priceController,
//                 label: 'Price',
//                 icon: Icons.monetization_on,
//                 validator: (value) => value!.isEmpty ? 'Please enter price' : null,
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: 20),
//               // Select Image Button
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f),
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Select Image from Gallery',
//                   style: TextStyle(color: Colors.black, fontSize: 16),
//                 ),
//               ),
//               // Show selected image
//               if (_imageFile != null)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10),
//                   child: Image.file(_imageFile!),
//                 ),
//               // Add Medication Button
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _addMedication();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f),
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Add Medication',
//                   style: TextStyle(color: Colors.black, fontSize: 20),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Custom text field builder with icon and validation
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.black87),
//           labelText: label,
//           labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black87, width: 1),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.black87, width: 2),
//           ),
//         ),
//         style: TextStyle(color: Colors.black, fontSize: 18),
//         validator: validator,
//       ),
//     );
//   }
// }


// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'medicationList.dart';
//
// // صفحة إضافة الدواء
// class AddMedicationPage extends StatefulWidget {
//   @override
//   _AddMedicationPageState createState() => _AddMedicationPageState();
// }
//
// class _AddMedicationPageState extends State<AddMedicationPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _medicationNameController = TextEditingController();
//   final TextEditingController _scientificNameController = TextEditingController();
//   final TextEditingController _stockQuantityController = TextEditingController();
//   final TextEditingController _expirationDateController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _typeController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _imageNameController = TextEditingController();
//
//   // إعداد صورة الدواء
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//
//   // اختيار الصورة من المعرض
//   Future<void> _pickImage() async {
//     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//         _imageNameController.text = pickedFile.name; // تعيين اسم الصورة
//       });
//     }
//   }
//
//   Future<void> _addMedication() async {
//     // التحقق من صحة المدخلات
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL API الخاصة بك
//     var request = http.MultipartRequest('POST', Uri.parse(url));
//
//     // إضافة البيانات النصية
//     request.fields['medication_name'] = _medicationNameController.text;
//     request.fields['scientific_name'] = _scientificNameController.text;
//     request.fields['stock_quantity'] = _stockQuantityController.text;
//     request.fields['expiration_date'] = _expirationDateController.text;
//     request.fields['description'] = _descriptionController.text;
//     request.fields['type'] = _typeController.text;
//     request.fields['price'] = _priceController.text;
//
//     // إضافة الصورة إذا كانت موجودة
//     if (_image != null) {
//       final bytes = await _image!.readAsBytes();
//       String base64Image = base64Encode(bytes);
//       print('Base64 image: $base64Image'); // أضف هذا السطر للتحقق من الصورة
//       request.fields['pic'] = 'data:image/png;base64,' + base64Image;
//     }
//
//     // إرسال الطلب
//     var response = await request.send();
//
//     // التحقق من حالة الاستجابة
//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('تم إضافة الدواء بنجاح')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MedicationListPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('فشل في إضافة الدواء')),
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("إضافة دواء"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: _medicationNameController,
//                   decoration: InputDecoration(labelText: 'اسم الدواء'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال اسم الدواء';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _scientificNameController,
//                   decoration: InputDecoration(labelText: 'الاسم العلمي'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال الاسم العلمي';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _stockQuantityController,
//                   decoration: InputDecoration(labelText: 'الكمية في المخزن'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال الكمية';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _expirationDateController,
//                   decoration: InputDecoration(labelText: 'تاريخ انتهاء الصلاحية'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال تاريخ انتهاء الصلاحية';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(labelText: 'الوصف'),
//                 ),
//                 TextFormField(
//                   controller: _typeController,
//                   decoration: InputDecoration(labelText: 'النوع'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال النوع';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _priceController,
//                   decoration: InputDecoration(labelText: 'السعر'),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'يرجى إدخال السعر';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: Container(
//                     color: Colors.grey[200],
//                     width: double.infinity,
//                     height: 150,
//                     child: _image == null
//                         ? Center(child: Text('اضغط لاختيار الصورة'))
//                         : Image.file(_image!, fit: BoxFit.cover),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _addMedication,
//                   child: Text('إضافة الدواء'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import 'medicationList.dart';
// // // Add Medication Page
// // class AddMedicationPage extends StatefulWidget {
// //   @override
// //   _AddMedicationPageState createState() => _AddMedicationPageState();
// // }
// //
// // class _AddMedicationPageState extends State<AddMedicationPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final TextEditingController _medicationNameController = TextEditingController();
// //   final TextEditingController _scientificNameController = TextEditingController();
// //   final TextEditingController _stockQuantityController = TextEditingController();
// //   final TextEditingController _expirationDateController = TextEditingController();
// //   final TextEditingController _descriptionController = TextEditingController();
// //   final TextEditingController _typeController = TextEditingController();
// //   final TextEditingController _priceController = TextEditingController();
// //   final TextEditingController _imageNameController = TextEditingController();
// //
// //   // Image picker setup
// //   File? _image;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   // Pick image from gallery
// //   Future<void> _pickImage() async {
// //     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _image = File(pickedFile.path);
// //         _imageNameController.text = pickedFile.name; // Set the image name in the text field
// //       });
// //     }
// //   }
// //
// //   // Convert image to base64 string
// //   Future<String?> _getImageBase64() async {
// //     if (_image == null) return null;
// //     final bytes = await _image!.readAsBytes();
// //     return base64Encode(bytes);
// //   }
// //
// //   Future<void> _addMedication() async {
// //     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL API الخاصة بك
// //     var request = http.MultipartRequest('POST', Uri.parse(url));
// //
// //     // Add text fields
// //     request.fields['medication_name'] = _medicationNameController.text;
// //     request.fields['scientific_name'] = _scientificNameController.text;
// //     request.fields['stock_quantity'] = _stockQuantityController.text;
// //     request.fields['expiration_date'] = _expirationDateController.text;
// //     request.fields['description'] = _descriptionController.text;
// //     request.fields['type'] = _typeController.text;
// //     request.fields['price'] = _priceController.text;
// //
// //     // Add image if available and convert to base64
// //     if (_image != null) {
// //       // Read image as bytes
// //       final bytes = await _image!.readAsBytes();
// //       String base64Image = base64Encode(bytes);
// //       request.fields['pic'] = 'data:image/png;base64,' + base64Image;
// //     }
// //
// //     // Send the request
// //     var response = await request.send();
// //
// //     if (response.statusCode == 201) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Medication added successfully')),
// //       );
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => MedicationListPage()),
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to add medication')),
// //       );
// //     }
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("Add Medication"),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             children: [
// //               TextField(
// //                 controller: _medicationNameController,
// //                 decoration: InputDecoration(labelText: 'Medication Name'),
// //               ),
// //               TextField(
// //                 controller: _scientificNameController,
// //                 decoration: InputDecoration(labelText: 'Scientific Name'),
// //               ),
// //               TextField(
// //                 controller: _stockQuantityController,
// //                 decoration: InputDecoration(labelText: 'Stock Quantity'),
// //                 keyboardType: TextInputType.number,
// //               ),
// //               TextField(
// //                 controller: _expirationDateController,
// //                 decoration: InputDecoration(labelText: 'Expiration Date'),
// //               ),
// //               TextField(
// //                 controller: _descriptionController,
// //                 decoration: InputDecoration(labelText: 'Description'),
// //               ),
// //               TextField(
// //                 controller: _typeController,
// //                 decoration: InputDecoration(labelText: 'Type'),
// //               ),
// //               TextField(
// //                 controller: _priceController,
// //                 decoration: InputDecoration(labelText: 'Price'),
// //                 keyboardType: TextInputType.number,
// //               ),
// //               SizedBox(height: 16),
// //               GestureDetector(
// //                 onTap: _pickImage,
// //                 child: Container(
// //                   color: Colors.grey[200],
// //                   width: double.infinity,
// //                   height: 150,
// //                   child: _image == null
// //                       ? Center(child: Text('Tap to select image'))
// //                       : Image.file(_image!, fit: BoxFit.cover),
// //                 ),
// //               ),
// //               SizedBox(height: 16),
// //               ElevatedButton(
// //                 onPressed: _addMedication,
// //                 child: Text('Add Medication'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import 'dart:io';
// // import 'medicationList.dart'; // تأكد من أنك تمتلك صفحة لعرض قائمة الأدوية
// //
// // class AddMedicationPage extends StatefulWidget {
// //   @override
// //   _AddMedicationPageState createState() => _AddMedicationPageState();
// // }
// //
// // class _AddMedicationPageState extends State<AddMedicationPage> {
// //   final _formKey = GlobalKey<FormState>();
// //
// //   // Controllers
// //   final TextEditingController _medicationNameController = TextEditingController();
// //   final TextEditingController _scientificNameController = TextEditingController();
// //   final TextEditingController _stockQuantityController = TextEditingController();
// //   final TextEditingController _expirationDateController = TextEditingController();
// //   final TextEditingController _descriptionController = TextEditingController();
// //   final TextEditingController _typeController = TextEditingController();
// //   final TextEditingController _priceController = TextEditingController();
// //   final TextEditingController _imageNameController = TextEditingController();
// //
// //   // Image picker setup
// //   File? _image;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   // Pick image from gallery
// //   Future<void> _pickImage() async {
// //     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _image = File(pickedFile.path);
// //         _imageNameController.text = pickedFile.name; // Set the image name in the text field
// //       });
// //     }
// //   }
// //
// //   // Add Medication function
// //   Future<void> _addMedication() async {
// //     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL API الخاصة بك
// //     var request = http.MultipartRequest('POST', Uri.parse(url));
// //
// //     // Add text fields
// //     request.fields['medication_name'] = _medicationNameController.text;
// //     request.fields['scientific_name'] = _scientificNameController.text;
// //     request.fields['stock_quantity'] = _stockQuantityController.text;
// //     request.fields['expiration_date'] = _expirationDateController.text;
// //     request.fields['description'] = _descriptionController.text;
// //     request.fields['type'] = _typeController.text;
// //     request.fields['price'] = _priceController.text;
// //
// //     // Add image if available
// //     if (_image != null) {
// //       var pic = await http.MultipartFile.fromPath('pic', _image!.path);
// //       request.files.add(pic);
// //     }
// //
// //     // Send the request
// //     var response = await request.send();
// //
// //     if (response.statusCode == 201) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Medication added successfully')),
// //       );
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => MedicationListPage()),
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to add medication')),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           "Add New Medication",
// //           style: TextStyle(
// //             fontSize: 24,
// //           ),
// //         ),
// //         backgroundColor: const Color(0xff2f9a8f),
// //       ),
// //       body: Container(
// //         decoration: BoxDecoration(
// //           image: DecorationImage(
// //             image: AssetImage('images/pat.jpg'),
// //             fit: BoxFit.cover,
// //             colorFilter: ColorFilter.mode(
// //               Colors.black.withOpacity(0.3),
// //               BlendMode.darken,
// //             ),
// //           ),
// //         ),
// //         padding: const EdgeInsets.all(16.0),
// //         child: Form(
// //           key: _formKey,
// //           child: ListView(
// //             children: [
// //               // Circle Avatar for image upload
// //               GestureDetector(
// //                 onTap: _pickImage,
// //                 child: CircleAvatar(
// //                   radius: 80,
// //                   backgroundColor: Colors.blueAccent,
// //                   backgroundImage: _image != null ? FileImage(_image!) : null,
// //                   child: _image == null
// //                       ? Icon(
// //                     Icons.camera_alt,
// //                     size: 50,
// //                     color: Colors.white,
// //                   )
// //                       : null,
// //                 ),
// //               ),
// //               SizedBox(height: 20),
// //
// //               // Field for Medication Name
// //               _buildTextField(
// //                 controller: _medicationNameController,
// //                 label: 'Medication Name',
// //                 icon: Icons.medication,
// //                 validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
// //               ),
// //               // Field for Scientific Name
// //               _buildTextField(
// //                 controller: _scientificNameController,
// //                 label: 'Scientific Name',
// //                 icon: Icons.science,
// //                 validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
// //               ),
// //               // Field for Stock Quantity
// //               _buildTextField(
// //                 controller: _stockQuantityController,
// //                 label: 'Stock Quantity',
// //                 icon: Icons.storage,
// //                 validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
// //                 keyboardType: TextInputType.number,
// //               ),
// //               // Field for Expiration Date
// //               _buildTextField(
// //                 controller: _expirationDateController,
// //                 label: 'Expiration Date',
// //                 icon: Icons.date_range,
// //                 validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
// //               ),
// //               // Field for Description
// //               _buildTextField(
// //                 controller: _descriptionController,
// //                 label: 'Description',
// //                 icon: Icons.description,
// //                 validator: (value) => value!.isEmpty ? 'Please enter description' : null,
// //               ),
// //               // Field for Type
// //               _buildTextField(
// //                 controller: _typeController,
// //                 label: 'Type',
// //                 icon: Icons.category,
// //                 validator: (value) => value!.isEmpty ? 'Please enter type' : null,
// //               ),
// //               // Field for Price
// //               _buildTextField(
// //                 controller: _priceController,
// //                 label: 'Price',
// //                 icon: Icons.monetization_on,
// //                 validator: (value) => value!.isEmpty ? 'Please enter price' : null,
// //                 keyboardType: TextInputType.numberWithOptions(decimal: true),
// //               ),
// //               SizedBox(height: 20),
// //
// //               // Add Medication Button
// //               ElevatedButton(
// //                 onPressed: () {
// //                   if (_formKey.currentState!.validate()) {
// //                     _addMedication();
// //                   }
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xff2f9a8f),
// //                   padding: EdgeInsets.symmetric(vertical: 15),
// //                 ),
// //                 child: Text(
// //                   'Add Medication',
// //                   style: TextStyle(color: Colors.black, fontSize: 20),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Helper method to build text fields
// //   Widget _buildTextField({
// //     required TextEditingController controller,
// //     required String label,
// //     required IconData icon,
// //     bool obscureText = false,
// //     TextInputType keyboardType = TextInputType.text,
// //     String? Function(String?)? validator,
// //     bool enabled = true, // Added to enable/disable the text field
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 10.0),
// //       child: TextFormField(
// //         controller: controller,
// //         obscureText: obscureText,
// //         keyboardType: keyboardType,
// //         enabled: enabled, // Control the text field's enabled state
// //         decoration: InputDecoration(
// //           prefixIcon: Icon(icon, color: Colors.black87),
// //           labelText: label,
// //           labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
// //           focusedBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Colors.black87, width: 1),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Colors.black87, width: 2),
// //           ),
// //         ),
// //         style: TextStyle(color: Colors.black, fontSize: 18),
// //         validator: validator,
// //       ),
// //     );
// //   }
// // }
//
//
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import 'dart:io';
// // import 'medicationList.dart'; // Make sure you have a page for displaying the medication list
// //
// // class AddMedicationPage extends StatefulWidget {
// //   @override
// //   _AddMedicationPageState createState() => _AddMedicationPageState();
// // }
// //
// // class _AddMedicationPageState extends State<AddMedicationPage> {
// //   final _formKey = GlobalKey<FormState>();
// //
// //   // Controllers
// //   final TextEditingController _medicationNameController = TextEditingController();
// //   final TextEditingController _scientificNameController = TextEditingController();
// //   final TextEditingController _stockQuantityController = TextEditingController();
// //   final TextEditingController _expirationDateController = TextEditingController();
// //   final TextEditingController _descriptionController = TextEditingController();
// //   final TextEditingController _typeController = TextEditingController();
// //   final TextEditingController _priceController = TextEditingController();
// //   final TextEditingController _imageNameController = TextEditingController(); // New TextEditingController for the image name
// //
// //   // Image picker setup
// //   File? _image;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   // Pick image from gallery
// //   Future<void> _pickImage() async {
// //     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _image = File(pickedFile.path);
// //         _imageNameController.text = pickedFile.name; // Set the image name in the text field
// //       });
// //     }
// //   }
// //
// //   // Add Medication function
// //   Future<void> _addMedication() async {
// //     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL الـ API
// //     var request = http.MultipartRequest('POST', Uri.parse(url));
// //
// //     // Add text fields
// //     request.fields['medication_name'] = _medicationNameController.text;
// //     request.fields['scientific_name'] = _scientificNameController.text;
// //     request.fields['stock_quantity'] = _stockQuantityController.text;
// //     request.fields['expiration_date'] = _expirationDateController.text;
// //     request.fields['description'] = _descriptionController.text;
// //     request.fields['type'] = _typeController.text;
// //     request.fields['price'] = _priceController.text;
// //     request.fields['image_name'] = _imageNameController.text; // Send the image name
// //
// //     // Add image if available
// //     if (_image != null) {
// //       var pic = await http.MultipartFile.fromPath('image', _image!.path);
// //       request.files.add(pic);
// //     }
// //
// //     // Send the request
// //     var response = await request.send();
// //
// //     if (response.statusCode == 201) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Medication added successfully')),
// //       );
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => MedicationListPage()),
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to add medication')),
// //       );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           "Add New Medication",
// //           style: TextStyle(
// //             fontSize: 24,
// //           ),
// //         ),
// //         backgroundColor: const Color(0xff2f9a8f),
// //       ),
// //       body: Container(
// //         decoration: BoxDecoration(
// //           image: DecorationImage(
// //             image: AssetImage('images/pat.jpg'),
// //             fit: BoxFit.cover,
// //             colorFilter: ColorFilter.mode(
// //               Colors.black.withOpacity(0.3),
// //               BlendMode.darken,
// //             ),
// //           ),
// //         ),
// //         padding: const EdgeInsets.all(16.0),
// //         child: Form(
// //           key: _formKey,
// //           child: ListView(
// //             children: [
// //               _buildTextField(
// //                 controller: _medicationNameController,
// //                 label: 'Medication Name',
// //                 icon: Icons.medication,
// //                 validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _scientificNameController,
// //                 label: 'Scientific Name',
// //                 icon: Icons.science,
// //                 validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _stockQuantityController,
// //                 label: 'Stock Quantity',
// //                 icon: Icons.storage,
// //                 validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
// //                 keyboardType: TextInputType.number,
// //               ),
// //               _buildTextField(
// //                 controller: _expirationDateController,
// //                 label: 'Expiration Date',
// //                 icon: Icons.date_range,
// //                 validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _descriptionController,
// //                 label: 'Description',
// //                 icon: Icons.description,
// //                 validator: (value) => value!.isEmpty ? 'Please enter description' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _typeController,
// //                 label: 'Type',
// //                 icon: Icons.category,
// //                 validator: (value) => value!.isEmpty ? 'Please enter type' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _priceController,
// //                 label: 'Price',
// //                 icon: Icons.monetization_on,
// //                 validator: (value) => value!.isEmpty ? 'Please enter price' : null,
// //                 keyboardType: TextInputType.numberWithOptions(decimal: true),
// //               ),
// //
// //               // New TextField for image name
// //               _buildTextField(
// //                 controller: _imageNameController,
// //                 label: 'Image Name',
// //                 icon: Icons.image,
// //                 validator: (value) => value!.isEmpty ? 'Please upload an image first' : null,
// //                 enabled: false, // Disable the text field to prevent editing
// //               ),
// //
// //               SizedBox(height: 20),
// //
// //               // Upload image button
// //               ElevatedButton(
// //                 onPressed: _pickImage,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blueAccent,
// //                   padding: EdgeInsets.symmetric(vertical: 15),
// //                 ),
// //                 child: Text(
// //                   'Upload Image',
// //                   style: TextStyle(color: Colors.white, fontSize: 20),
// //                 ),
// //               ),
// //
// //               SizedBox(height: 20),
// //
// //               // Add Medication button
// //               ElevatedButton(
// //                 onPressed: () {
// //                   if (_formKey.currentState!.validate()) {
// //                     _addMedication();
// //                   }
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xff2f9a8f),
// //                   padding: EdgeInsets.symmetric(vertical: 15),
// //                 ),
// //                 child: Text(
// //                   'Add Medication',
// //                   style: TextStyle(color: Colors.black, fontSize: 20),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTextField({
// //     required TextEditingController controller,
// //     required String label,
// //     required IconData icon,
// //     bool obscureText = false,
// //     TextInputType keyboardType = TextInputType.text,
// //     String? Function(String?)? validator,
// //     bool enabled = true, // Added to enable/disable the text field
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 10.0),
// //       child: TextFormField(
// //         controller: controller,
// //         obscureText: obscureText,
// //         keyboardType: keyboardType,
// //         enabled: enabled, // Control the text field's enabled state
// //         decoration: InputDecoration(
// //           prefixIcon: Icon(icon, color: Colors.black87),
// //           labelText: label,
// //           labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
// //           focusedBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Colors.black87, width: 1),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Colors.black87, width: 2),
// //           ),
// //         ),
// //         style: TextStyle(color: Colors.black, fontSize: 18),
// //         validator: validator,
// //       ),
// //     );
// //   }
// // }
//
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:image_picker/image_picker.dart';
// // import 'dart:io';
// // import 'medicationList.dart'; // Make sure you have a page for displaying the medication list
// // //
// // class AddMedicationPage extends StatefulWidget {
// //   @override
// //   _AddMedicationPageState createState() => _AddMedicationPageState();
// // }
// //
// // class _AddMedicationPageState extends State<AddMedicationPage> {
// //   final _formKey = GlobalKey<FormState>();
// //
// //   // Controllers
// //   final TextEditingController _medicationNameController = TextEditingController();
// //   final TextEditingController _scientificNameController = TextEditingController();
// //   final TextEditingController _stockQuantityController = TextEditingController();
// //   final TextEditingController _expirationDateController = TextEditingController();
// //   final TextEditingController _descriptionController = TextEditingController();
// //   final TextEditingController _typeController = TextEditingController();
// //   final TextEditingController _priceController = TextEditingController();
// //
// //   // Image picker setup
// //   File? _image;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   // Pick image from gallery
// //   Future<void> _pickImage() async {
// //     final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _image = File(pickedFile.path);
// //       });
// //     }
// //   }
// //   Future<void> _addMedication() async {
// //     final url = 'http://10.0.2.2:5000/api/healup/medication/add'; // URL الـ API
// //     var request = http.MultipartRequest('POST', Uri.parse(url));
// //
// //     // إضافة الحقول النصية
// //     request.fields['medication_name'] = _medicationNameController.text;
// //     request.fields['scientific_name'] = _scientificNameController.text;
// //     request.fields['stock_quantity'] = _stockQuantityController.text;
// //     request.fields['expiration_date'] = _expirationDateController.text;
// //     request.fields['description'] = _descriptionController.text;
// //     request.fields['type'] = _typeController.text;
// //     request.fields['price'] = _priceController.text;
// //
// //     // إضافة الصورة إذا كانت موجودة
// //     if (_image != null) {
// //       var pic = await http.MultipartFile.fromPath('image', _image!.path);
// //       request.files.add(pic);
// //     }
// //
// //     // إرسال الطلب
// //     var response = await request.send();
// //
// //     if (response.statusCode == 201) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Medication added successfully')),
// //       );
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => MedicationListPage()),
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to add medication')),
// //       );
// //     }
// //   }
// //
// //   // Add Medication function
// //   // Future<void> _addMedication() async {
// //   //   final url = 'http://10.0.2.2:5000/api/healup/medication/add';
// //   //   var request = http.MultipartRequest('POST', Uri.parse(url));
// //   //
// //   //   // Add text fields
// //   //   request.fields['medication_name'] = _medicationNameController.text;
// //   //   request.fields['scientific_name'] = _scientificNameController.text;
// //   //   request.fields['stock_quantity'] = _stockQuantityController.text;
// //   //   request.fields['expiration_date'] = _expirationDateController.text;
// //   //   request.fields['description'] = _descriptionController.text;
// //   //   request.fields['type'] = _typeController.text;
// //   //   request.fields['price'] = _priceController.text;
// //   //
// //   //   // Add image if available
// //   //   if (_image != null) {
// //   //     var pic = await http.MultipartFile.fromPath('image', _image!.path);
// //   //     request.files.add(pic);
// //   //   }
// //   //
// //   //   var response = await request.send();
// //   //
// //   //   if (response.statusCode == 201) {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       SnackBar(content: Text('Medication added successfully')),
// //   //     );
// //   //     Navigator.pushReplacement(
// //   //       context,
// //   //       MaterialPageRoute(builder: (context) => MedicationListPage()),
// //   //     );
// //   //   } else {
// //   //     ScaffoldMessenger.of(context).showSnackBar(
// //   //       SnackBar(content: Text('Failed to add medication')),
// //   //     );
// //   //   }
// //   // }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     print("========================================");
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text(
// //           "Add New Medication",
// //           style: TextStyle(
// //             fontSize: 24,
// //           ),
// //         ),
// //         backgroundColor: const Color(0xff2f9a8f),
// //       ),
// //       body: Container(
// //         decoration: BoxDecoration(
// //           image: DecorationImage(
// //             image: AssetImage('images/pat.jpg'),
// //
// //             //image: AssetImage('images/back.jpg'),
// //             fit: BoxFit.cover,
// //             colorFilter: ColorFilter.mode(
// //               Colors.black.withOpacity(0.3),
// //               BlendMode.darken,
// //             ),
// //           ),
// //         ),
// //         padding: const EdgeInsets.all(16.0),
// //         child: Form(
// //           key: _formKey,
// //           child: ListView(
// //             children: [
// //               _buildTextField(
// //                 controller: _medicationNameController,
// //                 label: 'Medication Name',
// //                 icon: Icons.medication,
// //                 validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _scientificNameController,
// //                 label: 'Scientific Name',
// //                 icon: Icons.science,
// //                 validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _stockQuantityController,
// //                 label: 'Stock Quantity',
// //                 icon: Icons.storage,
// //                 validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
// //                 keyboardType: TextInputType.number,
// //               ),
// //               _buildTextField(
// //                 controller: _expirationDateController,
// //                 label: 'Expiration Date',
// //                 icon: Icons.date_range,
// //                 validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _descriptionController,
// //                 label: 'Description',
// //                 icon: Icons.description,
// //                 validator: (value) => value!.isEmpty ? 'Please enter description' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _typeController,
// //                 label: 'Type',
// //                 icon: Icons.category,
// //                 validator: (value) => value!.isEmpty ? 'Please enter type' : null,
// //               ),
// //               _buildTextField(
// //                 controller: _priceController,
// //                 label: 'Price',
// //                 icon: Icons.monetization_on,
// //                 validator: (value) => value!.isEmpty ? 'Please enter price' : null,
// //                 keyboardType: TextInputType.numberWithOptions(decimal: true),
// //               ),
// //               SizedBox(height: 20),
// //
// //               // Upload image button
// //               ElevatedButton(
// //                 onPressed: _pickImage,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blueAccent,
// //                   padding: EdgeInsets.symmetric(vertical: 15),
// //                 ),
// //                 child: Text(
// //                   'Upload Image',
// //                   style: TextStyle(color: Colors.white, fontSize: 20),
// //                 ),
// //               ),
// //
// //               SizedBox(height: 20),
// //
// //               // Add Medication button
// //               ElevatedButton(
// //                 onPressed: () {
// //                   if (_formKey.currentState!.validate()) {
// //                     _addMedication();
// //                   }
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xff2f9a8f),
// //                   padding: EdgeInsets.symmetric(vertical: 15),
// //                 ),
// //                 child: Text(
// //                   'Add Medication',
// //                   style: TextStyle(color: Colors.black, fontSize: 20),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTextField({
// //     required TextEditingController controller,
// //     required String label,
// //     required IconData icon,
// //     bool obscureText = false,
// //     TextInputType keyboardType = TextInputType.text,
// //     String? Function(String?)? validator,
// //   }) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 10.0),
// //       child: TextFormField(
// //         controller: controller,
// //         obscureText: obscureText,
// //         keyboardType: keyboardType,
// //         decoration: InputDecoration(
// //           prefixIcon: Icon(icon, color: Colors.black87),
// //           labelText: label,
// //           labelStyle: TextStyle(color: Colors.black87, fontSize: 18),
// //           focusedBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Colors.black87, width: 1),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Colors.black87, width: 2),
// //           ),
// //         ),
// //         style: TextStyle(color: Colors.black, fontSize: 18),
// //         validator: validator,
// //       ),
// //     );
// //   }
// // }
