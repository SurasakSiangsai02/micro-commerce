# 📁 Project Structure Documentation
## Micro-Commerce Flutter E-commerce App

> **อัปเดตล่าสุด:** 3 พฤศจิกายน 2025  
> **เวอร์ชัน:** Flutter 3.35.2 | Dart 3.6.1

---

## 🏗️ **โครงสร้างหลักของโปรเจค**

```
micro_commerce/
├── 📱 lib/                          # Source code หลัก
├── 📚 docs/                         # เอกสารประกอบ
├── 🤖 android/                      # Android platform
├── 🍎 ios/                          # iOS platform  
├── 🐧 linux/                        # Linux platform
├── 🪟 windows/                      # Windows platform
├── 🌐 web/                          # Web platform
├── 🧪 test/                         # Test files
├── 🔧 pubspec.yaml                  # Dependencies config
├── 🔥 firebase_options.dart         # Firebase config
├── 🛡️ storage-rules.rules          # Firebase Storage rules
├── 🛡️ firestore.rules             # Firestore Database rules
├── 🙈 .gitignore                   # Git ignore patterns
└── 📋 README.md                    # Project README
```

---

## 📱 **lib/ - Source Code หลัก**

### 📂 **lib/main.dart** - Entry Point
```dart
/// 🚀 Micro-Commerce E-commerce App
/// 
/// ระบบ E-commerce ครบวงจร ประกอบด้วย:
/// 
/// 🔥 Backend & Database:
/// • Firebase Authentication (Login/Register)  
/// • Firestore Database (Products, Users, Orders, Cart)
/// • Real-time data synchronization
/// 
/// 🛒 Core Features:
/// • Product Catalog with Search & Filter
/// • Shopping Cart with Persistent Storage
/// • User Authentication & Profiles
/// • Order Management System
/// • Real-time Cart Sync across devices
```

**หน้าที่:**
- จุดเริ่มต้นของ App
- Initialize Firebase และ Services
- Setup Provider Pattern สำหรับ State Management
- กำหนด Theme และ Navigation
- จัดการ Error Handling ระดับ Global

---

### 📂 **lib/config/ - App Configuration**

#### `app_config.dart` - ⚙️ **Main App Configuration**
```dart
/// 🔐 Secure App Configuration
/// 
/// ใช้ environment variables เพื่อความปลอดภัย
/// ไม่เก็บ sensitive keys ในโค้ดโดยตรง
```

**หน้าที่:**
- จัดการ Environment Variables
- กำหนดค่า API Keys (Stripe, Firebase)
- Setup Development/Production environments
- Security Configuration

#### `security_config.dart` - 🛡️ **Security Settings**
**หน้าที่:**
- Password policies
- Validation rules
- Security headers
- Data encryption settings

#### `stripe_config.dart` - 💳 **Payment Configuration**  
**หน้าที่:**
- Stripe payment gateway setup
- Payment methods configuration
- Currency settings
- Transaction limits

---

### 📂 **lib/constants/ - App Constants**

**หน้าที่:**
- กำหนดค่าคงที่ของ App
- Colors, Fonts, Sizes
- API endpoints
- Default values
- Error messages

---

### 📂 **lib/models/ - Data Models**

#### `user.dart` - 👤 **User Model**
```dart
class UserModel {
  String uid, email, name, role;
  DateTime createdAt;
  Map<String, dynamic> preferences;
}
```

#### `product.dart` - 🛍️ **Product Model**
```dart
class Product {
  String id, name, description, category;
  double price, discountPrice;
  List<String> images;
  int stock;
  Map<String, dynamic> specifications;
}
```

#### `product_variant.dart` - 🎨 **Product Variants**
```dart
class ProductVariant {
  String id, productId, name;
  double price;
  int stock;
  Map<String, dynamic> attributes; // size, color, etc.
}
```

#### `coupon.dart` - 🎫 **Coupon System**
```dart
class Coupon {
  String id, code, description;
  CouponType type; // percentage, fixed
  double value, minAmount;
  DateTime validFrom, validTo;
  int usageLimit;
}
```

