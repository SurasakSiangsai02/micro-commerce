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
/// 
/// 🏗️ Architecture:
/// • Provider Pattern (State Management)
/// • Service Layer (Auth, Database)
/// • Error Handling & Loading States
/// • Responsive UI Design

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart'; // ปิดชั่วคราว
import 'firebase_options.dart';
import 'config/app_config.dart';
import 'utils/theme.dart';
import 'services/payment_service.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/coupon_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/customer/product_detail_screen.dart';
import 'screens/customer/checkout_screen.dart';
import 'screens/customer/order_confirmation_screen.dart';
import 'screens/customer/order_history_screen.dart';
import 'screens/common/home_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/user_role_management_screen.dart';
import 'models/product.dart';

/// Entry point - เริ่มต้น Environment Variables, Firebase, Stripe และ App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 🔐 โหลด Environment Variables ก่อน
    await AppConfig.load();
    
    // เริ่มต้น Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // เริ่มต้น Firebase App Check (ป้องกัน abuse)
    // ปิดชั่วคราวเพื่อแก้ปัญหา API not enabled
    /*
    if (AppConfig.isDevelopment) {
      // ใช้ Debug provider สำหรับ development
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
        webProvider: ReCaptchaV3Provider('debug-token'),
      );
    } else {
      // ใช้ production providers สำหรับ production
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        webProvider: ReCaptchaV3Provider('your-recaptcha-site-key'),
      );
    }
    */
    
    // เริ่มต้น Stripe Payment
    await PaymentService.initialize();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthProvider()),
          ChangeNotifierProvider(create: (context) => CartProvider()),
          ChangeNotifierProvider(create: (context) => ChatProvider()),
          ChangeNotifierProvider(create: (context) => CouponProvider(), lazy: false),
        ],
        child: const MyApp(),
      ),
    );
    
  } catch (e) {
    // แสดง error หากโหลด config ไม่ได้
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Configuration Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load app configuration:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your .env file and make sure all required keys are set.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micro Commerce',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/order-confirmation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return OrderConfirmationScreen(
            order: args?['order'],
            totalAmount: args?['totalAmount'],
            paymentMethod: args?['paymentMethod'],
          );
        },
        '/order-history': (context) => const OrderHistoryScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/user-roles': (context) => const UserRoleManagementScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product-detail') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
