import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'doctorList.dart';
class AddDoctorPage extends StatefulWidget {
  @override
  _AddDoctorPageState createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _yearExperienceController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _sealController = TextEditingController();

  // Add Doctor function
  Future<void> _addDoctor() async {
    final url = 'http://10.0.2.2:5000/api/healup/doctors/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'username': _usernameController.text,
        'password': _passwordController.text,
        'specialization': _specializationController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'hospital': _hospitalController.text,
        'availability': _availabilityController.text,
        'yearExperience': int.parse(_yearExperienceController.text),
        'pricePerHour': int.parse(_pricePerHourController.text),
        'seal': _sealController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Doctor added successfully')),
      );
      //Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DoctorListPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add doctor')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        //automaticallyImplyLeading: false,  // لإزالة سهم التراجع
        title: const Text(
        "Add New Doctor",
        style: TextStyle(
        fontSize: 24,  // زيادة حجم الخط
        //fontWeight: FontWeight.bold,  // جعل الخط عريض
    ),
    ),
    backgroundColor: const Color(0xff2f9a8f),
        ),
    body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/pat.jpg'),

            //image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Doctor Name
              _buildTextField(
                controller: _nameController,
                label: 'Doctor Name',
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? 'Please enter doctor\'s name' : null,
              ),
              // Username
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.account_circle,
                validator: (value) => value!.isEmpty ? 'Please enter username' : null,
              ),
              // Password
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                //obscureText: true,
                validator: (value) => value!.isEmpty ? 'Please enter password' : null,
              ),
              // Specialization
              _buildTextField(
                controller: _specializationController,
                label: 'Specialization',
                icon: Icons.medical_services,
                validator: (value) => value!.isEmpty ? 'Please enter specialization' : null,
              ),
              // Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone,
                validator: (value) => value!.isEmpty ? 'Please enter phone number' : null,
              ),
              // Email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                validator: (value) => value!.isEmpty ? 'Please enter email' : null,
              ),
              // Address
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                validator: (value) => value!.isEmpty ? 'Please enter address' : null,
              ),
              // Hospital
              _buildTextField(
                controller: _hospitalController,
                label: 'Hospital',
                icon: Icons.local_hospital,
                validator: (value) => value!.isEmpty ? 'Please enter hospital' : null,
              ),
              // Availability
              _buildTextField(
                controller: _availabilityController,
                label: 'Availability',
                icon: Icons.access_time,
                validator: (value) => value!.isEmpty ? 'Please enter availability' : null,
              ),
              // Year of Experience
              _buildTextField(
                controller: _yearExperienceController,
                label: 'Years of Experience',
                icon: Icons.accessibility,
                validator: (value) => value!.isEmpty ? 'Please enter years of experience' : null,
                keyboardType: TextInputType.number,
              ),
              // Price Per Hour
              _buildTextField(
                controller: _pricePerHourController,
                label: 'Price Per Hour',
                icon: Icons.monetization_on,
                validator: (value) => value!.isEmpty ? 'Please enter price per hour' : null,
                keyboardType: TextInputType.number,
              ),
              // Seal
              _buildTextField(
                controller: _sealController,
                label: 'Seal',
                icon: Icons.security,
                validator: (value) => value!.isEmpty ? 'Please enter seal' : null,
              ),
              SizedBox(height: 20),
              // Add Doctor Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addDoctor();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2f9a8f),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Add Doctor',
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
          //prefixIcon: Icon(icon, color: const Color(0xff2f9a8f)),
          prefixIcon: Icon(icon, color: Colors.black87),
          labelText: label,
          labelStyle: TextStyle(color:  Colors.black87, fontSize: 18),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color:  Colors.black87, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color:  Colors.black87, width: 2),
          ),
        ),
        style: TextStyle(color: Colors.black, fontSize: 18), // Text color set to black
        validator: validator,
      ),
    );
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class AddDoctorPage extends StatefulWidget {
//   @override
//   _AddDoctorPageState createState() => _AddDoctorPageState();
// }
//
// class _AddDoctorPageState extends State<AddDoctorPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // تعريف الـ TextEditingController بدون قيم افتراضية
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _specializationController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _hospitalController = TextEditingController();
//   final TextEditingController _availabilityController = TextEditingController();
//   final TextEditingController _yearExperienceController = TextEditingController();
//   final TextEditingController _pricePerHourController = TextEditingController();
//   final TextEditingController _sealController = TextEditingController();
//
//   Future<void> _addDoctor() async {
//     final url = 'http://10.0.2.2:5000/api/healup/doctors/register';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'name': _nameController.text,
//         'username': _usernameController.text,
//         'password': _passwordController.text,
//         'specialization': _specializationController.text,
//         'phone': _phoneController.text,
//         'email': _emailController.text,
//         'address': _addressController.text,
//         'hospital': _hospitalController.text,
//         'availability': _availabilityController.text,
//         'yearExperience': int.parse(_yearExperienceController.text),
//         'pricePerHour': int.parse(_pricePerHourController.text),
//         'seal': _sealController.text,
//       }),
//     );
//
//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Doctor added successfully')),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add doctor')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add Doctor"),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/back.jpg'), // الصورة المطلوبة
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.4),
//               BlendMode.darken,
//             ),
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               // حقل Name
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter name' : null,
//               ),
//               // حقل Username
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter username' : null,
//               ),
//               // حقل Password
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 //obscureText: true, // إخفاء النص عند الكتابة
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter password' : null,
//               ),
//               // حقل Specialization
//               TextFormField(
//                 controller: _specializationController,
//                 decoration: InputDecoration(
//                   labelText: 'Specialization',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter specialization' : null,
//               ),
//               // حقل Phone
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter phone' : null,
//               ),
//               // حقل Email
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter email' : null,
//               ),
//               // حقل Address
//               TextFormField(
//                 controller: _addressController,
//                 decoration: InputDecoration(
//                   labelText: 'Address',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter address' : null,
//               ),
//               // حقل Hospital
//               TextFormField(
//                 controller: _hospitalController,
//                 decoration: InputDecoration(
//                   labelText: 'Hospital',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter hospital' : null,
//               ),
//               // حقل Availability
//               TextFormField(
//                 controller: _availabilityController,
//                 decoration: InputDecoration(
//                   labelText: 'Availability',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter availability' : null,
//               ),
//               // حقل Year of Experience
//               TextFormField(
//                 controller: _yearExperienceController,
//                 decoration: InputDecoration(
//                   labelText: 'Year of Experience',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter year of experience' : null,
//               ),
//               // حقل Price Per Hour
//               TextFormField(
//                 controller: _pricePerHourController,
//                 decoration: InputDecoration(
//                   labelText: 'Price Per Hour',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter price per hour' : null,
//               ),
//               // حقل Seal
//               TextFormField(
//                 controller: _sealController,
//                 decoration: InputDecoration(
//                   labelText: 'Seal',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter seal' : null,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _addDoctor();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f), // تغيير خلفية الزر
//                 ),
//                 child: Text('Add Doctor', style: TextStyle(color: Colors.black, fontSize: 22)),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//


