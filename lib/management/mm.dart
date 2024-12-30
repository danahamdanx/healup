
// return AlertDialog(
// title: Text("Confirm Delete"),
// content: Text("Are you sure you want to delete ${item['name']}?"),
// actions: [
// TextButton(
// onPressed: () {
// Navigator.of(context).pop(); // Close the dialog
// },
// style: TextButton.styleFrom(
// backgroundColor: const Color(0xff2f9a8f), // Set the color for the text of the button
// ),
// child: const Text("Cancel"),
// ),
// ElevatedButton(
// onPressed: () async {
// Navigator.of(context).pop(); // Close the dialog
//
// // Fetch the cartId by medication name from the server
// final cartId = await fetchCartIdByMedicationName(medicationName);
//
// if (cartId != null) {
// // Remove the item from the cart list first
// setState(() {
// widget.cart.removeAt(index);
// ScaffoldMessenger.of(context).showSnackBar(
// SnackBar(
// content: Text("${item['name']} removed from the list."),
// duration: const Duration(seconds: 2),
// ),
// );
// });
//
// // Delete the item from the database using cartId
// await deleteItemFromDatabase(cartId);
//
// // Show a confirmation message for removal
// ScaffoldMessenger.of(context).showSnackBar(
// SnackBar(
// content: Text(
// "${item['name']} removed successfully from the database."),
// duration: const Duration(seconds: 2),
// ),
// );
// } else {
// ScaffoldMessenger.of(context).showSnackBar(
// SnackBar(
// content: Text("Failed to retrieve Cart ID."),
// duration: const Duration(seconds: 2),
// ),
// );
// }
// },
// style: ElevatedButton.styleFrom(
// backgroundColor: const Color(0xff2f9a8f), // Set the button color
// ),
// child: const Text("Delete"),
// ),
// ],
// // );