#### `chat_room.dart` - 💬 **Chat Room**
```dart
class ChatRoom {
  String id, customerId, adminId;
  String title, status;
  DateTime createdAt, lastMessageAt;
  List<String> participants;
}
```

#### `chat_message.dart` - 📩 **Chat Messages**
```dart
class ChatMessage {
  String id, roomId, senderId, content;
  MessageType type; // text, image, file
  DateTime timestamp;
  bool isRead;
}
```

**หน้าที่ของ Models:**
- กำหนดโครงสร้างข้อมูล
- Serialization (JSON ↔ Object)
- Data validation
- Type safety

---

### 📂 **lib/providers/ - State Management**

#### `auth_provider.dart` - 🔐 **Authentication State**
```dart
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  AuthState _state = AuthState.loading;
  
  // Methods: login(), logout(), register(), updateProfile()
}
```

#### `cart_provider.dart` - 🛒 **Shopping Cart State**
```dart
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  double _total = 0.0;
  
  // Methods: addItem(), removeItem(), updateQuantity(), clear()
}
```

#### `chat_provider.dart` - 💬 **Chat State Management**
```dart
class ChatProvider extends ChangeNotifier {
  List<ChatRoom> _rooms = [];
  List<ChatMessage> _messages = [];
  
  // Methods: loadRooms(), sendMessage(), markAsRead()
}
```

#### `coupon_provider.dart` - 🎫 **Coupon State**
```dart
class CouponProvider extends ChangeNotifier {
  List<Coupon> _availableCoupons = [];
  Coupon? _appliedCoupon;
  
  // Methods: applyCoupon(), removeCoupon(), validateCoupon()
}
```

**หน้าที่ของ Providers:**
- จัดการ Application State
- Notify widgets เมื่อข้อมูลเปลี่ยน
- Business logic ระดับ UI
- Data caching

---

### 📂 **lib/services/ - Business Logic Layer**

#### `auth_service.dart` - 🔐 **Authentication Service**
```dart
class AuthService {
  // Firebase Auth integration
  Future<UserCredential> signIn(String email, String password);
  Future<void> signOut();
  Future<UserCredential> register(String email, String password);
  Future<void> resetPassword(String email);
}
```

#### `database_service.dart` - 🗄️ **Database Operations**
```dart
class DatabaseService {
  // Firestore CRUD operations
  Future<List<Product>> getProducts();
  Future<void> addProduct(Product product);
  Future<void> updateProduct(String id, Product product);
  Future<void> deleteProduct(String id);
}
```

#### `storage_service.dart` - 📁 **File Storage**
```dart
class StorageService {
  // Firebase Storage for images/files
  Future<String> uploadImage(File image, String path);
  Future<void> deleteFile(String url);
  Future<List<String>> uploadMultipleImages(List<File> images);
}
```

#### `payment_service.dart` - 💳 **Payment Processing**
```dart
class PaymentService {
  // Stripe integration
  Future<PaymentIntent> createPaymentIntent(double amount);
  Future<bool> processPayment(String paymentMethodId);
  Future<List<PaymentMethod>> getPaymentMethods();
}
```

#### `chat_service.dart` - 💬 **Chat System**
```dart
class ChatService {
  // Real-time chat functionality
  Stream<List<ChatMessage>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, String content);
  Future<ChatRoom> createChatRoom(String customerId);
}
```

#### `coupon_service.dart` - 🎫 **Coupon Management**
```dart
class CouponService {
  // Coupon validation and application
  Future<Coupon?> validateCoupon(String code);
  Future<double> calculateDiscount(List<CartItem> items, Coupon coupon);
  Future<void> useCoupon(String couponId, String userId);
}
```

#### `firebase_tester.dart` - 🧪 **Firebase Testing**
```dart
class FirebaseTester {
  // Firebase connection testing
  Future<void> testAuth();
  Future<void> testFirestore();  
  Future<void> testStorage();
}
```

**หน้าที่ของ Services:**
- จัดการ Business Logic
- การเชื่อมต่อกับ Backend/APIs
- Data transformation
- Error handling

---

### 📂 **lib/screens/ - UI Screens**

