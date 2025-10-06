/// 🛡️ SecurityConfig - การตั้งค่าความปลอดภัยสำหรับแอป
/// 
/// คุณสมบัติ:
/// • ควบคุมการแสดง Admin Setup Tool
/// • ปิดเครื่องมือ Debug ใน Production
/// • จัดการสิทธิ์การเข้าถึงฟีเจอร์พิเศษ
class SecurityConfig {
  /// 🏗️ ตรวจสอบว่าอยู่ในโหมด Development หรือไม่
  static bool get isDevelopment {
    bool isDebugMode = false;
    assert(isDebugMode = true); // assert จะทำงานเฉพาะใน debug mode
    return isDebugMode;
  }

  /// 🔐 ตรวจสอบว่าสามารถแสดง Admin Setup Tool ได้หรือไม่
  static bool get canShowAdminSetup {
    // แสดงเฉพาะใน Development mode หรือเมื่อยังไม่มี Admin ในระบบ
    return isDevelopment;
  }

  /// 🛠️ ตรวจสอบว่าสามารถแสดง Debug Tools ได้หรือไม่
  static bool get canShowDebugTools {
    return isDevelopment;
  }

  /// ⚠️ แสดงข้อความเตือนสำหรับเครื่องมือ Development
  static String get developmentWarning {
    return 'เครื่องมือนี้ใช้ในโหมดพัฒนาเท่านั้น\nกรุณาลบออกก่อน Deploy สู่ Production';
  }

  /// 🎯 ตรวจสอบสิทธิ์ Admin
  static bool canAccessAdminFeatures(String? userRole) {
    return userRole == 'admin' || userRole == 'moderator';
  }

  /// 🔒 ตรวจสอบสิทธิ์ Super Admin (เฉพาะ Admin)
  static bool canAccessSuperAdminFeatures(String? userRole) {
    return userRole == 'admin';
  }
}