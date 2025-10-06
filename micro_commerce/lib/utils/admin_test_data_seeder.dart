import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🧪 AdminTestDataSeeder - สร้างข้อมูลทดสอบสำหรับระบบ Admin
/// 
/// ฟีเจอร์:
/// • สร้าง Admin user สำหรับทดสอบ (รหัสผ่าน: admin123)
/// • สร้าง Moderator user สำหรับทดสอบ (รหัสผ่าน: moderator123)
/// • สร้างข้อมูลสินค้าที่มี variants
/// • สร้างคำสั่งซื้อตัวอย่าง
class AdminTestDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 👤 สร้าง Admin User สำหรับทดสอบ
  /// รหัสผ่าน: admin123
  static Future<void> createAdminUser() async {
    try {
      const email = 'admin@microcommerce.com';
      const password = 'admin123';
      
      // สร้างบัญชี Firebase Auth (หรืออัปเดตถ้ามีแล้ว)
      UserCredential? userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('🔐 Admin auth account created');
      } catch (authError) {
        // ถ้าบัญชีมีแล้ว ให้ login แล้วอัปเดตข้อมูล
        if (authError.toString().contains('email-already-in-use')) {
          print('📧 Admin email already exists, updating user data only');
        } else {
          print('⚠️ Auth error: $authError');
        }
      }

      // สร้างหรืออัปเดตข้อมูลใน Firestore
      final adminData = {
        'email': email,
        'name': 'System Administrator',
        'role': 'admin',
        'phone': '080-123-4567',
        'address': '123 Admin Street, Bangkok, Thailand',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      String userId = userCredential?.user?.uid ?? 'admin-test-user-id';
      await _firestore
          .collection('users')
          .doc(userId)
          .set(adminData, SetOptions(merge: true));

      print('✅ Admin user created successfully');
      print('📧 Email: $email');
      print('🔑 Password: $password');
    } catch (e) {
      print('❌ Error creating admin user: $e');
    }
  }

  /// 👥 สร้าง Moderator User สำหรับทดสอบ
  /// รหัสผ่าน: moderator123
  static Future<void> createModeratorUser() async {
    try {
      const email = 'moderator@microcommerce.com';
      const password = 'moderator123';
      
      // สร้างบัญชี Firebase Auth (หรืออัปเดตถ้ามีแล้ว)
      UserCredential? userCredential;
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('🔐 Moderator auth account created');
      } catch (authError) {
        // ถ้าบัญชีมีแล้ว ให้ login แล้วอัปเดตข้อมูล
        if (authError.toString().contains('email-already-in-use')) {
          print('📧 Moderator email already exists, updating user data only');
        } else {
          print('⚠️ Auth error: $authError');
        }
      }

      // สร้างหรืออัปเดตข้อมูลใน Firestore
      final moderatorData = {
        'email': email,
        'name': 'Product Manager',
        'role': 'moderator',
        'phone': '080-234-5678',
        'address': '456 Moderator Avenue, Bangkok, Thailand',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      String userId = userCredential?.user?.uid ?? 'moderator-test-user-id';
      await _firestore
          .collection('users')
          .doc(userId)
          .set(moderatorData, SetOptions(merge: true));

      print('✅ Moderator user created successfully');
      print('📧 Email: $email');
      print('🔑 Password: $password');
    } catch (e) {
      print('❌ Error creating moderator user: $e');
    }
  }

  /// 🛍️ สร้างสินค้าที่มี Product Variants
  static Future<void> createProductsWithVariants() async {
    try {
      // เสื้อยืดที่มีหลายสีและขนาด
      final tshirtData = {
        'name': 'เสื้อยืดคอตตอน Premium',
        'description': 'เสื้อยืดผ้าคอตตอน 100% นุ่มสบาย ระบายอากาศดี เหมาะสำหรับใส่ประจำวัน',
        'price': 299.0,
        'category': 'เสื้อผ้า',
        'stock': 100, // สต็อกรวม
        'images': [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
          'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=400',
        ],
        'rating': 4.5,
        'reviewCount': 23,
        'hasVariants': true,
        'variantOptions': [
          {
            'type': 'color',
            'name': 'สี',
            'values': [
              {
                'value': 'white',
                'displayName': 'ขาว',
                'colorCode': '#FFFFFF',
              },
              {
                'value': 'black',
                'displayName': 'ดำ',
                'colorCode': '#000000',
              },
              {
                'value': 'navy',
                'displayName': 'กรมท่า',
                'colorCode': '#000080',
              },
              {
                'value': 'red',
                'displayName': 'แดง',
                'colorCode': '#FF0000',
              },
            ],
          },
          {
            'type': 'size',
            'name': 'ขนาด',
            'values': [
              {'value': 'S', 'displayName': 'S'},
              {'value': 'M', 'displayName': 'M'},
              {'value': 'L', 'displayName': 'L'},
              {'value': 'XL', 'displayName': 'XL'},
            ],
          },
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('products')
          .doc('tshirt-with-variants')
          .set(tshirtData);

      // สร้าง variants สำหรับเสื้อยืด
      final variants = [
        // White variants
        {'color': 'white', 'size': 'S', 'stock': 5, 'priceAdjustment': 0.0},
        {'color': 'white', 'size': 'M', 'stock': 10, 'priceAdjustment': 0.0},
        {'color': 'white', 'size': 'L', 'stock': 8, 'priceAdjustment': 0.0},
        {'color': 'white', 'size': 'XL', 'stock': 3, 'priceAdjustment': 20.0},

        // Black variants
        {'color': 'black', 'size': 'S', 'stock': 7, 'priceAdjustment': 0.0},
        {'color': 'black', 'size': 'M', 'stock': 12, 'priceAdjustment': 0.0},
        {'color': 'black', 'size': 'L', 'stock': 15, 'priceAdjustment': 0.0},
        {'color': 'black', 'size': 'XL', 'stock': 6, 'priceAdjustment': 20.0},

        // Navy variants
        {'color': 'navy', 'size': 'S', 'stock': 4, 'priceAdjustment': 0.0},
        {'color': 'navy', 'size': 'M', 'stock': 9, 'priceAdjustment': 0.0},
        {'color': 'navy', 'size': 'L', 'stock': 11, 'priceAdjustment': 0.0},
        {'color': 'navy', 'size': 'XL', 'stock': 2, 'priceAdjustment': 20.0},

        // Red variants
        {'color': 'red', 'size': 'S', 'stock': 1, 'priceAdjustment': 30.0}, // Low stock
        {'color': 'red', 'size': 'M', 'stock': 6, 'priceAdjustment': 30.0},
        {'color': 'red', 'size': 'L', 'stock': 4, 'priceAdjustment': 30.0},
        {'color': 'red', 'size': 'XL', 'stock': 0, 'priceAdjustment': 50.0}, // Out of stock
      ];

      final batch = _firestore.batch();
      for (int i = 0; i < variants.length; i++) {
        final variant = variants[i];
        final variantData = {
          'id': 'variant-$i',
          'productId': 'tshirt-with-variants',
          'name': '${variant['color']}-${variant['size']}',
          'attributes': {
            'color': variant['color'],
            'size': variant['size'],
          },
          'priceAdjustment': variant['priceAdjustment'],
          'stock': variant['stock'],
          'images': [],
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        batch.set(
          _firestore
              .collection('products')
              .doc('tshirt-with-variants')
              .collection('variants')
              .doc('variant-$i'),
          variantData,
        );
      }

      await batch.commit();
      print('✅ T-shirt with variants created successfully');

      // รองเท้าที่มีหลายขนาดและสี
      final shoeData = {
        'name': 'รองเท้าผ้าใบ Sport',
        'description': 'รองเท้าผ้าใบสำหรับวิ่งและออกกำลังกาย น้ำหนักเบา ใส่สบาย',
        'price': 1299.0,
        'category': 'รองเท้า',
        'stock': 50,
        'images': [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
          'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400',
        ],
        'rating': 4.8,
        'reviewCount': 45,
        'hasVariants': true,
        'variantOptions': [
          {
            'type': 'color',
            'name': 'สี',
            'values': [
              {
                'value': 'white',
                'displayName': 'ขาว',
                'colorCode': '#FFFFFF',
              },
              {
                'value': 'black',
                'displayName': 'ดำ',
                'colorCode': '#000000',
              },
              {
                'value': 'blue',
                'displayName': 'น้ำเงิน',
                'colorCode': '#0066CC',
              },
            ],
          },
          {
            'type': 'size',
            'name': 'ขนาด',
            'values': [
              {'value': '38', 'displayName': '38'},
              {'value': '39', 'displayName': '39'},
              {'value': '40', 'displayName': '40'},
              {'value': '41', 'displayName': '41'},
              {'value': '42', 'displayName': '42'},
              {'value': '43', 'displayName': '43'},
            ],
          },
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('products')
          .doc('shoes-with-variants')
          .set(shoeData);

      print('✅ Shoes with variants created successfully');
    } catch (e) {
      print('❌ Error creating products with variants: $e');
    }
  }

  /// 📦 สร้างคำสั่งซื้อตัวอย่างสำหรับทดสอบ Analytics
  static Future<void> createSampleOrders() async {
    try {
      final orders = [
        {
          'userId': 'customer-1',
          'items': [
            {
              'productId': 'product-1',
              'productName': 'เสื้อยืดคอตตอน',
              'price': 299.0,
              'quantity': 2,
              'imageUrl': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
            },
          ],
          'subtotal': 598.0,
          'tax': 41.86,
          'total': 639.86,
          'status': 'delivered',
          'paymentMethod': 'Credit Card',
          'shippingAddress': {
            'name': 'John Doe',
            'address': '123 Test Street',
            'city': 'Bangkok',
            'postalCode': '10110',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        },
        {
          'userId': 'customer-2',
          'items': [
            {
              'productId': 'product-2',
              'productName': 'รองเท้าผ้าใบ',
              'price': 1299.0,
              'quantity': 1,
              'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
            },
          ],
          'subtotal': 1299.0,
          'tax': 90.93,
          'total': 1389.93,
          'status': 'shipped',
          'paymentMethod': 'Credit Card',
          'shippingAddress': {
            'name': 'Jane Smith',
            'address': '456 Another Street',
            'city': 'Bangkok',
            'postalCode': '10120',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
        },
        {
          'userId': 'customer-3',
          'items': [
            {
              'productId': 'product-1',
              'productName': 'เสื้อยืดคอตตอน',
              'price': 299.0,
              'quantity': 1,
              'imageUrl': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
            },
          ],
          'subtotal': 299.0,
          'tax': 20.93,
          'total': 319.93,
          'status': 'pending',
          'paymentMethod': 'Credit Card',
          'shippingAddress': {
            'name': 'Bob Johnson',
            'address': '789 Test Avenue',
            'city': 'Bangkok',
            'postalCode': '10130',
          },
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        },
      ];

      final batch = _firestore.batch();
      for (int i = 0; i < orders.length; i++) {
        final orderRef = _firestore.collection('orders').doc('sample-order-$i');
        batch.set(orderRef, orders[i]);
      }

      await batch.commit();
      print('✅ Sample orders created successfully');
    } catch (e) {
      print('❌ Error creating sample orders: $e');
    }
  }

  /// 🚀 รันการสร้างข้อมูลทดสอบทั้งหมด
  static Future<void> seedAllTestData() async {
    print('🌱 Starting admin test data seeding...');
    
    await createAdminUser();
    await createModeratorUser();
    await createProductsWithVariants();
    await createSampleOrders();
    
    print('🎉 Admin test data seeding completed!');
  }

  /// 🧹 ลบข้อมูลทดสอบทั้งหมด
  static Future<void> clearTestData() async {
    try {
      print('🧹 Clearing test data...');
      
      // ลบ test users
      await _firestore.collection('users').doc('admin-test-user-id').delete();
      await _firestore.collection('users').doc('moderator-test-user-id').delete();
      
      // ลบ test products
      await _firestore.collection('products').doc('tshirt-with-variants').delete();
      await _firestore.collection('products').doc('shoes-with-variants').delete();
      
      // ลบ sample orders
      for (int i = 0; i < 3; i++) {
        await _firestore.collection('orders').doc('sample-order-$i').delete();
      }
      
      print('✅ Test data cleared successfully');
    } catch (e) {
      print('❌ Error clearing test data: $e');
    }
  }
}