#### 📂 **screens/auth/ - Authentication Screens**
- `login_screen.dart` - หน้าเข้าสู่ระบบ
- `register_screen.dart` - หน้าสมัครสมาชิก
- `forgot_password_screen.dart` - หน้ารีเซ็ตรหัสผ่าน
- `profile_screen.dart` - หน้าโปรไฟล์ผู้ใช้

#### 📂 **screens/customer/ - Customer Interface**
- `customer_home_screen.dart` - หน้าหลักลูกค้า
- `product_list_screen.dart` - รายการสินค้า
- `product_detail_screen.dart` - รายละเอียดสินค้า
- `cart_screen.dart` - ตะกร้าสินค้า
- `checkout_screen.dart` - หน้าชำระเงิน
- `order_history_screen.dart` - ประวัติการสั่งซื้อ
- `customer_chat_screen.dart` - แชทกับ Admin

#### 📂 **screens/admin/ - Admin Panel**
- `admin_dashboard_screen.dart` - แดชบอร์ดผู้ดูแล
- `product_management_screen.dart` - จัดการสินค้า
- `add_product_screen.dart` - เพิ่มสินค้าใหม่
- `edit_product_screen.dart` - แก้ไขสินค้า
- `order_management_screen.dart` - จัดการคำสั่งซื้อ
- `user_management_screen.dart` - จัดการผู้ใช้
- `coupon_management_screen.dart` - จัดการคูปอง
- `admin_chat_screen.dart` - แชทกับลูกค้า

#### 📂 **screens/chat/ - Chat System**
- `chat_list_screen.dart` - รายการห้องแชท
- `chat_detail_screen.dart` - หน้าแชทรายละเอียด

#### 📂 **screens/common/ - Shared Screens**
- `splash_screen.dart` - หน้า Loading เริ่มต้น
- `error_screen.dart` - หน้าแสดง Error
- `settings_screen.dart` - หน้าตั้งค่า

**หน้าที่ของ Screens:**
- User Interface (UI)
- User Experience (UX)
- การแสดงผลข้อมูล
- การรับ Input จากผู้ใช้

---

### 📂 **lib/widgets/ - Reusable Components**

```
widgets/
├── common/                    # Widget ทั่วไป
│   ├── loading_indicator.dart # Loading animations
│   ├── error_dialog.dart     # Error dialogs
│   ├── custom_button.dart    # Custom buttons
│   └── custom_text_field.dart # Text inputs
├── product/                   # Product-related widgets
│   ├── product_card.dart     # Product display cards
│   ├── product_grid.dart     # Product grid layout
│   └── price_display.dart    # Price formatting
├── chat/                      # Chat widgets
│   ├── message_bubble.dart   # Chat message bubbles
│   ├── message_input.dart    # Message input field
│   └── chat_list_tile.dart   # Chat room list item
└── cart/                      # Cart widgets
    ├── cart_item_widget.dart # Cart item display
    ├── cart_summary.dart     # Cart totals
    └── quantity_selector.dart # Quantity +/- buttons
```

**หน้าที่ของ Widgets:**
- UI Components ที่ใช้ซ้ำได้
- Consistent design system
- Reusable functionality
- Clean code organization

---

### 📂 **lib/utils/ - Utilities & Helpers**

```
utils/
├── theme.dart              # App theme configuration
├── logger.dart            # Logging utility
├── validators.dart        # Input validation
├── formatters.dart        # Data formatting
├── constants.dart         # App constants
├── helpers.dart           # Helper functions
└── extensions.dart        # Dart extensions
```

**หน้าที่:**
- ฟังก์ชันช่วยเหลือทั่วไป
- การจัดรูปแบบข้อมูล
- Validation logic
- App theming
- Logging system

---

## 📚 **docs/ - Documentation**

