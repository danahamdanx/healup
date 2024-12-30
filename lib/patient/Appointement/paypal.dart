// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';
//
// class PayPalPayment extends StatefulWidget {
//   final double totalPrice;
//   final String currency;
//
//   const PayPalPayment({
//     Key? key,
//     required this.totalPrice,
//     required this.currency,
//   }) : super(key: key);
//
//   @override
//   _PayPalPaymentState createState() => _PayPalPaymentState();
// }
//
//
// class _PayPalPaymentState extends State<PayPalPayment> {
//   final String clientId = "AWl8BrcC_9CMymu9yJyWKNfvqCEtFZaJ2BVNstPBO75aacWOGx9kkcTZEP66RQXfWkiefPxx9Oe25rPC";
//   final String secretKey = "EAP5UXYTrQTtLczOUnN2QjzQQgB0_ovdgcJZ6qqEHAHwPQJwKEcsG8jybtJ4QaNFTbWM-6UqhfRkdNnu";
//   final String returnURL = "success.snippetcoder.com";
//   final String cancelURL = "cancel.snippetcoder.com";
//
//   // دالة لإنشاء الطلب
//   Future<String> createOrder() async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:5000/api/healup/paypal/create-order'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'amount': widget.totalPrice.toStringAsFixed(2), // Dynamic total price
//           'currency': widget.currency,                  // Dynamic currency
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final String approvalUrl = responseData['approvalUrl'];
//
//         if (await canLaunch(approvalUrl)) {
//           await launch(approvalUrl); // Open approval URL in browser
//         } else {
//           throw Exception('Could not launch approval URL');
//         }
//         return responseData['id'];
//       } else {
//         throw Exception('Failed to create order');
//       }
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
//
//
//   // دالة لالتقاط الدفع
//   Future<void> capturePayment(String orderId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:5000/api/healup/paypal/capture-order'), // استبدل بعنوان IP الخاص بك
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'orderId': orderId}),
//       );
//
//       if (response.statusCode == 200) {
//         print('Payment captured: ${response.body}');
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Payment Successful'),
//             content: Text('The payment was successfully captured.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         print('Failed to capture payment: ${response.body}');
//         throw Exception('Payment capture failed');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   // دالة لبدء الدفع
//   Future<void> startPayment() async {
//     try {
//       String orderId = await createOrder();
//       // بعد تأكيد المشتري على الدفع عبر PayPal، قم بالاتصال بهذا الكود لالتقاط الدفع
//       // لاحظ أن هذا سيحدث بعد أن يتم تأكيد الدفع من قبل المستخدم عبر المتصفح.
//     } catch (e) {
//       print('Payment error: $e');
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Payment Failed'),
//           content: Text('There was an error with the payment process: $e'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PayPal Payment'),
//         backgroundColor: const Color(0xff2f9a8f),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: startPayment,
//           child: const Text('Pay with PayPal'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Color(0xff2f9a8f),
//             foregroundColor: Colors.white,
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             textStyle: TextStyle(fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'bill.dart';
import 'package:intl/intl.dart';  // Import the intl package for DateFormat

class PayPal extends StatefulWidget {
  final double totalPrice;
  final String currency;
  final String patientId; // Patient ID passed from the login page
  final String prescriptionId;
  final String patientAddress;  // Add patientAddress

  const PayPal({
    Key? key,
    required this.totalPrice,
    required this.currency,
    required this.patientId,
    required this.prescriptionId,
    required this.patientAddress,

  }) : super(key: key);

  @override
  _PayPalPaymentState createState() => _PayPalPaymentState();
}

class _PayPalPaymentState extends State<PayPal> {
  final String clientId = "AWl8BrcC_9CMymu9yJyWKNfvqCEtFZaJ2BVNstPBO75aacWOGx9kkcTZEP66RQXfWkiefPxx9Oe25rPC";
  final String secretKey = "EAP5UXYTrQTtLczOUnN2QjzQQgB0_ovdgcJZ6qqEHAHwPQJwKEcsG8jybtJ4QaNFTbWM-6UqhfRkdNnu";
  final String returnURL = "success.snippetcoder.com";
  final String cancelURL = "cancel.snippetcoder.com";

  Future<String> createOrder() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/healup/paypal/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': widget.totalPrice.toStringAsFixed(2),
          'currency': widget.currency,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String approvalUrl = responseData['approvalUrl'];

        // Redirect to PayPal for approval
        if (await canLaunch(approvalUrl)) {
          await launch(approvalUrl);
        } else {
          throw Exception('Could not launch approval URL');
        }

        return responseData['id']; // Return the order ID
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }




  Future<void> capturePayment(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/healup/paypal/capture-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Payment captured successfully: ${responseData}');
        _showDialog('Payment Successful', 'The payment was successfully captured.', true);
      } else {
        print('Failed to capture payment: ${response.body}');
        throw Exception('Payment capture failed');
      }
    } catch (e) {
      _showDialog('Payment Failed', 'Error: $e', false);
    }
  }


  void _showDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(isSuccess); // Return to previous page
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> startPayment() async {
    try {
      String orderId = await createOrder();
      await capturePayment(orderId);
    } catch (e) {
      _showDialog('Payment Failed', 'Error: $e', false);
    }
  }


  Future<void> addOrderByPrescription(String prescriptionId, String orderDate) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/healup/orders/create-by-prescription'),
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

        double totalPrice = widget.totalPrice+5; // You can adjust this based on your order data
        String paymentMethod = "Card"; // Set payment method to Cash (or you can use other methods)

        // Call the payment creation API
        //await createPayment(orderId, totalPrice, paymentMethod);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );
        await createPayment(orderId, totalPrice, paymentMethod);

        await createBilling(orderId);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Bill(
        //       billingId: billingId,  // Pass billingId
        //       patientAddress: patientAddress,  // Pass patientAddress
        //     ),
        //   ),
        // );

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
        Uri.parse('http://10.0.2.2:5000/api/healup/payment/add'),
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
        Uri.parse('http://10.0.2.2:5000/api/healup/billing/add'),
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
              patientAddress: widget.patientAddress,  // Pass patientAddress
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
        Uri.parse('http://10.0.2.2:5000/api/healup/payment/update/$paymentId'),
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
        Uri.parse('http://10.0.2.2:5000/api/healup/billing/update/$billingId'),
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
    print('++++++++++++++++++++++++++++++++++++++');
    print('Patient id : ${widget.patientId}');
    print('total price: ${widget.totalPrice}');
    print('Prescription id: ${widget.prescriptionId}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
        backgroundColor: const Color(0xff2f9a8f),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            String orderDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

            // طباعة التاريخ في الـ console أو في واجهة المستخدم
            print("Order Date: $orderDate");
            addOrderByPrescription(widget.prescriptionId, orderDate);

            //await addOrderByPrescription();  // Ensure that the async function is awaited properly
          },
          //onPressed: startPayment,
          child: const Text('Pay with PayPal'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff2f9a8f),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}