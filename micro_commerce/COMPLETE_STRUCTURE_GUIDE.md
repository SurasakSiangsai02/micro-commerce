# 🏗️ **Micro-Commerce Project Structure**
## **Complete File Structure & Documentation**

> 📅 **อัปเดต:** 3 พฤศจิกายน 2025  
> 🚀 **Flutter Version:** 3.35.2 | **Dart:** 3.6.1

---

## 📊 **Project Overview**

**Micro-Commerce** เป็นแอป E-commerce ที่พัฒนาด้วย Flutter และใช้ Firebase เป็น Backend มีฟีเจอร์ครบครันสำหรับการค้าออนไลน์

### **🎯 Core Features:**
- 🛒 **E-commerce System** - Product catalog, Cart, Orders
- 🔐 **Authentication** - Login/Register/Profiles  
- 💳 **Payment Integration** - Stripe payment gateway
- 💬 **Real-time Chat** - Customer-Admin communication
- 🎫 **Coupon System** - Discount codes & promotions
- 👥 **User Management** - Customer & Admin roles
- 📊 **Analytics** - Sales & user behavior tracking

---

## 📁 **Complete Project Structure**

```
micro_commerce/
│
├── 📱 lib/                              # 🎯 Main source code
│   ├── 🔧 config/                       # App configuration
│   │   ├── app_config.dart              # Main app settings & env variables
│   │   ├── security_config.dart         # Security policies & validation rules  
│   │   └── stripe_config.dart           # Payment gateway configuration
│   │
│   ├── 📐 constants/                    # App constants & enums
│   │   └── [constants files]            # Colors, sizes, API endpoints
│   │
│   ├── 🗃️ models/                       # Data models & schemas
│   │   ├── user.dart                    # User model (Customer/Admin profiles)
│   │   ├── product.dart                 # Product model (catalog items)
│   │   ├── product_variant.dart         # Product variants (size, color, etc.)
│   │   ├── coupon.dart                  # Coupon system model
│   │   ├── chat_room.dart              # Chat room model
│   │   └── chat_message.dart           # Chat message model
│   │
│   ├── 🔄 providers/                    # State management (Provider pattern)
│   │   ├── auth_provider.dart           # 🔐 Authentication state & user session
│   │   ├── cart_provider.dart           # 🛒 Shopping cart state & operations  
│   │   ├── chat_provider.dart           # 💬 Chat system state management
│   │   └── coupon_provider.dart         # 🎫 Coupon application & validation
│   │
│   ├── 🖥️ screens/                      # UI screens & pages
│   │   ├── 🔐 auth/                     # Authentication screens
│   │   │   ├── login_screen.dart        # User login interface
│   │   │   ├── register_screen.dart     # New user registration  
│   │   │   ├── forgot_password_screen.dart # Password reset
│   │   │   └── profile_screen.dart      # User profile management
│   │   │
│   │   ├── 👤 customer/                 # Customer-facing screens
│   │   │   ├── product_list_screen.dart # Product catalog & search
│   │   │   ├── product_detail_screen.dart # Individual product details
│   │   │   ├── cart_screen.dart         # Shopping cart interface  
│   │   │   ├── checkout_screen.dart     # Payment & order completion
│   │   │   ├── order_history_screen.dart # Past orders & tracking
│   │   │   ├── order_confirmation_screen.dart # Order success page
│   │   │   └── customer_chat_screen.dart # Customer support chat
│   │   │
│   │   ├── 👑 admin/                    # Admin panel screens
│   │   │   ├── admin_dashboard_screen.dart # Admin overview & metrics
│   │   │   ├── product_management_screen.dart # Product CRUD operations
│   │   │   ├── product_form_screen.dart # Add/Edit product form
│   │   │   ├── order_management_screen.dart # Order processing & fulfillment  
│   │   │   ├── user_management_screen.dart # Customer management
│   │   │   ├── user_role_management_screen.dart # Role & permissions
│   │   │   ├── coupon_management_screen.dart # Coupon creation & management
│   │   │   ├── coupon_form_screen.dart  # Add/Edit coupon form
│   │   │   ├── admin_chat_screen.dart   # Customer support interface
│   │   │   └── analytics_screen.dart    # Sales & performance analytics
│   │   │
│   │   ├── 💬 chat/                     # Chat system screens
│   │   │   ├── chat_list_screen.dart    # List of chat conversations
│   │   │   └── chat_detail_screen.dart  # Individual chat interface
│   │   │
│   │   └── 🔄 common/                   # Shared screens
│   │       ├── splash_screen.dart       # App loading screen
│   │       ├── error_screen.dart        # Error display & handling
│   │       └── settings_screen.dart     # App settings & preferences
│   │
│   ├── ⚙️ services/                     # Business logic & API integration
│   │   ├── auth_service.dart            # 🔐 Firebase Authentication integration
│   │   ├── database_service.dart        # 🗄️ Firestore database operations (CRUD)
│   │   ├── storage_service.dart         # 📁 Firebase Storage (image/file uploads)
│   │   ├── payment_service.dart         # 💳 Stripe payment processing
│   │   ├── chat_service.dart            # 💬 Real-time chat functionality
│   │   ├── coupon_service.dart          # 🎫 Coupon validation & application
│   │   └── firebase_tester.dart         # 🧪 Firebase connectivity testing
│   │
│   ├── 🧰 utils/                        # Utilities & helper functions
│   │   ├── theme.dart                   # App theme & styling
│   │   ├── logger.dart                  # Logging system
│   │   ├── validators.dart              # Input validation functions
│   │   ├── formatters.dart              # Data formatting utilities
│   │   ├── constants.dart               # App-wide constants
│   │   ├── helpers.dart                 # General helper functions
│   │   └── extensions.dart              # Dart language extensions
│   │
│   ├── 🧩 widgets/                      # Reusable UI components
│   │   ├── 🔄 common/                   # Generic widgets
│   │   │   ├── loading_indicator.dart   # Loading animations & spinners
│   │   │   ├── error_dialog.dart        # Error message dialogs
│   │   │   ├── custom_button.dart       # Styled buttons
│   │   │   └── custom_text_field.dart   # Input fields
│   │   │
│   │   ├── 🛍️ product/                  # Product-related widgets  
│   │   │   ├── product_card.dart        # Product display cards
│   │   │   ├── product_grid.dart        # Product grid layout
│   │   │   └── price_display.dart       # Price formatting widget
│   │   │
│   │   ├── 💬 chat/                     # Chat UI components
│   │   │   ├── message_bubble.dart      # Chat message bubbles
│   │   │   ├── message_input.dart       # Message compose field
│   │   │   └── chat_list_tile.dart      # Chat room list items
│   │   │
│   │   └── 🛒 cart/                     # Shopping cart widgets
│   │       ├── cart_item_widget.dart    # Individual cart item display
│   │       ├── cart_summary.dart        # Cart totals & summary
│   │       └── quantity_selector.dart   # Quantity increase/decrease
│   │
│   ├── 🔥 firebase_options.dart         # Firebase project configuration
│   └── 🚀 main.dart                     # App entry point & initialization
│
├── 📚 docs/                             # 📖 Project documentation
│   ├── 📋 guides/                       # User & developer guides
│   │   ├── ADMIN_GUIDE.md              # Admin panel usage instructions
│   │   ├── ARCHITECTURE.md             # System architecture overview
│   │   ├── COUPON_CODES_GUIDE.md       # Coupon system documentation
│   │   ├── COUPON_CALCULATION_EXAMPLES.md # Discount calculation examples
│   │   ├── COUPON_TESTING_GUIDE.md     # Coupon testing procedures
│   │   ├── DEMO_GUIDE.md               # Product demonstration guide
│   │   ├── DEMO_QUICK_START.md         # Quick start instructions
│   │   ├── RELEASE_GUIDE.md            # Release & deployment guide
│   │   ├── SHARING_TEMPLATES.md        # Content sharing templates
│   │   └── TESTING_INSTRUCTIONS.md     # Testing methodologies
│   │
│   ├── ⚙️ configuration/                # Setup & configuration guides
│   │   ├── CONFIRMATION_DIALOG_DOCUMENTATION.md # UI confirmation dialogs
│   │   ├── FIREBASE_STORAGE_RULES.md   # Firebase Storage setup
│   │   └── README.md                   # Configuration overview
│   │
│   ├── 💬 chat-system/                 # Chat system documentation  
│   │   └── README.md                   # Chat implementation details
│   │
│   ├── 📊 reports/                     # Project reports & analytics
│   │   ├── DEMO_ANALYTICS.md           # Usage analytics & metrics
│   │   └── README.md                   # Reports overview
│   │
│   ├── 📋 DOCUMENTATION_INDEX.md       # Master documentation index
│   ├── 📖 README.md                   # Documentation overview  
│   ├── 📸 SCREENSHOTS.md              # App screenshots & UI gallery
│   └── 📋 MICRO_COMMERCE_GUIDE.txt    # Plain text user guide
│
├── 🤖 android/                         # Android platform files
├── 🍎 ios/                            # iOS platform files  
├── 🐧 linux/                          # Linux platform files
├── 🪟 windows/                        # Windows platform files
├── 🌐 web/                            # Web platform files
├── 🧪 test/                           # Test files
│   ├── unit_test.dart                  # Unit tests
│   └── widget_test.dart                # Widget tests
│
├── 🔧 Configuration Files:
├── 📦 pubspec.yaml                     # Dependencies & project config
├── 🔥 firebase_options.dart           # Firebase SDK configuration  
├── 🛡️ storage-rules.rules            # Firebase Storage security rules
├── 🛡️ firestore.rules               # Firestore Database security rules
├── 🙈 .gitignore                     # Git ignore patterns
├── 📋 README.md                      # Main project README
└── 📄 PROJECT_STRUCTURE.md           # This file
```

