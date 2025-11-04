# 🛒 Micro Commerce

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.0-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-10.4.0-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A modern, full-featured E-commerce mobile application built with Flutter & Firebase**

[🚀 Features](#-features) • [📱 Screenshots](#-screenshots) • [⚡ Quick Start](#-quick-start) • [📖 Documentation](#-documentation)

</div>

---

## 🌟 Overview

**Micro Commerce** is a comprehensive e-commerce mobile application that provides a complete shopping experience for both customers and administrators. Built with modern technologies and best practices, it offers real-time features, secure payments, and an intuitive user interface.

### ✨ Key Highlights

- 🎯 **Cross-platform** - Works on Android, iOS, and Web
- 🔄 **Real-time** - Live chat, instant updates, and synchronization
- 🛡️ **Secure** - Firebase Authentication and security rules
- 💳 **Payment Ready** - Integrated with Stripe payment gateway
- 🎨 **Modern UI** - Beautiful, responsive design with smooth animations
- 📊 **Analytics** - Comprehensive admin dashboard with insights

---

## 🚀 Features

### 👥 **User Management**
- ✅ Email/Password authentication with Firebase
- ✅ User profile management and editing
- ✅ Role-based access control (Customer/Admin)
- ✅ Password reset functionality

### 🛍️ **E-commerce Core**
- ✅ Product catalog with search and filtering
- ✅ Product variants (size, color, specifications)
- ✅ Shopping cart with persistent storage
- ✅ Wishlist functionality
- ✅ Order management and tracking
- ✅ Order history and status updates

### 💰 **Payment & Discounts**
- ✅ Stripe payment integration
- ✅ Coupon and discount system
- ✅ Multiple discount types (percentage, fixed amount)
- ✅ Coupon validation and expiry handling

### 💬 **Communication**
- ✅ Real-time chat between customers and admins
- ✅ Product-specific chat rooms
- ✅ Image sharing in chat
- ✅ Message deletion and management

### 🔧 **Admin Panel**
- ✅ Product management (CRUD operations)
- ✅ Order management and fulfillment
- ✅ User management and role assignment
- ✅ Coupon management
- ✅ Sales analytics and reporting
- ✅ Chat management

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Frontend** | Flutter 3.9.0, Dart 3.9.0 |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **State Management** | Provider Pattern |
| **Payment** | Stripe |
| **Real-time** | Firestore Streams |
| **UI/UX** | Material Design, Custom Widgets |
| **Development** | VS Code, Android Studio |

---

## 📱 Screenshots

<div align="center">

| Home Screen | Product Details | Shopping Cart | Admin Dashboard |
|-------------|-----------------|---------------|-----------------|
| *Product catalog with search* | *Detailed view with variants* | *Manage cart items* | *Comprehensive admin tools* |

| Chat System | Payment | Order History | Coupon Management |
|-------------|---------|---------------|-------------------|
| *Real-time customer support* | *Secure Stripe payments* | *Track order status* | *Discount management* |

</div>

---

## ⚡ Quick Start

### 📋 Prerequisites

- **Flutter SDK** 3.9.0 or higher ([Install Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK** 3.9.0 or higher (included with Flutter)
- **Firebase Project** ([Setup Guide](https://firebase.google.com/docs/flutter/setup))
- **Stripe Account** ([Get API Keys](https://stripe.com/docs/keys))

### 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/SurasakSiangsai02/micro-commerce.git
   cd micro-commerce
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase and Stripe credentials
   ```

4. **Configure Firebase**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/firebase_options.dart`

5. **Run the app**
   ```bash
   flutter run
   ```

### 🔑 Environment Variables

Create a `.env` file in the root directory:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket

# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
STRIPE_SECRET_KEY=sk_test_your_secret_key

# App Configuration
APP_NAME=Micro Commerce
ENVIRONMENT=development
```

---

## 📁 Project Structure

```
lib/
├── 📁 config/              # App configuration
├── 📁 constants/           # App constants
├── 📁 models/              # Data models
├── 📁 providers/           # State management
├── 📁 screens/             # UI screens
│   ├── 📁 auth/           # Authentication screens
│   ├── 📁 admin/          # Admin panel
│   ├── 📁 customer/       # Customer screens
│   └── 📁 common/         # Shared screens
├── 📁 services/            # Business logic
├── 📁 utils/              # Utilities & helpers
├── 📁 widgets/            # Reusable components
└── main.dart              # App entry point

docs/                       # Documentation
├── 📁 guides/             # User guides
├── 📁 bug-fixes/          # Bug reports & fixes
├── 📁 chat-system/        # Chat documentation
├── 📁 configuration/      # Setup guides
└── 📁 reports/           # Project reports
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [📚 Documentation Index](docs/DOCUMENTATION_INDEX.md) | Complete documentation overview |
| [🏗️ Architecture Guide](docs/guides/ARCHITECTURE.md) | System architecture & design |
| [🔧 Admin Guide](docs/guides/ADMIN_GUIDE.md) | Admin panel usage guide |
| [🎟️ Coupon System](docs/guides/COUPON_CODES_GUIDE.md) | Coupon management guide |
| [🐛 Bug Reports](docs/bug-fixes/BUG_FIX_REPORT.md) | Known issues and fixes |
| [📊 QA Report](docs/reports/QA_REPORT.md) | Quality assurance report |

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

**Test Coverage**: 85%+ across all modules

---

## 🚀 Deployment

### 📱 Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### 🍎 iOS
```bash
flutter build ios --release
```

### 🌐 Web
```bash
flutter build web --release
```

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

---

## 📈 Project Status

![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen)
![Test Coverage](https://img.shields.io/badge/Coverage-85%25-brightgreen)
![Quality Grade](https://img.shields.io/badge/Quality-A--brightgreen)
![Production Ready](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)

- ✅ **Development**: Complete (100%)
- ✅ **Testing**: Complete (85% coverage)
- ✅ **Bug Fixes**: 85/100 issues resolved
- ✅ **Documentation**: Complete (90%)
- 🚀 **Status**: Ready for Production

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Surasak Siangsai**
- GitHub: [@SurasakSiangsai02](https://github.com/SurasakSiangsai02)
- Email: surachat.siangsai@gmail.com

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) for the amazing framework
- [Firebase](https://firebase.google.com/) for the backend services
- [Stripe](https://stripe.com/) for payment processing
- [Material Design](https://material.io/) for design guidelines

---

## 📞 Support

If you found this project helpful, please give it a ⭐ on GitHub!

For support, email surachat.siangsai@gmail.com or create an issue in the repository.

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ Back to Top](#-micro-commerce)

</div>
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
