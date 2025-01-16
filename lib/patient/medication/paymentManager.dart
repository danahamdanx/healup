import 'package:dio/dio.dart';
import 'package:first/patient/medication/stripe_keys.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart'; // Import this to use kIsWeb
import 'dart:js' as js;

abstract class PaymentManager {
  // Declare the JavaScript function using the @JS() annotation

  static Future<void> makePayment(double amount, String currency) async {
    try {
      // Convert amount to cents (multiply by 100) and cast to int
      int amountInCents = (amount * 100).toInt();

      if (kIsWeb) {
        // Handle web-specific logic (using Stripe's JavaScript SDK)
        String clientSecret = await _simulatePaymentIntent(amountInCents, currency);

        // Call the JavaScript function to initialize Stripe
        if (js.context.hasProperty('initializeStripe')) {
          js.context.callMethod('initializeStripe', [clientSecret, ApiKeys.publishableKey]);
        } else {
          throw Exception('initializeStripe method not found.');
        }

      } else {
        // Handle mobile-specific logic (using flutter_stripe package)
        String clientSecret = await _getClientSecret(amountInCents.toString(), currency);
        await _initializePaymentSheet(clientSecret);
        await Stripe.instance.presentPaymentSheet();
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  // For web, simulate backend payment intent creation
  static Future<String> _simulatePaymentIntent(int amount, String currency) async {
    Dio dio = Dio();
    var response = await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretKey}', // Secret key for backend requests
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      ),
      data: {
        'amount': amount.toString(),
        'currency': currency,
      },
    );
    return response.data['client_secret'];
  }

  // Mobile: Initialize Payment Sheet using flutter_stripe package
  static Future<void> _initializePaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "Siwar",
      ),
    );
  }

  // Mobile: Get client secret for mobile payments (iOS/Android) from your backend
  static Future<String> _getClientSecret(String amount, String currency) async {
    Dio dio = Dio();
    var response = await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretKey}', // Secret Key used for backend requests
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
      data: {
        'amount': amount,
        'currency': currency,
      },
    );
    return response.data["client_secret"];
  }

  Future<void> _handleWebPayment(String clientSecret) async {
    try {
      // Ensure the method exists before calling it
      if (js.context.hasProperty('initializeStripe')) {
        js.context.callMethod('initializeStripe', [clientSecret, ApiKeys.publishableKey]);
      } else {
        throw Exception('initializeStripe method not found.');
      }
    } catch (e) {
      print('Error calling initializeStripe: $e');
    }
  }
}
