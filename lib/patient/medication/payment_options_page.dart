import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart.dart';
import 'package:intl/intl.dart';  // Import the intl package for DateFormat
import "BillPage.dart";
import 'paymentManager.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb




class PaymentOptionsPage extends StatefulWidget {
  final double totalPrice;
  final String patientId;
 // final List<Map<String, dynamic>> cart;
  final List<Map<String, dynamic>> selectedMedicationsDetails; // Add the new parameter


  PaymentOptionsPage({
    Key? key,
    required this.totalPrice,
    required this.patientId,
    //required this.cart,
    required this.selectedMedicationsDetails, // Update constructor to include this
  }) : super(key: key);

  @override
  _PaymentOptionsPageState createState() => _PaymentOptionsPageState();
}

class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
  late String patientAddress;
  bool isLoading = true;
  final TextEditingController _addressController = TextEditingController(); // Controller for user input

  bool isMedicationsLoaded = false; // New flag to check if medications are loaded

  // Create a GlobalKey for CartPage to access the CartPage state
  final GlobalKey<CartPageState> cartPageKey = GlobalKey<CartPageState>();
  final double conversionRate = 0.27;
  late double totalPriceUSD; // Declare totalPriceUSD as a late variable

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();

    // Calculate totalPriceUSD here when widget is available
    totalPriceUSD =( widget.totalPrice * conversionRate)+5;

  }
  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }

  Future<void> fetchPatientDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/healup/patients/getPatientById/${widget.patientId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          patientAddress = data['address'] ?? 'Address not available';
          isLoading = false;
        });
      } else {
        setState(() {
          patientAddress = 'Address not available';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        patientAddress = 'Error fetching address';
        isLoading = false;
      });
    }
  }

  // Method to show dialog for changing the pickup location
  void _showChangeLocationDialog() {
    _addressController.text = patientAddress; // Pre-fill the current address

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Pickup Location"),
          content: TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: "Enter new address",
            ),
            keyboardType: TextInputType.streetAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                setState(() {
                  patientAddress = _addressController.text; // Update address
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to call the 'addOrder' API
  Future<void> addOrder_cash() async {
    String orderDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, dynamic>> medicationList = widget.selectedMedicationsDetails.map((med) {
      return {
        'medication_id': med['id'],
        'quantity': med['quantity'],
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/healup/orders/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': widget.patientId,
          'medications': medicationList,
          'order_date': orderDate,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Order placed successfully! Order ID: ${data['orderId']}, Serial Number: ${data['serialNumber']}");

        double totalPrice = widget.totalPrice+18.5; // You can adjust this based on your order data

        //print("Total Price: \$${totalPrice}");
        //print("Payment Method: $paymentMethod");

        await createPayment(data['orderId'], totalPrice, "Cash");
        await createBilling(data['orderId']);


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
      } else {
        print("Failed to place order: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order!')),
        );
      }
    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order!')),
      );
    }
  }

  Future<void> addOrder_card() async {
    String orderDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    List<Map<String, dynamic>> medicationList = widget.selectedMedicationsDetails.map((med) {
      return {
        'medication_id': med['id'],
        'quantity': med['quantity'],
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/healup/orders/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'patient_id': widget.patientId,
          'medications': medicationList,
          'order_date': orderDate,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print("Order placed successfully! Order ID: ${data['orderId']}, Serial Number: ${data['serialNumber']}");

        double totalPrice = widget.totalPrice+18.5; // You can adjust this based on your order data

        //print("Total Price: \$${totalPrice}");
        //print("Payment Method: $paymentMethod");

        await createPayment(data['orderId'], totalPrice, "Card");
        await createBilling(data['orderId']);


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
      } else {
        print("Failed to place order: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order!')),
        );
      }
    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order!')),
      );
    }
  }

  Future<void> createPayment(String orderId, double totalPrice, String paymentMethod) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/healup/payment/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderId': orderId,
          'amount': totalPrice,
          'method': paymentMethod,
          'status': 'completed', // Assuming the payment is completed
          'currency': 'USD', // Set your default currency (USD in this case)
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final String paymentId = data['_id']; // Extracting paymentId from the response

        print("Payment created successfully! Payment ID: ${data['_id']}");
        print("Payment created successfully! Payment ID: $paymentId");

        await updatePayment(paymentId);


      } else {
        print("Failed to create payment: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create payment!')),
        );
      }
    } catch (e) {
      print("Error creating payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating payment!')),
      );
    }
  }
  Future<void> createBilling(String orderId) async {
    try {
      final billingResponse = await http.post(
        Uri.parse('${getBaseUrl()}/api/healup/billing/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderId': orderId,
          'paymentStatus': 'Pending', // Default payment status is "Pending"
        }),
      );

      if (billingResponse.statusCode == 201) {
        final billingData = json.decode(billingResponse.body);
       // final String billingid = billingData['_id']; // Extracting paymentId from the response

        print("Billing Created Successfully: ${billingData}");

        // Assuming the response contains a billing ID (optional to print if needed)
        // Extract billingId and ensure it's not null
        final billingId = billingData['billing']?['_id'];

        if (billingId == null) {
          throw Exception("Billing ID is missing in the response.");
        }

        print("Billing ID: $billingId");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Billing created successfully!')),
        );
        await updateBilling(billingId);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BillPage(
              billingId: billingId,  // Pass billingId
              patientAddress: patientAddress,  // Pass patientAddress
            ),
          ),
        );
      } else {
        final billingData = json.decode(billingResponse.body);
        print("Billing Error: ${billingData['message']}");
      }
    } catch (e) {
      print("Error in billing: $e");
    }
  }

  Future<void> updatePayment(String paymentId) async {
    try {
      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/healup/payment/update/$paymentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': 'Completed',
        }),
      );

      if (response.statusCode == 200) {
        print("Payment updated successfully!");
      } else {
        final paymentData = json.decode(response.body);
        print("Payment update error: ${paymentData['message']}");
      }
    } catch (e) {
      print("Error updating payment: $e");
    }
  }

  Future<void> updateBilling(String billingId) async {
    try {
      final response = await http.put(
        Uri.parse('${getBaseUrl()}/api/healup/billing/update/$billingId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'paymentStatus': 'Completed',
        }),
      );

      if (response.statusCode == 200) {
        print("Billing updated successfully!");
      } else {
        final billingData = json.decode(response.body);
        print("Billing update error: ${billingData['message']}");
      }
    } catch (e) {
      print("Error updating billing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Print patientId and totalPrice for debugging
    print("++++++++++++++++++++++++++++++++++++++");

    print("Patient ID: ${widget.patientId}");
    print("Total Price: \$${widget.totalPrice}");

    // Ensure medications data is passed and not empty
    if (widget.selectedMedicationsDetails != null && widget.selectedMedicationsDetails.isNotEmpty) {
      print("Selected Medications: ");
      for (var medication in widget.selectedMedicationsDetails) {
        print("Medication: ${medication['name']}, Quantity: ${medication['quantity']}, ID: ${medication['id']}");
      }
      setState(() {
        isMedicationsLoaded = true; // Mark medications as loaded
      });
    } else {
      print("No medications available.");
    }

    if(kIsWeb){return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm order"),
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
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color:  Color(0xffe5eeff), // Set the card's background color
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              width: 400,
              height: 600,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Your Pickup location : ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? CircularProgressIndicator()
                      : Text(
                    patientAddress,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: _showChangeLocationDialog,
                    // Show dialog when pressed
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    child: const Text(
                      "Change Pickup Location",
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(
                            0xff414370), // Use the desired color for the text
                      ),
                    ),
                  ),
                  const Text(
                    " ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8), // حشو داخل الحافة
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFB0B0B0),
                        // لون الحدود الأسود الفاتح (رمادي غامق)

                        //color: Colors.black, // اللون الأسود للحدود
                        width: 1, // سمك الحدود (رفيع)
                      ),
                      borderRadius: BorderRadius.circular(
                          4), // حواف دائرية خفيفة (اختياري)
                    ),
                    child: const Text(
                      "Delivery fees \$5",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff800020),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // لضبط المحاذاة إلى اليسار
                    children: [
                      const Text(
                        "Choose Payment Method",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // توزيع المسافة بالتساوي بين الأزرار
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await PaymentManager.makePayment(
                                  totalPriceUSD, "USD");
                              await addOrder_card(); // Make sure to call the addOrder_card method here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff414370),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                            ),
                            child: const Text(
                              "Pay with Card",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // إضافة مسافة بين الأزرار
                          ElevatedButton(
                            onPressed: () async {
                              String orderDate = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now());

                              // طباعة التاريخ في الـ console أو في واجهة المستخدم
                              print("Order Date: $orderDate");
                              addOrder_cash(); // Call the addOrder function to create the order

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff414370),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                            ),
                            child: const Text(
                              "Pay with Cash",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                          //const SizedBox(width: 20),
                          // إضافة مسافة بين الأزرار
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
    }else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Confirm order",style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold,fontSize: 25),),
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
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color:  Color(0xffe5eeff), // Set the card's background color
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                width: 400,
                height: 600,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Your Pickup location : ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    isLoading
                        ? CircularProgressIndicator()
                        : Text(
                      patientAddress,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: _showChangeLocationDialog,
                      // Show dialog when pressed
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        "Change Pickup Location",
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(
                              0xff414370), // Use the desired color for the text
                        ),
                      ),
                    ),
                    const Text(
                      " ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8), // حشو داخل الحافة
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFB0B0B0),
                          // لون الحدود الأسود الفاتح (رمادي غامق)

                          //color: Colors.black, // اللون الأسود للحدود
                          width: 1, // سمك الحدود (رفيع)
                        ),
                        borderRadius: BorderRadius.circular(
                            4), // حواف دائرية خفيفة (اختياري)
                      ),
                      child: const Text(
                        "Delivery fees \$5",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff800020),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // لضبط المحاذاة إلى اليسار
                      children: [
                        const Text(
                          "Choose Payment Method",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // توزيع المسافة بالتساوي بين الأزرار
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await PaymentManager.makePayment(
                                    totalPriceUSD, "USD");
                                await addOrder_card(); // Make sure to call the addOrder_card method here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff414370),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: const Text(
                                "Pay with Card",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // إضافة مسافة بين الأزرار
                            ElevatedButton(
                              onPressed: () async {
                                String orderDate = DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now());

                                // طباعة التاريخ في الـ console أو في واجهة المستخدم
                                print("Order Date: $orderDate");
                                addOrder_cash(); // Call the addOrder function to create the order

                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff414370),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: const Text(
                                "Pay with Cash",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            //const SizedBox(width: 20),
                            // إضافة مسافة بين الأزرار
                          ],
                        ),
                      ],
                    )
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



