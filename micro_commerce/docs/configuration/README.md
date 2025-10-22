# 🔐 การตั้งค่าและความปลอดภัย (Configuration & Security)

เอกสารการตั้งค่าระบบและความปลอดภัยสำหรับ Micro Commerce

## 🛡️ เอกสารในโฟลเดอร์นี้

### 🔥 FIREBASE_STORAGE_RULES.md
**การตั้งค่า Firebase Storage Security Rules**
- 🎯 **สำหรับ:** Developer, DevOps
- 📝 **เนื้อหา:** กฎความปลอดภัย, การอัปโหลดไฟล์
- ⚠️ **ปัญหาที่แก้:** `User is not authorized to perform the desired action`
- ✅ **สถานะ:** แก้ไขเสร็จสิ้น

### ✅ CONFIRMATION_DIALOG_DOCUMENTATION.md
**เอกสารระบบ Confirmation Dialog**
- 🎯 **สำหรับ:** Developer
- 📝 **เนื้อหา:** การใช้งาน dialog ยืนยัน, best practices
- 🔧 **ฟีเจอร์:** Dialog ยืนยันสำหรับการกระทำสำคัญ

## 🔥 Firebase Configuration

### 🛡️ Security Rules
```javascript
// Storage Rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // อนุญาตให้ authenticated users อัปโหลด/ดาวน์โหลด
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}

// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users สามารถอ่าน/เขียนข้อมูลตัวเองได้เท่านั้น
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products อ่านได้ทุกคน, แต่เขียนได้เฉพาะ admin
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
                   get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 🔧 Environment Variables
```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=micro-commerce-6de78
FIREBASE_STORAGE_BUCKET=micro-commerce-6de78.appspot.com

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# App Configuration
APP_NAME=Micro Commerce
APP_VERSION=1.0.0
ENVIRONMENT=development
```

## ✅ Confirmation Dialog System

### 🎯 การใช้งาน
```dart
// การใช้งาน Confirmation Dialog
await ConfirmationDialogs.showDeleteConfirmation(
  context: context,
  title: 'ลบสินค้า',
  message: 'คุณแน่ใจหรือไม่ที่จะลบสินค้านี้?',
  onConfirm: () async {
    // ทำการลบสินค้า
  },
);
```

### 🔧 ประเภท Dialog ที่มี
- 🗑️ **Delete Confirmation:** ยืนยันการลบ
- 💾 **Save Confirmation:** ยืนยันการบันทึก
- 🚪 **Logout Confirmation:** ยืนยันการออกจากระบบ
- 📤 **Submit Confirmation:** ยืนยันการส่งข้อมูล

## 🔐 Security Best Practices

### 🛡️ Authentication Security
- ✅ ใช้ Firebase Authentication
- ✅ Validate email format
- ✅ Enforce strong password policy
- ✅ Implement password reset functionality
- ✅ Session timeout handling

### 🗂️ Data Security
- ✅ Input validation ทุก field
- ✅ Sanitize user input
- ✅ Role-based access control
- ✅ Secure API endpoints
- ✅ Encrypt sensitive data

### 📱 App Security
- ✅ HTTPS only communication
- ✅ Certificate pinning
- ✅ Obfuscated code in production
- ✅ No sensitive data in logs
- ✅ Secure storage for tokens

## 🔧 Configuration Files

### 📄 lib/config/
```
config/
├── app_config.dart          # App configuration
├── security_config.dart     # Security settings
└── stripe_config.dart       # Payment configuration
```

### 🔑 Key Configuration Classes
```dart
// app_config.dart
class AppConfig {
  static String get apiKey => _getEnvVar('FIREBASE_API_KEY');
  static String get projectId => _getEnvVar('FIREBASE_PROJECT_ID');
  static bool get isDevelopment => _getEnvVar('ENVIRONMENT') == 'development';
}

// security_config.dart
class SecurityConfig {
  static const int maxLoginAttempts = 5;
  static const Duration sessionTimeout = Duration(hours: 24);
  static const List<String> allowedDomains = ['micro-commerce.com'];
}
```

## 🚀 Setup Instructions

### 1️⃣ Firebase Setup
1. สร้าง Firebase Project
2. เปิดใช้ Authentication, Firestore, Storage
3. ตั้งค่า Security Rules
4. ดาวน์โหลด configuration files

### 2️⃣ Environment Setup
1. คัดลอก `.env.example` เป็น `.env`
2. กรอกค่า API keys และ configuration
3. ตรวจสอบว่าไฟล์ `.env` อยู่ใน `.gitignore`

### 3️⃣ Security Rules Deployment
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy Security Rules
firebase deploy --only firestore:rules,storage
```

## ⚠️ Common Issues & Solutions

### 🔥 Firebase Storage Issues
- **ปัญหา:** `User is not authorized`
- **วิธีแก้:** อัปเดต Storage Rules ตาม `FIREBASE_STORAGE_RULES.md`

### 🔐 Authentication Issues
- **ปัญหา:** User ล็อกอินไม่ได้
- **วิธีแก้:** ตรวจสอบ API keys และ configuration

### 📱 App Configuration Issues
- **ปัญหา:** App เริ่มต้นไม่ได้
- **วิธีแก้:** ตรวจสอบ `.env` file และ environment variables

## 📊 Security Checklist

| Item | Status | Priority |
|------|--------|----------|
| Firebase Security Rules | ✅ Done | High |
| Authentication Setup | ✅ Done | High |
| Environment Variables | ✅ Done | High |
| Confirmation Dialogs | ✅ Done | Medium |
| Input Validation | ✅ Done | High |
| Error Handling | ✅ Done | Medium |
| Secure Storage | ✅ Done | High |
| HTTPS Enforcement | ✅ Done | High |

## 📌 หมายเหตุ

- 🔐 อย่าเผยแพร่ API keys หรือ secrets ใน repository
- 🔄 Security Rules ต้องได้รับการทดสอบก่อน deploy
- ⚠️ เมื่อเปลี่ยน configuration ให้ทดสอบทุกฟีเจอร์
- 📝 บันทึกการเปลี่ยนแปลง configuration ทุกครั้ง
- 🔒 ใช้ environment ต่างกันสำหรับ development และ production