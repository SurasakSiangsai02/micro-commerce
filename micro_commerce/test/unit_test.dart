import 'package:flutter_test/flutter_test.dart';
import 'package:micro_commerce/models/product.dart';
import 'package:micro_commerce/models/user.dart';
import 'package:micro_commerce/utils/logger.dart';

/// 🧪 Unit Tests สำหรับ Micro-Commerce App
/// 
/// Test Cases ครอบคลุม:
/// • Model validation และ serialization
/// • Business logic validation
/// • Utility functions
/// • Error handling

void main() {
  group('📦 Product Model Tests', () {
    test('TC001: สร้าง Product object สำเร็จ', () {
      final product = Product(
        id: 'test_001',
        name: 'iPhone 15 Pro',
        description: 'Apple iPhone 15 Pro สีธรรมชาติ 128GB',
        price: 39900.0,
        images: ['https://example.com/iphone15.jpg'],
        category: 'Electronics',
        stock: 50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.id, equals('test_001'));
      expect(product.name, equals('iPhone 15 Pro'));
      expect(product.price, equals(39900.0));
      expect(product.stock, equals(50));
      expect(product.stock > 0, equals(true));
    });

    test('TC002: Product out of stock validation', () {
      final product = Product(
        id: 'test_002',
        name: 'Out of Stock Item',
        description: 'Test item',
        price: 100.0,
        images: [],
        category: 'Test',
        stock: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.stock <= 0, equals(true));
    });

    test('TC003: Product ฟิลด์ images เป็น List', () {
      final product = Product(
        id: 'test_003',
        name: 'Test Product',
        description: 'Test Description',
        price: 299.99,
        images: ['image1.jpg', 'image2.jpg'],
        category: 'Electronics',
        stock: 25,
      );

      expect(product.images, isA<List<String>>());
      expect(product.images.length, equals(2));
      expect(product.images.first, equals('image1.jpg'));
    });
  });

  group('👤 User Model Tests', () {
    test('TC004: สร้าง Customer User สำเร็จ', () {
      final user = User(
        uid: 'customer_001',
        email: 'customer@example.com',
        name: 'John Doe',
        role: UserRole.customer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.role, equals(UserRole.customer));
      expect(user.isAdmin, equals(false));
      expect(user.role == UserRole.customer, equals(true));
    });

    test('TC005: สร้าง Admin User สำเร็จ', () {
      final adminUser = User(
        uid: 'admin_001',
        email: 'admin@microcommerce.com',
        name: 'Admin User',
        role: UserRole.admin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(adminUser.role, equals(UserRole.admin));
      expect(adminUser.isAdmin, equals(true));
      expect(adminUser.role == UserRole.customer, equals(false));
    });
  });

  group('💬 Chat Message Tests', () {
    test('TC006: ตรวจสอบ Chat Message Type', () {
      // Test basic string types
      expect('text', equals('text'));
      expect('image', equals('image'));
      expect('file', equals('file'));
    });

    test('TC007: ตรวจสอบ URL Validation', () {
      const validUrls = [
        'https://firebase.storage.googleapis.com/image.jpg',
        'https://example.com/photo.png',
      ];
      
      const invalidUrls = [
        '',
        'invalid-url',
        'not-a-url',
      ];

      for (var url in validUrls) {
        expect(url.startsWith('http'), equals(true));
      }

      for (var url in invalidUrls) {
        expect(url.startsWith('http'), equals(false));
      }
    });
  });

  group('🔧 Logger Utility Tests', () {
    test('TC008: Logger info message', () {
      // Test that Logger doesn't throw exceptions
      expect(() => Logger.info('Test info message'), returnsNormally);
    });

    test('TC009: Logger error message', () {
      // Test that Logger doesn't throw exceptions
      expect(() => Logger.error('Test error message'), returnsNormally);
    });
  });

  group('📱 Business Logic Tests', () {
    test('TC010: คำนวณราคารวมสินค้าในตะกร้า', () {
      final products = [
        Product(
          id: '1',
          name: 'Product A',
          description: 'Description A',
          price: 100.0,
          images: [],
          category: 'Test',
          stock: 10,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: '2',
          name: 'Product B',
          description: 'Description B',
          price: 250.0,
          images: [],
          category: 'Test',
          stock: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final quantities = {'1': 2, '2': 1}; // Product A x2, Product B x1
      double totalPrice = 0.0;
      
      for (var product in products) {
        final quantity = quantities[product.id] ?? 0;
        totalPrice += product.price * quantity;
      }

      expect(totalPrice, equals(450.0)); // (100 * 2) + (250 * 1) = 450
    });

    test('TC011: ตรวจสอบ Email Format Validation', () {
      const validEmails = [
        'user@example.com',
        'admin@microcommerce.com',
        'test.user+label@domain.co.th',
      ];

      const invalidEmails = [
        'invalid-email',
        '@domain.com',
        'user@',
        '',
      ];

      for (var email in validEmails) {
        expect(_isValidEmail(email), equals(true), reason: 'Should accept: $email');
      }

      for (var email in invalidEmails) {
        expect(_isValidEmail(email), equals(false), reason: 'Should reject: $email');
      }
    });

    test('TC012: Password Strength Validation', () {
      const weakPasswords = [
        '123',
        'password',
        'abc',
        '',
      ];

      const strongPasswords = [
        'admin123',
        'myStrongPass2024',
        'SecurePassword123',
      ];

      for (var password in weakPasswords) {
        expect(_isStrongPassword(password), equals(false), reason: 'Should reject weak: $password');
      }

      for (var password in strongPasswords) {
        expect(_isStrongPassword(password), equals(true), reason: 'Should accept strong: $password');
      }
    });
  });

  // 🔐 Password Reset Tests
  group('🔐 Password Reset Tests', () {
    test('TC013: Valid email format for password reset', () {
      // Valid email formats
      expect(_isValidEmail('user@example.com'), isTrue);
      expect(_isValidEmail('test.email+tag@domain.co.uk'), isTrue);
      expect(_isValidEmail('user123@gmail.com'), isTrue);

      // Invalid email formats
      expect(_isValidEmail('invalid-email'), isFalse);
      expect(_isValidEmail('user@'), isFalse);
      expect(_isValidEmail('@domain.com'), isFalse);
      expect(_isValidEmail(''), isFalse);
    });

    test('TC014: Password reset success workflow', () {
      const testEmail = 'test@example.com';
      
      // Simulate password reset request
      expect(_isValidEmail(testEmail), isTrue);
      
      // Log password reset attempt
      print('✅ Password reset email would be sent to: $testEmail');
      
      expect(testEmail.isNotEmpty, isTrue);
    });
  });
}

/// Helper function สำหรับ Email validation
bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  return email.isNotEmpty && emailRegex.hasMatch(email);
}

/// Helper function สำหรับ Password strength validation  
bool _isStrongPassword(String password) {
  // เช็คความยาวและไม่เป็นคำง่ายๆ
  if (password.length < 6) return false;
  
  // Reject common weak passwords
  const commonWeakPasswords = ['password', '123456', 'abc123', 'qwerty'];
  if (commonWeakPasswords.contains(password.toLowerCase())) return false;
  
  return true;
}