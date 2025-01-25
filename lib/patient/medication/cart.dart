import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'paymentCard.dart'; // تأكد من أنك أضفت الاستيراد الصحيح للصفحة الجديدة
import 'billPage.dart'; // Adjust the path according to your project structure
import 'payment_options_page.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

//class _CartPageState extends State<CartPage> {
class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final String patientId;

  // Declare a GlobalKey to access the state of CartPage

  CartPage({
    required this.cart,
    required this.patientId,
    Key? key,
  }) : super(key: key);

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  // متغير لتخزين حالة التحديد لكل دواء
  Map<int, bool> selectedItems = {};
  List<Map<String, dynamic>> selectedMedications = [];

  // Method to calculate the total price of the selected items (including quantity)
  double getTotalPrice() {
    double total = 0.0;
    for (var item in widget.cart) {
      int index = widget.cart.indexOf(item);
      if (selectedItems[index] ?? false) {
        total += (item['final_price'] * item['quantity']);
      }
    }
    return total;
  }

  String getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:5000"; // For web
    } else {
      return "http://10.0.2.2:5000"; // For mobile (Android emulator)
    }
  }

  // Method to increment the quantity of an item
  void incrementQuantity(int index) async {
    final item = widget.cart[index];
    final medicationName = item['name']; // Get medication name

    // Fetch the cartId using medication name
    final cartId = await fetchCartIdByMedicationName(medicationName);

    if (cartId != null) {
      setState(() {
        widget.cart[index]['quantity']++;
      });

      // Update the quantity in the database using cartId
      await updateQuantityInDatabase(cartId, widget.cart[index]['quantity']);
    } else {
      // Handle error if cartId cannot be fetched
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to retrieve Cart ID."),
        ),
      );
    }
  }


  // Method to decrement the quantity of an item
  void decrementQuantity(int index) async {
    final item = widget.cart[index];
    final medicationName = item['name']; // Get medication name

    // Fetch the cartId using medication name
    final cartId = await fetchCartIdByMedicationName(medicationName);

    if (cartId != null) {
      if (widget.cart[index]['quantity'] > 1) {
        setState(() {
          widget.cart[index]['quantity']--;
        });

        // Update the quantity in the database using cartId
        await updateQuantityInDatabase(cartId, widget.cart[index]['quantity']);
      } else {
        showDeleteConfirmationDialog(context, index);
      }
    } else {
      // Handle error if cartId cannot be fetched
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to retrieve Cart ID."),
        ),
      );
    }
  }


  // Method to show a confirmation dialog before deleting an item
  void showDeleteConfirmationDialog(BuildContext context, int index) async {
    final item = widget.cart[index];
    final medicationName = item['name'];  // Assuming each item has a 'name' field which we will use to fetch the cartId

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete ${item['name']}?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f), // Set the color for the text of the button
              ),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                // Fetch the cartId by medication name from the server
                final cartId = await fetchCartIdByMedicationName(medicationName);

                if (cartId != null) {
                  // Remove the item from the cart list first
                  setState(() {
                    widget.cart.removeAt(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${item['name']} removed from the list."),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  });

                  // Delete the item from the database using cartId
                  await deleteItemFromDatabase(cartId);

                  // Show a confirmation message for removal
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "${item['name']} removed successfully from the database."),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to retrieve Cart ID."),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2f9a8f), // Set the button color
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }


  Future<String?> fetchCartIdByMedicationName(String medicationName) async {
    try {
      final response = await http.get(
        Uri.parse("${getBaseUrl()}/api/healup/cart/medication-id/$medicationName"),  // Endpoint to fetch cartId by medication name
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['cartId'];  // Assuming the response contains the 'cartId'
      } else {
        throw Exception("Failed to fetch Cart ID: ${response.body}");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching Cart ID: $error"),
        ),
      );
      return null;
    }
  }

  Future<String?> fetchCartIdByMedicationId(String medicationId) async {
    try {
      final response = await http.get(
        Uri.parse("${getBaseUrl()}/api/healup/cart/$medicationId"),  // Endpoint to fetch item details by medicationId
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['cartId'];  // Assuming the response contains the 'cartId'
      } else {
        throw Exception("Failed to fetch Cart ID: ${response.body}");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching Cart ID: $error"),
        ),
      );
      return null;
    }
  }


  // Fetch cart items from the server
  Future<void> fetchCartItems() async {
    try {
      final response = await http.get(
          Uri.parse("${getBaseUrl()}/api/healup/cart"));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          widget.cart.clear();
          for (var item in data) {
            widget.cart.add({
              'id': item['id'],
              'name': item['medication_name'],
              'image': item['image'] ?? 'images/default_medicine.png',
              'final_price': item['final_price'],
              'quantity': item['quantity'],
            });
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Failed to fetch cart items: ${response.reasonPhrase}"),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $error"),
        ),
      );
    }
  }

  // Method to delete an item from the database
  Future<void> deleteItemFromDatabase(String cartId) async {
    try {
      final response = await http.delete(
        Uri.parse("${getBaseUrl()}/api/healup/cart/delete/$cartId"),  // Using cartId in the URL
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete item: ${response.body}");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete item: $error"),
        ),
      );
    }
  }


  // Method to update the quantity of an item in the database
  Future<void> updateQuantityInDatabase(String cartId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse("${getBaseUrl()}/api/healup/cart/update/$cartId"), // Using cartId in the URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update quantity");
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update quantity: $error"),
        ),
      );
    }
  }


  Future<String?> fetchMedicationIdByName(String medicationName) async {
    final response = await http.get(
      Uri.parse(
          '${getBaseUrl()}/api/healup/cart/medication-id/$medicationName'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('medicationId')) {
        return data['medicationId']; // return the medication id
      }
    } else {
      print('Error fetching medication id: ${response.body}');
    }

    return null; // Return null if there's an error or the medication is not found
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  bool isAnyItemSelected() {
    // تحديد الأدوية التي تم اختيارها بناءً على الـ Checkbox
    final selectedMedications = widget.cart.where((item) =>
    selectedItems[widget.cart.indexOf(item)] ?? false).toList();
    return selectedMedications.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Cart", style: TextStyle(fontSize: 24)),
          backgroundColor: const Color(0xff414370),
          elevation: 4,
        ),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[400]!, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 20.0),  // Large padding for web
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Check if cart is empty
                widget.cart.isEmpty
                    ? const Center(
                  child: Text(
                    "Your cart is empty.",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color:  Color(0xffe5eeff), // Set the card's background color

                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10.0),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: selectedItems[index] ?? false,
                                onChanged: (bool? value) async {
                                  setState(() {
                                    selectedItems[index] = value ?? false;

                                    if (selectedItems[index] == true) {
                                      selectedMedications.add(widget.cart[index]);
                                    } else {
                                      selectedMedications.removeWhere(
                                            (item) =>
                                        item['id'] == widget.cart[index]['id'],
                                      );
                                    }
                                  });

                                  if (selectedItems[index] == true) {
                                    await fetchMedicationDetails([item['id']]);
                                  }
                                },
                                activeColor: const Color(0xff414370),
                              ),
                              item['image'].isNotEmpty
                                  ? Image.asset(
                                item['image'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                'images/default_medicine.png',
                                width: 70,
                                height: 70,
                              ),
                            ],
                          ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("₪${(item['final_price'] * item['quantity']).toStringAsFixed(2)}"),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => decrementQuantity(index),
                                  ),
                                  Text("${item['quantity']}"),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => incrementQuantity(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => showDeleteConfirmationDialog(context, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Total Price and Confirmation Button
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Price:",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₪${getTotalPrice().toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          List<Map<String, dynamic>> selectedMedicationsDetails = [];

                          if (isAnyItemSelected()) {
                            for (var selectedItem in selectedMedications) {
                              String? medicationId = await fetchMedicationIdByName(selectedItem['name']);
                              selectedMedicationsDetails.add({
                                'name': selectedItem['name'],
                                'quantity': selectedItem['quantity'],
                                'id': medicationId,
                              });
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentOptionsPage(
                                  totalPrice: getTotalPrice(),
                                  patientId: widget.patientId,
                                  selectedMedicationsDetails: selectedMedicationsDetails,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select at least one item to proceed."),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xfff08486), // Customize button color
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        )
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Cart",style: TextStyle(color: Colors.white70,fontSize: 25,fontWeight: FontWeight.bold),),
          backgroundColor: const Color(0xff414370),
        ),
        body: Stack(
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
            widget.cart.isEmpty
                ? const Center(
              child: Text(
                "Your cart is empty.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            )
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        color:  Color(0xffe5eeff), // Set the card's background color

                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: selectedItems[index] ?? false,
                                onChanged: (bool? value) async {
                                  setState(() {
                                    selectedItems[index] = value ?? false;

                                    if (selectedItems[index] == true) {
                                      // Add item to selected list when checked
                                      selectedMedications.add(
                                          widget.cart[index]);
                                    } else {
                                      // Remove item from selected list when unchecked
                                      selectedMedications.removeWhere(
                                            (item) =>
                                        item['id'] == widget.cart[index]['id'],
                                      );
                                    }
                                    // Print the updated list of selected items
                                    print("Updated Selected List:");
                                    for (var item in selectedMedications) {
                                      print(
                                          "ID: ${item['id']}, Name: ${item['name']}, Quantity: ${item['quantity']}");
                                    }
                                  });

                                  if (selectedItems[index] == true) {
                                    // Fetch the medication details from the server
                                    await fetchMedicationDetails([item['id']]);
                                  } else {
                                    // When item is deselected, just print the ID and Name
                                    print('Item deselected:');
                                    print('ID: ${item['id']}');
                                    print('Name: ${item['name']}');
                                  }
                                },
                                activeColor: const Color(0xff414370),
                              ),
                              if (item['image'].isNotEmpty)
                                Image.asset(
                                  item['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              else
                                Image.asset(
                                  'images/default_medicine.png',
                                  width: 50,
                                  height: 50,
                                ),
                            ],
                          ),
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("₪${(item['final_price'] * item['quantity'])
                                  .toStringAsFixed(2)}"),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => decrementQuantity(index),
                                  ),
                                  Text("${item['quantity']}"),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => incrementQuantity(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                showDeleteConfirmationDialog(context, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(

                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.grey[400]!, Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Price:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₪${getTotalPrice().toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          List<Map<String,
                              dynamic>> selectedMedicationsDetails = [];

                          // Check if any item is selected before proceeding
                          if (isAnyItemSelected()) {
                            // List to store the medication IDs for selected items
                            List<String> selectedMedicationIds = [];

                            // Print all selected medications with their details (name, quantity, and id)
                            print("Selected Medications with Details:");
                            for (var selectedItem in selectedMedications) {
                              String? medicationId = await fetchMedicationIdByName(
                                  selectedItem['name']);
                              selectedMedicationsDetails.add({
                                'name': selectedItem['name'],
                                'quantity': selectedItem['quantity'],
                                'id': medicationId,
                              });
                              print(
                                  "Medication: ${selectedItem['name']}, Quantity: ${selectedItem['quantity']}, ID: $medicationId");
                            }
                            print("=================================");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaymentOptionsPage(
                                      totalPrice: getTotalPrice(),
                                      patientId: widget.patientId,
                                      selectedMedicationsDetails: selectedMedicationsDetails, // Pass the list of selected medications
                                    ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Please select at least one item to proceed."),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(
                              0xfff08486), // Set the color for the text of the button
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> fetchMedicationDetails(List<String> ids) async {
    final url = Uri.parse('${getBaseUrl()}/api/healup/cart/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': ids}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> cartItems = jsonDecode(response.body);

        print('Response: $cartItems'); // Log the entire response to debug

        for (var item in cartItems) {
          print('Item selected:');
          print('m_ID: ${item['medication_id']}'); // Ensure medication_id exists in the response
          print('Name: ${item['medication_name']}');
          print('final_price: ₪${(item['final_price'] * item['quantity']).toStringAsFixed(2)}');
          print('Quantity: ${item['quantity']}');
        }
      } else {
        print('Failed to load medication details.');
      }
    } catch (error) {
      print('Error fetching medication details: $error');
    }
  }
}


