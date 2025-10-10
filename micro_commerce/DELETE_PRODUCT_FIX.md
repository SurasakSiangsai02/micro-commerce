# 🚨 แก้ไขปัญหาการลบสินค้าค้างนาน

## ⚠️ ปัญหาที่พบ:
เมื่อทำการลบสินค้า หน้าโหลดขึ้นมานานและไม่หยุด ทำให้ผู้ใช้ไม่รู้ว่าเกิดอะไรขึ้น

## 🔍 สาเหตุของปัญหา:

### 1. การจัดการ Loading Dialog ไม่ถูกต้อง
```dart
// ❌ ปัญหาเดิม
showDialog(context: context, builder: (context) => CircularProgressIndicator());
// อาจมีปัญหาการจัดการ context และการปิด dialog
```

### 2. ไม่มี Timeout Protection
```dart
// ❌ ไม่มี timeout
await DatabaseService.deleteProduct(product.id);
// อาจค้างนานถ้าเน็ตช้าหรือมีปัญหา
```

### 3. Error Handling ไม่ครอบคลุม
- ไม่มีการตรวจสอบ network connectivity
- ไม่มีการแยกประเภท error
- ไม่มี retry mechanism

## ✅ การแก้ไขที่ทำ:

### 1. สร้าง LoadingDialog ที่ปลอดภัย 🛡️

#### `lib/widgets/loading_dialog.dart`:
```dart
class LoadingDialog {
  static bool _isShowing = false;
  static late BuildContext _dialogContext;

  // ✅ ป้องกันการแสดง dialog ซ้ำ
  static void show(BuildContext context, {
    String message = 'กำลังดำเนินการ...',
    Duration? timeout,
  }) {
    if (_isShowing) return;
    
    _isShowing = true;
    // แสดง dialog พร้อม WillPopScope ป้องกันการปิด
    showDialog(/*...*/);
    
    // Auto close หาก timeout
    if (timeout != null) {
      Future.delayed(timeout, () {
        if (_isShowing) hide();
      });
    }
  }

  // ✅ ปิด dialog อย่างปลอดภัย
  static void hide() {
    if (!_isShowing) return;
    try {
      _isShowing = false;
      Navigator.pop(_dialogContext);
    } catch (e) {
      _isShowing = false; // Dialog อาจถูกปิดไปแล้ว
    }
  }
}
```

### 2. ปรับปรุง DatabaseService ให้มี Timeout 🕐

#### `lib/services/database_service.dart`:
```dart
static Future<void> deleteProduct(String productId) async {
  try {
    // ✅ ตรวจสอบว่าสินค้ามีอยู่จริง
    final docSnapshot = await productsCollection.doc(productId).get();
    if (!docSnapshot.exists) {
      throw Exception('ไม่พบสินค้าที่ต้องการลบ');
    }
    
    // ✅ เพิ่ม timeout 5 วินาที
    await productsCollection.doc(productId).delete().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('การลบสินค้าใช้เวลานานเกินไป');
      },
    );
    
  } catch (e) {
    // ✅ แยกประเภท error
    if (e.toString().contains('permission-denied')) {
      throw Exception('ไม่มีสิทธิ์ในการลบสินค้า');
    } else if (e.toString().contains('network')) {
      throw Exception('ปัญหาการเชื่อมต่ออินเตอร์เน็ต');
    } else {
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }
}
```

### 3. ปรับปรุง UI Flow ใน ProductManagementScreen 🎯

#### `_performDeleteProduct()` ใหม่:
```dart
Future<void> _performDeleteProduct(Product product) async {
  Navigator.pop(context); // ปิด confirmation dialog
  
  try {
    // ✅ แสดง loading พร้อม timeout 15 วินาที
    LoadingDialog.show(
      context,
      message: 'กำลังลบสินค้า "${product.name}"...',
      timeout: const Duration(seconds: 15),
    );
    
    // ✅ เรียก API พร้อม timeout 10 วินาที
    await DatabaseService.deleteProduct(product.id).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('การลบสินค้าใช้เวลานานเกินไป กรุณาลองใหม่');
      },
    );
    
    // ✅ ปิด loading และแสดงข้อความสำเร็จ
    LoadingDialog.hide();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ลบสินค้า "${product.name}" สำเร็จ'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      _loadCategories(); // โหลดข้อมูลใหม่
    }
    
  } catch (e) {
    // ✅ จัดการ error พร้อม retry option
    LoadingDialog.hide();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'ลองใหม่',
            textColor: Colors.white,
            onPressed: () => _performDeleteProduct(product),
          ),
        ),
      );
    }
  }
}
```

## 🛡️ ความปลอดภัยที่เพิ่ม:

### 1. Timeout Protection
- **Database Timeout**: 5 วินาที
- **UI Timeout**: 10 วินาที  
- **Auto Close Dialog**: 15 วินาที

### 2. Error Handling
- ✅ ตรวจสอบสินค้าก่อนลบ
- ✅ แยกประเภท error (permission, network, etc.)
- ✅ แสดงข้อความที่เหมาะสม
- ✅ มีปุ่ม "ลองใหม่"

### 3. UI/UX ที่ดีขึ้น
- ✅ Loading message ที่ชัดเจน
- ✅ ป้องกันการปิด dialog โดยไม่ได้ตั้งใจ
- ✅ ป้องกันการแสดง dialog ซ้ำ
- ✅ Auto close ป้องกันการค้าง

## 🚀 ผลลัพธ์:

### ✅ แก้ปัญหาการค้าง:
- หน้าโหลดจะปิดอัตโนมัติภายใน 15 วินาที
- มี timeout protection หลายชั้น
- แสดงข้อความ error ที่ชัดเจน

### ✅ UX ที่ดีขึ้น:
- แสดงชื่อสินค้าที่กำลังลบ
- มีปุ่ม "ลองใหม่" เมื่อเกิด error
- ข้อความสำเร็จ/ผิดพลาดที่เข้าใจง่าย

### ✅ ความปลอดภัย:
- ป้องกัน multiple dialogs
- จัดการ context อย่างปลอดภัย
- ตรวจสอบ mounted state

---
**สถานะ**: ✅ แก้ไขเสร็จสิ้น - การลบสินค้าทำงานได้อย่างปลอดภัยและไม่ค้างแล้ว