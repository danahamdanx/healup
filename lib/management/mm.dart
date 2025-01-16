// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'paymentCard.dart'; // تأكد من أنك أضفت الاستيراد الصحيح للصفحة الجديدة
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'paymentCard.dart';
// import 'cart.dart';
// import 'map.dart';
// import 'package:intl/intl.dart';  // Import the intl package for DateFormat
// import "BillPage.dart";
//
//
//
// class PaymentPage extends StatefulWidget {
//   // final List<Map<String, dynamic>> cart; // Cart list
//   final String patientId; // Patient ID passed from the login page
//   final double totalPrice; // Add totalPrice parameter
//   final List<Map<String, dynamic>> selectedMedicationsDetails; // Add the new parameter
//   final String patientAddress;  // Add patientAddress
//
//   const PaymentPage({
//     Key? key,
//     // required this.cart,
//     required this.patientId,
//     required this.totalPrice, // Receive totalPrice
//     required this.selectedMedicationsDetails, // Update constructor to include this
//     required this.patientAddress,
//   }) : super(key: key);
//
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> {
//   // Initial selected currency (Shekel)
//   String _selectedCurrency = '\$';
//   bool isMedicationsLoaded = false; // New flag to check if medications are loaded
//   final TextEditingController cardNumberController = TextEditingController();
//   final cardNumberFormatter = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {'#': RegExp(r'[0-9]')});
//   String cardHintText = "xxxx xxxx xxxx xxxx"; // النص التلميحي الأولي
//
//
//   // List of currencies and their symbols
//   final List<Map<String, String>> currencies = [
//     {'currency': '₪', 'name': 'Israeli Shekel'},
//     {'currency': '\$', 'name': 'US Dollar'},
//     {'currency': '€', 'name': 'Euro'},
//     {'currency': '£', 'name': 'British Pound'},
//     {'currency': '₹', 'name': 'Indian Rupee'},
//     {'currency': '¥', 'name': 'Japanese Yen'},
//     {'currency': '₣', 'name': 'Swiss Franc'},
//     {'currency': '₣', 'name': 'Canadian Dollar'},
//     {'currency': '₣', 'name': 'Australian Dollar'},
//     {'currency': '₺', 'name': 'Turkish Lira'},
//     {'currency': '₽', 'name': 'Russian Ruble'},
//     {'currency': '₴', 'name': 'Ukrainian Hryvnia'},
//     {'currency': '₱', 'name': 'Philippine Peso'},
//     {'currency': 'BRL', 'name': 'Brazilian Real'},
//     {'currency': 'KSh', 'name': 'Kenyan Shilling'},
//   ];
//
//   // Exchange rates (you can modify these to reflect real-time rates or use an API)
//   final Map<String, double> exchangeRates = {
//     '₪': 1.0, // Israeli Shekel
//     '\$': 0.27, // US Dollar
//     '€': 0.25, // Euro
//     '£': 0.21, // British Pound
//     '₹': 22.8, // Indian Rupee
//     '¥': 36.0, // Japanese Yen
//     '₣': 0.23, // Swiss Franc
//     '₣': 0.23, // Canadian Dollar
//     '₣': 0.23, // Australian Dollar
//     '₺': 7.5,  // Turkish Lira
//     '₽': 20.0, // Russian Ruble
//     '₴': 7.5,  // Ukrainian Hryvnia
//     '₱': 14.5, // Philippine Peso
//     'BRL': 1.3, // Brazilian Real
//     'KSh': 30.0, // Kenyan Shilling
//   };
//
//   double getConvertedPrice(String currency) {
//     double exchangeRate = exchangeRates[currency] ?? 1.0; // Default to 1.0 if not found
//     double t=widget.totalPrice+5;
//     return t * exchangeRate;
//   }
//
//   // Controllers to capture input text from the fields
//   //final TextEditingController cardNumberController = TextEditingController();
//   final TextEditingController expirationDateController = TextEditingController();
//   final TextEditingController cvvController = TextEditingController();
//
//   // تنسيق رقم البطاقة بحيث يظهر بالشكل xxxx xxxx xxxx xxxx
//   //final cardNumberFormatter = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {'#': RegExp(r'[0-9]')});
//
//   // تنسيق التاريخ ليظهر بالشكل MM/YY
//   final expirationDateFormatter = MaskTextInputFormatter(mask: '##/##', filter: {'#': RegExp(r'[0-9]')});
//
//   // تنسيق الـ CVV ليظهر 3 أرقام فقط
//   final cvvFormatter = MaskTextInputFormatter(mask: '###', filter: {'#': RegExp(r'[0-9]')});
//
//   @override
//   void dispose() {
//     cardNumberController.dispose();
//     expirationDateController.dispose();
//     cvvController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     cardNumberController.addListener(_updateCardHintText); // إضافة مستمع لتحديث النص التلميحي
//
//   }
//
//
// // دالة لتحديث النص التلميحي بناءً على الإدخال
//   void _updateCardHintText() {
//     String text = cardNumberController.text.replaceAll(" ", ""); // إزالة المسافات
//     setState(() {
//       if (text.length == 0) {
//         cardHintText = "xxxx xxxx xxxx xxxx"; // إذا لم يكن هناك نص مدخل
//       } else if (text.length == 1) {
//         cardHintText = "1xxx xxxx xxxx xxxx"; // عند إدخال أول رقم
//       } else if (text.length == 2) {
//         cardHintText = "14xx xxxx xxxx xxxx"; // عند إدخال الرقمين الأولين
//       } else if (text.length == 3) {
//         cardHintText = "145x xxxx xxxx xxxx"; // عند إدخال أول ثلاثة أرقام
//       } else if (text.length == 4) {
//         cardHintText = "1456 xxxx xxxx xxxx"; // عند إدخال أول أربعة أرقام
//       } else {
//         cardHintText = "$text${'x' * (16 - text.length)}"; // بقية الأرقام كـ 'x'
//       }
//     });
//   }
//   bool simulatePayment(String cardNumber, String expirationDate, String cvv) {
//     // You can use a simple condition to simulate different outcomes of the transaction.
//
//     // For testing, simulate a success if the card number is a known valid fake number (for example, testing the card "4111111111111111").
//     // This is just an example and not a valid card number for real-world usage.
//
//     if (cardNumber == '4111111111111111') {
//       return true; // Simulate successful payment
//     }
//
//     return false; // Simulate failure for other card numbers
//   }
//   @override
//   Widget build(BuildContext context) {
//     print("+++++++++++++++++++++++++++");
//
//     print("Patient ID: ${widget.patientId}");
//     print("Total Price: \$${widget.totalPrice}");
//     print('Patient Address: ${widget.patientAddress}');
//
//     if (widget.selectedMedicationsDetails != null && widget.selectedMedicationsDetails.isNotEmpty) {
//       print("Selected Medications: ");
//       for (var medication in widget.selectedMedicationsDetails) {
//         print("Medication: ${medication['name']}, Quantity: ${medication['quantity']}, ID: ${medication['id']}");
//       }
//       setState(() {
//         isMedicationsLoaded = true; // Mark medications as loaded
//       });
//     } else {
//       print("No medications available.");
//     }
//     double convertedPrice = getConvertedPrice(_selectedCurrency);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment Card"),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('images/back.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Center(
//             child: SingleChildScrollView(  // Wrap the entire content with scroll view
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 margin: const EdgeInsets.all(16.0),
//                 elevation: 8,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Card Information",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(
//                             flex: 3,
//                             child:TextField(
//                               controller: cardNumberController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 cardNumberFormatter,
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: cardHintText,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f),
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f),
//                                   ),
//                                 ),
//                                 contentPadding: const EdgeInsets.all(12),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: expirationDateController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 expirationDateFormatter,
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: "MM/YY",
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f),
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: TextField(
//                               controller: cvvController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 cvvFormatter,
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: "CVV",
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f),
//                                   ),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: const BorderSide(
//                                     color: Color(0xff2f9a8f),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),  // Add this line to separate the Center widget properly
//                       Center(
//                         child: Text(
//                           "Total Price: ${_selectedCurrency}${convertedPrice.toStringAsFixed(2)}",
//                           style: const TextStyle(
//                             fontSize: 30,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xff2f9a8f),
//                           ),
//                         ),
//                       ),
//                       //const SizedBox(height: 8),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Select Currency",
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       // Currency Dropdown
//                       DropdownButton<String>(
//                         value: _selectedCurrency,
//                         icon: const Icon(Icons.arrow_drop_down),
//                         isExpanded: true,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             _selectedCurrency = newValue!;
//                           });
//                         },
//                         items: currencies.map<DropdownMenuItem<String>>((currency) {
//                           return DropdownMenuItem<String>(
//                             value: currency['currency'],
//                             child: Text('${currency['name']} (${currency['currency']})'),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 20),
//                       Center(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff2f9a8f),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 50,
//                               vertical: 15,
//                             ),
//                           ),
//                           onPressed: () {
//                             String cardNumber = cardNumberController.text.replaceAll(" ", "");
//                             String expirationDate = expirationDateController.text;
//                             String cvv = cvvController.text;
//
//                             // You can add validation for the card number, expiration date, and CVV if needed
//                             if (cardNumber.length == 16 && expirationDate.length == 5 && cvv.length == 3) {
//                               // Simulating a successful transaction
//                               bool paymentSuccess = simulatePayment(cardNumber, expirationDate, cvv);
//
//                               if (paymentSuccess) {
//                                 // Show a success message
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: Text('Payment Successful'),
//                                       content: Text('Your payment of ${_selectedCurrency}${widget.totalPrice} was successful!'),
//                                       actions: <Widget>[
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                           child: Text('OK'),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               } else {
//                                 // Show a failure message
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: Text('Payment Failed'),
//                                       content: Text('There was an issue processing your payment. Please try again.'),
//                                       actions: <Widget>[
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                           child: Text('OK'),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               }
//                             } else {
//                               // Show error if card details are incomplete or invalid
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return AlertDialog(
//                                     title: Text('Invalid Card Details'),
//                                     content: Text('Please check the card number, expiration date, and CVV and try again.'),
//                                     actions: <Widget>[
//                                       TextButton(
//                                         onPressed: () {
//                                           Navigator.of(context).pop();
//                                         },
//                                         child: Text('OK'),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               );
//                             }
//                           },
//                           child: const Text(
//                             "Pay",
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




// //addmedication
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'medicationList.dart'; // Make sure you have a page for displaying the medication list
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
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
//   // Add Medication function
//   Future<void> _addMedication() async {
//     final url = 'http://10.0.2.2:5000/api/healup/medication/add';
//     final response = await http.post(
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
//       }),
//     );
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Add New Medication",
//           style: TextStyle(
//             fontSize: 24,
//           ),
//         ),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body:
//       Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/pat.jpg'),
//
//             //image: AssetImage('images/back.jpg'),
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
//                 icon: Icons.storage,
//                 validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
//                 keyboardType: TextInputType.number,
//               ),
//               // Expiration Date
//               _buildTextField(
//                 controller: _expirationDateController,
//                 label: 'Expiration Date',
//                 icon: Icons.date_range,
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
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//               ),
//               SizedBox(height: 20),
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
