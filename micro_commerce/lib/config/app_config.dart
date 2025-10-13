import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// 🔐 Secure App Configuration
/// 
/// ใช้ environment variables เพื่อความปลอดภัย
/// ไม่เก็บ sensitive keys ในโค้ดโดยตรง
/// 
/// Setup:
/// 1. สร้างไฟล์ .env ในโฟลเดอร์รูท
/// 2. เพิ่ม keys ใน .env
/// 3. เพิ่ม .env ใน .gitignore
/// 4. ใช้ AppConfig.load() ใน main.dart
class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // ===========================================
  // STRIPE CONFIGURATION
  // ===========================================
  
  static String get stripePublishableKey {
    final key = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('❌ STRIPE_PUBLISHABLE_KEY not found in .env file');
    }
    return key;
  }
  
  static String get stripeSecretKey {
    final key = dotenv.env['STRIPE_SECRET_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('❌ STRIPE_SECRET_KEY not found in .env file');
    }
    return key;
  }
  
  static String get stripeMerchantIdentifier {
    return dotenv.env['STRIPE_MERCHANT_IDENTIFIER'] ?? 'merchant.com.app';
  }
  
  static String get stripeMerchantCountryCode {
    return dotenv.env['STRIPE_MERCHANT_COUNTRY_CODE'] ?? 'US';
  }
  
  static String get stripeMerchantDisplayName {
    return dotenv.env['STRIPE_MERCHANT_DISPLAY_NAME'] ?? 'Micro Commerce';
  }
  
  // ===========================================
  // FIREBASE CONFIGURATION
  // ===========================================
  
  static String? get firebaseApiKey {
    return dotenv.env['FIREBASE_API_KEY'];
  }
  
  static String? get firebaseProjectId {
    return dotenv.env['FIREBASE_PROJECT_ID'];
  }
  
  static String? get firebaseMessagingSenderId {
    return dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
  }
  
  static String? get firebaseAppId {
    return dotenv.env['FIREBASE_APP_ID'];
  }
  
  static String? get firebaseAppIdWeb {
    return dotenv.env['FIREBASE_APP_ID_WEB'];
  }
  
  static String? get firebaseAppIdAndroid {
    return dotenv.env['FIREBASE_APP_ID_ANDROID'];
  }
  
  static String? get firebaseAppIdIos {
    return dotenv.env['FIREBASE_APP_ID_IOS'];
  }
  
  static String? get firebaseAppIdMacos {
    return dotenv.env['FIREBASE_APP_ID_MACOS'];
  }
  
  static String? get firebaseAuthDomain {
    return dotenv.env['FIREBASE_AUTH_DOMAIN'];
  }
  
  static String? get firebaseStorageBucket {
    return dotenv.env['FIREBASE_STORAGE_BUCKET'];
  }
  
  static String? get firebaseMeasurementId {
    return dotenv.env['FIREBASE_MEASUREMENT_ID'];
  }
  
  static String? get firebaseIosBundleId {
    return dotenv.env['FIREBASE_IOS_BUNDLE_ID'];
  }
  
  // ===========================================
  // APP CONFIGURATION
  // ===========================================
  
  static String get appEnv {
    return dotenv.env['APP_ENV'] ?? 'development';
  }
  
  static bool get isDebug {
    final debug = dotenv.env['APP_DEBUG']?.toLowerCase();
    return debug == 'true' || kDebugMode;
  }
  
  static bool get isProduction {
    return appEnv.toLowerCase() == 'production';
  }
  
  static bool get isDevelopment {
    return appEnv.toLowerCase() == 'development';
  }
  
  static String? get apiBaseUrl {
    return dotenv.env['API_BASE_URL'];
  }
  
  // ===========================================
  // STRIPE HELPERS
  // ===========================================
  
  static const String defaultCurrency = 'usd';
  
  static const List<String> supportedPaymentMethods = [
    'card',
    'apple_pay',
    'google_pay',
  ];
  
  static bool get isStripeTestMode {
    return stripePublishableKey.contains('pk_test');
  }
  
  static String formatStripeAmount(double amount) {
    // Stripe ต้องการจำนวนเงินเป็น cents (สำหรับ USD)
    return (amount * 100).round().toString();
  }
  
  static double parseStripeAmount(String stripeAmount) {
    // แปลงจาก cents กลับเป็น dollars
    return double.parse(stripeAmount) / 100;
  }
  
  // ===========================================
  // INITIALIZATION
  // ===========================================
  
  /// โหลด environment variables
  /// เรียกใช้ใน main.dart ก่อน runApp()
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      
      if (isDebug) {
        Logger.info('AppConfig loaded successfully');
        Logger.info('Environment: $appEnv');
        Logger.info('Stripe Test Mode: $isStripeTestMode');
      }
      
      // Validate required keys
      _validateRequiredKeys();
      
    } catch (e) {
      if (isDebug) {
        Logger.error('Error loading .env file', error: e);
        Logger.info('Make sure .env file exists and contains required keys');
      }
      rethrow;
    }
  }
  
  /// ตรวจสอบ keys ที่จำเป็น
  static void _validateRequiredKeys() {
    final requiredKeys = [
      'STRIPE_PUBLISHABLE_KEY',
      'STRIPE_SECRET_KEY',
    ];
    
    final missingKeys = <String>[];
    
    for (final key in requiredKeys) {
      if (dotenv.env[key] == null || dotenv.env[key]!.isEmpty) {
        missingKeys.add(key);
      }
    }
    
    if (missingKeys.isNotEmpty) {
      Logger.error(
        'Missing required environment variables: ${missingKeys.join(', ')}'
      );
      throw Exception(
        'Missing required environment variables: ${missingKeys.join(', ')}'
      );
    }
  }
  
  // ===========================================
  // SECURITY HELPERS
  // ===========================================
  
  /// ซ่อน sensitive keys สำหรับ logging
  static String maskKey(String key) {
    if (key.length <= 8) return '***';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }
  
  /// แสดงข้อมูล config (ไม่แสดง sensitive keys)
  static Map<String, dynamic> getConfigInfo() {
    return {
      'app_env': appEnv,
      'is_debug': isDebug,
      'is_production': isProduction,
      'stripe_test_mode': isStripeTestMode,
      'stripe_publishable_key': maskKey(stripePublishableKey),
      'stripe_merchant_name': stripeMerchantDisplayName,
      'api_base_url': apiBaseUrl ?? 'Not set',
    };
  }
}