import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'map_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:first/services/notification_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb


class PatApp extends StatefulWidget {
  final String name;
  final String specialization;
  final String photo;
  late double rating; // Mutable
  late int reviews;   // Mutable
  final String address;
  final String hospital;
  final String availability;
  final int duration;
  final int yearsOfExperience;
  final double price;
  final String patientId;
  final String doctorId;
  final Function(Map<String, String>) onAppointmentBooked;
  final Function(double newRating, int newReviews) onRatingUpdated; // Add this

  PatApp({
    Key? key,
    required this.name,
    required this.specialization,
    required this.photo,
    required this.rating,
    required this.reviews,
    required this.address,
    required this.hospital,
    required this.availability,
    required this.duration,
    required this.yearsOfExperience,
    required this.price,
    required this.patientId,
    required this.doctorId,
    required this.onAppointmentBooked,
    required this.onRatingUpdated,  // Include it in the constructor

  }) : super(key: key);
  @override
  _PatAppState createState() => _PatAppState(); // Move createState here

}


  @override

class _PatAppState extends State<PatApp> {
  String? selectedDate;
  String? selectedTime;
  DateTime currentMonth = DateTime.now();
  final Map<String, Set<String>> reservedTimesByDate = {};
  // Callback to update the rating in the parent widget
  void updateRating(double newRating, int newReviews) {
    setState(() {
      widget.rating = newRating;
      widget.reviews = newReviews;
    });
  }

  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }
  // Fetch the coordinates of the address
  Future<LatLng> _getCoordinates(String address) async {
    if (kIsWeb) {
      // Use Google Maps Geocoding API for Web
      final apiKey = "YOUR_GOOGLE_MAPS_API_KEY";
      final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey");

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['results'].isNotEmpty) {
            double lat = data['results'][0]['geometry']['location']['lat'];
            double lng = data['results'][0]['geometry']['location']['lng'];
            return LatLng(lat, lng);
          }
        }
      } catch (e) {
        print("Error fetching coordinates: $e");
      }
      return LatLng(0.0, 0.0); // Default fallback if the request fails
    } else {
      // Use the geocoding plugin for mobile
      try {
        List<Location> locations = await locationFromAddress(address);
        return LatLng(locations.first.latitude, locations.first.longitude);
      } catch (e) {
        print("Error getting coordinates: $e");
        return LatLng(0.0, 0.0); // Default fallback if the geocoding fails
      }
    }
  }



  // Fetch the reserved time slots for the selected doctor and date
  Future<void> fetchReservedTimes() async {
    if (selectedDate == null) return;

    final apiUrl = "${getBaseUrl()}/api/healup/appointments/doctor/${widget.doctorId}/available-slots/$selectedDate";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reservedTimes = data['reservedTimes'] as List;

        setState(() {
          reservedTimesByDate[selectedDate!] = Set.from(reservedTimes.map((e) => e.toString()));
        });
      } else {
        throw Exception("Failed to load reserved times.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching reserved times.")),
      );
    }
  }

  // Generate time intervals (60-minute slots)
  List<String> generateTimeIntervals(String availability, int duration) {
    final parts = availability.split(' - ');
    if (parts.length != 2) return [];

    DateTime start = _parseTime(parts[0].trim());
    DateTime end = _parseTime(parts[1].trim());

    List<String> intervals = [];
    DateTime current = start;

    while (current.isBefore(end)) {
      DateTime next = current.add(Duration(minutes: duration));
      if (next.isAfter(end)) next = end; // Adjust the last interval to not exceed `end`
      intervals.add("${_formatTime(current)} - ${_formatTime(next)}");
      current = next;
    }

    return intervals;
  }


  DateTime _parseTime(String timeStr) {
    int hour = int.parse(timeStr.split(":")[0].trim());
    int minute = int.parse(timeStr.split(":")[1].split(" ")[0].trim());
    String period = timeStr.split(" ")[1].trim().toUpperCase();

    if (period == "PM" && hour < 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, minute);
  }

  String _formatTime(DateTime time) {
    return DateFormat.jm().format(time); // e.g., "10:00 AM"
  }

  Future<void> bookAppointmentToBackend(String? date, String? time) async {
    if (date == null || time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a valid date and time.")),
      );
      return;
    }

    // Sanitize the time string
    String sanitizedTime = time.replaceAll(RegExp(r'[\u00A0\u202F\u200B]'), ' ').trim();

    final apiUrl = "${getBaseUrl()}/api/healup/appointments/book";

  //  String? deviceToken = await FirebaseMessaging.instance.getToken();
    //print("Device Token: $deviceToken");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patient_id": widget.patientId,
          "doctor_id": widget.doctorId,
          "app_date": "$date $sanitizedTime",
       //   "device_token": deviceToken,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          reservedTimesByDate[date] ??= {};
          reservedTimesByDate[date]!.add(sanitizedTime);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment successfully booked!")),
        );
       // NotificationService.showNotification(
       //   "Appointment Booked",
      //    "Your appointment with Dr. ${widget.name} is confirmed!",
     //   );
      } else {
        final responseData = jsonDecode(response.body);
        final message = responseData["message"] ?? "Failed to book appointment.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to book appointment.")),
      );
    }
  }

  void _showRatingDialog(BuildContext context) {
    double selectedRating = 0; // Initial rating value

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rate Doctor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How was your experience with ${widget.name}?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      selectedRating > index ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1.0; // Set the rating value
                      });
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedRating > 0) {
                  await _submitRating(selectedRating); // Submit the rating
                  Navigator.pop(context); // Close dialog after submission
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a rating before submitting."),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRating(double rating) async {
    final apiUrl = "${getBaseUrl()}/api/healup/doctors/${widget.doctorId}";

    try {
      print('Sending PUT request to: $apiUrl');

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "rating": rating,
          "reviews": widget.reviews + 1, // Increment the reviews count
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if 'rating' is null before updating
        double newRating = responseData['rating'] != null ? double.parse(responseData['rating'].toString()) : 0.0;
        int newReviews = responseData['reviews'] != null ? responseData['reviews'] : 0;

        // Call the callback to update the parent state with new rating and reviews
        widget.onRatingUpdated(newRating, newReviews);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for your feedback!")),
        );
      } else {
        print('Failed to submit rating. Status Code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit rating. Please try again.")),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Patient ID: ${widget.patientId}'); // Debugging statement

    if (kIsWeb) {
      print(widget.hospital); // To debug and check the value
      if (widget.hospital == null || widget.hospital.isEmpty) {
        // Handle the case when the hospital name is missing or invalid
        print('Hospital data is missing');
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          backgroundColor: const Color(0xff414370),
        ),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xfff3efd9), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Container(
            color: const Color(0xfff0f0f0), // Set the color of the background here
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Padding around the content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Info Section
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(widget.photo),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color(0xff414370)),
                              ),
                              Text(
                                widget.specialization,
                                style:  TextStyle(fontSize: 20, color: Colors.grey,fontWeight: FontWeight.bold),
                              ),
                              Text('${widget.yearsOfExperience} years Experience',style: TextStyle(color: Color(0xff414370),)),
                              const SizedBox(height: 8), // Add some space
                              // Wrap the Rating Row with GestureDetector
                              GestureDetector(
                                onTap: () {
                                  _showRatingDialog(context); // Call the dialog when tapped
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20), // Star Icon
                                    const SizedBox(width: 8),
                                    Text(
                                      '${widget.rating.toStringAsFixed(1)} (${widget.reviews} reviews)',
                                      style: const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff414370)),
                                    ),
                                  ],
                                ),
                              ),


                              Text('\₪${widget.price}/hr', style: const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff414370))),

                              // Hospital Address with Location Icon
                              const SizedBox(height: 8), // Adding some space between price and address
                              // Address Section with Location Icon
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.red, // Red color for location icon
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8), // Space between icon and address text
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        // Get the coordinates of the address
                                        LatLng coordinates = await _getCoordinates(widget.hospital);
                                        // Navigate to MapScreen with the address and location
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MapScreen(
                                              address: widget.hospital,
                                              location: coordinates,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        widget.hospital,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xff414370), // Address text color
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis, // To avoid text overflow
                                        maxLines: 1, // To display address on a single line
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Month Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: currentMonth.isAfter(DateTime.now())
                              ? () {
                            setState(() {
                              currentMonth = DateTime(
                                currentMonth.year,
                                currentMonth.month - 1,
                              );
                            });
                          }
                              : null,
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(currentMonth),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(
                                currentMonth.year,
                                currentMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Days of the Month
                    const SizedBox(height: 30), // Increased space before the days section
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_daysInMonth(currentMonth), (index) {
                          final day = index + 1;
                          final date = DateTime(currentMonth.year, currentMonth.month, day);
                          final isPast = date.isBefore(DateTime.now());
                          final isSelected = selectedDate == DateFormat('yyyy-MM-dd').format(date);

                          return GestureDetector(
                            onTap: !isPast
                                ? () {
                              setState(() {
                                selectedDate = DateFormat('yyyy-MM-dd').format(date);
                              });
                            }
                                : null,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6.0),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xff8aa2d4) : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isPast ? Colors.grey : Colors.black,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPast ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Time Slots Section
                    Text('Time Slots', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: generateTimeIntervals(widget.availability,widget.duration)
                            .map((time) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: _buildTimeButton(time),
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 80),

                    // Book Now Button
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                        child: ElevatedButton(
                          onPressed: selectedDate != null && selectedTime != null
                              ? () => bookAppointmentToBackend(selectedDate, selectedTime)
                              : () {
                            // Display Snackbar if date or time is not selected
                            final snackBar = SnackBar(
                              content: Text(
                                selectedDate == null
                                    ? 'Please select a date.'
                                    : 'Please select a time.',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.redAccent,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff414370),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    // Add this container under the Book Now button with the same color
                    Container(
                      color: const Color(0xfff0f0f0), // Make sure it matches the rest of the background
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Your additional content here, for example:
                          Text('Some other content under the button',style: TextStyle(          color: const Color(0xfff0f0f0), // Set the color of the background here
                          ),),                      ],
                      ),
                    ),
                    Container(
                      color: const Color(0xfff0f0f0), // Make sure it matches the rest of the background
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Your additional content here, for example:
                          Text('Some other content under the button',style: TextStyle(          color: const Color(0xfff0f0f0), // Set the color of the background here
                          ),),                      ],
                      ),
                    ),
                    Container(
                      color: const Color(0xfff0f0f0), // Make sure it matches the rest of the background
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Your additional content here, for example:
                          Text('Some other content under the button',style: TextStyle(          color: const Color(0xfff0f0f0), // Set the color of the background here
                          ),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],)
      );
    }


  else{
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name,style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold,fontSize: 25),),
        backgroundColor: const Color(0xff414370),
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
            child: Container(
              color: Colors.white.withOpacity(0.6),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Info Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(widget.photo),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Color(0xff414370)),
                            ),
                            Text(
                              widget.specialization,
                              style:  TextStyle(fontSize: 20, color: Colors.grey,fontWeight: FontWeight.bold),
                            ),
                            Text('${widget.yearsOfExperience} years Experience',style: TextStyle(color: Color(0xff414370),)),
                            const SizedBox(height: 8), // Add some space
                            // Wrap the Rating Row with GestureDetector
                            GestureDetector(
                              onTap: () {
                                _showRatingDialog(context); // Call the dialog when tapped
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 20), // Star Icon
                                  const SizedBox(width: 8),
                                  Text(
                                    '${widget.rating.toStringAsFixed(1)} (${widget.reviews} reviews)',
                                    style: const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff414370)),
                                  ),
                                ],
                              ),
                            ),


                            Text('\₪${widget.price}/hr', style: const TextStyle(fontWeight: FontWeight.bold,color: Color(0xff414370))),

                            // Hospital Address with Location Icon
                            const SizedBox(height: 8), // Adding some space between price and address
                            // Address Section with Location Icon
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red, // Red color for location icon
                                  size: 20,
                                ),
                                const SizedBox(width: 8), // Space between icon and address text
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      // Get the coordinates of the address
                                      LatLng coordinates = await _getCoordinates(widget.hospital);
                                      // Navigate to MapScreen with the address and location
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                            address: widget.hospital,
                                            location: coordinates,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      widget.hospital,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff414370), // Address text color
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis, // To avoid text overflow
                                      maxLines: 1, // To display address on a single line
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Month Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: currentMonth.isAfter(DateTime.now())
                            ? () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month - 1,
                            );
                          });
                        }
                            : null,
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(currentMonth),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          setState(() {
                            currentMonth = DateTime(
                              currentMonth.year,
                              currentMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Days of the Month
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1.5, // Adjust for oval shape
                    ),
                    itemCount: _daysInMonth(currentMonth),
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final date = DateTime(currentMonth.year, currentMonth.month, day);
                      final isPast = date.isBefore(DateTime.now());
                      final isSelected = selectedDate == DateFormat('yyyy-MM-dd').format(date);

                      return GestureDetector(
                        onTap: !isPast
                            ? () {
                          setState(() {
                            selectedDate = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                            : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xff8aa2d4) : Colors.white,
                            borderRadius: BorderRadius.circular(25), // Oval shape
                            border: Border.all(
                              color: isPast ? Colors.grey : Colors.black,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPast ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Time Slots Section
                  Text('Time Slots', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Column(
                    children: generateTimeIntervals(widget.availability,widget.duration)
                        .map((time) => _buildTimeButton(time))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // Book Now Button
                  // Inside the build method of _PatAppState
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                      child: ElevatedButton(
                        onPressed: selectedDate != null && selectedTime != null
                            ? () => bookAppointmentToBackend(selectedDate, selectedTime)
                            : () {
                          // Display Snackbar if date or time is not selected
                          final snackBar = SnackBar(
                            content: Text(
                              selectedDate == null
                                  ? 'Please select a date.'
                                  : 'Please select a time.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.redAccent,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff414370),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
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

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  Widget _buildTimeButton(String time) {
    final now = DateTime.now();
    final isExpiredToday = selectedDate ==
        DateFormat('yyyy-MM-dd').format(now) &&
        _parseTime(time.split(' - ')[0]).isBefore(now);

    final isSelected = selectedTime == time; // Check if this time is selected
    final isReserved = reservedTimesByDate[selectedDate]?.contains(time) ??
        false;

    return GestureDetector(
      onTap: !isExpiredToday && !isReserved
          ? () {
        setState(() {
          selectedTime = time; // Set the selected time
        });
      }
          : null,
      child: Container(
        alignment: Alignment.center,
        // Center time text
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isExpiredToday
              ? Colors.grey // Grey for expired time slots
              : (isReserved
              ? Color(0xff800020) // Red for reserved times
              : (isSelected
              ? const Color(0xff8aa2d4) // Highlight color for selected time
              : Colors.white)), // Default white for unselected time
          borderRadius: BorderRadius.circular(25), // Oval shape
          border: Border.all(
            color: isReserved ? Color(0xff8aa2d4) : (isSelected
                ? Colors.black
                : Colors.grey), // Black edges for selected time
            width: isSelected ? 2 : 1, // Thicker edges for selected time
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            // Bold for selected time
            color: isExpiredToday
                ? Colors.black45 // Greyed out for expired times
                : isReserved
                ? Colors.white // White for reserved times
                : Colors.black, // Black for all other states
          ),
        ),
      ),
    );
  }
}
