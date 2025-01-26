import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'medicationList.dart'; // Make sure you have a page for displaying the medication list
import 'package:flutter/foundation.dart'; // For kIsWeb

class EditMedicationPage extends StatefulWidget {
  final String medicationId; // The ID of the medication to be edited

  EditMedicationPage({required this.medicationId});

  @override
  _EditMedicationPageState createState() => _EditMedicationPageState();
}

class _EditMedicationPageState extends State<EditMedicationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _medicationNameController = TextEditingController();
  final TextEditingController _scientificNameController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedicationDetails();
  }
  Future<void> _fetchMedicationDetails() async {
    if(kIsWeb){
      final url = 'http://localhost:5000/api/healup/medication/${widget.medicationId}';
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final medication = jsonDecode(response.body)['medication'];  // Accessing the 'medication' object from the response
          print("Fetched Medication: $medication");

          String imageName = medication['image'] ?? '';
          print("Fetched Medication Image Name: '$imageName'");

          // Set the text fields with the fetched data, and check for null values
          _medicationNameController.text = medication['medication_name'] ?? '';
          _scientificNameController.text = medication['scientific_name'] ?? '';
          _stockQuantityController.text = medication['stock_quantity']?.toString() ?? '';
          _expirationDateController.text = medication['expiration_date'] ?? '';
          _descriptionController.text = medication['description'] ?? '';
          _typeController.text = medication['type'] ?? '';
          _priceController.text = medication['price']?.toString() ?? '';

          // Ensure that the image is correctly assigned to _imageController
          //String imageName = medication['image'] ?? '';
          _imageController.text = imageName;

          // Print the image name
          String imageName2 = medication['image'] ?? '';
          print("Fetched Medication Image Name: '$imageName2'");

          _dosageController.text = medication['dosage'] ?? '';

          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load medication details')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medication details: $e')),
        );
      }
    }
    else{
      final url = 'http://10.0.2.2:5000/api/healup/medication/${widget.medicationId}';
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final medication = jsonDecode(response.body)['medication'];  // Accessing the 'medication' object from the response
          print("Fetched Medication: $medication");

          String imageName = medication['image'] ?? '';
          print("Fetched Medication Image Name: '$imageName'");

          // Set the text fields with the fetched data, and check for null values
          _medicationNameController.text = medication['medication_name'] ?? '';
          _scientificNameController.text = medication['scientific_name'] ?? '';
          _stockQuantityController.text = medication['stock_quantity']?.toString() ?? '';
          _expirationDateController.text = medication['expiration_date'] ?? '';
          _descriptionController.text = medication['description'] ?? '';
          _typeController.text = medication['type'] ?? '';
          _priceController.text = medication['price']?.toString() ?? '';

          // Ensure that the image is correctly assigned to _imageController
          //String imageName = medication['image'] ?? '';
          _imageController.text = imageName;

          // Print the image name
          String imageName2 = medication['image'] ?? '';
          print("Fetched Medication Image Name: '$imageName2'");

          _dosageController.text = medication['dosage'] ?? '';

          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load medication details')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medication details: $e')),
        );
      }

    }
  }


  Future<void> _updateMedication() async {
    if(kIsWeb){
      final url = 'http://localhost:5000/api/healup/medication/update/${widget.medicationId}';

      // إذا لم يقم المستخدم بتغيير الصورة، نحتفظ بالقيمة الأصلية الموجودة في _imageController.text
      String imageName = _imageController.text;

      // إرسال طلب PUT لتحديث الدواء
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'medication_name': _medicationNameController.text,
          'scientific_name': _scientificNameController.text,
          'stock_quantity': int.parse(_stockQuantityController.text),
          'expiration_date': _expirationDateController.text,
          'description': _descriptionController.text,
          'type': _typeController.text,
          'price': double.parse(_priceController.text),
          'image':  imageName,  // إرسال اسم الصورة كما هو
          'dosage': _dosageController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication updated successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MedicationListPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update medication')),
        );
      }
    }
    else{
      final url = 'http://10.0.2.2:5000/api/healup/medication/update/${widget.medicationId}';

      // إذا لم يقم المستخدم بتغيير الصورة، نحتفظ بالقيمة الأصلية الموجودة في _imageController.text
      String imageName = _imageController.text;

      // إرسال طلب PUT لتحديث الدواء
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'medication_name': _medicationNameController.text,
          'scientific_name': _scientificNameController.text,
          'stock_quantity': int.parse(_stockQuantityController.text),
          'expiration_date': _expirationDateController.text,
          'description': _descriptionController.text,
          'type': _typeController.text,
          'price': double.parse(_priceController.text),
          'image':  imageName,  // إرسال اسم الصورة كما هو
          'dosage': _dosageController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Medication updated successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MedicationListPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update medication')),
        );
      }

    }
  }
  @override
  Widget build(BuildContext context) {
    if(kIsWeb){
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Medication",
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
              width: 500, // تحديد عرض الحاوية ليشبه الكود الثاني
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true, // لضمان أن الـ ListView لا يتمدد بشكل غير ضروري
                  children: [
                    _buildTextField(
                      controller: _medicationNameController,
                      label: 'Medication Name',
                      icon: Icons.medication,
                      validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
                    ),
                    _buildTextField(
                      controller: _scientificNameController,
                      label: 'Scientific Name',
                      icon: Icons.science,
                      validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
                    ),
                    _buildTextField(
                      controller: _stockQuantityController,
                      label: 'Stock Quantity',
                      icon: Icons.storage,
                      validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _expirationDateController,
                      label: 'Expiration Date',
                      icon: Icons.date_range,
                      validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      validator: (value) => value!.isEmpty ? 'Please enter description' : null,
                    ),
                    _buildTextField(
                      controller: _typeController,
                      label: 'Type',
                      icon: Icons.category,
                      validator: (value) => value!.isEmpty ? 'Please enter type' : null,
                    ),
                    _buildTextField(
                      controller: _dosageController,
                      label: 'Dosage',
                      icon: Icons.local_pharmacy,
                      validator: (value) => value!.isEmpty ? 'Please enter dosage' : null,
                    ),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Price',
                      icon: Icons.monetization_on,
                      validator: (value) => value!.isEmpty ? 'Please enter price' : null,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateMedication();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff414370),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        'Update Medication',
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

    }
    else{
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Medication ",
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
                _buildTextField(
                  controller: _medicationNameController,
                  label: 'Medication Name',
                  icon: Icons.medication,
                  validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
                ),
                _buildTextField(
                  controller: _scientificNameController,
                  label: 'Scientific Name',
                  icon: Icons.science,
                  validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
                ),
                _buildTextField(
                  controller: _stockQuantityController,
                  label: 'Stock Quantity',
                  icon: Icons.storage,
                  validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: _expirationDateController,
                  label: 'Expiration Date',
                  icon: Icons.date_range,
                  validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
                ),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  validator: (value) => value!.isEmpty ? 'Please enter description' : null,
                ),
                _buildTextField(
                  controller: _typeController,
                  label: 'Type',
                  icon: Icons.category,
                  validator: (value) => value!.isEmpty ? 'Please enter type' : null,
                ),
                _buildTextField(
                  controller: _dosageController,
                  label: 'Dosage',
                  icon: Icons.local_pharmacy,
                  validator: (value) => value!.isEmpty ? 'Please enter dosage' : null,
                ),
                _buildTextField(
                  controller: _priceController,
                  label: 'Price',
                  icon: Icons.monetization_on,
                  validator: (value) => value!.isEmpty ? 'Please enter price' : null,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _updateMedication();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff414370),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Update Medication',
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


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'medicationList.dart'; // Make sure you have a page for displaying the medication list
//
// class EditMedicationPage extends StatefulWidget {
//   final String medicationId; // The ID of the medication to be edited
//
//   EditMedicationPage({required this.medicationId});
//
//   @override
//   _EditMedicationPageState createState() => _EditMedicationPageState();
// }
//
// class _EditMedicationPageState extends State<EditMedicationPage> {
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
//   final TextEditingController _imageController = TextEditingController(); // Added image field controller
//   final TextEditingController _dosageController = TextEditingController(); // Added dosage field controller
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMedicationDetails();
//   }
//
//   // Fetch medication details to pre-fill the form
//   Future<void> _fetchMedicationDetails() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/${widget.medicationId}'; // Use the correct URL for fetching medication details
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final medication = jsonDecode(response.body);
//       _medicationNameController.text = medication['medication_name'];
//       _scientificNameController.text = medication['scientific_name'];
//       _stockQuantityController.text = medication['stock_quantity'].toString();
//       _expirationDateController.text = medication['expiration_date'];
//       _descriptionController.text = medication['description'] ?? '';
//       _typeController.text = medication['type'];
//       _priceController.text = medication['price'].toString();
//       _imageController.text = medication['image']; // Set the image URL
//       _dosageController.text = medication['dosage'] ?? ''; // Set dosage value
//
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load medication details')),
//       );
//     }
//   }
//
//   // Update Medication function
//   Future<void> _updateMedication() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/update/${widget.medicationId}';
//     final response = await http.put(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'medication_name': _medicationNameController.text,
//         'scientific_name': _scientificNameController.text,
//         'stock_quantity': int.parse(_stockQuantityController.text),
//         'expiration_date': _expirationDateController.text,
//         'description': _descriptionController.text,
//         'type': _typeController.text,
//         'price': double.parse(_priceController.text),
//         'image': _imageController.text, // Include the image URL in the update request
//         'dosage': _dosageController.text, // Include dosage field in the update request
//
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Medication updated successfully')),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => MedicationListPage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update medication')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Edit Medication",
//           style: TextStyle(fontSize: 24),
//         ),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/back.jpg'),
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.3),
//               BlendMode.darken,
//             ),
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildTextField(
//                 controller: _medicationNameController,
//                 label: 'Medication Name',
//                 icon: Icons.medication,
//                 validator: (value) => value!.isEmpty ? 'Please enter medication name' : null,
//               ),
//               _buildTextField(
//                 controller: _scientificNameController,
//                 label: 'Scientific Name',
//                 icon: Icons.science,
//                 validator: (value) => value!.isEmpty ? 'Please enter scientific name' : null,
//               ),
//               _buildTextField(
//                 controller: _stockQuantityController,
//                 label: 'Stock Quantity',
//                 icon: Icons.storage,
//                 validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
//                 keyboardType: TextInputType.number,
//               ),
//               _buildTextField(
//                 controller: _expirationDateController,
//                 label: 'Expiration Date',
//                 icon: Icons.date_range,
//                 validator: (value) => value!.isEmpty ? 'Please enter expiration date' : null,
//               ),
//               _buildTextField(
//                 controller: _descriptionController,
//                 label: 'Description',
//                 icon: Icons.description,
//                 validator: (value) => value!.isEmpty ? 'Please enter description' : null,
//               ),
//               _buildTextField(
//                 controller: _typeController,
//                 label: 'Type',
//                 icon: Icons.category,
//                 validator: (value) => value!.isEmpty ? 'Please enter type' : null,
//               ),
//               _buildTextField(
//                 controller: _dosageController, // Added dosage field
//                 label: 'Dosage',
//                 icon: Icons.local_pharmacy,
//                 validator: (value) => value!.isEmpty ? 'Please enter dosage' : null,
//               ),
//               _buildTextField(
//                 controller: _priceController,
//                 label: 'Price',
//                 icon: Icons.monetization_on,
//                 validator: (value) => value!.isEmpty ? 'Please enter price' : null,
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _updateMedication();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f),
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child: Text(
//                   'Update Medication',
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
