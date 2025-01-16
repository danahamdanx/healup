import 'package:dio/dio.dart';
import 'package:first/patient/medication/stripe_keys.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:flutter/foundation.dart'; // Import this to use kIsWeb

abstract class PaymentManager {
  static Future<void> makePayment(double amount, String currency) async {
    try {
      // Convert amount to cents (multiply by 100) and cast to int
      int amountInCents = (amount * 100).toInt();

      // Get client secret only if it's not on the web
      if (kIsWeb) {
        // Handle web-specific logic if needed (e.g., using Stripe's JS SDK)
        throw Exception("Stripe payments are not supported in Flutter Web yet.");
      } else {
        String clientSecret = await _getClientSecret(amountInCents.toString(), currency);
        await _initializePaymentSheet(clientSecret);
        await Stripe.instance.presentPaymentSheet();
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  static Future<void> _initializePaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "Siwar",
      ),
    );
  }

  static Future<String> _getClientSecret(String amount, String currency) async {
    Dio dio = Dio();
    var response = await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      ),
      data: {
        'amount': amount,
        'currency': currency,
      },
    );
    return response.data["client_secret"];
  }
}


// import 'package:dio/dio.dart';
// import 'package:first/patient/medication/stripe_keys.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
//
// abstract class PaymentManager{
//
//   static Future<void>makePayment(int amount,String currency)async{
//     try {
//       String clientSecret=await _getClientSecret((amount*100).toString(), currency);
//       await _initializePaymentSheet(clientSecret);
//       await Stripe.instance.presentPaymentSheet();
//     } catch (error) {
//       throw Exception(error.toString());
//     }
//   }
//
//   static Future<void>_initializePaymentSheet(String clientSecret)async{
//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: clientSecret,
//         merchantDisplayName: "Siwar",
//       ),
//     );
//   }
//
//   static Future<String> _getClientSecret(String amount,String currency)async{
//     Dio dio=Dio();
//     var response= await dio.post(
//       'https://api.stripe.com/v1/payment_intents',
//       options: Options(
//         headers: {
//           'Authorization': 'Bearer ${ApiKeys.secretKey}',
//           'Content-Type': 'application/x-www-form-urlencoded'
//         },
//       ),
//       data: {
//         'amount': amount,
//         'currency': currency,
//       },
//     );
//     return response.data["client_secret"];
//   }
//
// }