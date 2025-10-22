# 📱 Release Guide - APK & TestFlight

## 📊 สถานะปัจจุบัน

### ✅ **สิ่งที่มีอยู่**
- 🔧 **Debug APK**: `app-debug.apk` (134.5 MB) - สร้างเมื่อ 18 Oct 2025
- 🎯 **Release APK**: `app-release.apk` (60.9 MB) - สร้างเมื่อ 22 Oct 2025 ✅
- 📝 **Source Code**: พร้อมสำหรับ production build
- 🔥 **Firebase**: ตั้งค่าเรียบร้อย
- 💳 **Stripe**: Integration พร้อมใช้งาน

### ❌ **สิ่งที่ยังไม่มี**
- 🍎 **iOS Build**: ยังไม่ได้ build สำหรับ TestFlight
- 🏪 **App Store Connect**: ยังไม่ได้เตรียม
- 📝 **Release Notes**: ยังไม่ได้เตรียม

---

## 🎯 สถานะปัจจุบัน (22 October 2025)

### 📱 Android APK
| Type | File | Size | Status |
|------|------|------|--------|
| **Release** | `app-release.apk` | **60.9 MB** | ✅ **พร้อมใช้งาน** |
| Debug | `app-debug.apk` | 134.5 MB | ✅ สำหรับทดสอบ |

**📍 Location:** `build/app/outputs/flutter-apk/`

### 📋 การแก้ไขปัญหาที่ทำไปแล้ว
1. ✅ **Developer Mode**: เปิดใช้งานใน Windows Settings
2. ✅ **Stripe SDK**: แก้ปัญหา missing classes ด้วยการปิด minification
3. ✅ **Linting**: ปิด lint checks สำหรับ release build
4. ✅ **ProGuard**: เพิ่ม rules สำหรับ Firebase และ Stripe

### 🔧 การตั้งค่าที่ทำไปแล้ว
- ✅ `android/app/proguard-rules.pro` - เพิ่ม keep rules
- ✅ `android/app/build.gradle.kts` - ปิด linting สำหรับ release
- ✅ Flutter pub get ทำงานได้ปกติ

---

## 🚀 วิธีสร้าง Release APK

### 1️⃣ **เตรียมพร้อมสำหรับ Release**

```bash
# ตรวจสอบ Flutter และ dependencies
flutter doctor
flutter pub get
flutter pub upgrade

# ทำความสะอาด build cache
flutter clean
flutter pub get
```

### 2️⃣ **สร้าง Release APK**

```bash
# สร้าง APK สำหรับ distribution
flutter build apk --release

# หรือสร้าง AAB (Android App Bundle) สำหรับ Google Play Store
flutter build appbundle --release
```

**ไฟล์ที่ได้:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### 3️⃣ **Sign APK (สำหรับ distribution)**

```bash
# สร้าง keystore (ครั้งแรกเท่านั้น)
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# ตั้งค่าใน android/key.properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../upload-keystore.jks
```

---

## 🍎 วิธีสร้าง iOS Build สำหรับ TestFlight

### 1️⃣ **เตรียม iOS Environment**

```bash
# ติดตั้ง Xcode (จาก Mac App Store)
# ติดตั้ง iOS deployment tools
flutter precache --ios
```

### 2️⃣ **Configure iOS Project**

1. เปิด `ios/Runner.xcworkspace` ใน Xcode
2. ตั้งค่า Bundle Identifier (เช่น `com.yourcompany.microcommerce`)
3. เลือก Development Team
4. ตั้งค่า Signing & Capabilities

### 3️⃣ **Build สำหรับ TestFlight**

```bash
# สร้าง iOS build
flutter build ios --release

# หรือ build archive ผ่าน Xcode
# 1. เปิด Xcode
# 2. Product → Archive
# 3. Upload to App Store Connect
```

---

## 📦 Release Checklist

### 🔍 **Pre-Release Testing**
- [ ] ทดสอบบน multiple devices
- [ ] ทดสอบ payment integration
- [ ] ทดสอบ Firebase connections
- [ ] ทดสอบ offline functionality
- [ ] ทดสอบ performance

### 📝 **Documentation**
- [ ] อัปเดต version ใน `pubspec.yaml`
- [ ] เขียน release notes
- [ ] อัปเดต CHANGELOG.md
- [ ] เตรียม App Store descriptions

### 🔐 **Security & Privacy**
- [ ] ตรวจสอบ API keys และ secrets
- [ ] อัปเดต privacy policy
- [ ] ตรวจสอบ permissions
- [ ] Obfuscate code

### 📱 **App Store Preparation**
- [ ] App icons ทุกขนาด
- [ ] Screenshots สำหรับ store
- [ ] App descriptions
- [ ] Keywords สำหรับ SEO

---

## 🛠️ Build Commands Reference

### Android Release
```bash
# Standard APK
flutter build apk --release --target-platform android-arm64

# Universal APK (ทุก architecture)
flutter build apk --release --split-per-abi

# App Bundle (สำหรับ Google Play)
flutter build appbundle --release
```

### iOS Release
```bash
# iOS Release Build
flutter build ios --release

# ระบุ specific configuration
flutter build ios --release --flavor production
```

### Web Release
```bash
# Web Release Build
flutter build web --release

# PWA optimized
flutter build web --release --pwa-strategy offline-first
```

---

## 📋 Version Management

### อัปเดต Version Number
```yaml
# ใน pubspec.yaml
version: 1.0.0+1
#        ↑     ↑
#   version  build number
```

### สำหรับ release ใหม่:
- **Major**: 2.0.0+1 (breaking changes)
- **Minor**: 1.1.0+1 (new features)
- **Patch**: 1.0.1+1 (bug fixes)

---

## 🚀 Distribution Options

### 📱 **Android**
1. **Google Play Store** (official)
2. **APK Direct Download** (sideloading)
3. **Amazon Appstore**
4. **Samsung Galaxy Store**

### 🍎 **iOS**
1. **App Store** (official)
2. **TestFlight** (beta testing)
3. **Enterprise Distribution** (internal)

### 🌐 **Web**
1. **Firebase Hosting**
2. **GitHub Pages**
3. **Netlify/Vercel**
4. **Custom Domain**

---

## 🔧 Next Steps สำหรับ Production

### 1. **สร้าง Release APK**
```bash
cd micro_commerce
flutter clean
flutter pub get
flutter build apk --release
```

### 2. **Setup App Store Connect (iOS)**
- สร้าง Apple Developer Account
- สร้าง App ID
- ตั้งค่า App Store Connect
- เตรียม metadata และ screenshots

### 3. **Setup Google Play Console (Android)**
- สร้าง Google Play Developer Account
- สร้าง app listing
- อัปโหลด APK/AAB
- ตั้งค่า pricing และ distribution

### 4. **Beta Testing**
- TestFlight สำหรับ iOS
- Google Play Internal Testing สำหรับ Android
- Firebase App Distribution สำหรับทั้งสอง platform

---

## 📞 Support & Resources

### การติดตั้ง Production
- [Flutter Release Build Guide](https://docs.flutter.dev/deployment)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)
- [iOS App Store Guide](https://developer.apple.com/app-store/)

### Tools ที่แนะนำ
- **Fastlane**: Automate deployment
- **CodeMagic**: CI/CD for Flutter
- **GitHub Actions**: Free CI/CD
- **Firebase App Distribution**: Beta testing

---

📝 **สถานะ**: Ready for Production Build  
🎯 **ขั้นตอนถัดไป**: สร้าง release APK และเตรียม iOS build  
📅 **อัปเดตล่าสุด**: October 22, 2025