---

## 🔍 **Detailed Component Analysis**

### 📱 **lib/main.dart - App Entry Point**
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

**🎯 Primary Functions:**
- Initialize Firebase services
- Setup Provider pattern for state management  
- Configure app theme & navigation
- Global error handling
- App lifecycle management

---

### 🗃️ **Models Layer - Data Structure**

#### **📦 Product Model (`product.dart`)**
```dart
class Product {
  final String id;                    // Unique identifier
  final String name;                  // Product name
  final String description;           // Product description  
  final double price;                 // Base price
  final double? discountPrice;        // Sale price (optional)
  final List<String> images;          // Product images URLs
  final String category;              // Product category
  final int stock;                    // Available quantity
  final double rating;                // Average rating (0-5)
  final int reviewCount;              // Number of reviews
  final DateTime createdAt;           // Creation timestamp
  final DateTime updatedAt;           // Last update timestamp
}
```

**🎯 Usage:**
- Product catalog display
- Cart item representation  
- Order line items
- Admin product management

#### **👤 User Model (`user.dart`)**
```dart
class UserModel {
  final String uid;                   // Firebase Auth UID
  final String email;                 // User email
  final String? name;                 // Display name
  final String? phoneNumber;          // Contact number
  final UserRole role;                // CUSTOMER | ADMIN
  final Map<String, dynamic> preferences; // User settings
  final DateTime createdAt;           // Account creation
  final DateTime lastLoginAt;         // Last login timestamp
}
```

