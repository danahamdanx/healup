import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'medicationList.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb


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
  final TextEditingController _dosageController = TextEditingController();  // إضافة حقل الجرعة


  // Image Picker
  File? _imageFile;
  String? _imageBase64; // تعريف المتغير لتخزين الصورة المحولة إلى base64

  String? _imageName;
  final ImagePicker _picker = ImagePicker();

  Future<void> _addMedication() async {
    if (kIsWeb) {
      // التأكد من أن جميع الحقول المطلوبة مملوءة
      if (_medicationNameController.text.isEmpty ||
          _scientificNameController.text.isEmpty ||
          _stockQuantityController.text.isEmpty ||
          _expirationDateController.text.isEmpty ||
          _typeController.text.isEmpty ||
          _priceController.text.isEmpty ||
          _dosageController.text.isEmpty) {
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
      String dosage = _dosageController.text.trim();  // إضافة الجرعة

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
      print('Dosage: $dosage');  // إضافة عرض الجرعة


      final url = 'http://localhost:5000/api/healup/medication/add';  // استخدم عنوان URL المناسب
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['medication_name'] = medicationName;
      request.fields['scientific_name'] = scientificName;
      request.fields['stock_quantity'] = stockQuantity;
      request.fields['expiration_date'] = expirationDate;
      request.fields['type'] = type;
      request.fields['price'] = price;
      request.fields['dosage'] = dosage;  // إضافة الجرعة إلى الطلب

      if (discountPercentage.isNotEmpty) {
        request.fields['discount_percentage'] = discountPercentage;
      }

      // إضافة الصورة في حالة وجودها
      if (_imageBase64 != null) {
        request.fields['image'] = "data:image/png;base64,$_imageBase64";  // إرسال الصورة المحولة إلى Base64
        request.fields['image_name'] = _imageName ?? 'image.png';  // اسم الصورة (اختياري)
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
    else{
      // التأكد من أن جميع الحقول المطلوبة مملوءة
      if (_medicationNameController.text.isEmpty ||
          _scientificNameController.text.isEmpty ||
          _stockQuantityController.text.isEmpty ||
          _expirationDateController.text.isEmpty ||
          _typeController.text.isEmpty ||
          _priceController.text.isEmpty ||
          _dosageController.text.isEmpty) {
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
      String dosage = _dosageController.text.trim();  // إضافة الجرعة

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
      print('Dosage: $dosage');  // إضافة عرض الجرعة

      final url = 'http://10.0.2.2:5000/api/healup/medication/add';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.fields['medication_name'] = medicationName;
      request.fields['scientific_name'] = scientificName;
      request.fields['stock_quantity'] = stockQuantity;
      request.fields['expiration_date'] = expirationDate;
      request.fields['type'] = type;
      request.fields['price'] = price;
      request.fields['dosage'] = dosage;  // إضافة الجرعة إلى الطلب

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

  }

  Future<void> _pickImage2() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _imageName = pickedFile.name;
      });

      // في حالة الويب
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes); // حفظ الصورة المحولة إلى Base64
      });
    }
  }

  Widget _buildImageDisplay() {
    if (kIsWeb) {
      // عرض الصورة باستخدام Image.memory في حالة الويب
      if (_imageBase64 != null) {
        return Image.memory(base64Decode(_imageBase64!)); // عرض الصورة من base64
      } else {
        return Icon(Icons.camera_alt, size: 40, color: Colors.black); // إذا لم يتم اختيار صورة بعد
      }
    } else {
      // عرض الصورة باستخدام Image.file في حالة الأجهزة المحمولة
      return _imageFile == null
          ? Icon(Icons.camera_alt, size: 40, color: Colors.black)
          : ClipOval(child: Image.file(_imageFile!, fit: BoxFit.cover));
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
    _dosageController.dispose();  // إضافة dispose هنا لحقل dosage

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // تخصيص واجهة الويب هنا
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add New Medication",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
              backgroundColor: Color(0xff414370),
            ),
          ),
          backgroundColor: const Color(0xff414370),
          iconTheme: const IconThemeData(
            color: Colors.white70, // تغيير لون سهم التراجع
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff3efd9), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 500, // تحديد العرض كما في الكود الثاني
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true, // لتقليص حجم ListView
                  children: [
                    // اختيار الصورة (دائرة مع أيقونة كاميرا)
                    GestureDetector(
                      onTap: _pickImage2,
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
                          if (_imageName != null)
                            Text(_imageName!, style: TextStyle(fontSize: 16, color: Colors.black)),
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
                    // Dosage
                    _buildTextField(
                      controller: _dosageController,
                      label: 'Dosage',
                      icon: Icons.local_hospital, // يمكنك استخدام أي أيقونة أخرى حسب الحاجة
                      validator: (value) => value!.isEmpty ? 'Please enter dosage' : null,
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
                        backgroundColor: const Color(0xff414370),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        'Add Medication',
                        style: TextStyle(color: Colors.white70, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

    //   if (kIsWeb) {
  //     // الكود الخاص بتطبيق الويب إذا كنت تريد إضافة شيء مختلف عن تطبيق الجوال هنا
  //     return Scaffold(
  //       appBar: AppBar(
  //         title: const Text(
  //           "Add New Medication ",
  //           style: TextStyle(
  //             fontSize: 24,
  //             color: Colors.white70,
  //             // fontWeight: FontWeight.bold,
  //             backgroundColor: Color(0xff414370),
  //           ),
  //         ),
  //         backgroundColor: const Color(0xff414370),
  //         iconTheme: const IconThemeData(
  //           color: Colors.white70,  // تغيير لون سهم التراجع
  //         ),
  //       ),
  //       body: Container(
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [Color(0xfff3efd9), Colors.white],
  //             begin: Alignment.topCenter,
  //             end: Alignment.bottomCenter,
  //           ),
  //         ),
  //         padding: const EdgeInsets.all(16.0),
  //         child: Form(
  //           key: _formKey,
  //           child: ListView(
  //             children: [
  //               //Image Selection (Circle Avatar with Camera Icon)
  //               GestureDetector(
  //                 onTap: _pickImage2,
  //                 child: Column(
  //                   children: [
  //                     CircleAvatar(
  //                       radius: 60,
  //                       backgroundColor: Colors.grey[200],
  //                       child: _imageFile == null
  //                           ? Icon(Icons.camera_alt, size: 40, color: Colors.black)
  //                           : ClipOval(child: Image.file(_imageFile!, fit: BoxFit.cover)),
  //                     ),
  //                     SizedBox(height: 8),
  //                     if (_imageName != null) Text(_imageName!, style: TextStyle(fontSize: 16, color: Colors.black)),
  //                   ],
  //                 ),
  //               ),
  //               SizedBox(height: 20),
  //
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
  //               // Dosage
  //               _buildTextField(
  //                 controller: _dosageController,
  //                 label: 'Dosage',
  //                 icon: Icons.local_hospital,  // يمكنك استخدام أي أيقونة أخرى حسب الحاجة
  //                 validator: (value) => value!.isEmpty ? 'Please enter dosage' : null,
  //               ),
  //               // Price
  //               _buildTextField(
  //                 controller: _priceController,
  //                 label: 'Price',
  //                 icon: Icons.monetization_on,
  //                 validator: (value) => value!.isEmpty ? 'Please enter price' : null,
  //                 keyboardType: TextInputType.number,
  //               ),
  //               // حقل نسبة العرض (اختياري)
  //               _buildTextField(
  //                 controller: _discountPercentageController,
  //                 label: 'Discount Percentage (Optional)',
  //                 icon: Icons.percent,
  //                 validator: (value) {
  //                   if (value != null && value.isNotEmpty) {
  //                     final double? percentage = double.tryParse(value);
  //                     if (percentage == null || percentage < 0 || percentage > 100) {
  //                       return 'Please enter a valid percentage between 0 and 100';
  //                     }
  //                   }
  //                   return null;
  //                 },
  //                 keyboardType: TextInputType.number,
  //               ),
  //               SizedBox(height: 20),
  //
  //               // Add Medication Button
  //               ElevatedButton(
  //                 onPressed: () {
  //                   if (_formKey.currentState!.validate()) {
  //                     _addMedication();
  //                   }
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xff414370),
  //                   padding: EdgeInsets.symmetric(vertical: 15),
  //                 ),
  //                 child: Text(
  //                   'Add Medication',
  //                   style: TextStyle(color: Colors.white70, fontSize: 20),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
    }
    else{
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Add New Medication ",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
              // fontWeight: FontWeight.bold,
              backgroundColor: Color(0xff414370),
            ),
          ),
          backgroundColor: const Color(0xff414370),
          iconTheme: const IconThemeData(
            color: Colors.white70,  // تغيير لون سهم التراجع
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff3efd9), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
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
                // Dosage
                _buildTextField(
                  controller: _dosageController,
                  label: 'Dosage',
                  icon: Icons.local_hospital,  // يمكنك استخدام أي أيقونة أخرى حسب الحاجة
                  validator: (value) => value!.isEmpty ? 'Please enter dosage' : null,
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
                    backgroundColor: const Color(0xff414370),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Add Medication',
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

    }

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
          prefixIcon: Icon(icon, color: Color(0xff414370)),
          labelText: label,
          labelStyle: TextStyle(color: Color(0xff414370), fontSize: 18),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff414370), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff414370), width: 2),
          ),
        ),
        style: TextStyle(color: Color(0xff414370), fontSize: 18),
        validator: validator,
      ),
    );
  }
}
