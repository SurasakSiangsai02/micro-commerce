import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../utils/logger.dart';

/// 💳 PaymentService - จัดการ Stripe Payment Processing
/// 
/// ฟีเจอร์:
/// • สร้าง Payment Intent
/// • ประมวลผลการชำระเงิน
/// • จัดการ Payment Methods
/// • Error Handling
/// 
/// 🔐 Security: ใช้ AppConfig เพื่อโหลด API keys จาก .env

class PaymentService {
  static PaymentService? _instance;
  
  // Singleton pattern
  static PaymentService get instance {
    _instance ??= PaymentService._internal();
    return _instance!;
  }
  
  PaymentService._internal();
  
  /// เริ่มต้น Stripe SDK
  static Future<void> initialize() async {
    try {
      Stripe.publishableKey = AppConfig.stripePublishableKey;
      Stripe.merchantIdentifier = AppConfig.stripeMerchantIdentifier;
      
      // เปิดใช้งาน Apple Pay และ Google Pay (หากรองรับ)
      await Stripe.instance.applySettings();
      
      Logger.info('Stripe initialized successfully');
    } catch (e) {
      Logger.warning('Stripe initialization failed', error: e);
      Logger.info('App will continue without Stripe payment support');
      // ไม่ throw exception เพื่อให้แอปยังทำงานได้
      // Credit card payment จะไม่สามารถใช้งานได้ แต่ COD และ Bank Transfer ยังใช้ได้
    }
  }
  
  /// สร้าง Payment Intent บน Stripe Server
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': AppConfig.formatStripeAmount(amount),
          'currency': currency.toLowerCase(),
          'customer': customerId,
          ..._formatMetadata(metadata),
          'automatic_payment_methods[enabled]': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger.business('Payment Intent created', {'paymentIntentId': data['id']});
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to create payment intent: ${error['error']['message']}');
      }
    } catch (e) {
      Logger.error('Error creating payment intent', error: e);
      rethrow;
    }
  }
  
  /// สร้าง Stripe Customer
  Future<String> createCustomer({
    required String email,
    required String name,
    String? phone,
  }) async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/customers');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'name': name,
          if (phone != null) 'phone': phone,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Logger.business('Customer created', {'customerId': data['id']});
        return data['id'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to create customer: ${error['error']['message']}');
      }
    } catch (e) {
      Logger.error('Error creating customer', error: e);
      rethrow;
    }
  }
  
  /// ประมวลผลการชำระเงินด้วย Card
  Future<PaymentResult> processCardPayment({
    required double amount,
    required String currency,
    required String customerId,
    required BuildContext context,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // 1. สร้าง Payment Intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        customerId: customerId,
        metadata: metadata,
      );
      
      // 2. Present Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: AppConfig.stripeMerchantDisplayName,
          customerId: customerId,
          style: ThemeMode.light,
        ),
      );
      
      // 3. Show Payment Sheet
      await Stripe.instance.presentPaymentSheet();
      
      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntent['id'],
        amount: amount,
        currency: currency,
        message: 'Payment completed successfully',
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult(
          success: false,
          message: 'Payment was cancelled',
        );
      } else {
        return PaymentResult(
          success: false,
          message: 'Payment failed: ${e.error.message}',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Payment failed: $e',
      );
    }
  }
  
  /// ตรวจสอบสถานะ Payment Intent
  Future<Map<String, dynamic>> getPaymentIntent(String paymentIntentId) async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to get payment intent: ${error['error']['message']}');
      }
    } catch (e) {
      Logger.error('Error getting payment intent', error: e);
      rethrow;
    }
  }

  /// Helper method สำหรับ format metadata สำหรับ Stripe API
  Map<String, String> _formatMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) {
      return {};
    }
    
    final Map<String, String> formattedMetadata = {};
    metadata.forEach((key, value) {
      // Stripe expects metadata as separate key-value pairs, not nested
      formattedMetadata['metadata[$key]'] = value.toString();
    });
    
    return formattedMetadata;
  }
}

/// ผลลัพธ์ของการชำระเงิน
class PaymentResult {
  final bool success;
  final String? paymentIntentId;
  final double? amount;
  final String? currency;
  final String message;
  
  PaymentResult({
    required this.success,
    this.paymentIntentId,
    this.amount,
    this.currency,
    required this.message,
  });
  
  @override
  String toString() {
    return 'PaymentResult(success: $success, paymentIntentId: $paymentIntentId, message: $message)';
  }
}