/// 📋 MICRO-COMMERCE ARCHITECTURE OVERVIEW
/// 
/// ระบบ E-commerce ครบวงจร สร้างด้วย Flutter + Firebase
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🏗️ SYSTEM ARCHITECTURE
/// ═══════════════════════════════════════════════════════════════
/// 
/// ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
/// │   PRESENTATION  │    │   BUSINESS      │    │   DATA          │
/// │   LAYER         │────│   LOGIC LAYER   │────│   LAYER         │
/// │                 │    │                 │    │                 │
/// │ • UI Screens    │    │ • Providers     │    │ • Services      │
/// │ • Widgets       │    │ • State Mgmt    │    │ • Firebase      │
/// │ • Navigation    │    │ • Validation    │    │ • Models        │
/// └─────────────────┘    └─────────────────┘    └─────────────────┘
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🔐 AUTHENTICATION SYSTEM
/// ═══════════════════════════════════════════════════════════════
/// 
/// AuthService ──┐
///               ├── Firebase Authentication
///               │   • Email/Password Login
///               │   • User Registration  
///               │   • Password Reset
///               │   • Real-time Auth State
///               │
///               └── Firestore Integration
///                   • Auto-create User Profile
///                   • Sync User Data
/// 
/// AuthProvider ──┐
///                ├── State Management
///                │   • Login Status
///                │   • User Profile  
///                │   • Loading States
///                │   • Error Handling
///                │
///                └── UI Integration
///                    • Login/Register Screens
///                    • Protected Routes
///                    • Profile Management
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🗄️ DATABASE SCHEMA (FIRESTORE)
/// ═══════════════════════════════════════════════════════════════
/// 
/// Collection: products/
/// ├── {productId}
///     ├── name: string
///     ├── description: string  
///     ├── price: number
///     ├── images: array
///     ├── category: string
///     ├── stock: number
///     ├── rating: number
///     ├── reviewCount: number
///     ├── createdAt: timestamp
///     └── updatedAt: timestamp
/// 
/// Collection: users/
/// ├── {userId}
///     ├── email: string
///     ├── name: string
///     ├── phone: string (optional)
///     ├── address: string (optional)
///     ├── createdAt: timestamp
///     ├── updatedAt: timestamp
///     │
///     └── Subcollection: cart/
///         ├── {productId}
///             ├── productId: string
///             ├── name: string
///             ├── price: number
///             ├── image: string
///             ├── quantity: number
///             ├── createdAt: timestamp
///             └── updatedAt: timestamp
/// 
/// Collection: orders/
/// ├── {orderId}
///     ├── userId: string
///     ├── items: array
///     ├── subtotal: number
///     ├── tax: number
///     ├── total: number
///     ├── status: string
///     ├── shippingAddress: map
///     ├── createdAt: timestamp
///     └── updatedAt: timestamp
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🛒 CRUD OPERATIONS
/// ═══════════════════════════════════════════════════════════════
/// 
/// DatabaseService:
/// 
/// PRODUCTS (READ-ONLY):
/// ├── getProducts() ────────── ดึงสินค้าทั้งหมด
/// ├── getProduct(id) ───────── ดึงสินค้าตัวเดียว  
/// ├── getProductsByCategory() ─ กรองตามหมวดหมู่
/// ├── searchProducts() ──────── ค้นหาสินค้า
/// └── getProductsStream() ───── Real-time updates
/// 
/// CART (FULL CRUD):
/// ├── addToCart() ──────────── CREATE/UPDATE สินค้า
/// ├── getCartItems() ───────── READ รายการตะกร้า
/// ├── updateCartItem() ─────── UPDATE จำนวน
/// ├── removeFromCart() ─────── DELETE สินค้า
/// └── clearCart() ──────────── DELETE ทั้งตะกร้า
/// 
/// ORDERS (CRU - NO DELETE):
/// ├── createOrder() ────────── CREATE คำสั่งซื้อ
/// ├── getUserOrders() ──────── READ ประวัติ
/// └── updateOrderStatus() ──── UPDATE สถานะ
/// 
/// USERS (RU - CREATE in Auth):
/// ├── getUserProfile() ─────── READ โปรไฟล์
/// └── updateUserProfile() ──── UPDATE ข้อมูล
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🎭 STATE MANAGEMENT (PROVIDER PATTERN)
/// ═══════════════════════════════════════════════════════════════
/// 
/// AuthProvider:
/// ├── Auth State ──────────── Login/Logout status
/// ├── User Profile ────────── Firestore user data
/// ├── Loading States ──────── UI feedback
/// ├── Error Handling ──────── User-friendly messages
/// └── Methods:
///     ├── signIn()
///     ├── register()  
///     ├── signOut()
///     └── resetPassword()
/// 
/// CartProvider:
/// ├── Cart Items ──────────── List of products
/// ├── Calculations ────────── Subtotal, tax, total
/// ├── Cart Operations ─────── Add, remove, update
/// ├── Order Creation ──────── Checkout process
/// └── Firestore Sync ──────── Real-time persistence
/// 
/// ═══════════════════════════════════════════════════════════════
/// ⚠️ ERROR HANDLING SYSTEM
/// ═══════════════════════════════════════════════════════════════
/// 
/// ErrorHandler:
/// ├── Network Errors ──────── Connection issues
/// ├── Auth Errors ─────────── Login/register problems
/// ├── Database Errors ─────── Firestore operations
/// ├── Validation Errors ───── Form validation
/// └── UI Feedback:
///     ├── SnackBar messages
///     ├── Dialog alerts
///     ├── Loading indicators
///     └── Retry mechanisms
/// 
/// Error Types Handled:
/// • user-not-found ────────── "ไม่พบผู้ใช้งาน"
/// • wrong-password ────────── "รหัสผ่านไม่ถูกต้อง"  
/// • email-already-in-use ──── "อีเมลนี้ถูกใช้แล้ว"
/// • weak-password ─────────── "รหัสผ่านไม่ปลอดภัย"
/// • network-request-failed ── "การเชื่อมต่อมีปัญหา"
/// • permission-denied ─────── "ไม่มีสิทธิ์เข้าถึง"
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🌐 FIREBASE INTEGRATION
/// ═══════════════════════════════════════════════════════════════
/// 
/// Services Used:
/// ├── Firebase Authentication
/// │   ├── Email/Password Provider
/// │   ├── Auth State Persistence  
/// │   └── Security Rules
/// │
/// ├── Cloud Firestore
/// │   ├── Real-time Database
/// │   ├── Offline Persistence
/// │   ├── Security Rules
/// │   └── Automatic Indexing
/// │
/// └── Firebase Hosting (Optional)
///     ├── Static Web Hosting
///     ├── SSL Certificate
///     └── CDN Distribution
/// 
/// Configuration:
/// ├── firebase_options.dart ── Platform configs
/// ├── Security Rules ──────── Database permissions
/// └── API Keys ─────────────── Environment specific
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🔄 DATA FLOW EXAMPLE
/// ═══════════════════════════════════════════════════════════════
/// 
/// User adds product to cart:
/// 1. UI: ProductCard.onTap()
/// 2. Provider: cartProvider.addToCart(product)
/// 3. Service: DatabaseService.addToCart(userId, item)
/// 4. Firebase: Write to users/{userId}/cart/{productId}
/// 5. Real-time: Firestore triggers update
/// 6. Provider: notifyListeners()
/// 7. UI: Cart badge updates automatically
/// 
/// User logs in:
/// 1. UI: LoginScreen form submission
/// 2. Provider: authProvider.signIn(email, password)
/// 3. Service: AuthService.signInWithEmail()
/// 4. Firebase: Authentication verification
/// 5. Service: DatabaseService.getUserProfile()
/// 6. Provider: Updates auth state + user profile
/// 7. UI: Navigation to HomeScreen
/// 8. Cart: Loads user's cart from Firestore
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🎨 UI STRUCTURE
/// ═══════════════════════════════════════════════════════════════
/// 
/// Screens:
/// ├── Auth Screens
/// │   ├── LoginScreen ──────── Email/Password login
/// │   ├── RegisterScreen ───── Account creation
/// │   └── ProfileEditScreen ── User profile management
/// │
/// ├── Customer Screens  
/// │   ├── ProductListScreen ── Browse products
/// │   ├── ProductDetailScreen ─ Product information
/// │   ├── CartScreen ───────── Shopping cart
/// │   ├── CheckoutScreen ───── Order placement
/// │   └── OrderConfirmation ── Success message
/// │
/// └── Common Screens
///     ├── HomeScreen ───────── Main navigation
///     └── TestScreen ────────── Debug utilities
/// 
/// Widgets:
/// ├── ProductCard ─────────── Product display
/// ├── CartItem ────────────── Cart list item
/// ├── CustomButton ────────── Styled buttons
/// ├── CustomTextField ─────── Form inputs
/// └── LoadingSpinner ──────── Loading states
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🚦 DEVELOPMENT WORKFLOW
/// ═══════════════════════════════════════════════════════════════
/// 
/// Setup:
/// 1. Flutter SDK installation
/// 2. Firebase project creation
/// 3. Firebase configuration
/// 4. Dependencies installation
/// 5. Database rules setup
/// 
/// Development:
/// 1. Model creation (Schema definition)
/// 2. Service layer (Business logic)
/// 3. Provider layer (State management)  
/// 4. UI layer (Screens & widgets)
/// 5. Testing & debugging
/// 
/// Deployment:
/// 1. Build optimization
/// 2. Firebase hosting setup
/// 3. Production configuration
/// 4. Security rules review
/// 5. Performance monitoring
/// 
/// ═══════════════════════════════════════════════════════════════
/// 🎯 KEY FEATURES IMPLEMENTED
/// ═══════════════════════════════════════════════════════════════
/// 
/// ✅ User Authentication (Login/Register/Logout)
/// ✅ Product Catalog with Real-time updates
/// ✅ Shopping Cart with Firestore persistence
/// ✅ Order Management System  
/// ✅ User Profile Management
/// ✅ Search & Filter functionality
/// ✅ Error Handling & Loading states
/// ✅ Responsive UI design
/// ✅ Real-time data synchronization
/// ✅ Offline data persistence
/// ✅ Form validation
/// ✅ Navigation flow
/// 
/// 🔄 Future Enhancements:
/// • Payment integration (Stripe)
/// • Push notifications
/// • Order tracking
/// • Product reviews & ratings
/// • Admin panel
/// • Analytics & reporting
/// • Multi-language support
/// • Dark mode theme
/// 
/// ═══════════════════════════════════════════════════════════════