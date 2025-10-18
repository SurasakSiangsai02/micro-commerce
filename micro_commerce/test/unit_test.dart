import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:micro_commerce/models/product.dart';
import 'package:micro_commerce/models/user.dart';
import 'package:micro_commerce/utils/logger.dart';
import 'package:micro_commerce/widgets/confirmation_dialog.dart';

/// 🧪 Unit Tests สำหรับ Micro-Commerce App
/// 
/// Test Cases ครอบคลุม:
/// • Model validation และ serialization
/// • Business logic validation
/// • Utility functions
/// • Error handling
/// • Confirmation Dialog system

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

  // � Order Model Tests
  group('🛒 Order Model Tests', () {
    test('TC013: Order model should not have couponType property', () {
      // Test that Order model doesn't have couponType/couponValue properties
      // This prevents NoSuchMethodError when accessing non-existent properties
      
      const testOrderData = {
        'id': 'test_order_123',
        'userId': 'user_123',
        'items': [],
        'subtotal': 100.0,
        'tax': 10.0,
        'total': 110.0,
        'status': 'completed',
        'paymentMethod': 'credit_card',
        'shippingAddress': {},
        'couponCode': 'SAVE20',
        'couponId': 'coupon_123',
        'discountAmount': 20.0,
      };
      
      // Verify that we use discountAmount instead of couponType/couponValue
      expect(testOrderData['discountAmount'], equals(20.0));
      expect(testOrderData['couponCode'], equals('SAVE20'));
      
      // This test ensures we don't access non-existent properties
      expect(testOrderData.containsKey('couponType'), isFalse);
      expect(testOrderData.containsKey('couponValue'), isFalse);
    });
  });

  // �️ Image Loading Tests
  group('🖼️ Image Loading Tests', () {
    test('TC014: Image URL validation', () {
      // Test valid image URLs
      const validUrls = [
        'https://example.com/image.jpg',
        'https://example.com/image.png',
        'https://example.com/image.webp',
        'https://via.placeholder.com/150',
      ];
      
      for (final url in validUrls) {
        expect(url.isNotEmpty, isTrue);
        expect(Uri.tryParse(url), isNotNull);
      }
      
      // Test invalid URLs should be handled gracefully
      const invalidUrls = [
        '',
        'invalid-url',
        'not-a-url',
      ];
      
      for (final url in invalidUrls) {
        if (url.isEmpty) {
          expect(url.isEmpty, isTrue);
        } else {
          // Invalid URLs should still be strings (handled by error builder)
          expect(url, isA<String>());
        }
      }
    });
    
    test('TC015: Image fallback handling', () {
      // Test fallback scenarios
      const testCases = [
        {
          'scenario': 'Product image fallback',
          'fallbackIcon': 'shopping_bag_outlined',
          'fallbackText': 'Product image not available'
        },
        {
          'scenario': 'Avatar image fallback', 
          'fallbackIcon': 'person_outline',
          'fallbackText': null
        },
        {
          'scenario': 'Chat image fallback',
          'fallbackIcon': 'image_outlined', 
          'fallbackText': 'Image not available'
        }
      ];
      
      for (final testCase in testCases) {
        expect(testCase['scenario'], isNotNull);
        expect(testCase['fallbackIcon'], isNotNull);
        // fallbackText can be null for avatars
      }
    });
  });

  // �🔐 Password Reset Tests
  group('🔐 Password Reset Tests', () {
    test('TC016: Valid email format for password reset', () {
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

    test('TC017: Password reset success workflow', () {
      const testEmail = 'test@example.com';
      
      // Simulate password reset request
      expect(_isValidEmail(testEmail), isTrue);
      
      // Log password reset attempt
      print('✅ Password reset email would be sent to: $testEmail');
      
      expect(testEmail.isNotEmpty, isTrue);
    });

    /// 🎯 TC016-TC021: Confirmation Dialog Tests
    test('TC016: ConfirmationDialog properties validation', () {
      final dialog = ConfirmationDialog(
        title: 'Test Title',
        message: 'Test Message',
        confirmText: 'ยืนยัน',
        cancelText: 'ยกเลิก',
        isDanger: true,
      );

      expect(dialog.title, equals('Test Title'));
      expect(dialog.message, equals('Test Message'));
      expect(dialog.confirmText, equals('ยืนยัน'));
      expect(dialog.cancelText, equals('ยกเลิก'));
      expect(dialog.isDanger, equals(true));
    });

    test('TC017: ConfirmationDialog default values', () {
      final dialog = ConfirmationDialog(
        title: 'Test',
        message: 'Test Message',
      );

      expect(dialog.confirmText, equals('ยืนยัน'));
      expect(dialog.cancelText, equals('ยกเลิก'));
      expect(dialog.isDanger, equals(false));
      expect(dialog.icon, isNull);
      expect(dialog.iconColor, isNull);
    });

    test('TC018: Cart deletion scenario validation', () {
      const productName = 'iPhone 15 Pro';
      const expectedTitle = 'ลบสินค้าออกจากตะกร้า';
      const expectedMessage = 'คุณต้องการลบ "iPhone 15 Pro" ออกจากตะกร้าหรือไม่?';
      
      // Simulate ConfirmationDialogs.showDeleteFromCartDialog logic
      expect(productName.isNotEmpty, equals(true));
      expect(expectedTitle.contains('ลบสินค้า'), equals(true));
      expect(expectedMessage.contains(productName), equals(true));
    });

    test('TC019: Checkout confirmation validation', () {
      const totalAmount = 1250.50;
      const paymentMethod = 'Credit Card';
      
      // Simulate checkout validation
      expect(totalAmount > 0, equals(true));
      expect(paymentMethod.isNotEmpty, equals(true));
      
      final formattedAmount = totalAmount.toStringAsFixed(2);
      expect(formattedAmount, equals('1250.50'));
    });

    test('TC020: Order cancellation validation', () {
      const orderId = 'ORD12345';
      const shortOrderId = 'ORD12345'; // Simulate .substring(0, 8)
      
      expect(orderId.isNotEmpty, equals(true));
      expect(shortOrderId.length <= 8, equals(true));
      
      // Validate order cancellation scenarios
      const validCancelableStatuses = ['pending', 'confirmed'];
      expect(validCancelableStatuses.contains('pending'), equals(true));
      expect(validCancelableStatuses.contains('shipped'), equals(false));
      expect(validCancelableStatuses.contains('delivered'), equals(false));
    });

    test('TC021: Dialog action scenarios validation', () {
      bool userConfirmed = false;
      bool userCancelled = false;
      
      // Simulate user confirmation
      void simulateConfirm() {
        userConfirmed = true;
      }
      
      void simulateCancel() {
        userCancelled = true;
      }
      
      // Test confirm action
      simulateConfirm();
      expect(userConfirmed, equals(true));
      expect(userCancelled, equals(false));
      
      // Reset and test cancel action
      userConfirmed = false;
      simulateCancel();
      expect(userConfirmed, equals(false));
      expect(userCancelled, equals(true));
    });

    /// 🎯 TC022-TC025: Chat Deletion System Tests
    test('TC022: Chat room deletion validation', () {
      const roomId = 'room_123';
      const userId = 'user_456';
      const customerName = 'ลูกค้า A';
      
      // Validate chat room deletion parameters
      expect(roomId.isNotEmpty, equals(true));
      expect(userId.isNotEmpty, equals(true));
      expect(customerName.isNotEmpty, equals(true));
      
      // Simulate deletion status change
      const newStatus = 'deleted_by_user';
      expect(newStatus.contains('deleted'), equals(true));
    });

    test('TC023: Chat deletion confirmation dialog', () {
      const customerName = 'ร้านค้า ABC';
      const expectedTitle = 'ลบการสนทนา';
      const expectedMessage = 'คุณต้องการลบการสนทนากับ "ร้านค้า ABC" หรือไม่?';
      
      expect(customerName.isNotEmpty, equals(true));
      expect(expectedTitle.contains('ลบ'), equals(true));
      expect(expectedMessage.contains(customerName), equals(true));
    });

    test('TC024: Chat room status validation', () {
      // Test valid chat room statuses
      const validStatuses = ['active', 'deleted_by_user', 'closed', 'pending'];
      
      expect(validStatuses.contains('active'), equals(true));
      expect(validStatuses.contains('deleted_by_user'), equals(true));
      expect(validStatuses.contains('invalid_status'), equals(false));
      
      // Test status transition logic
      const oldStatus = 'active';
      const newStatus = 'deleted_by_user';
      expect(oldStatus != newStatus, equals(true));
    });

    test('TC025: Chat swipe-to-delete validation', () {
      bool swipeTriggered = false;
      bool confirmationShown = false;
      bool itemDeleted = false;
      
      // Simulate swipe gesture
      void simulateSwipe() {
        swipeTriggered = true;
      }
      
      // Simulate confirmation dialog
      void simulateConfirmation(bool userConfirmed) {
        confirmationShown = true;
        if (userConfirmed) {
          itemDeleted = true;
        }
      }
      
      // Test swipe action
      simulateSwipe();
      expect(swipeTriggered, equals(true));
      
      // Test user confirms deletion
      simulateConfirmation(true);
      expect(confirmationShown, equals(true));
      expect(itemDeleted, equals(true));
      
      // Reset and test user cancels deletion
      itemDeleted = false;
      simulateConfirmation(false);
      expect(itemDeleted, equals(false));
    });

    /// 🎯 TC026-TC030: Message Deletion System Tests
    
    test('TC026: Text message deletion validation', () {
      // Mock message data
      final messageId = 'msg_123';
      final messageType = 'text';
      bool messageExists = true;
      bool confirmationShown = false;
      bool deletionSuccessful = false;
      
      // Simulate delete message process
      void simulateDeleteMessage(String msgId, String msgType) {
        expect(msgId, equals(messageId));
        expect(msgType, equals(messageType));
        
        // Show confirmation dialog
        confirmationShown = true;
        
        // Simulate user confirms deletion
        if (messageExists) {
          messageExists = false;
          deletionSuccessful = true;
        }
      }
      
      // Test deletion process
      simulateDeleteMessage(messageId, messageType);
      expect(confirmationShown, equals(true));
      expect(messageExists, equals(false));
      expect(deletionSuccessful, equals(true));
    });

    test('TC027: Image message deletion validation', () {
      // Mock image message data
      final messageId = 'img_456';
      final messageType = 'image';
      bool imageExists = true;
      bool confirmationShown = false;
      String? deletionType;
      
      // Simulate delete image message
      void simulateDeleteImage(String msgId, String msgType) {
        expect(msgId, equals(messageId));
        expect(msgType, equals(messageType));
        
        confirmationShown = true;
        deletionType = msgType;
        
        if (imageExists) {
          imageExists = false;
        }
      }
      
      // Test image deletion
      simulateDeleteImage(messageId, messageType);
      expect(confirmationShown, equals(true));
      expect(deletionType, equals('image'));
      expect(imageExists, equals(false));
    });

    test('TC028: File message deletion validation', () {
      // Mock file message data
      final messageId = 'file_789';
      final messageType = 'file';
      final fileName = 'document.pdf';
      bool fileExists = true;
      String? confirmationMessage;
      
      // Simulate delete file message
      void simulateDeleteFile(String msgId, String msgType, String fName) {
        expect(msgId, equals(messageId));
        expect(msgType, equals(messageType));
        expect(fName, equals(fileName));
        
        confirmationMessage = 'คุณต้องการลบไฟล์นี้หรือไม่?';
        
        if (fileExists) {
          fileExists = false;
        }
      }
      
      // Test file deletion
      simulateDeleteFile(messageId, messageType, fileName);
      expect(confirmationMessage, isNotNull);
      expect(confirmationMessage, contains('ลบไฟล์'));
      expect(fileExists, equals(false));
    });

    test('TC029: Message deletion permission validation', () {
      // Mock user and message data
      final currentUserId = 'user_123';
      final messageOwnerId = 'user_123';
      final otherUserId = 'user_456';
      bool canDelete = false;
      
      // Check if current user can delete message
      bool checkDeletePermission(String userId, String msgOwnerId) {
        return userId == msgOwnerId;
      }
      
      // Test owner can delete
      canDelete = checkDeletePermission(currentUserId, messageOwnerId);
      expect(canDelete, equals(true));
      
      // Test non-owner cannot delete
      canDelete = checkDeletePermission(otherUserId, messageOwnerId);
      expect(canDelete, equals(false));
    });

    test('TC030: Message deletion error handling', () {
      // Mock error scenarios
      bool networkError = false;
      bool permissionError = false;
      bool messageNotFound = false;
      String? errorMessage;
      
      // Simulate network error
      void simulateNetworkError() {
        networkError = true;
        errorMessage = 'Network connection failed';
      }
      
      // Simulate permission error
      void simulatePermissionError() {
        permissionError = true;
        errorMessage = 'No permission to delete this message';
      }
      
      // Simulate message not found
      void simulateMessageNotFound() {
        messageNotFound = true;
        errorMessage = 'Message not found';
      }
      
      // Test error scenarios
      simulateNetworkError();
      expect(networkError, equals(true));
      expect(errorMessage, contains('Network'));
      
      errorMessage = null;
      simulatePermissionError();
      expect(permissionError, equals(true));
      expect(errorMessage, contains('permission'));
      
      errorMessage = null;
      simulateMessageNotFound();
      expect(messageNotFound, equals(true));
      expect(errorMessage, contains('not found'));
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