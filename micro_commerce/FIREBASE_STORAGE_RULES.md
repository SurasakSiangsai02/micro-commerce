# Firebase Storage Security Rules Configuration

## ปัญหาที่พบ
- User ไม่สามารถอัพโหลดไฟล์ไป Firebase Storage ได้
- Error: `[firebase_storage/unauthorized] User is not authorized to perform the desired action`

## การแก้ไข
ต้องไปตั้งค่า Firebase Storage Rules ใน Firebase Console:

### ขั้นตอนที่ 1: เปิด Firebase Console
1. ไปที่ https://console.firebase.google.com
2. เลือกโปรเจ็กต์ `micro-commerce-6de78`

### ขั้นตอนที่ 2: ตั้งค่า Storage Security Rules
1. ไปที่ **Storage** > **Rules** 
2. แก้ไข Rules เป็น:

```javascript
rules_version = '2';

// Craft rules based on data in your Firestore database
// allow write: if firestore.get(
//    /databases/(default)/documents/users/$(request.auth.uid)).data.isAdmin == true;
service firebase.storage {
  match /b/{bucket}/o {
    
    // Chat Images - ผู้ใช้ที่ login แล้วสามารถอัพโหลดได้
    match /chat_images/{userId}/{imageId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Admin สามารถดูได้
    }
    
    // Chat Files - ผู้ใช้ที่ login แล้วสามารถอัพโหลดได้
    match /chat_files/{userId}/{fileId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Admin สามารถดูได้
    }
    
    // Product Images - เฉพาะ Admin เท่านั้น
    match /products/{productId}/{imageId} {
      allow read: if true; // ทุกคนดูได้
      allow write: if request.auth != null; // ต้อง login
    }
    
    // Default: Deny all
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### ขั้นตอนที่ 3: Publish Rules
1. กด **Publish** เพื่อบันทึกการเปลี่ยนแปลง

### การตรวจสอบ
Rules ข้างต้นจะอนุญาต:
- ✅ User ที่ login แล้วอัพโหลดรูป/ไฟล์แชทได้
- ✅ User สามารถดูไฟล์ของตัวเองได้
- ✅ Admin สามารถดูไฟล์ทั้งหมดได้
- ✅ ทุกคนดูรูปสินค้าได้
- ✅ User ที่ login แล้วอัพโหลดรูปสินค้าได้

### หากยังมีปัญหา - Rules แบบ Development (ไม่แนะนำสำหรับ Production)
หากต้องการทดสอบก่อน สามารถใช้ Rules แบบนี้ชั่วคราว:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ คำเตือน**: Rules นี้อนุญาตให้ user ที่ login แล้วทำอะไรก็ได้ ใช้เฉพาะการทดสอบเท่านั้น!