import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mappage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class Bill extends StatelessWidget {
  final String billingId;
  final String patientAddress;  // Add patientAddress

  Bill({required this.billingId, required this.patientAddress});  // Accept patientAddress in the constructor


  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }
  // Fetch Billing Details
  Future<Map<String, dynamic>> fetchBillingDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/healup/billing/$id'),
      );

      print('Response: ${response.body}'); // Debugging
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['billing']; // Extract billing details
      } else {
        throw Exception('Failed to load billing details: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error: ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Patient Address: $patientAddress');

    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bill Details", style: TextStyle(
              color: Colors.white70,
              fontSize: 25,
              fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xff414370),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: fetchBillingDetails(billingId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No billing details available.'));
            }

            final billing = snapshot.data!;
            final medicationList = billing['medicationList'] as List<
                dynamic>? ?? [];
            final totalAmount = billing['amount'] ?? 0;

            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title - healup
                    Center(
                      child: Text(
                        'healup',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date: ${billing['billingDate'] ?? "N/A"}',
                          style: const TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),

                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Medications',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight
                            .bold, color: Colors.blueGrey[800]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    medicationList.isEmpty
                        ? const Text('No medications found.')
                        : Column(
                      children: medicationList.map((med) {
                        final medicationName = med['medicationName'] ??
                            'Unknown';
                        final quantity = med['quantity'] ?? 0;
                        final price = med.containsKey('price') ? (med['price'] *
                            quantity).toStringAsFixed(2) : 'N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Color(0xffd4dcee),
                          // Set the card's background color

                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        medicationName,
                                        style: const TextStyle(fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text("Quantity: $quantity",
                                          style: const TextStyle(fontSize: 16)),
                                      Text("Price: ₪$price",
                                          style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: const Color(0xff414370),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          'Total Amount: ₪${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                        ),
                      ),

                    ),
                    const SizedBox(height: 180),
                    const Divider(),
                    Center(child: TextButton(

                      onPressed: () {
                        // Add the tracking functionality here
                        print("Tracking Order Button Pressed");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderTracking(
                              patientAddress: patientAddress,
                            ),
                          ),
                        );
                        // You can navigate to a tracking page or handle the tracking logic
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        backgroundColor: const Color(0xff414370),
                        disabledBackgroundColor: Colors.white,
                        minimumSize: const Size(
                            200, 50), // Set the minimum width and height

                      ),
                      child: const Text(
                        "Track Order",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70, // Set text color to black here
                        ),
                      ),
                    ),)
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Bill Details",
            style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 25),
          ),
          backgroundColor: const Color(0xff414370),
        ),
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xfff3efd9), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Main Content
            FutureBuilder<Map<String, dynamic>>(
              future: fetchBillingDetails(billingId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No billing details available.'));
                }

                final billing = snapshot.data!;
                final medicationList = billing['medicationList'] as List<dynamic>? ?? [];
                final totalAmount = billing['amount'] ?? 0;

                return Column(
                  children: [
                    // Scrollable content (Medications and others)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title - healup
                            Center(
                              child: Text(
                                'healup',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xff414370),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ' Date: ${billing['billingDate'] ?? "N/A"}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff414370),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            const Divider(
                              color: Colors.black,
                              thickness: 1,
                            ),

                            const SizedBox(height: 10),

                            // Medications Section - White Card Style
                            Center(
                              child: Text(
                                'Medications',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Display medications as cards
                            medicationList.isEmpty
                                ? const Text('No medications found.')
                                : Column(
                              children: medicationList.map((med) {
                                final medicationName = med['medicationName'] ?? 'Unknown';
                                final quantity = med['quantity'] ?? 0;
                                final price = med.containsKey('price')
                                    ? (med['price'] * quantity).toStringAsFixed(2)
                                    : 'N/A';

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Color(0xffd4dcee),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                medicationName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Quantity: $quantity",
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                              Text(
                                                "Price: ₪$price",
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Total Amount Box - Fixed at the Bottom
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xff414370),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Total Amount: ₪${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Track Order Button - Fixed at the Bottom
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {
                          // Add the tracking functionality here
                          print("Tracking Order Button Pressed");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderTracking(
                                patientAddress: patientAddress,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          backgroundColor: const Color(0xff414370),
                          minimumSize: const Size(200, 50),
                        ),
                        child: const Text(
                          "Track Order",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

    }
  }
}