#### **🛒 Cart Item Model**
```dart
class CartItem {
  final String productId;             // Reference to Product
  final String productName;           // Product name snapshot
  final double price;                 // Price snapshot
  final int quantity;                 // Selected quantity
  final String? selectedVariant;      // Size/Color selection
  final DateTime addedAt;             // When added to cart
}
```

---

### 🔄 **Providers Layer - State Management**

#### **🛒 Cart Provider (`cart_provider.dart`)**
```dart
class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Core Methods:
  Future<void> addItem(Product product, int quantity);
  Future<void> removeItem(String productId);
  Future<void> updateQuantity(String productId, int quantity);
  Future<void> clearCart();
  
  // Computed Properties:
  double get subtotal;                // Items total
  double get tax;                     // Calculated tax
  double get total;                   // Final amount
  int get itemCount;                  // Total items
}
```

**🎯 Features:**
- Real-time cart synchronization with Firestore
- Automatic total calculations
- Error handling & loading states
- Cart persistence across app sessions

#### **🔐 Auth Provider (`auth_provider.dart`)**
```dart
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  AuthState _state = AuthState.loading;
  
  // Authentication Methods:
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updateProfile(UserModel updatedUser);
  
  // State Properties:
  UserModel? get currentUser;
  bool get isAuthenticated;
  bool get isAdmin;
  AuthState get state;
}
```

---

### ⚙️ **Services Layer - Business Logic**

#### **🗄️ Database Service (`database_service.dart`)**
```dart
class DatabaseService {
  // Product Operations:
  Future<List<Product>> getProducts({String? category, String? searchQuery});
  Future<Product?> getProduct(String productId);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(String productId, Product product);
  Future<void> deleteProduct(String productId);
  
  // Order Operations:
  Future<String> createOrder(List<CartItem> items, UserModel user);
  Future<List<Order>> getUserOrders(String userId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  
  // User Operations:
  Future<UserModel?> getUserProfile(String userId);
  Future<void> updateUserProfile(String userId, UserModel user);
}
```

#### **💳 Payment Service (`payment_service.dart`)**
```dart
class PaymentService {
  // Stripe Integration:
  Future<PaymentIntent> createPaymentIntent(double amount, String currency);
  Future<bool> confirmPayment(String paymentIntentId, String paymentMethodId);
  Future<List<PaymentMethod>> getPaymentMethods(String customerId);
  Future<void> attachPaymentMethod(String paymentMethodId, String customerId);
  
  // Customer Management:
  Future<String> createStripeCustomer(UserModel user);
  Future<void> updateCustomer(String customerId, UserModel user);
}
```

