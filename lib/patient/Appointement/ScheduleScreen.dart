import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:first/patient/Appointement/EHRdetailsPage.dart'; // Adjust the import path as needed
import 'package:first/patient/Appointement/patientPrescriptionForm.dart'; // Adjust the import path as needed
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Map<String, dynamic>> appointments = [];
  Map<String, dynamic> prescriptionData = {}; // Store prescription data

  bool isLoading = true;
  String patientId = ""; // Add a variable to store the patient ID
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Declare the storage instance

  Map<String, String> doctorPhotos = {}; // To store doctor photos
  List<String> availableTimeSlots = [];
  List<String> bookedTimeSlots = []; // Track booked slots for validation
  static const String baseUrl = "http://10.0.2.2:5000/";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getPatientId();
    if (patientId.isNotEmpty) {
      fetchAppointments();
    }
    fetchAllDoctors();
  }
  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }
  Future<void> _getPatientId() async {
    try {
      String? id = await _storage.read(key: 'patient_id');
      debugPrint("Fetched patient ID from storage: $id");
      setState(() {
        patientId = id ?? "";
      });
    } catch (e) {
      debugPrint("Error fetching patient ID: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch patient ID.")),
      );
    }
  }
  bool isWithin48Hours(String appointmentDate) {
    // Split the date and time range into its components
    final parts = appointmentDate.split(' - ');
    if (parts.isEmpty) {
      throw FormatException("Invalid appointment date format.");
    }

    // Extract the start date and time (e.g., "2024-12-31 2:00 PM")
    final startDateTimeString = parts[0];

    // Parse the start date and time
    final appointmentTime = DateFormat('yyyy-MM-dd h:mm a').parse(startDateTimeString);

    // Get the current time
    final currentTime = DateTime.now();

    // Check if the appointment is within 48 hours
    return appointmentTime.difference(currentTime).inHours <= 48;
  }


  Future<void> fetchAppointments() async {
    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient ID is not available.")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final apiUrl = "${getBaseUrl()}/api/healup/appointments/patient/$patientId";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final appointmentData =
        List<Map<String, dynamic>>.from(jsonDecode(response.body));
        setState(() {
          appointments = appointmentData;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch appointments.");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching appointments: $error")),
      );
    }
  }

// Fetch all doctors' data
  Future<void> fetchAllDoctors() async {
    final apiUrl = "${getBaseUrl()}/api/healup/doctors/doctors";
    try {
      print("Fetching doctors...");  // Check if the function is being called
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        print("Response from doctors API: ${response.body}");  // Print the raw response
        final doctorsData = List<Map<String, dynamic>>.from(jsonDecode(response.body));

        // Print out the fetched doctor data for debugging
        print("Fetched doctors data: $doctorsData");

        // Map doctors' photo URLs by doctorId
        for (var doctor in doctorsData) {
          final doctorId = doctor['_id'];
          String photoUrl = doctor['photo'];

          // Print the doctor photo URL and ID for debugging
          print("Doctor ID: $doctorId, Photo URL: $photoUrl");

          // Store the doctor photo URL, or use a placeholder if it's empty
          doctorPhotos[doctorId] = photoUrl.isNotEmpty ? photoUrl : 'https://example.com/placeholder.jpg'; // Default placeholder
        }
      } else {
        print("Failed to fetch doctors. Status code: ${response.statusCode}");
        throw Exception("Failed to fetch doctors.");
      }
    } catch (error) {
      print("Error fetching doctors: $error");
    }
  }



  Future<void> fetchDoctorAvailableSlots(String doctorId, String date) async {
    final apiUrl = "${getBaseUrl()}/api/healup/appointments/doctor/$doctorId/available-slots/$date";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          availableTimeSlots = List<String>.from(data['availableSlots']);
          bookedTimeSlots = List<String>.from(data['bookedSlots']);  // Track booked slots
        });

        // Check for any duplicate appointments before allowing the user to proceed
        if (bookedTimeSlots.isEmpty) {
          // Handle no booked slots case
          print("No appointments are booked for this doctor.");
        } else {
          // If there are any booked slots, validate if the slot the user picks is not in booked slots.
          print("Booked time slots: $bookedTimeSlots");
        }
      } else {
        throw Exception("Failed to fetch available time slots.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PLease choose from the available slots")),
      );
    }
  }


