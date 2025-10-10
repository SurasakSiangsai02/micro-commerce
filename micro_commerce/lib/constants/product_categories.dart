/// 📂 Product Categories Constants
/// 
/// ไฟล์นี้เก็บค่าคงที่สำหรับหมวดหมู่สินค้า
/// เพื่อให้ทุกหน้าใช้หมวดหมู่เดียวกัน
class ProductCategories {
  // หมวดหมู่หลักที่ใช้ในระบบ (ภาษาอังกฤษ - ใช้เป็นค่าใน database)
  static const List<String> categories = [
    'Electronics',
    'Fashion', 
    'Home',
    'Sports',
    'Books',
  ];

  // ชื่อหมวดหมู่ที่แสดงผล (ภาษาไทย)
  static const Map<String, String> categoryDisplayNames = {
    'Electronics': 'เครื่องใช้ไฟฟ้า',
    'Fashion': 'เสื้อผ้า', 
    'Home': 'ของใช้ในบ้าน',
    'Sports': 'กีฬา',
    'Books': 'หนังสือ',
  };

  // ไอคอนสำหรับแต่ละหมวดหมู่
  static const Map<String, String> categoryIcons = {
    'Electronics': '📱',
    'Fashion': '👕', 
    'Home': '🏠',
    'Sports': '⚽',
    'Books': '📚',
  };

  // ฟังก์ชันสำหรับแปลงจากภาษาอังกฤษเป็นภาษาไทย
  static String getDisplayName(String category) {
    return categoryDisplayNames[category] ?? category;
  }

  // ฟังก์ชันสำหรับแปลงจากภาษาไทยเป็นภาษาอังกฤษ
  static String getEnglishName(String displayName) {
    for (final entry in categoryDisplayNames.entries) {
      if (entry.value == displayName) {
        return entry.key;
      }
    }
    return displayName;
  }

  // ฟังก์ชันสำหรับดึงไอคอน
  static String getIcon(String category) {
    return categoryIcons[category] ?? '📦';
  }

  // ตรวจสอบว่าหมวดหมู่นั้นมีอยู่หรือไม่
  static bool isValidCategory(String category) {
    return categories.contains(category);
  }

  // รายการหมวดหมู่สำหรับ dropdown (ภาษาไทย)
  static List<String> get displayCategories {
    return categories.map((cat) => getDisplayName(cat)).toList();
  }

  // รายการหมวดหมู่พร้อมไอคอน
  static List<Map<String, String>> get categoriesWithIcons {
    return categories.map((cat) => {
      'key': cat,
      'name': getDisplayName(cat),
      'icon': getIcon(cat),
    }).toList();
  }
}