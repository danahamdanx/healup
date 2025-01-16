import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:first/patient/medication/stripe_keys.dart';
import 'package:js/js.dart';

class PaymentManagerWeb {
  // Initialize the payment process and call Stripe API
  static Future<void> makePayment(double amount, String currency) async {
    try {
      // Get the client secret (usually from your backend)
      String clientSecret = await _getClientSecret(amount, currency);

      // Initialize the Stripe instance and present the payment UI
      await _initializeStripe(clientSecret);
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  // Create a payment intent (this should ideally come from your backend)
  static Future<String> _getClientSecret(double amount, String currency) async {
    Dio dio = Dio();
    var response = await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
      data: {
        'amount': (amount * 100).toInt().toString(), // Convert to cents
        'currency': currency,
      },
    );
    return response.data["client_secret"];
  }

  // Initialize Stripe via JS interop and confirm the payment
  static Future<void> _initializeStripe(String clientSecret) async {
    // Use JS interop to interact with Stripe
   // final stripe = html.window.Stripe('your-publishable-key-here');

    // Confirm the payment using the Stripe API
   // final result = await stripe.confirmCardPayment(clientSecret);

    //if (result['error'] != null) {
      // Handle error, e.g., show an error message to the user
  //    print('Error confirming payment: ${result['error']}');
   // } else {
      // Payment successful, proceed with confirmation
   //   print('Payment confirmed successfully');
 //   }
  }
}
