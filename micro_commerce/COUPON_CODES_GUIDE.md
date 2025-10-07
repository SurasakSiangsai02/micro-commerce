# 🎟️ คู่มือการสร้างและใช้งานคูปองส่วนลด

## สำหรับ Admin - การสร้างคูปอง

### ขั้นตอนการสร้างคูปอง:

1. **Login เป็น Admin**
   - ใช้บัญชี admin ที่มีสิทธิ์

2. **เข้าสู่ Coupon Management**
   - ไปที่ Admin Dashboard
   - เลือก "Coupon Management"

3. **สร้างคูปองใหม่**
   - กด "Add New Coupon"
   - กรอกข้อมูล:

### 📝 ตัวอย่างคูปองที่แนะนำให้สร้าง:

#### คูปองส่วนลดเปอร์เซ็นต์:
```
Code: WELCOME20
Type: Percentage
Value: 20
Usage Limit: 100
Expiry Date: 31/12/2025
Description: ส่วนลด 20% สำหรับลูกค้าใหม่
```

```
Code: FLASH50
Type: Percentage  
Value: 50
Usage Limit: 50
Expiry Date: 15/11/2025
Description: Flash Sale ลด 50% 
```

#### คูปองส่วนลดจำนวนเงินคงที่:
```
Code: FLAT10
Type: Fixed Amount
Value: 10.00
Usage Limit: 200
Expiry Date: 31/12/2025
Description: ลดทันที $10 สำหรับทุกออเดอร์
```

```
Code: STUDENT5
Type: Fixed Amount
Value: 5.00
Usage Limit: 1000
Expiry Date: 30/06/2026
Description: ส่วนลดนักเรียน $5
```

#### คูปอง VIP:
```
Code: VIP100
Type: Fixed Amount
Value: 100.00
Usage Limit: 10
Expiry Date: 31/12/2025
Description: คูปอง VIP สำหรับลูกค้าพิเศษ
```

## สำหรับลูกค้า - การใช้คูปอง

### วิธีใช้คูปองใน Checkout:

1. **เพิ่มสินค้าในตะกร้า**
2. **ไปที่ Checkout**
3. **ใส่รหัสคูปอง**
   - ในช่อง "Coupon Code"
   - กด "Apply Coupon"
4. **ตรวจสอบส่วนลด**
   - ดูการคำนวณส่วนลด
   - ตรวจสอบยอดสุทธิ

### 🎯 คูปองตัวอย่างที่จะสร้างให้ทดสอบ:

#### สำหรับการทดสอบ:
- `TEST10` - ลด $10 (ทดสอบระบบ)
- `DEMO20` - ลด 20% (สำหรับ Demo)
- `QA50` - ลด 50% (สำหรับ QA Testing)

## 🚀 Next Steps:

1. **รัน Flutter App**: `flutter run`
2. **Login เป็น Admin** 
3. **สร้างคูปองตามตัวอย่างข้างต้น**
4. **Login เป็นลูกค้าเพื่อทดสอบใช้คูปอง**

---
**สถานะปัจจุบัน**: ระบบพร้อมใช้งาน - รอการสร้างคูปองผ่าน Admin Dashboard