// Check if the new selected slot is already booked
  Future<void> updateAppointmentDate(String appointmentId, String newAppDate) async {
    // Check if the selected time slot is already booked
    if (bookedTimeSlots.contains(newAppDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected time slot is already booked. Please choose another one.")),
      );
      return; // Don't proceed with updating the appointment if the slot is taken
    }

    final apiUrl = "${getBaseUrl()}/api/healup/appointments/update-date/$patientId";

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        body: jsonEncode({
          'appointment_id': appointmentId,  // Add appointment_id to the body
          'new_app_date': newAppDate,       // Add new appointment date to the body
        }),
        headers: {
          'Content-Type': 'application/json',  // Set the content type to JSON
        },
      );

      if (response.statusCode == 200) {
        final updatedAppointment = jsonDecode(response.body);

        setState(() {
          var index = appointments.indexWhere((a) => a['_id'] == appointmentId);
          if (index != -1) {
            appointments[index]['app_date'] = updatedAppointment['appointment']['app_date'];
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment date updated successfully")),
        );
      } else {
        throw Exception("Failed to update appointment.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating appointment: $error")),
      );
    }
  }


  bool isWithin48Hourss(DateTime appointmentDateTime) {
    final currentTime = DateTime.now();
    return appointmentDateTime.difference(currentTime).inHours <= 48;
  }

  void _showDateTimePicker(String appointmentId, String doctorId, String appointmentDate) async {
    try {
      // Extract the start time from the range "2025-12-29 10:00 AM - 11:00 AM"
      final startTime = appointmentDate.split(" - ")[0];  // "2025-12-29 10:00 AM"

      // Parse the start time into a DateTime object using DateFormat
      final DateTime parsedDateTime = DateFormat("yyyy-MM-dd h:mm a").parse(startTime);

      // Check if the appointment is within 48 hours
      if (isWithin48Hourss(parsedDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You cannot edit an appointment within 48 hours of its scheduled time.")),
        );
        return;
      }

      // Step 1: Pick a new date using a date picker
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(), // default to today's date
        firstDate: DateTime.now(),   // Ensure users can't pick a date in the past
        lastDate: DateTime(2100),    // Limit to future dates
      );

      if (selectedDate != null) {
        final formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

        // Step 2: Fetch available time slots for the doctor on the selected date
        await fetchDoctorAvailableSlots(doctorId, formattedDate);

        if (availableTimeSlots.isNotEmpty) {
          // Step 3: Show a dialog with available time slots
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Select New Appointment Time"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: availableTimeSlots.map((slot) {
                      bool isSlotBooked = bookedTimeSlots.contains(slot);

                      return ListTile(
                        title: Text(slot),
                        onTap: isSlotBooked
                            ? null // Disable slot if booked
                            : () {
                          // If the slot is booked already, prevent update
                          if (bookedTimeSlots.contains(slot)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Slot already booked! Please pick another slot.")),
                            );
                            return;
                          }

                          updateAppointmentDate(appointmentId, "$formattedDate $slot");
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        tileColor: isSlotBooked ? Colors.grey : null, // Change color if booked
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No available time slots for this doctor.")),
          );
        }
      }
    } catch (e) {
      print("Error parsing date: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid appointment date format.")),
      );
    }
  }




  Future<void> deleteAppointment(String appointmentId, String appointmentDate) async {

    print('$appointmentDate');
    if (isWithin48Hours(appointmentDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot delete an appointment within 48 hours of its scheduled time.")),
      );
      return;
    }
    final apiUrl = "${getBaseUrl()}/api/healup/appointments/delete/$appointmentId";
    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          appointments.removeWhere((appointment) => appointment['_id'] == appointmentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment deleted successfully")),
        );
      } else {
        throw Exception("Failed to delete appointment.");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting appointment: $error")),
      );
    }
  }
  Future<void> fetchPrescription(String appointmentId) async {
    final apiUrl = "${getBaseUrl()}/api/healup/prescriptions/appointment/$appointmentId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final doctorSpecialization=data['prescription']['doctor_id']['specialization'];
        final doctorPhone=data['prescription']['doctor_id']['phone'];
        final doctorHospital=data['prescription']['doctor_id']['hospital'];

        final prescriptionText = data['prescription']['prescription_text'] ?? '';

        // Extract the fields from the prescription text
        final doctorName = RegExp(r"Doctor Name: (.+)").firstMatch(prescriptionText)?.group(1) ?? 'N/A';
        final patientName = RegExp(r"Patient Name: (.+)").firstMatch(prescriptionText)?.group(1) ?? 'N/A';
        final patientAge = RegExp(r"Patient Age: (\d+)").firstMatch(prescriptionText)?.group(1) ?? 'N/A';
        final date = RegExp(r"Date: (.+)").firstMatch(prescriptionText)?.group(1) ?? 'N/A';

        // Extract medications
        final medicationPattern = RegExp(r"- ID: (.+), Name: (.+), Quantity: (\d+), Dosage: (.+)");
        final medications = medicationPattern
            .allMatches(prescriptionText)
            .map((match) => {
          'id': match.group(1) ?? '', // Provide default empty string if null
          'name': match.group(2) ?? '', // Provide default empty string if null
          'quantity': match.group(3) ?? '', // Provide default empty string if null
          'dosage': match.group(4) ?? '', // Provide default empty string if null
        })
            .toList();


        // Navigate to PrescriptionPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionPage(
              appointmentId: appointmentId, // Pass the appointmentId here
              doctorSpecialization:doctorSpecialization,
              doctorName: doctorName,
              doctorPhone:doctorPhone,
              doctorHospital:doctorHospital,
              patientName: patientName,
              patientAge: patientAge,
              date: date,
              medications: medications,
              patientId: patientId,  // Pass patientId here

            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The Prescription is currently not available. Please try again later.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching prescription: $error")),
      );
    }
  }

  Future<void> fetchEHR(String appointmentId, BuildContext context) async {
    final apiUrl = "${getBaseUrl()}/api/healup/ehr/appointment_id/$appointmentId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ehrRecord = data['ehrRecord'];  // Extract 'ehrRecord'

        // Navigate to EHR details page, passing the 'ehrRecord'
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EHRDetailPage(ehr: ehrRecord),  // Correctly pass the 'ehrRecord'
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The EHR is currently not available. Please try again later.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching EHR: $error")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    if (patientId.isEmpty) {
      return Center(
        child: Text("Error: Patient ID is not available."),
      );
    }

    if (kIsWeb) {
      // Web-specific implementation with card-based grid layout
      return Scaffold(
        appBar: AppBar(
          title: const Text("Your Appointments",style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold,fontSize: 25),),
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
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : appointments.isEmpty
                ? const Center(child: Text("No appointments found."))
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Adjust the number of columns based on the screen size
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.5, // Adjust the aspect ratio for card proportions
                ),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  final doctorId = appointment['doctor_id']?['_id'];
                  final doctorName = appointment['doctor_id']?['name'] ?? 'No name available';
                  final doctorSpecialty =
                      appointment['doctor_id']?['specialization'] ?? 'Specialty not available';
                  final doctorPhoto = doctorId != null && doctorPhotos.containsKey(doctorId)
                      ? doctorPhotos[doctorId]
                      : null;

                  return Card(
                    color:  Color(0xffd4dcee), // Set the card's background color

                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20.0,
                                backgroundImage: (doctorPhoto?.isNotEmpty ?? false)
                                    ? AssetImage(doctorPhoto!)
                                    : const AssetImage('assets/images/person_icon.png')
                                as ImageProvider,
                                child: (doctorPhoto == null || doctorPhoto!.isEmpty)
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    Text(
                                      doctorSpecialty,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            "Date: ${appointment['app_date']}",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Status: ${appointment['status']}",
                            style: TextStyle(
                              color: appointment['status'] == 'Completed'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (appointment['status'] != 'Completed') ...[
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    if (doctorId != null) {
                                      _showDateTimePicker(appointment['_id'], doctorId, appointment['app_date']);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deleteAppointment(appointment['_id'], appointment['app_date']);
                                  },
                                ),


                              ],
                              if (appointment['status'] == 'Completed') ...[
                                IconButton(
                                  icon: const Icon(Icons.medical_services, color: Colors.blue),
                                  onPressed: () {
                                    fetchPrescription(appointment['_id']);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.article, color: Colors.amber),
                                  onPressed: () {
                                    fetchEHR(appointment['_id'], context);
                                  },
                                ),
                              ],
                            ],
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
      );
    }else {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Your Appointments",style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold,fontSize: 25),),
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
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : appointments.isEmpty
            ? const Center(child: Text("No appointments found."))
            : ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final doctorId = appointment['doctor_id']?['_id']; // Ensure correct doctor ID access
            final doctorName = appointment['doctor_id']?['name'] ??
                'No name available';
            final doctorSpecialty = appointment['doctor_id']?['specialization'] ??
                'Specialty not available';
            final doctorPhoto = doctorId != null &&
                doctorPhotos.containsKey(doctorId)
                ? doctorPhotos[doctorId]
                : null; // Get doctor's photo URL or null

            return Card(
              margin: const EdgeInsets.all(8.0),
              color:  Color(0xffd4dcee), // Set the card's background color

              elevation: 5.0,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: SizedBox(
                  width: 70, // Adjust width to accommodate the larger CircleAvatar
                 // height: 100, // Adjust height to accommodate the larger CircleAvatar
                  child: CircleAvatar(
                    radius: 70.0, // Increased radius
                    backgroundImage: (doctorPhoto?.isNotEmpty ?? false)
                        ? AssetImage(doctorPhoto!) // Display doctor's photo
                        : const AssetImage('assets/images/person_icon.png') as ImageProvider,
                    child: (doctorPhoto == null || doctorPhoto!.isEmpty)
                        ? const Icon(Icons.person, size: 60) // Adjust icon size for larger CircleAvatar
                        : null,
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black),
                    ),
                    Text(
                      doctorSpecialty, // Display doctor's specialty here
                      style: TextStyle(
                          fontStyle: FontStyle.normal, color: Colors.grey[700]),
                    ),
                  ],
                ),
                subtitle: Text(
                  "${appointment['app_date']} - ${appointment['status']}",
                  style: TextStyle(color: Color(0xff414370),
                      fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // If the status is not 'Completed', show the edit and delete icons
                    if (appointment['status'] != 'Completed') ...[
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          if (doctorId != null) {
                            _showDateTimePicker(appointment['_id'], doctorId, appointment['app_date']);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteAppointment(appointment['_id'], appointment['app_date']);
                        },
                      ),
                    ],

                    // If the status is 'Completed', show the medical_services and article icons
                    if (appointment['status'] == 'Completed') ...[
                      IconButton(
                        icon: const Icon(Icons.medical_services, color: Colors.blue),
                        onPressed: () {
                          fetchPrescription(appointment['_id']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.article, color: Colors.amber),
                        onPressed: () {
                          fetchEHR(appointment['_id'], context);
                        },
                      ),
                    ],
                  ],
                ),


              ),
            );
          },
        )

      ],
    ),
  );
}
  }
}