import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; // Add this import to use SocketException
import 'package:flutter/foundation.dart'; // For kIsWeb


class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  OrderDetailsPage({required this.orderId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic> orderDetails = {};

  Future<void> fetchOrderDetails() async {
    if(kIsWeb){
      try {
        final response = await http.get(
          Uri.parse("http://localhost:5000/api/healup/orders/${widget.orderId}"),
        );
        if (response.statusCode == 200) {
          setState(() {
            orderDetails = jsonDecode(response.body);
          });
          print('========================='); // طباعة تفاصيل الطلب

          print('Order Details: $orderDetails'); // طباعة تفاصيل الطلب

          getPaymentByOrderId(widget.orderId);
          getBillingByOrderId(widget.orderId); // Pass the orderId directly here
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch order details")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }
    else{
      try {
        final response = await http.get(
          Uri.parse("http://10.0.2.2:5000/api/healup/orders/${widget.orderId}"),
        );
        if (response.statusCode == 200) {
          setState(() {
            orderDetails = jsonDecode(response.body);
          });
          print('========================='); // طباعة تفاصيل الطلب

          print('Order Details: $orderDetails'); // طباعة تفاصيل الطلب

          getPaymentByOrderId(widget.orderId);
          getBillingByOrderId(widget.orderId); // Pass the orderId directly here
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch order details")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $error")),
        );
      }

    }

  }

  Future<List<dynamic>?> getPaymentByOrderId(String orderId) async {
    if(kIsWeb){
      final url = Uri.parse(
          'http://localhost:5000/api/healup/payment/order/$orderId');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          var payments = data is List ? data : data['payments'];

          if (payments != null && payments.isNotEmpty) {
            setState(() {
              orderDetails['payments'] = payments;
            });
          }

          return payments;
        } else {
          throw Exception('Failed to load payments');
        }
      } catch (error) {
        throw Exception("An error occurred while fetching payments");
      }

    }
    else{
      final url = Uri.parse(
          'http://10.0.2.2:5000/api/healup/payment/order/$orderId');

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          var payments = data is List ? data : data['payments'];

          if (payments != null && payments.isNotEmpty) {
            setState(() {
              orderDetails['payments'] = payments;
            });
          }

          return payments;
        } else {
          throw Exception('Failed to load payments');
        }
      } catch (error) {
        throw Exception("An error occurred while fetching payments");
      }

    }

  }

  Future<void> getBillingByOrderId(String orderId) async {
    if(kIsWeb){
      final url = 'http://localhost:5000/api/healup/billing/order/$orderId';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final List<dynamic> billings = jsonDecode(response.body);

          setState(() {
            orderDetails['billings'] = billings;
          });
        } else {
          print('Failed to load billings');
        }
      } catch (error) {
        print('Error: $error');
      }

    }
    else{
      final url = 'http://10.0.2.2:5000/api/healup/billing/order/$orderId';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final List<dynamic> billings = jsonDecode(response.body);

          setState(() {
            orderDetails['billings'] = billings;
          });
        } else {
          print('Failed to load billings');
        }
      } catch (error) {
        print('Error: $error');
      }

    }

  }

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Widget _buildTextField(String label, dynamic value) {
    String displayValue = value is double
        ? value.toStringAsFixed(2)
        : value is int
        ? value.toString()
        : value ?? "N/A";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: displayValue,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[400]!,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[400]!,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff414370),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Order Details ",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
             //fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xff414370),
          iconTheme: const IconThemeData(
            color: Colors.white70,  // تغيير لون سهم التراجع
          ),
        ),
        body: Container(
          width: double.infinity, // لجعل الخلفية تمتد على كامل الصفحة
          height: double.infinity, // لجعل الخلفية تمتد على كامل الصفحة
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xfff3efd9), Colors.white],  // التدرج اللوني
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: orderDetails.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // موازاة العناصر إلى المنتصف
              mainAxisAlignment: MainAxisAlignment.center, // لضمان أن العناصر في المنتصف
              children: [
                // Order Details Card
                Center(
                  child: Container(
                    width: 600, // تحديد العرض للحد من الامتداد
                    child: _buildCard(
                      "Order Details",
                      [
                        _buildTextField("Order ID", orderDetails['_id']),
                        _buildTextField("Patient", orderDetails['patient_id']['username']),
                        _buildTextField("Order Date", orderDetails['order_date']),
                        _buildTextField(
                            "Medications",
                            orderDetails['medications']?.map((med) {
                              String medicationName = med['medication_id'] != null
                                  ? med['medication_id']['medication_name'] ?? 'Unknown medication'
                                  : 'Unknown medication';
                              int quantity = med['quantity'] ?? 0;
                              return "$medicationName (x$quantity)";
                            })?.join(", ") ?? "No medications"
                        ),
                      ],
                    ),
                  ),
                ),
                // Payment Details Card
                if (orderDetails['payments'] != null && orderDetails['payments'].isNotEmpty)
                  Center(
                    child: Container(
                      width: 600, // تحديد العرض للحد من الامتداد
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: orderDetails['payments'].map<Widget>((payment) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField("Payment ID", payment['_id']),
                              _buildTextField("Amount", payment['amount']),
                              _buildTextField("Payment Method", payment['method']),
                              _buildTextField("Status", payment['status']),
                              _buildTextField("Currency", payment['currency']),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                // Billing Details Card
                if (orderDetails['billings'] != null && orderDetails['billings'].isNotEmpty)
                  Center(
                    child: Container(
                      width: 600, // تحديد العرض للحد من الامتداد
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: orderDetails['billings'].map<Widget>((billing) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTextField("Billing ID", billing['_id']),
                              _buildTextField("Payment Status", billing['paymentStatus']),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Order Details ",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white70,
              //fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xff414370),
          iconTheme: const IconThemeData(
            color: Colors.white70,  // تغيير لون سهم التراجع
          ),
        ),
        body:

        orderDetails.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Details Card
              // Inside the build method of OrderDetailsPage
              _buildCard(
                "Order Details",
                [
                  _buildTextField("Order ID", orderDetails['_id']),
                  _buildTextField("Patient", orderDetails['patient_id']['username']),
                  _buildTextField("Order Date", orderDetails['order_date']),
                  _buildTextField(
                      "Medications",
                      orderDetails['medications']?.map((med) {
                        // Ensure med['medication_id'] is not null before accessing medication_name
                        String medicationName = med['medication_id'] != null
                            ? med['medication_id']['medication_name'] ?? 'Unknown medication'
                            : 'Unknown medication';
                        // Ensure quantity is also checked
                        int quantity = med['quantity'] ?? 0;

                        return "$medicationName (x$quantity)";
                      })?.join(", ") ?? "No medications"
                  ),
                ],
              ),

              if (orderDetails['payments'] != null &&
                  orderDetails['payments'].isNotEmpty)
                _buildCard(
                  "Payment Details",
                  orderDetails['payments'].map<Widget>((payment) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField("Payment ID", payment['_id']),
                        _buildTextField("Amount", payment['amount']),
                        _buildTextField("Payment Method", payment['method']),
                        _buildTextField("Status", payment['status']),
                        _buildTextField("Currency", payment['currency']),
                      ],
                    );
                  }).toList(),
                ),
              // Billing Details Card
              if (orderDetails['billings'] != null &&
                  orderDetails['billings'].isNotEmpty)
                _buildCard(
                  "Billing Details",
                  orderDetails['billings'].map<Widget>((billing) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField("Billing ID", billing['_id']),
                        _buildTextField(
                            "Payment Status", billing['paymentStatus']),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        //),
      );
    }

    }

    }
