import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mappage.dart';
import 'package:intl/intl.dart';  // Import the intl package for DateFormat
import 'bill.dart';
import 'paymentManager2.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class PaymentOptions extends StatefulWidget {
  final double totalPrice;
  final String patientId;
  final String prescriptionId; // إضافة prescriptionId

  PaymentOptions({
    Key? key,
    required this.totalPrice,
    required this.patientId,
    required this.prescriptionId,  // إضافة prescriptionId
  }) : super(key: key);

  @override
  _PaymentOptionsState createState() => _PaymentOptionsState();
}
class _PaymentOptionsState extends State<PaymentOptions> {
  late String patientAddress;
  bool isLoading = true;
  final TextEditingController _addressController = TextEditingController(); // Controller for user input

  // Create a GlobalKey for CartPage to access the CartPage state
  //final GlobalKey<CartPageState> cartPageKey = GlobalKey<CartPageState>();
  final double conversionRate = 0.27;
  late double totalPriceUSD; // Declare totalPriceUSD as a late variable

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
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

  Future<void> addOrderByPrescription_cash(String prescriptionId, String orderDate) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/healup/orders/create-by-prescription'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prescription_id': prescriptionId,
          'order_date': orderDate,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Handle successful order creation (e.g., show a confirmation message)
        final String orderId = data['order']['_id'];  // Adjust according to your response structure

        print("Order Created Successfully: ${data['message']}");
        print("Order ID: $orderId"); // Print the orderId to the console

        double totalPrice = widget.totalPrice+18.5; // You can adjust this based on your order data

        // Call the payment creation API
        //await createPayment(orderId, totalPrice, paymentMethod);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
        await createPayment(orderId, totalPrice, "Cash");

        await createBilling(orderId);

      } else {
        final data = json.decode(response.body);
        print("Error: ${data['message']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> addOrderByPrescription_card(String prescriptionId, String orderDate) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/healup/orders/create-by-prescription'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prescription_id': prescriptionId,
          'order_date': orderDate,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Handle successful order creation (e.g., show a confirmation message)
        final String orderId = data['order']['_id'];  // Adjust according to your response structure

        print("Order Created Successfully: ${data['message']}");
        print("Order ID: $orderId"); // Print the orderId to the console

        double totalPrice = widget.totalPrice+18.5; // You can adjust this based on your order data

        // Call the payment creation API
        //await createPayment(orderId, totalPrice, paymentMethod);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
        await createPayment(orderId, totalPrice, "Card");

        await createBilling(orderId);

      } else {
        final data = json.decode(response.body);
        print("Error: ${data['message']}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  Future<void> createPayment(String orderId, double totalPrice, String paymentMethod) async {
    try {
      final paymentResponse = await http.post(
        Uri.parse('${getBaseUrl()}/api/healup/payment/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderId': orderId,
          'amount': totalPrice,
          'method': paymentMethod,
          'status': 'pending',  // Default payment status is "pending"
          'currency': 'USD',  // You can change the currency if needed
        }),
      );

      if (paymentResponse.statusCode == 201) {
        final paymentData = json.decode(paymentResponse.body);
        print("Payment Created Successfully: ${paymentData}");

        final String paymentId = paymentData['_id'];  // Adjust the key according to your response structure
        print("Payment ID: $paymentId");


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment created successfully!')),
        );
        await updatePayment(paymentId);

      } else {
        final paymentData = json.decode(paymentResponse.body);
        print("Payment Error: ${paymentData['message']}");
      }
    } catch (e) {
      print("Error in payment: $e");
    }
  }
  Future<void> createBilling(String orderId) async {
    try {
      final billingResponse = await http.post(
        Uri.parse('${getBaseUrl()}/api/healup/billing/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'orderId': orderId,
          'paymentStatus': 'Pending',  // Default payment status is "Pending"
        }),
      );

      if (billingResponse.statusCode == 201) {
        final billingData = json.decode(billingResponse.body);
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
            builder: (context) => Bill(
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
    print("+++++++++++++++++++++++++++++++++++++++++++++++");

    print("Patient ID: ${widget.patientId}");
    print("Total Price: \$${widget.totalPrice}");
    print("Prescription id : ${widget.prescriptionId}");

    if (kIsWeb) {
      // Web version
      return Scaffold(
        appBar: AppBar(
          title: const Text("Confirm order"),
          backgroundColor: const Color(0xff2f9a8f),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/back.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
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
                              0xff2f9a8f), // Use the desired color for the text
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
                          color: Colors.black,
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
                                String orderDate = DateFormat('yyyy-MM-dd').format(
                                    DateTime.now());

                                await PaymentManager2.makePayment(
                                    totalPriceUSD, "USD");
                                await addOrderByPrescription_card(
                                    widget.prescriptionId, orderDate);
                                // Make sure to call the addOrder_card method here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2f9a8f),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: const Text(
                                "Pay with Card",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20), // إضافة مسافة بين الأزرار
                            ElevatedButton(
                              onPressed: () async {
                                String orderDate = DateFormat('yyyy-MM-dd').format(
                                    DateTime.now());

                                // طباعة التاريخ في الـ console أو في واجهة المستخدم
                                print("Order Date: $orderDate");
                                addOrderByPrescription_cash(
                                    widget.prescriptionId, orderDate);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2f9a8f),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: const Text(
                                "Pay with Cash",
                                style: TextStyle(fontSize: 18, color: Colors.white),
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
    else {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Confirm order"),
      backgroundColor: const Color(0xff2f9a8f),
    ),
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/back.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
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
                          0xff2f9a8f), // Use the desired color for the text
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
                      color: Colors.black,
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
                            String orderDate = DateFormat('yyyy-MM-dd').format(
                                DateTime.now());

                            await PaymentManager2.makePayment(
                                totalPriceUSD, "USD");
                            await addOrderByPrescription_card(
                                widget.prescriptionId, orderDate);
                            // Make sure to call the addOrder_card method here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2f9a8f),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                          child: const Text(
                            "Pay with Card",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20), // إضافة مسافة بين الأزرار
                        ElevatedButton(
                          onPressed: () async {
                            String orderDate = DateFormat('yyyy-MM-dd').format(
                                DateTime.now());

                            // طباعة التاريخ في الـ console أو في واجهة المستخدم
                            print("Order Date: $orderDate");
                            addOrderByPrescription_cash(
                                widget.prescriptionId, orderDate);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff2f9a8f),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                          child: const Text(
                            "Pay with Cash",
                            style: TextStyle(fontSize: 18, color: Colors.white),
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



