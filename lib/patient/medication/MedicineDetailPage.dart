import 'dart:convert'; // For sending data as JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For calling API
import 'medicine.dart';  // Use the shared Medicine model
import 'cart.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class MedicineDetailPage extends StatefulWidget {
  final Medicine medicine; // This will use the shared Medicine model
  final List<Map<String, dynamic>> cart; // Reference to the shared cart list
  final String patientId; // New parameter for patientId

  const MedicineDetailPage({
    super.key,
    required this.medicine,
    required this.cart,
    required this.patientId, // Pass the patientId here
  });

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  int quantity = 1;  // Already defined
  bool _isLoading = false;  // Define _isLoading as a boolean variable

  // Method to increment the quantity of the selected medicine
  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  // Method to decrement the quantity of the selected medicine
  void decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }

  void _addToCart(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add to Cart"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Select Quantity:"),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text(
                        "$quantity",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xff414370), // Set background color
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white, // Set text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Add padding between the buttons
                      ElevatedButton(
                        onPressed: () async {
                          // Add the medicine to the shared cart list
                          widget.cart.add({
                            'name': widget.medicine.medication_name,
                            'quantity': quantity,
                            'price': widget.medicine.final_price,
                            'image': widget.medicine.image,
                          });

                          // Show a success message
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text(
                          //         "$quantity x ${widget.medicine.medication_name} added to cart."),
                          //   ),
                          // );
                          print("+++++++++++++++++++++");
                          print("added to cart");


                          // Call the API to add the medicine to the database
                          await _sendToDatabase();

                          // Close the dialog and page
                         // Navigator.pop(context); // Close the dialog
                          //Navigator.pop(context); // Close the details page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff414370), // Set background color
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white, // Set text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to send data to the server to add to the database
  Future<void> _sendToDatabase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Check if the medication exists in the cart
      final medicationName = widget.medicine.medication_name;

      final getIdResponse = await http.get(
        Uri.parse('${getBaseUrl()}/api/healup/cart/medication-id/$medicationName'),
      );

      if (getIdResponse.statusCode == 200) {
        // Medication found, get the cart ID, medication ID, and current quantity from the response
        final responseJson = json.decode(getIdResponse.body);
        final cartId = responseJson['cartId'];  // Get the cart ID
        final existingQuantity = responseJson['quantity'] ?? 0;  // Get existing quantity if available

        // Step 2: Calculate the new total quantity
        final newQuantity = existingQuantity + quantity;  // Add existing and new quantity

        // Step 3: Update the cart with the new quantity using the cartId
        final updateResponse = await http.put(
          Uri.parse('${getBaseUrl()}/api/healup/cart/update/$cartId'),  // Use cartId instead of medicationId
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'quantity': newQuantity,  // Use the new calculated quantity
          }),
        );

        if (updateResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The medicine quantity has been updated in the cart'),
              backgroundColor: Colors.green,
            ),
          );

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update medicine: ${updateResponse.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // If medication is not found in the cart, add it
        final addResponse = await http.post(
          Uri.parse('${getBaseUrl()}/api/healup/cart/add'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'medication_id': widget.medicine.id,  // Pass the medication id
            'medication_name': widget.medicine.medication_name,
            'image': widget.medicine.image,
            'price': widget.medicine.final_price,
            'quantity': quantity,  // Add the quantity the user selected
          }),
        );

        if (addResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The medicine has been successfully added to the cart'),
              backgroundColor: Colors.green,
            ),
          );
          print("+++++++++++++++++++++");
          print("added to cart");


          // Return to the MedicineDetailPage with updated cart data
          //Navigator.pop(context);  // Pop current page (dialog)
          //Navigator.pop(context);  // Pop the current MedicineDetailPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MedicineDetailPage(
                medicine: widget.medicine,
                cart: widget.cart,  // Pass the updated cart data
                patientId: widget.patientId, // Pass the patientId again
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add medicine: ${addResponse.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while adding. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web-specific layout adjustments
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.medicine.medication_name,style: TextStyle(color: Colors.white70),),
          backgroundColor: const Color(0xff414370),
        ),

        body:Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[400]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Center(  // This will center everything on the web screen
              child: Padding(
                padding: const EdgeInsets.all(40.0),  // Add padding for web
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Center the image and make it smaller on web
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 250, // Smaller height for the image on web
                        child: Image.asset(
                          widget.medicine.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),  // Space between the image and content
                    // Medicine name
                    Text(
                      widget.medicine.medication_name,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Medicine description
                    Text(
                      widget.medicine.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // عرض dosage بعد الوصف
                    Text(
                      "Dosage: ${widget.medicine.dosage}",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Medicine price
                    Text(
                      "₪${widget.medicine.final_price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff800020),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Add to Cart button with larger size
                    ElevatedButton(
                      onPressed: () {
                        _addToCart(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff414370),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),  // Increased padding for a larger button
                        textStyle: const TextStyle(fontSize: 24),  // Increased font size
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,  // Increased font size for the button text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        )

      );
    }  else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.medicine.medication_name,style: TextStyle(color: Colors.white70,fontWeight: FontWeight.bold,fontSize: 25),),
          backgroundColor: const Color(0xff414370), // تغيير اللون هنا
        ),

        body: Stack(
          children: [
            // Background image
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Medicine image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 350,
                          child: Image.asset(
                            widget.medicine.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Medicine name
                      Text(
                        widget.medicine.medication_name,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Medicine description
                      Text(
                        widget.medicine.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // عرض dosage بعد الوصف
                      Text(
                        "Dosage: ${widget.medicine.dosage}",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Medicine price
                      Text(
                        "₪${widget.medicine.final_price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff800020),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Add to Cart button
                      ElevatedButton(
                        onPressed: () {
                          _addToCart(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff414370),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
