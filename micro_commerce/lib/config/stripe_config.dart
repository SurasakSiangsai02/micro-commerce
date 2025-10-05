import 'app_config.dart';

/// 💳 Stripe Configuration
/// 
/// ⚠️  DEPRECATED: ใช้ AppConfig แทน
/// 
/// ใช้ environment variables เพื่อความปลอดภัย
/// ไม่เก็บ API Keys ในโค้ดโดยตรง
/// 
/// Migration Guide:
/// - เปลี่ยนจาก StripeConfig.publishableKey 
/// - เป็น AppConfig.stripePublishableKey

class StripeConfig {
  // ⚠️ DEPRECATED: ใช้ AppConfig แทน
  @Deprecated('Use AppConfig.stripePublishableKey instead')
  static String get publishableKey => AppConfig.stripePublishableKey;
  
  @Deprecated('Use AppConfig.stripeSecretKey instead')
  static String get secretKey => AppConfig.stripeSecretKey;
  
  @Deprecated('Use AppConfig.stripeMerchantIdentifier instead')
  static String get merchantIdentifier => AppConfig.stripeMerchantIdentifier;
  
  @Deprecated('Use AppConfig.stripeMerchantCountryCode instead')
  static String get merchantCountryCode => AppConfig.stripeMerchantCountryCode;
  
  @Deprecated('Use AppConfig.stripeMerchantDisplayName instead')
  static String get merchantDisplayName => AppConfig.stripeMerchantDisplayName;
  
  @Deprecated('Use AppConfig.defaultCurrency instead')
  static String get defaultCurrency => AppConfig.defaultCurrency;
  
  @Deprecated('Use AppConfig.supportedPaymentMethods instead')
  static List<String> get supportedPaymentMethods => AppConfig.supportedPaymentMethods;
  
  @Deprecated('Use AppConfig.isStripeTestMode instead')
  static bool get isTestMode => AppConfig.isStripeTestMode;
  
  @Deprecated('Use AppConfig.formatStripeAmount instead')
  static String formatAmount(double amount) => AppConfig.formatStripeAmount(amount);
  
  @Deprecated('Use AppConfig.parseStripeAmount instead')
  static double parseAmount(String stripeAmount) => AppConfig.parseStripeAmount(stripeAmount);
}