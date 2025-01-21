import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'DoctorMainPage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class DoctorLoginPage extends StatefulWidget {
  @override
  _DoctorLoginPageState createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late RegExp emailRegExp;
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  final _storage = FlutterSecureStorage();


  Future<void> _login() async {
    if(kIsWeb){
      if (_formKey.currentState!.validate()) {
        final email = _emailController.text;
        final password = _passwordController.text;

        try {
          // Replace with your backend URL
          final response = await http.post(
            Uri.parse('http://localhost:5000/api/healup/doctors/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          );

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);

            // Store the token and doctor info in secure storage
            await _storage.write(key: 'auth_token', value: responseData['token']);
            await _storage.write(key: 'doctor_name', value: responseData['username']);
            await _storage.write(key: 'doctor_id', value: responseData['_id']);

            // Navigate to Doctor Main Page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          } else {
            final responseData = json.decode(response.body);
            _showErrorDialog(responseData['message'] ?? 'Invalid email or password');
          }
        } catch (e) {
          print('Error: $e');
          _showErrorDialog('An error occurred. Please try again later.');
        }

      }


    }
    else{
      if (_formKey.currentState!.validate()) {
        final email = _emailController.text;
        final password = _passwordController.text;

        try {
          // Replace with your backend URL
          final response = await http.post(
            Uri.parse('http://10.0.2.2:5000/api/healup/doctors/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          );

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);

            // Store the token and doctor info in secure storage
            await _storage.write(key: 'auth_token', value: responseData['token']);
            await _storage.write(key: 'doctor_name', value: responseData['username']);
            await _storage.write(key: 'doctor_id', value: responseData['_id']);

            // Navigate to Doctor Main Page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          } else {
            final responseData = json.decode(response.body);
            _showErrorDialog(responseData['message'] ?? 'Invalid email or password');
          }
        } catch (e) {
          print('Error: $e');
          _showErrorDialog('An error occurred. Please try again later.');
        }

      }

    }

  }

  void _showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: Stack(
          children: [
            // خلفية الصورة
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/back.jpg'), // الصورة الخلفية
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // طبقة شفافة
            Container(
              color: Colors.black.withOpacity(0.1),
            ),
            // SafeArea للمحتوى
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400), // تقليص عرض المربع
                  child: Container(
                    // إطار حول المحتوى
                    decoration: BoxDecoration(
                      color: Color(0xff2f9a8f).withOpacity(0.4), // خلفية شفافة بلون أخضر
                      borderRadius: BorderRadius.circular(25), // زوايا دائرية
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5), // لون الحدود
                        width: 2, // عرض الحدود
                      ),
                    ),
                    padding: const EdgeInsets.all(24), // المسافة داخل الإطار
                    height: 600, // تقليص الارتفاع ليصبح أرفع
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 60, // تقليل حجم الشعار
                          backgroundImage: AssetImage('images/logo.png'), // صورة الشعار
                        ),
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.lightBlue, Colors.lightGreen],
                          ).createShader(bounds),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 35, // تقليص حجم النص
                              fontFamily: 'Hello Valentina',
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Form container with email and password fields
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0), // تقليص المسافة الجانبية
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: Colors.grey[700]),
                                    prefixIcon: const Icon(Icons.email),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15), // تقليل المسافة بين الحقول
                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(color: Colors.grey[700]),
                                    prefixIcon: const Icon(Icons.lock),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15), // تقليل المسافة بين الحقول
                                // Forgot Password Button (Aligned to the left)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Login Button
                                ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff2f9a8f),
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    else{
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/signlogin.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xff2f9a8f), size: 30),
                        onPressed: () => Navigator.of(context).pushReplacementNamed("welcomePage"),
                      ),
                    ),
                    const SizedBox(height: 60),
                    const Center(
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: AssetImage('images/logo.png'), // Replace with your image
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.lightBlue, Colors.lightGreen],
                                tileMode: TileMode.clamp,
                              ).createShader(bounds),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 55,
                                  fontFamily: 'Hello Valentina',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                prefixIcon: const Icon(Icons.email),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                prefixIcon: const Icon(Icons.lock),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Forgot Password Button (Aligned to the left)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: (){},
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Login Button
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2f9a8f),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
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
  }

}

