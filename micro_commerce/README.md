# Micro Commerce

แอพพลิเคชัน E-commerce ที่พัฒนาด้วย Flutter

## การติดตั้ง

ก่อนที่จะรันโปรเจคนี้ คุณจำเป็นต้องติดตั้งสิ่งต่อไปนี้:

1. **Flutter SDK** (เวอร์ชั่น 3.0.0 หรือใหม่กว่า)
   - [วิธีการติดตั้ง Flutter](https://flutter.dev/docs/get-started/install)
   - รัน `flutter doctor` เพื่อตรวจสอบการติดตั้ง

2. **Dart SDK** (เวอร์ชั่น 3.0.0 หรือใหม่กว่า)
   - จะมาพร้อมกับ Flutter SDK

3. **IDE**
   - Android Studio: [ดาวน์โหลด](https://developer.android.com/studio)
   - หรือ VS Code: [ดาวน์โหลด](https://code.visualstudio.com/)
     - ติดตั้ง Flutter และ Dart extensions

4. **Git**
   - [ดาวน์โหลด](https://git-scm.com/downloads)

## วิธีการรันโปรเจค

1. **Clone โปรเจค**
   ```bash
   git clone https://github.com/SurasakSiangsai02/micro-commerce.git
   cd micro-commerce
   ```

2. **ติดตั้ง Dependencies**
   ```bash
   flutter pub get
   ```

3. **รันแอพพลิเคชัน**
   ```bash
   # ตรวจสอบอุปกรณ์ที่เชื่อมต่อ
   flutter devices
   
   # รันบนอุปกรณ์ที่ต้องการ
   flutter run
   ```

## โครงสร้างโปรเจค

```
lib/
├── models/         # โมเดลข้อมูล
├── providers/      # จัดการ State
├── screens/        # หน้าจอต่างๆ
│   ├── auth/       # หน้าเกี่ยวกับ Authentication
│   └── customer/   # หน้าสำหรับลูกค้า
├── utils/          # Utilities ต่างๆ
└── widgets/        # Widget ที่ใช้ซ้ำ
```

## ฟีเจอร์

- 🎨 UI ที่ทันสมัย
- 🔐 ระบบ Authentication
- 🛍️ แสดงรายการสินค้าและรายละเอียด
- 🛒 ระบบตะกร้าสินค้า
- 📱 Responsive design
- 🎯 จัดการ State ด้วย Provider

## เทคโนโลยีที่ใช้

- Flutter
- Dart
- Provider (State Management)
- Firebase (เร็วๆ นี้)

## การรันบนแพลตฟอร์มต่างๆ

### Android
1. เปิดโหมดนักพัฒนาและ USB debugging บนมือถือ Android
2. เชื่อมต่อมือถือหรือเปิด Emulator
3. รัน `flutter run`

### iOS (ต้องใช้ Mac)
1. ติดตั้ง Xcode
2. ตั้งค่า iOS Simulator หรือเชื่อมต่ออุปกรณ์ iOS
3. รัน `flutter run`

### Web
- รัน `flutter run -d chrome`

## ปัญหาที่พบบ่อยและวิธีแก้ไข

1. **หา Flutter SDK ไม่พบ**
   - ตรวจสอบว่าได้เพิ่ม Flutter ใน PATH
   - รัน `flutter doctor` เพื่อตรวจสอบการติดตั้ง

2. **ปัญหาเกี่ยวกับ Dependencies**
   - ลบไฟล์ `pubspec.lock`
   - รัน `flutter pub get` อีกครั้ง

3. **ปัญหาเกี่ยวกับ Android SDK**
   - เปิด Android Studio
   - ไปที่ Tools > SDK Manager
   - ติดตั้ง Android SDK ที่จำเป็น

## การติดต่อ

Surasak Siangsai - [@SurasakSiangsai02](https://github.com/SurasakSiangsai02)

ลิงก์โปรเจค: [https://github.com/SurasakSiangsai02/micro-commerce](https://github.com/SurasakSiangsai02/micro-commerce)
