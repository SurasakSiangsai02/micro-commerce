# 🔧 การแก้ไขปัญหา Order History Screen

## ⚠️ ปัญหาที่พบ:
หน้า Order History แสดงราคาเดิมที่ยังไม่ได้หักส่วนลดจากคูปอง

## 🎯 สาเหตุของปัญหา:

### 1. Database Service คำนวณราคาใหม่
```dart
// ❌ ปัญหา: createOrderWithPayment() คำนวณราคาใหม่โดยไม่สนใจคูปอง
final subtotal = cartItems.fold<double>(0, (sum, item) => sum + item.total);
final tax = subtotal * 0.07; // 7% tax - ไม่มีส่วนลด
final total = subtotal + tax;
```

### 2. ข้อมูลคูปองไม่ถูกส่ง
- `orderData` ไม่มี `discountAmount`, `couponCode`, `couponId`
- Order object ที่สร้างไม่มีข้อมูลคูปอง

### 3. UI ไม่แสดงข้อมูลคูปอง
- Order History Card ไม่แสดงว่าใช้คูปอง
- ไม่แสดงรหัสคูปองที่ใช้

## ✅ การแก้ไขที่ทำ:

### 1. ปรับปรุง createOrderWithPayment() ใน DatabaseService
```dart
static Future<String> createOrderWithPayment(String userId, List<user_model.CartItem> cartItems, Map<String, dynamic> orderData) async {
  try {
    // ✅ ใช้ข้อมูลจาก orderData ที่คำนวณแล้ว
    final originalTotal = cartItems.fold<double>(0, (sum, item) => sum + item.total);
    final discountAmount = orderData['discountAmount'] ?? 0.0;
    final subtotalAfterDiscount = originalTotal - discountAmount;
    final taxRate = 0.08; // 8% tax
    final taxAmount = subtotalAfterDiscount * taxRate;
    final finalTotal = orderData['finalTotal'] ?? (subtotalAfterDiscount + taxAmount);

    // ✅ สร้าง Order พร้อมข้อมูลคูปอง
    final order = user_model.Order(
      id: orderRef.id,
      userId: userId,
      items: cartItems,
      subtotal: originalTotal,
      tax: taxAmount,
      total: finalTotal,
      status: 'confirmed',
      paymentMethod: orderData['paymentMethod'] ?? 'credit_card',
      shippingAddress: orderData['shippingAddress'] ?? {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      couponCode: orderData['couponCode'],      // ✅ เพิ่ม
      couponId: orderData['couponId'],          // ✅ เพิ่ม
      discountAmount: discountAmount,           // ✅ เพิ่ม
    );
  }
}
```

### 2. เพิ่มการแสดงข้อมูลคูปองใน Order History Card
```dart
// ✅ แสดงข้อมูลคูปอง
if (order.hasCoupon) ...[
  Row(
    children: [
      Icon(Icons.local_offer, size: 16, color: AppTheme.lightGreen),
      const SizedBox(width: 4),
      Text(
        'Coupon applied: ${order.couponCode}',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.lightGreen,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
  const SizedBox(height: 8),
],
```

### 3. ข้อมูลที่ส่งจาก CheckoutScreen
CheckoutScreen ส่ง `orderData` ที่มีข้อมูลครบถ้วน:
- `originalTotal` - ราคาเดิม
- `discountAmount` - จำนวนส่วนลด  
- `finalTotal` - ราคาสุทธิ
- `couponCode` - รหัสคูปอง
- `couponId` - ID คูปอง

## 🧮 ตัวอย่างการแสดงผลใหม่:

### Order History Card - กรณีมีคูปอง:
```
Order #ABC12345           [Pending]
Ordered on 07/10/2025
2 items
🎟️ Coupon applied: SAVE20
Total: $86.40
```

### Order History Card - กรณีไม่มีคูปอง:
```
Order #DEF67890           [Confirmed]
Ordered on 06/10/2025
1 item
Total: $108.00
```

## 🚀 ผลลัพธ์:

### ✅ สิ่งที่แก้ไขแล้ว:
1. **ราคาถูกต้อง** - Order History แสดงราคาหลังหักส่วนลดแล้ว
2. **ข้อมูลคูปองครบถ้วน** - บันทึกและแสดงข้อมูลคูปองใน database
3. **UI ชัดเจน** - แสดงไอคอนและรหัสคูปองที่ใช้
4. **การคำนวณสอดคล้อง** - Tax คำนวณจากราคาหลังหักส่วนลด (8%)

### 🔄 Flow ที่ถูกต้อง:
1. **Checkout Screen**: คำนวณราคาพร้อมคูปอง → ส่งข้อมูลครบถ้วน
2. **Database Service**: ใช้ข้อมูลที่ส่งมา → บันทึกลง Firestore
3. **Order History**: แสดงข้อมูลจาก database → ราคาและคูปองถูกต้อง
4. **Order Detail**: แสดงรายละเอียดครบถ้วน (มีการปรับปรุงแล้วก่อนหน้า)

## 📋 การทดสอบ:

### ขั้นตอนทดสอบ:
1. **สร้างคูปองใหม่** ผ่าน Admin Dashboard
2. **เพิ่มสินค้าในตะกร้า** ($100)
3. **ใช้คูปองใน Checkout** (เช่น SAVE20 สำหรับ 20% off)
4. **Complete Order** และไปที่ Order Confirmation
5. **ตรวจสอบ Order History** 

### ผลลัพธ์ที่คาดหวัง:
- ✅ Order History Card แสดง "Coupon applied: SAVE20"
- ✅ Total: $86.40 (แทน $108.00)
- ✅ Order Detail แสดงรายละเอียดการคำนวณครบถ้วน

## 📊 สรุปการปรับปรุงระบบ:

### Before Fix:
```
Cart Total: $100.00
→ Database: Total = $107.00 (7% tax, no discount)
→ Order History: $107.00 ❌
```

### After Fix:
```
Cart Total: $100.00
Coupon SAVE20: -$20.00
Subtotal: $80.00
Tax (8%): $6.40
→ Database: Total = $86.40 (with coupon data)
→ Order History: $86.40 ✅ + Coupon info
```

---
**สถานะ**: ✅ แก้ไขเสร็จสิ้น - Order History แสดงราคาที่ถูกต้องแล้ว