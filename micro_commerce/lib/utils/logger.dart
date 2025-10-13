import 'package:flutter/foundation.dart';

/// 📝 Logger Service - ระบบ logging ที่เหมาะสมสำหรับ production
/// 
/// ฟีเจอร์:
/// • Log levels (debug, info, warning, error)
/// • Production-safe logging 
/// • Structured logging
/// • Performance monitoring
class Logger {
  static const String _tag = 'MicroCommerce';
  
  /// 🐛 Debug level - สำหรับ development เท่านั้น
  static void debug(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      debugPrint('🐛 [$logTag] $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
    }
  }
  
  /// ℹ️ Info level - ข้อมูลทั่วไป
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      debugPrint('ℹ️ [$logTag] $message');
    }
  }
  
  /// ⚠️ Warning level - สำหรับเหตุการณ์ที่ควรระวัง
  static void warning(String message, {String? tag, Object? error}) {
    final logTag = tag ?? _tag;
    debugPrint('⚠️ [$logTag] $message');
    if (error != null && kDebugMode) {
      debugPrint('Warning: $error');
    }
  }
  
  /// 🚨 Error level - สำหรับ errors ที่สำคัญ
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final logTag = tag ?? _tag;
    debugPrint('🚨 [$logTag] $message');
    
    if (error != null) {
      debugPrint('Error: $error');
    }
    
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
    
    // TODO: ใน production ควรส่งไป crash reporting service
    // เช่น Firebase Crashlytics หรือ Sentry
  }
  
  /// 📊 Performance tracking
  static void performance(String operation, Duration duration, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      final ms = duration.inMilliseconds;
      debugPrint('📊 [$logTag] $operation took ${ms}ms');
    }
  }
  
  /// 🔐 Security-sensitive logging (ไม่ log sensitive data)
  static void security(String message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      debugPrint('🔐 [$logTag] $message');
    }
    // ใน production ควรส่งไป security monitoring
  }
  
  /// 💰 Business logic logging
  static void business(String event, Map<String, dynamic>? data, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      debugPrint('💰 [$logTag] $event');
      if (data != null) {
        debugPrint('Data: $data');
      }
    }
    // ใน production ควรส่งไป analytics service
  }
}