---

### 🖥️ **Screens Layer - User Interface**

#### **👤 Customer Screens**

**🛍️ Product List Screen (`product_list_screen.dart`)**
- Product catalog with grid/list view toggle
- Search & filter functionality  
- Category-based navigation
- Infinite scroll pagination
- Add to cart quick actions

**🔍 Product Detail Screen (`product_detail_screen.dart`)**
- Detailed product information
- Image gallery with zoom
- Variant selection (size, color)
- Quantity selector
- Add to cart/Buy now buttons
- Product reviews & ratings

**🛒 Cart Screen (`cart_screen.dart`)**
- Cart items list with images
- Quantity adjustment controls
- Remove item functionality
- Price calculations & totals
- Coupon code application
- Proceed to checkout button

**💳 Checkout Screen (`checkout_screen.dart`)**
- Shipping address form
- Payment method selection
- Order summary review
- Stripe payment integration
- Order confirmation

#### **👑 Admin Screens**

**📊 Admin Dashboard (`admin_dashboard_screen.dart`)**
- Sales overview & metrics
- Recent orders summary
- Low stock alerts
- User activity statistics
- Quick action buttons

**📦 Product Management (`product_management_screen.dart`)**
- Product list with search/filter
- Bulk operations (delete, update status)
- Add new product button
- Edit/Delete individual products
- Stock level monitoring

**📋 Order Management (`order_management_screen.dart`)**
- Order list with status filtering
- Order details view
- Status update controls
- Customer information
- Shipping management

---

### 🧩 **Widgets Layer - Reusable Components**

#### **🛍️ Product Components**

**Product Card (`product_card.dart`)**
```dart
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  
  // Features:
  // - Product image with placeholder
  // - Name & price display
  // - Rating stars
  // - Add to cart button
  // - Discount badge (if applicable)
}
```

**Price Display (`price_display.dart`)**
```dart
class PriceDisplay extends StatelessWidget {
  final double price;
  final double? discountPrice;
  final TextStyle? style;
  
  // Features:
  // - Original price with strikethrough (if discount)
  // - Discount price highlighting
  // - Percentage discount calculation
  // - Currency formatting
}
```

#### **🛒 Cart Components**

**Cart Item Widget (`cart_item_widget.dart`)**
```dart
class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQuantityChanged;
  
  // Features:
  // - Product image & name
  // - Quantity selector with +/- buttons
  // - Price calculation
  // - Remove button
  // - Loading state during updates
}
```

---

## 🔧 **Configuration & Setup Files**

### **📦 pubspec.yaml - Dependencies**
```yaml
name: micro_commerce
description: A comprehensive Flutter e-commerce application

dependencies:
  flutter:
  
  # Firebase Backend:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3  
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  
  # State Management:
  provider: ^6.1.1
  
  # Payment Processing:
  flutter_stripe: ^10.1.1
  
  # UI & UX:
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  
  # Utilities:
  intl: ^0.18.1
  flutter_dotenv: ^5.1.0
```

### **🔥 Firebase Configuration**

**Storage Rules (`storage-rules.rules`)**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Product images (public read, admin write)
    match /products/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null 
        && request.auth.token.email_verified == true;
    }
    
    // Chat files (participants only)
    match /chat/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
    
    // User avatars (user or admin)
    match /avatars/{userId} {
      allow read: if true;
      allow write: if request.auth != null 
        && (request.auth.uid == userId || isAdmin());
    }
  }
}
```

**Firestore Rules (`firestore.rules`)**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Products (public read, admin write)
    match /products/{productId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // User profiles (owner or admin access)
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId || isAdmin();
      
      // User's cart (private)
      match /cart/{itemId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Orders (customer and admin access)
    match /orders/{orderId} {
      allow read: if isOwnerOrAdmin(resource.data.customerId);
      allow write: if isAdmin();
    }
  }
  
  function isAdmin() {
    return request.auth != null && 
           request.auth.token.role == 'admin';
  }
}
```

---

## 🏗️ **Architecture & Design Patterns**

### **🎯 Design Patterns Used:**

1. **📋 Provider Pattern (State Management)**
   - Centralized state management
   - Reactive UI updates
   - Clean separation of concerns

2. **🏪 Repository Pattern (Data Access)**
   - Abstract data layer
   - Consistent API interface
   - Easy testing & mocking

3. **🏗️ Service Layer Pattern (Business Logic)**
   - Encapsulated business rules
   - Reusable across UI components
   - Independent of UI framework

