import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the package
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Appointement/patApp.dart'; // Import the PatApp page
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing the JSON response
import 'Appointement/AllDoctorsPage.dart';
import 'Appointement/patApp.dart';
import 'login&signUP/login.dart';
import 'chatBot/chatBot.dart';
import 'medication/MedicineDetailPage.dart';
import 'medication/cart.dart';
import 'medication/medicine.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

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

  late AnimationController _animationController; // Controller for animation
  late Animation<Offset> _slideAnimation; // Animation for sliding

  String userName = "";
  String patientId = ""; // Add a variable to store the patient ID
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Declare the storage instance

  void onRatingUpdated(double newRating, int newReviews) {
    setState(() {
      // Handle the updated rating and reviews here
      print('New Rating: $newRating, New Reviews: $newReviews');
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDoctors();
    fetchDiscountedMedications();  // Fetch discounted medications
    _setupAnimation();  // Setup the animation

    _getUserName();
    _getPatientId(); // Fetch the patient ID when the screen initializes
  }

  // Setup the sliding animation
  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,  // 'this' refers to the TickerProvider provided by the mixin
      duration: Duration(seconds: 3),  // Adjusted duration for each slide
    )..repeat(reverse: true); // Repeat the animation with reverse motion

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),  // Starting position (0, 0)
      end: Offset(-1.0, 0), // Ending position (moving left)
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
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
    widget.onPatientIdReceived(patientId); // Pass patientId to parent widget
  }

  Future<void> fetchDoctors() async {
    // Determine the correct base URL depending on the platform (web vs mobile)
    final String baseUrl = kIsWeb
        ? 'http://localhost:5000/api/healup/doctors/doctors'
        : 'http://10.0.2.2:5000/api/healup/doctors/doctors'; // For mobile emulators

    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        doctors = data
            .map((doctor) => {
          '_id': doctor['_id'],  // Include doctor ID
          'name': doctor['name'],
          'photo': doctor['photo'],
          'hospital': doctor['hospital'],
          'specialization': doctor['specialization'],
          'reviews': int.parse(doctor['reviews'].toString()),
          'rating': double.parse(doctor['rating'].toString()),
          'price': double.parse(doctor['pricePerHour'].toString()),
          'yearExperience': int.parse(doctor['yearExperience'].toString()),
          'availability': doctor['availability'],
          'address': doctor['address'],
        })
            .toList()
          ..sort((a, b) => b['reviews'].compareTo(a['reviews'])) // Sort by reviews (descending)
          ..take(5); // Show up to 5 doctors
      });
    } else {
      throw Exception('Failed to load doctors');
    }
  }

