# 📚 Documentation Center - Micro Commerce

เอกสารประกอบโปรเจค Micro Commerce ที่จัดระเบียบเป็นหมวดหมู่เพื่อความสะดวกในการค้นหาและอ่าน

## 📁 โครงสร้างเอกสาร

```
docs/
├── README.md (ไฟล์นี้)
├── DOCUMENTATION_INDEX.md (ดัชนีเอกสารหลัก)
├── guides/                 (คู่มือการใช้งาน)
├── bug-fixes/              (การแก้ไขปัญหา)
├── chat-system/            (ระบบแชท)
├── configuration/          (การตั้งค่า)
└── reports/                (รายงาน)
```

## 🎯 เริ่มต้นอ่านเอกสาร

### 👨‍💻 สำหรับ Developer ใหม่
1. 📖 [`DOCUMENTATION_INDEX.md`](DOCUMENTATION_INDEX.md) - ดัชนีเอกสารทั้งหมด
2. 🏗️ [`guides/ARCHITECTURE.md`](guides/ARCHITECTURE.md) - โครงสร้างระบบ
3. 🔧 [`guides/ADMIN_GUIDE.md`](guides/ADMIN_GUIDE.md) - คู่มือแอดมิน

### 🛠️ สำหรับ Admin/Manager
1. 🔧 [`guides/ADMIN_GUIDE.md`](guides/ADMIN_GUIDE.md) - คู่มือใช้งานแอดมิน
2. 🎟️ [`guides/COUPON_CODES_GUIDE.md`](guides/COUPON_CODES_GUIDE.md) - จัดการคูปอง
3. 📊 [`reports/QA_REPORT.md`](reports/QA_REPORT.md) - รายงานคุณภาพ

### 🧪 สำหรับ QA Tester
1. 🧪 [`guides/COUPON_TESTING_GUIDE.md`](guides/COUPON_TESTING_GUIDE.md) - ทดสอบคูปอง
2. 📊 [`reports/QA_REPORT.md`](reports/QA_REPORT.md) - รายงานการทดสอบ
3. 🐛 [`bug-fixes/BUG_LOG.md`](bug-fixes/BUG_LOG.md) - บันทึกบัค

## 📂 คำอธิบายแต่ละโฟลเดอร์

### 📚 [`guides/`](guides/) - คู่มือการใช้งาน
เอกสารสำหรับการใช้งานระบบต่างๆ
- Architecture และโครงสร้างระบบ
- คู่มือแอดมิน
- คู่มือระบบคูปอง
- ตัวอย่างการใช้งาน

### 🔧 [`bug-fixes/`](bug-fixes/) - การแก้ไขปัญหา
เอกสารการแก้ไขบัคและปรับปรุงระบบ
- รายงานการแก้ไขหลัก
- บันทึกบัคและปัญหา
- การแก้ไขเฉพาะระบบ
- การปรับปรุงโค้ด

### 💬 [`chat-system/`](chat-system/) - ระบบแชท
เอกสารเกี่ยวกับระบบแชทและการจัดการข้อความ
- การลบข้อความแชท
- รายงานปัญหาแชท
- เอกสารการทำงานของระบบ

### 🔐 [`configuration/`](configuration/) - การตั้งค่า
เอกสารการตั้งค่าระบบและความปลอดภัย
- Firebase Storage Rules
- Confirmation Dialog
- การตั้งค่าความปลอดภัย

### 📊 [`reports/`](reports/) - รายงาน
รายงานการทดสอบและสรุปโปรเจค
- รายงาน QA
- สรุปโปรเจคสุดท้าย
- สถิติและ metrics

## 🔍 การค้นหาเอกสาร

### ตามหัวข้อ
- 🏠 **เริ่มต้น** → [`DOCUMENTATION_INDEX.md`](DOCUMENTATION_INDEX.md)
- 🏗️ **โครงสร้างระบบ** → [`guides/ARCHITECTURE.md`](guides/ARCHITECTURE.md)
- 🔧 **ใช้งานแอดมิน** → [`guides/ADMIN_GUIDE.md`](guides/ADMIN_GUIDE.md)
- 🎟️ **จัดการคูปอง** → [`guides/COUPON_CODES_GUIDE.md`](guides/COUPON_CODES_GUIDE.md)
- 🐛 **ดูปัญหา** → [`bug-fixes/BUG_FIX_REPORT.md`](bug-fixes/BUG_FIX_REPORT.md)

### ตามประเภทปัญหา
- **ปัญหาแอดมิน** → [`bug-fixes/ADMIN_FIXES.md`](bug-fixes/ADMIN_FIXES.md)
- **ปัญหาแชท** → [`chat-system/CHAT_DELETION_ERROR_REPORT.md`](chat-system/CHAT_DELETION_ERROR_REPORT.md)
- **ปัญหาหมวดหมู่** → [`bug-fixes/CATEGORY_ADMIN_FIX.md`](bug-fixes/CATEGORY_ADMIN_FIX.md)
- **ปัญหา UI** → [`bug-fixes/BLACK_SCREEN_FIX_REPORT.md`](bug-fixes/BLACK_SCREEN_FIX_REPORT.md)

## 📌 หมายเหตุ

- 📄 เอกสารทั้งหมดเขียนเป็นภาษาไทยเพื่อความเข้าใจง่าย
- 🔄 เอกสารได้รับการอัปเดตสม่ำเสมอ
- ❓ หากมีคำถาม สามารถดูใน [`DOCUMENTATION_INDEX.md`](DOCUMENTATION_INDEX.md) เพื่อหาเอกสารที่เหมาะสม
- 🆕 เอกสารใหม่จะถูกเพิ่มในโฟลเดอร์ที่เหมาะสมและอัปเดตดัชนี

---

📝 **อัปเดตล่าสุด:** October 22, 2025  
💼 **โปรเจค:** Micro Commerce E-commerce Platform  
🏷️ **เวอร์ชัน:** Documentation v1.0