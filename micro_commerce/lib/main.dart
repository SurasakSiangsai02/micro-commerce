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
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/profile_edit_screen.dart';
import 'screens/customer/product_list_screen.dart';
import 'screens/customer/product_detail_screen.dart';
import 'screens/customer/cart_screen.dart';
import 'screens/customer/checkout_screen.dart';
import 'screens/customer/order_confirmation_screen.dart';
import 'screens/common/home_screen.dart';
import 'screens/debug/test_screen.dart';
import 'models/product.dart';

/// Entry point - เริ่มต้น Firebase และ App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/order-confirmation': (context) => const OrderConfirmationScreen(),
        '/test': (context) => const TestScreen(),
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