// Fetch discounted medications from the API
  Future<void> fetchDiscountedMedications() async {
    // Determine the correct base URL depending on the platform (web vs mobile)
    final String baseUrl = kIsWeb
        ? 'http://localhost:5000/api/healup/medication/discounted'
        : 'http://10.0.2.2:5000/api/healup/medication/discounted'; // For mobile emulators

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
        }).toList();
      });
    } else {
      throw Exception('Failed to load medications');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();  // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (patientId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if it's Web
    if (kIsWeb) {
      return Scaffold(

        body: Row(
          children: [
            // Main Content (no sidebar)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section with notification and help icons on the right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side: Greeting Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $userName!',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'How are you today?',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                            ],
                          ),
                        ),
                        // Right side: Notification and Help Icons
                        Row(
                          children: [

                            IconButton(
                              icon: const Icon(Icons.live_help_sharp, size: 33),
                              color: Colors.black,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatBot(patientId: patientId),
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
                    // Discounted Medications Section
                    const Text(
                      'Discounted Medications',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    medications.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      height: 180,  // Reduced the height to make the section smaller
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: medications.length,
                            itemBuilder: (context, index) {
                              final medication = medications[index];

                              final medicationName = medication['name'] ?? 'Unknown Medication';
                              final imageUrl = medication['image'] ?? 'images/default_image.jpg'; // Fallback to a default image
                              final discount = medication['discount'] ?? 0;
                              final price = medication['price'] ?? 0.0;
                              final finalPrice = medication['final_price'] ?? price;

                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Transform.translate(
                                  offset: _slideAnimation.value,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Handle tap on the medication card
                                      print("Medication tapped: $medicationName");
                                    },
                                    child: Container(
                                      width: 150,  // Reduced the width of the card
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.asset(
                                              imageUrl,  // Medication image
                                              width: 140,  // Reduced the width of the image
                                              height: 80,  // Reduced the height of the image
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  medicationName,  // Name of the medication
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,  // Reduced font size
                                                    color: medicationName == 'Unknown Medication'
                                                        ? Colors.red
                                                        : Colors.teal,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Discount: $discount%",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,  // Reduced font size
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "\$$price",  // Original price with strike-through
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    decoration: TextDecoration.lineThrough,
                                                    decorationColor: Colors.grey[600],
                                                    fontSize: 12,  // Reduced font size
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "\$$finalPrice",  // Final price after discount
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 14,  // Reduced font size
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Image.asset(
                                              imageUrl,  // Correctly use the image URL from the map
                                              width: 210,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );


                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),
// Doctor Speciality Section
                    const Text(
                      'Doctor Speciality',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120, // Increase height to give more space for each card
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 20), // Add padding for better spacing on the sides
                        children: [
                          DoctorSpecialityCard(
                            icon: Icons.medical_services,
                            title: 'General',
                            onTap: () {
                              _navigateToSpecialty('General');
                            },
                          ),
                          const SizedBox(width: 15), // Add space between cards
                          DoctorSpecialityCard(
                            icon: FontAwesomeIcons.brain,
                            title: 'Neurologic',
                            onTap: () {
                              _navigateToSpecialty('Neurology');
                            },
                          ),
                          const SizedBox(width: 15), // Add space between cards
                          DoctorSpecialityCard(
                            icon: FontAwesomeIcons.baby,
                            title: 'Pediatrics',
                            onTap: () {
                              _navigateToSpecialty('Pediatrics');
                            },
                          ),
                          const SizedBox(width: 15), // Add space between cards
                          DoctorSpecialityCard(
                            icon: FontAwesomeIcons.heartPulse,
                            title: 'Cardiology',
                            onTap: () {
                              _navigateToSpecialty('Cardiology');
                            },
                          ),
                          const SizedBox(width: 15), // Add space between cards
                          DoctorSpecialityCard(
                            icon: FontAwesomeIcons.bone,
                            title: 'Orthopedics',
                            onTap: () {
                              _navigateToSpecialty('Orthopedics');
                            },
                          ),
                          const SizedBox(width: 15), // Add space between cards
                          DoctorSpecialityCard(
                            icon: FontAwesomeIcons.handSparkles,
                            title: 'Dermatologic',
                            onTap: () {
                              _navigateToSpecialty('Dermatology');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recommended Doctors Section with "See All" button
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
                                builder: (context) =>
                                    AllDoctorsPage(patientId: patientId),
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
                    // Display doctors list here
                    doctors.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: doctors.length > 5 ? 5 : doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = doctors[index];

                        // Print the doctor ID to verify it's being passed
                        print('Doctor ID: ${doctor['_id']}');
                        print('Patient ID: $patientId');

                        return DoctorCard(
                          patientId: patientId,
                          doctorId: doctor['_id'],
                          // Pass the doctor ID
                          name: doctor['name'],
                          photo: doctor['photo'],
                          hospital: doctor['hospital'],
                          specialization: doctor['specialization'],
                          reviews: doctor['reviews'],
                          rating: doctor['rating'],
                          price: doctor['price'],
                          availability: doctor['availability'],
                          yearExperience: doctor['yearExperience'],
                          address: doctor['address'],
                          onAppointmentBooked: widget.onAppointmentBooked,
                          onAppointmentCanceled: widget.onAppointmentCanceled,
                          onRatingUpdated: onRatingUpdated, // Pass the callback here
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    else {
      // Mobile layout as already present
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff6be4d7),
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.lightBlue, Colors.lightGreen],
              tileMode: TileMode.clamp,
            ).createShader(bounds),
            child: const Text(
              'HealUp',
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'Hello Valentina',
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'images/pat.jpg',
                fit: BoxFit.cover,
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
                                  builder: (context) => ChatBot(patientId: patientId),
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  medications.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: medications.length,
                          itemBuilder: (context, index) {
                            final medication = medications[index];

                            final medicationName = medication['name'] ?? 'Unknown Medication';
                            final imageUrl = medication['image'] ?? 'images/default_image.jpg'; // Fallback to a default image
                            final discount = medication['discount'] ?? 0;
                            final price = medication['price'] ?? 0.0;
                            final finalPrice = medication['final_price'] ?? price;

                            // Replace 'medicine' with 'medication' and 'widget.patientId' with 'patientId'
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Transform.translate(
                                offset: _slideAnimation.value,
                                child: GestureDetector(
                                  // داخل الكود الموجود في ListView.builder
                                  onTap: () {
                                    print("++++++++++++++++++++++=");

                                    // Safely handle null values and ensure type consistency for numbers
                                    final medicationName = medication['name'] ?? 'Unknown Medication';
                                    final imageUrl = medication['image'] ?? 'images/default_image.jpg'; // Fallback to a default image
                                    final discount = medication['discount'] ?? 0;
                                    final price = (medication['price'] ?? 0) is int
                                        ? (medication['price'] as int).toDouble()
                                        : medication['price'] ?? 0.0;
                                    final finalPrice = (medication['final_price'] ?? price) is int
                                        ? (medication['final_price'] as int).toDouble()
                                        : medication['final_price'] ?? price;
                                    final description = medication['description'] ?? 'No description available';
                                    final type = medication['type'] ?? 'Unknown';
                                    print("Full Medication Data: $medication");

                                    // Print the values to check
                                    print("Medication Name: $medicationName");
                                    print("Image URL: $imageUrl");
                                    print("Discount: $discount%");
                                    print("Price: $price");
                                    print("Final Price: $finalPrice");
                                    print("Description: $description");
                                    print("Type: $type");

                                    // Create Medicine object for navigation
                                    Medicine selectedMedicine = Medicine(
                                      id: medication['_id'] ?? '',  // Ensure _id is not null
                                      medication_name: medicationName,
                                      image: imageUrl,
                                      description: description,  // Fallback for description
                                      price: price,
                                      final_price: finalPrice,
                                      type: type,
                                      quantity: 1,  // Default quantity
                                    );

                                    // Navigate to MedicineDetailPage
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MedicineDetailPage(
                                          medicine: selectedMedicine,
                                          cart: cart,  // Pass cart
                                          patientId: patientId,  // Pass patientId
                                        ),
                                      ),
                                    );
                                  },





                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.9,
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
                                                  medicationName,  // Use the name from the map
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 21,
                                                    color: medicationName == 'Unknown Medication'
                                                        ? Colors.red
                                                        : Colors.teal,
                                                  ),
                                                  textAlign: TextAlign.left,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Discount: ${medication['discount']} %",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "\$$price",  // Correctly use the price from the map
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    decoration: TextDecoration.lineThrough,
                                                    decorationColor: Colors.grey[600],
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "\$$finalPrice",  // Correctly use the finalPrice from the map
                                                  style: TextStyle(
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
                                            imageUrl,  // Correctly use the image URL from the map
                                            width: 210,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );


                          },
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
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Recommended Doctors Section with "See All" button
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
                  // Display doctors list here
                  doctors.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      :ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctors.length > 5 ? 5 : doctors.length, // Show up to 5 doctors
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];

                      // Print the doctor ID to verify it's being passed
                      print('Doctor ID: ${doctor['_id']}');
                      print('Patent ID: $patientId');

                      return DoctorCard(
                        patientId: patientId,
                        doctorId: doctor['_id'],  // Pass the doctor ID
                        name: doctor['name'],
                        photo: doctor['photo'],
                        hospital: doctor['hospital'],
                        specialization: doctor['specialization'],
                        reviews: doctor['reviews'],
                        rating: doctor['rating'],
                        price: doctor['price'],
                        availability: doctor['availability'],
                        yearExperience: doctor['yearExperience'],
                        address: doctor['address'],
                        onAppointmentBooked: widget.onAppointmentBooked,
                        onAppointmentCanceled: widget.onAppointmentCanceled,
                        onRatingUpdated: onRatingUpdated,  // Pass the callback here

                      );
                    },
                  ),
                  // Add this inside your HomeTab's build method, perhaps after the Doctor Speciality section
                  const SizedBox(height: 20), // Add spacing

                ],
              ),
            ),
          ],
        ),
      );
    }
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
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(photo),
          radius: 25,
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
        width: 120,
        height: 100,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xffeef7fe),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xff2f9a8f)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