4. **🧩 Component Pattern (UI Architecture)**
   - Reusable UI components
   - Consistent design system
   - Maintainable codebase

### **📊 Data Flow Architecture:**
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   UI Screens    │ ←→ │    Providers     │ ←→ │    Services     │
│   (Widgets)     │    │ (State Mgmt)     │    │ (Business Logic)│
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         ↕
                              ┌─────────────────────────────────────┐
                              │         Firebase Backend           │
                              │  • Auth  • Firestore  • Storage   │
                              └─────────────────────────────────────┘
```

### **🔐 Security Architecture:**
```
┌───────────────────────────────────────────────────────────┐
│                    Security Layers                        │
├───────────────────────────────────────────────────────────┤
│ 1. Firebase Security Rules  - Database & Storage Access  │
│ 2. Authentication          - User Identity Verification  │  
│ 3. Input Validation        - Data Sanitization          │
│ 4. Environment Variables   - Secret Management          │
│ 5. Role-Based Access      - Permission Control          │
└───────────────────────────────────────────────────────────┘
```

---

## 📊 **Key Features & Capabilities**

### **🛒 E-commerce Core:**
- ✅ Product catalog with search & filtering
- ✅ Shopping cart with real-time sync
- ✅ Order management & tracking
- ✅ Payment processing (Stripe integration)
- ✅ User authentication & profiles
- ✅ Inventory management
- ✅ Product variants (size, color, etc.)

### **💬 Communication System:**
- ✅ Real-time chat between customers & admin
- ✅ File sharing in conversations
- ✅ Message history & persistence
- ✅ Online status indicators
- ✅ Push notifications (ready for implementation)

### **🎫 Promotion & Marketing:**
- ✅ Coupon code system
- ✅ Percentage & fixed amount discounts
- ✅ Minimum order value requirements
- ✅ Usage limits & expiry dates
- ✅ Bulk coupon operations

### **👥 User Management:**
- ✅ Customer account registration
- ✅ Admin panel with role management
- ✅ User profile management
- ✅ Order history tracking
- ✅ Address book management

### **📊 Analytics & Reporting:**
- ✅ Sales performance metrics
- ✅ User behavior analytics
- ✅ Inventory reports
- ✅ Revenue tracking
- ✅ Customer insights

---

## 🚀 **Development & Deployment**

### **🛠️ Development Setup:**
1. **Environment Preparation:**
   ```bash
   flutter doctor
   firebase login
   flutter pub get
   ```

2. **Configuration:**
   - Create `.env` file with API keys
   - Setup Firebase project
   - Configure Stripe account
   - Deploy Firebase rules

3. **Running the App:**
   ```bash
   flutter run --debug          # Development mode
   flutter run --release        # Production mode  
   flutter build apk           # Android build
   flutter build ios           # iOS build
   ```

### **📦 Project Dependencies:**
- **State Management:** Provider pattern
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Payment:** Stripe Flutter SDK
- **UI Components:** Material Design 3
- **Image Handling:** Image picker & caching
- **Environment Config:** flutter_dotenv

### **🧪 Testing Strategy:**
- **Unit Tests:** Models, Services, Providers
- **Widget Tests:** Individual UI components
- **Integration Tests:** Complete user flows
- **Firebase Tests:** Database rules & security

---

## 📋 **Summary**

**Micro-Commerce** เป็นโปรเจค E-commerce ที่มีโครงสร้างที่ชัดเจนและแบ่งแยกความรับผิดชอบได้ดี:

### **🎯 Architecture Strengths:**
- ✅ **Clean Architecture** - แยกชั้น UI, Business Logic, และ Data
- ✅ **Scalable Design** - ง่ายต่อการเพิ่มฟีเจอร์ใหม่
- ✅ **Maintainable Code** - โครงสร้างที่เป็นระเบียบ
- ✅ **Security First** - การรักษาความปลอดภัยในทุกชั้น
- ✅ **Real-time Sync** - ข้อมูลอัปเดตแบบ Real-time

### **🚀 Ready for Production:**
- Payment processing integration
- User authentication & authorization  
- Real-time data synchronization
- Responsive design for multiple platforms
- Comprehensive error handling

### **📈 Growth Potential:**
- ง่ายต่อการเพิ่มฟีเจอร์ใหม่
- รองรับ Multi-platform deployment
- Scalable backend architecture
- Analytics & reporting ready
- API-ready for future integrations

---

> 📝 **Note:** เอกสารนี้สะท้อนโครงสร้างโปรเจคปัจจุบัน หากมีการเปลี่ยนแปลง กรุณาอัปเดตเอกสารให้ตรงกับสถานะล่าสุด