import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Appointement/patApp.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Appointement/AllDoctorsPage.dart';
import 'login&signUP/login.dart';
import 'chatBot/chatBot.dart';
import 'medication/MedicineDetailPage.dart';
import 'medication/cart.dart';
import 'medication/medicine.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class HomeTab extends StatefulWidget {
  final Function(Map<String, dynamic>) onAppointmentBooked;
  final Function(Map<String, dynamic>) onAppointmentCanceled;
  final String userName;
  final Function(String) onPatientIdReceived;

  const HomeTab({
    super.key,
    required this.onAppointmentBooked,
    required this.onAppointmentCanceled,
    required this.userName,
    required this.onPatientIdReceived,
  });

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> medications = []; // To store discounted medications
  static List<Map<String, dynamic>> cart = [];

  String userName = "";
  String patientId = "";
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Add these variables for the animation
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startTimer();
    fetchDoctors();
    fetchDiscountedMedications();
    _getUserName();
    _getPatientId();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < medications.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _getUserName() async {
    final storage = FlutterSecureStorage();
    String? storedName = await storage.read(key: 'patient_name');
    setState(() {
      userName = storedName ?? "Patient";
    });
  }

  Future<void> _getPatientId() async {
    String? id = await _storage.read(key: 'patient_id');
    setState(() {
      patientId = id ?? "";
    });
    widget.onPatientIdReceived(patientId);
  }

  Future<void> fetchDoctors() async {
    final String baseUrl = kIsWeb
        ? 'http://localhost:5000/api/healup/doctors/doctors'
        : 'http://10.0.2.2:5000/api/healup/doctors/doctors';

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        doctors = data
            .map((doctor) => {
          '_id': doctor['_id'],
          'name': doctor['name'],
          'photo': doctor['photo'],
          'hospital': doctor['hospital'],
          'specialization': doctor['specialization'],
          'reviews': int.parse(doctor['reviews'].toString()),
          'rating': double.parse(doctor['rating'].toString()),
          'price': double.parse(doctor['pricePerHour'].toString()),
          'yearExperience': int.parse(doctor['yearExperience'].toString()),
          'availability': doctor['availability'],
          'duration': int.parse(doctor['duration'].toString()),
          'address': doctor['address'],
        })
            .toList()
          ..sort((a, b) => b['reviews'].compareTo(a['reviews']))
          ..take(5);
      });
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  Future<void> fetchDiscountedMedications() async {
    final String baseUrl = kIsWeb
        ? 'http://localhost:5000/api/healup/medication/discounted'
        : 'http://10.0.2.2:5000/api/healup/medication/discounted';

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        medications = data.map((medication) => {
          'name': medication['medication_name'],
          'image': medication['image'],
          'discount': medication['discount_percentage'],
          'price': medication['price'],
          'final_price': medication['final_price'],
          'description': medication['description'],
          'type': medication['type'],
          '_id': medication['_id'],
        }).toList();
      });
    } else {
      throw Exception('Failed to load medications');
    }
  }


  @override
  Widget build(BuildContext context) {
    if(kIsWeb){return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff414370),
        title:  ShaderMask(
          shaderCallback: (bounds) =>  LinearGradient(
            colors: [
              Color(0xff414370), // Soft teal (primary color)
              Colors.blue, // Soft blue (secondary color)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.clamp,
          ).createShader(bounds),
          child: const Text(
            'HealUp',
            style: TextStyle(
              fontSize: 55,
              fontFamily: 'Hello Valentina',
              fontWeight: FontWeight.bold,
              color: Colors.white, // Use white for better contrast with the gradient
            ),
          ),
        ),

      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff6bc9ee), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $userName!',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'How are you today?',
                            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.live_help_sharp, size: 33),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SymptomChatScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Discounted Medications Section
                const Text(
                  'Discounted Medications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                medications.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  height: 200,
                  //width: 400,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: medications.length,
                    scrollDirection: Axis.horizontal,
                    padEnds: false, // Prevents extra padding at the ends
                    pageSnapping: true, // Ensures smooth snapping
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final medication = medications[index];
                      final medicationName = medication['name'] ?? 'Unknown Medication';
                      final imageUrl = medication['image'] ?? 'images/default_image.jpg';
                      final discount = medication['discount'] ?? 0;
                      final price = medication['price'] ?? 0.0;
                      final finalPrice = medication['final_price'] ?? price;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjust horizontal padding
                        child: GestureDetector(
                          onTap: () {
                            final description = medication['description'] ?? 'No description available';
                            final type = medication['type'] ?? 'Unknown';
                            final selectedMedicine = Medicine(
                              id: medication['_id'] ?? '',
                              medication_name: medicationName,
                              image: imageUrl,
                              description: description,
                              price: price,
                              final_price: finalPrice,
                              type: type,
                              quantity: 1,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicineDetailPage(
                                  medicine: selectedMedicine,
                                  cart: cart,
                                  patientId: patientId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 400, // Set a fixed width for the card
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          medicationName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 21,
                                            color: medicationName == 'Unknown Medication'
                                                ? Colors.red
                                                : Colors.teal,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Discount: ${discount}%",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "\$$price",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "\$$finalPrice",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    imageUrl,
                                    width: 300, // Adjust image width
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Doctor Speciality',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      DoctorSpecialityCard(
                        icon: Icons.medical_services,
                        title: 'General',
                        onTap: () {
                          _navigateToSpecialty('General');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.brain,
                        title: 'Neurologic',
                        onTap: () {
                          _navigateToSpecialty('Neurology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.baby,
                        title: 'Pediatrics',
                        onTap: () {
                          _navigateToSpecialty('Pediatrics');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.heartPulse,
                        title: 'Cardiology',
                        onTap: () {
                          _navigateToSpecialty('Cardiology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.bone,
                        title: 'Orthopedics',
                        onTap: () {
                          _navigateToSpecialty('Orthopedics');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.handSparkles,
                        title: 'Dermatologic',
                        onTap: () {
                          _navigateToSpecialty('Dermatology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.eye,
                        title: 'Ophthalmology ',
                        onTap: () {
                          _navigateToSpecialty('Ophthalmology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.xRay,
                        title: 'Radiology  ',
                        onTap: () {
                          _navigateToSpecialty('Radiology ');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.stethoscope,
                        title: 'Internal Medicine  ',
                        onTap: () {
                          _navigateToSpecialty('Internal Medicine ');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recommended Doctors',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllDoctorsPage(patientId: patientId),
                          ),
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                doctors.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length > 5 ? 5 : doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return DoctorCard(
                      patientId: patientId,
                      doctorId: doctor['_id'],
                      name: doctor['name'],
                      photo: doctor['photo'],
                      hospital: doctor['hospital'],
                      specialization: doctor['specialization'],
                      reviews: doctor['reviews'],
                      rating: doctor['rating'],
                      price: doctor['price'],
                      availability: doctor['availability'],
                      duration: doctor['duration'],
                      yearExperience: doctor['yearExperience'],
                      address: doctor['address'],
                      onAppointmentBooked: widget.onAppointmentBooked,
                      onAppointmentCanceled: widget.onAppointmentCanceled,
                      onRatingUpdated: (newRating, newReviews) {
                        // Handle rating update
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );}else{return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff414370),
        title:  ShaderMask(
          shaderCallback: (bounds) =>  LinearGradient(
            colors: [
              Color(0xff6be4d7), // Soft teal (primary color)
              Color(0xff414370), // Soft blue (secondary color)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.clamp,
          ).createShader(bounds),
          child: const Text(
            'HealUp',
            style: TextStyle(
              fontSize: 40,
              fontFamily: 'Hello Valentina',
              fontWeight: FontWeight.bold,
              color: Colors.white, // Use white for better contrast with the gradient
            ),
          ),
        ),

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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $userName!',
                            style:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color(0xff414370)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'How are you today?',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.live_help_sharp, size: 33),
                          color: Colors.grey[800],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SymptomChatScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                 Text(
                  'Discounted Medications',
                  style: TextStyle(color:Colors.grey[800],fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                medications.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: medications.length,
                    itemBuilder: (context, index) {
                      final medication = medications[index];
                      final medicationName = medication['name'] ?? 'Unknown Medication';
                      final imageUrl = medication['image'] ?? 'images/default_image.jpg';
                      final discount = medication['discount'] ?? 0;
                      final price = medication['price'] ?? 0.0;
                      final finalPrice = medication['final_price'] ?? price;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            final description = medication['description'] ?? 'No description available';
                            final type = medication['type'] ?? 'Unknown';
                            final selectedMedicine = Medicine(
                              id: medication['_id'] ?? '',
                              medication_name: medicationName,
                              image: imageUrl,
                              description: description,
                              price: price,
                              final_price: finalPrice,
                              type: type,
                              quantity: 1,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicineDetailPage(
                                  medicine: selectedMedicine,
                                  cart: cart,
                                  patientId: patientId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffb8e1f1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          medicationName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 21,
                                            color: medicationName == 'Unknown Medication'
                                                ? Colors.red
                                                : Color(0xff414370),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Discount: ${discount}%",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "\$$price",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "\$$finalPrice",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    imageUrl,
                                    width: 210,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                 Text(
                  'Doctor Speciality',
                  style: TextStyle(color:Colors.grey[800],fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      DoctorSpecialityCard(
                        icon: Icons.medical_services,
                        title: 'General',
                        onTap: () {
                          _navigateToSpecialty('General');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.brain,
                        title: 'Neurologic',
                        onTap: () {
                          _navigateToSpecialty('Neurology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.baby,
                        title: 'Pediatrics',
                        onTap: () {
                          _navigateToSpecialty('Pediatrics');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.heartPulse,
                        title: 'Cardiology',
                        onTap: () {
                          _navigateToSpecialty('Cardiology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.bone,
                        title: 'Orthopedics',
                        onTap: () {
                          _navigateToSpecialty('Orthopedics');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.handSparkles,
                        title: 'Dermatologic',
                        onTap: () {
                          _navigateToSpecialty('Dermatology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.eye,
                        title: 'Ophthalmology ',
                        onTap: () {
                          _navigateToSpecialty('Ophthalmology');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.xRay,
                        title: 'Radiology  ',
                        onTap: () {
                          _navigateToSpecialty('Radiology ');
                        },
                      ),
                      DoctorSpecialityCard(
                        icon: FontAwesomeIcons.stethoscope,
                        title: 'Internal Medicine  ',
                        onTap: () {
                          _navigateToSpecialty('Internal Medicine ');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      'Recommended Doctors',
                      style: TextStyle(color:Colors.grey[800],fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllDoctorsPage(patientId: patientId),
                          ),
                        );
                      },
                      child:  Text(
                        'See All',
                        style: TextStyle(
                          color:Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                doctors.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.length > 5 ? 5 : doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return DoctorCard(
                      patientId: patientId,
                      doctorId: doctor['_id'],
                      name: doctor['name'],
                      photo: doctor['photo'],
                      hospital: doctor['hospital'],
                      specialization: doctor['specialization'],
                      reviews: doctor['reviews'],
                      rating: doctor['rating'],
                      price: doctor['price'],
                      availability: doctor['availability'],
                      duration: doctor['duration'],
                      yearExperience: doctor['yearExperience'],
                      address: doctor['address'],
                      onAppointmentBooked: widget.onAppointmentBooked,
                      onAppointmentCanceled: widget.onAppointmentCanceled,
                      onRatingUpdated: (newRating, newReviews) {
                        // Handle rating update
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );}

  }




  void _navigateToSpecialty(String specialty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllDoctorsPage(patientId: patientId,initialSpecialty: specialty),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String patientId;
  final String doctorId;  // Add the doctorId parameter
  final String name;
  final String photo;
  final String hospital;
  final String specialization;
  final int reviews;
  final double rating;
  final double price;
  final int yearExperience;
  final String availability;
  final int duration;
  final String address;
  final Function(Map<String, dynamic>) onAppointmentBooked;
  final Function(Map<String, dynamic>) onAppointmentCanceled;
  final Function(double newRating, int newReviews) onRatingUpdated;  // Add this callback

  const DoctorCard({
    super.key,
    required this.patientId,
    required this.doctorId,  // Add the doctorId to the constructor
    required this.name,
    required this.photo,
    required this.hospital,
    required this.specialization,
    required this.reviews,
    required this.rating,
    required this.price,
    required this.availability,
    required this.duration,
    required this.yearExperience,
    required this.address,
    required this.onAppointmentBooked,
    required this.onAppointmentCanceled,
    required this.onRatingUpdated,  // Include the callback in the constructor

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color:  Color(0xffb8e1f1), // Set the card's background color

      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(photo),
          radius: 30,
        ),
        title: Expanded( // Wrap the title with Expanded to avoid overflow
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$specialization | ',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  hospital,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[700], size: 16),
                Text('$rating ($reviews reviews)'),
              ],
            ),
          ],
        ),
        onTap: () {
          // Print doctorId to verify it's being passed correctly
          print("Doctor tapped, ID: $doctorId");

          // Pass the doctorId to the next page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatApp(
                name: name,
                specialization: specialization,
                photo: photo,
                rating: rating,
                reviews: reviews,
                address: address,
                hospital:hospital,
                availability: availability,
                duration :duration,
                yearsOfExperience: yearExperience,
                price: price,
                patientId: patientId,
                doctorId: doctorId,  // Pass the doctorId to PatApp
                onAppointmentBooked: onAppointmentBooked,
                onRatingUpdated: onRatingUpdated,  // Pass the callback here

              ),
            ),
          );
        },
      ),
    );

  }
}


class DoctorSpecialityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap; // Added onTap callback

  const DoctorSpecialityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Wrap the Container with GestureDetector to handle taps
      child: Container(
        width: 150,
        height: 100,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffb8e1f1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xff414370 )),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


