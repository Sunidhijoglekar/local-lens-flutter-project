import 'package:stripe_payment/stripe_payment.dart';


class PaymentService {
  static void init() {
    // Initialize Stripe options with your publishable key.
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: "your_publishable_key", // Replace with your actual Stripe publishable key.
        merchantId: "Test", // This is required for Apple Pay (can be removed if you're not using Apple Pay).
        androidPayMode: 'test', // Use 'production' when your app is live.
      ),
    );
  }

  static Future<void> processPayment() async {
    try {
      // Request card form input from the user.
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      );

      // The paymentMethod.id can be sent to your server to create a charge.
      print("Received payment method ID: ${paymentMethod.id}");

      // Optionally, show a loading indicator or progress feedback to the user.
      // Simulate charge or proceed to confirmation here.

      // Example: You may want to call an API on your backend to create a charge with the received paymentMethod.id.
      // await createCharge(paymentMethod.id);

      // For now, just simulate confirmation success.
      print("Payment processed successfully.");
    } catch (e) {
      // Handle payment failure
      print("Payment failed: $e");
      // Optionally show user-friendly error UI
    }
  }

  // You can implement this method to make a request to your backend server
  // to actually charge the user after receiving the paymentMethod.id.
  // Future<void> createCharge(String paymentMethodId) async {
  //   // Call your backend API here to create a charge with the paymentMethodId.
  //   // For example, send the paymentMethodId to your server using an HTTP request.
  // }
} 