////////////////////////
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class AddDoctorPage extends StatefulWidget {
//   @override
//   _AddDoctorPageState createState() => _AddDoctorPageState();
// }
//
// class _AddDoctorPageState extends State<AddDoctorPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // تعيين القيم الافتراضية
//   final TextEditingController _nameController = TextEditingController(text: "Dr. manar");
//   final TextEditingController _usernameController = TextEditingController(text: "manar2121");
//   final TextEditingController _passwordController = TextEditingController(text: "securePassword123");
//   final TextEditingController _specializationController = TextEditingController(text: "General");
//   final TextEditingController _phoneController = TextEditingController(text: "123-456-7890");
//   final TextEditingController _emailController = TextEditingController(text: "manar@example.com");
//   final TextEditingController _addressController = TextEditingController(text: "Nablus");
//   final TextEditingController _hospitalController = TextEditingController(text: "Rafidea Hospital");
//   final TextEditingController _availabilityController = TextEditingController(text: "9 AM - 5 PM");
//   final TextEditingController _yearExperienceController = TextEditingController(text: "10");
//   final TextEditingController _pricePerHourController = TextEditingController(text: "200");
//   final TextEditingController _sealController = TextEditingController(text: "Dr. manar,mm");
//
//   Future<void> _addDoctor() async {
//     final url = 'http://10.0.2.2:5000/api/healup/doctors/register';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'name': _nameController.text,
//         'username': _usernameController.text,
//         'password': _passwordController.text,
//         'specialization': _specializationController.text,
//         'phone': _phoneController.text,
//         'email': _emailController.text,
//         'address': _addressController.text,
//         'hospital': _hospitalController.text,
//         'availability': _availabilityController.text,
//         'yearExperience': int.parse(_yearExperienceController.text),
//         'pricePerHour': int.parse(_pricePerHourController.text),
//         'seal': _sealController.text,
//       }),
//     );
//
//     if (response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Doctor added successfully')),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add doctor')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add Doctor"),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/back.jpg'), // الصورة المطلوبة
//             fit: BoxFit.cover,
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.25),
//               BlendMode.darken,
//             ),
//           ),
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               // حقل Name
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter name' : null,
//               ),
//               // حقل Username
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter username' : null,
//               ),
//               // حقل Password
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 //obscureText: true, // إخفاء النص عند الكتابة
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter password' : null,
//               ),
//               // حقل Specialization
//               TextFormField(
//                 controller: _specializationController,
//                 decoration: InputDecoration(
//                   labelText: 'Specialization',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter specialization' : null,
//               ),
//               // حقل Phone
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: InputDecoration(
//                   labelText: 'Phone',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter phone' : null,
//               ),
//               // حقل Email
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter email' : null,
//               ),
//               // حقل Address
//               TextFormField(
//                 controller: _addressController,
//                 decoration: InputDecoration(
//                   labelText: 'Address',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter address' : null,
//               ),
//               // حقل Hospital
//               TextFormField(
//                 controller: _hospitalController,
//                 decoration: InputDecoration(
//                   labelText: 'Hospital',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter hospital' : null,
//               ),
//               // حقل Availability
//               TextFormField(
//                 controller: _availabilityController,
//                 decoration: InputDecoration(
//                   labelText: 'Availability',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter availability' : null,
//               ),
//               // حقل Year of Experience
//               TextFormField(
//                 controller: _yearExperienceController,
//                 decoration: InputDecoration(
//                   labelText: 'Year of Experience',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter year of experience' : null,
//               ),
//               // حقل Price Per Hour
//               TextFormField(
//                 controller: _pricePerHourController,
//                 decoration: InputDecoration(
//                   labelText: 'Price Per Hour',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter price per hour' : null,
//               ),
//               // حقل Seal
//               TextFormField(
//                 controller: _sealController,
//                 decoration: InputDecoration(
//                   labelText: 'Seal',
//                   labelStyle: TextStyle(color: Colors.black, fontSize: 19),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: const Color(0xff2f9a8f), width: 2),
//                   ),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black, width: 1),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black, fontSize: 19),
//                 validator: (value) => value!.isEmpty ? 'Please enter seal' : null,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _addDoctor();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xff2f9a8f), // تغيير خلفية الزر
//                 ),
//                 child: Text('Add Doctor', style: TextStyle(color:Colors.black, fontSize: 22)),
//               )
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