### 📂 **docs/guides/ - User Guides**
```
guides/
├── ADMIN_GUIDE.md                # คำแนะนำสำหรับ Admin
├── ARCHITECTURE.md              # สถาปัตยกรรมระบบ
├── COUPON_CODES_GUIDE.md        # การใช้คูปอง
├── COUPON_CALCULATION_EXAMPLES.md # ตัวอย่างการคำนวณส่วนลด
├── COUPON_TESTING_GUIDE.md      # การทดสอบระบบคูปอง
├── DEMO_GUIDE.md               # คำแนะนำการ Demo
├── DEMO_QUICK_START.md         # เริ่มต้นใช้งานด่วน
├── RELEASE_GUIDE.md            # คำแนะนำการปล่อยเวอร์ชัน
├── SHARING_TEMPLATES.md        # เทมเพลตการแชร์
└── TESTING_INSTRUCTIONS.md    # คำแนะนำการทดสอบ
```

### 📂 **docs/configuration/ - Setup Guides**
```
configuration/
├── CONFIRMATION_DIALOG_DOCUMENTATION.md # Dialog confirmations
├── FIREBASE_STORAGE_RULES.md           # Firebase Storage setup
└── README.md                           # Configuration overview
```

### 📂 **docs/chat-system/ - Chat Documentation**
```
chat-system/
├── README.md                    # Chat system overview
└── [other chat-related docs]
```

### 📂 **docs/reports/ - Project Reports**
```
reports/
├── DEMO_ANALYTICS.md           # Analytics และ metrics
└── README.md                   # Reports overview
```

**หน้าที่ของ docs/:**
- เอกสารคำแนะนำการใช้งาน
- Setup และ Configuration guides
- Architecture documentation
- Best practices
- Troubleshooting guides

---

## 🔧 **Configuration Files**

### `pubspec.yaml` - **Dependencies & Assets**
```yaml
dependencies:
  flutter:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  provider: ^6.1.1
  flutter_stripe: ^10.1.1
```

### `firebase_options.dart` - **Firebase Configuration**
- Auto-generated Firebase config
- Platform-specific settings
- API keys และ project IDs

### `storage-rules.rules` - **Firebase Storage Rules**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Security rules for file uploads
  }
}
```

### `firestore.rules` - **Firestore Database Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Security rules for database access
  }
}
```

---

## 🏗️ **Architecture Overview**

### **Pattern ที่ใช้:**
1. **Provider Pattern** - State Management
2. **Service Layer** - Business Logic
3. **Repository Pattern** - Data Access
4. **Clean Architecture** - Separation of Concerns

### **Data Flow:**
```
UI (Screens/Widgets) 
    ↕ 
Providers (State Management)
    ↕
Services (Business Logic)
    ↕
Firebase (Backend/Database)
```

### **Security Layers:**
1. **Firebase Security Rules** - Database & Storage access
2. **Authentication** - User verification
3. **Input Validation** - Data sanitization
4. **Environment Variables** - Secret management

---

## 🎯 **Key Features**

### 🛒 **E-commerce Core:**
- Product catalog với search & filter
- Shopping cart with persistence
- Order management system
- Payment integration (Stripe)
- User authentication & profiles

### 💬 **Communication:**
- Real-time chat system
- Admin-customer messaging
- File sharing in chat
- Message history

### 🎫 **Promotion System:**
- Coupon codes
- Discount calculations
- Usage limits & validation
- Expiry date management

### 👥 **User Management:**
- Customer accounts
- Admin panel
- Role-based permissions
- Profile management

### 📊 **Analytics & Reporting:**
- Sales analytics
- User behavior tracking
- Performance metrics
- Demo analytics

---

## 🚀 **Development Workflow**

1. **Setup Environment**
   - Install Flutter SDK
   - Setup Firebase project
   - Configure environment variables

2. **Development**
   - Create/modify models
   - Implement services
   - Build UI screens
   - Add providers for state management

3. **Testing**
   - Unit tests for models & services
   - Widget tests for UI components
   - Integration tests for user flows

4. **Deployment**
   - Build for target platforms
   - Deploy Firebase rules
   - Configure production environment

---

> 📋 **หมายเหตุ:** เอกสารนี้อัปเดตตามโครงสร้างโปรเจคปัจจุบัน หากมีการเปลี่ยนแปลงโครงสร้าง กรุณาอัปเดตเอกสารนี้ด้วย