# 📚 คู่มือการใช้งาน (User Guides)

เอกสารคู่มือการใช้งานระบบต่างๆ ของ Micro Commerce

## 📖 เอกสารในโฟลเดอร์นี้

### 🏗️ ARCHITECTURE.md
**โครงสร้างระบบและสถาปัตยกรรม**
- 🎯 **สำหรับ:** Developer ที่ต้องการเข้าใจโครงสร้างโปรเจค
- 📝 **เนื้อหา:** System architecture, Database schema, Authentication system
- 🔗 **ควรอ่านคู่กับ:** README.md (ในโฟลเดอร์หลัก)

### 🔧 ADMIN_GUIDE.md
**คู่มือการใช้งานระบบแอดมิน**
- 🎯 **สำหรับ:** แอดมินและผู้จัดการระบบ
- 📝 **เนื้อหา:** การจัดการสินค้า, ผู้ใช้, คำสั่งซื้อ, รายงาน
- 🔗 **ควรอ่านคู่กับ:** COUPON_CODES_GUIDE.md

### 🎟️ COUPON_CODES_GUIDE.md
**คู่มือการสร้างและใช้งานคูปองส่วนลด**
- 🎯 **สำหรับ:** แอดมินที่ต้องการสร้างคูปอง
- 📝 **เนื้อหา:** วิธีสร้างคูปอง, ตัวอย่างคูปอง
- 🔗 **ควรอ่านคู่กับ:** COUPON_CALCULATION_EXAMPLES.md, COUPON_TESTING_GUIDE.md

### 📊 COUPON_CALCULATION_EXAMPLES.md
**ตัวอย่างการคำนวณส่วนลดคูปอง**
- 🎯 **สำหรับ:** Developer และแอดมิน
- 📝 **เนื้อหา:** ตัวอย่างการคำนวณส่วนลดแบบต่างๆ
- 🔗 **ควรอ่านคู่กับ:** COUPON_CODES_GUIDE.md

### 🧪 COUPON_TESTING_GUIDE.md
**คู่มือการทดสอบระบบคูปอง**
- 🎯 **สำหรับ:** QA Tester และ Developer
- 📝 **เนื้อหา:** วิธีทดสอบคูปอง, test cases
- 🔗 **ควรอ่านคู่กับ:** ../reports/QA_REPORT.md

## 🚀 ลำดับการอ่านที่แนะนำ

### สำหรับ Developer ใหม่:
1. **ARCHITECTURE.md** - เข้าใจโครงสร้างก่อน
2. **ADMIN_GUIDE.md** - เรียนรู้การใช้งาน
3. **COUPON_CODES_GUIDE.md** - ทำความเข้าใจระบบคูปอง

### สำหรับ Admin/Manager:
1. **ADMIN_GUIDE.md** - เริ่มต้นที่นี่
2. **COUPON_CODES_GUIDE.md** - จัดการคูปอง
3. **COUPON_CALCULATION_EXAMPLES.md** - ดูตัวอย่าง

### สำหรับ QA Tester:
1. **COUPON_TESTING_GUIDE.md** - เรียนรู้การทดสอบ
2. **COUPON_CALCULATION_EXAMPLES.md** - ทำความเข้าใจการคำนวณ
3. **ADMIN_GUIDE.md** - เข้าใจการทำงานของระบบ

## 📌 หมายเหตุ

- 📄 เอกสารเหล่านี้เป็นคู่มือหลักสำหรับการใช้งานระบบ
- 🔄 หากพบปัญหาในการใช้งาน ให้ดูเอกสารใน ../bug-fixes/
- 🔧 หากต้องการตั้งค่าระบบ ให้ดูเอกสารใน ../configuration/
- 📊 หากต้องการดูรายงาน ให้ดูเอกสารใน ../reports/