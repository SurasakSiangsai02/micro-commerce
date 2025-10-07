import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/user.dart' as user_model;

/// 🔥 DatabaseService - หัวใจของระบบ E-commerce
/// 
/// รับผิดชอบ:
/// - เชื่อมต่อกับ Firebase Firestore (ฐานข้อมูล Cloud)
/// - จัดการ CRUD operations ทั้งหมด (Create, Read, Update, Delete)
/// - รองรับ Real-time data sync
/// 
/// Schema ใน Firestore:
/// • products/          - สินค้าทั้งหมด
/// • users/             - ข้อมูลผู้ใช้
/// • orders/            - ประวัติคำสั่งซื้อ
/// • users/{id}/cart/   - ตะกร้าสินค้าแต่ละคน
class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// === FIRESTORE COLLECTIONS ===
  /// เชื่อมต่อกับ Collections ต่างๆ ใน Firebase
  
  static CollectionReference get productsCollection =>
      _firestore.collection('products');

  static CollectionReference get usersCollection =>
      _firestore.collection('users');

  static CollectionReference get ordersCollection =>
      _firestore.collection('orders');

  /// Cart เป็น subcollection - แต่ละ user มีตะกร้าของตัวเอง
  static CollectionReference cartCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('cart');

  /// === 🛍️ PRODUCTS CRUD ===
  /// จัดการข้อมูลสินค้าใน Firestore
  /// • รองรับ Real-time updates
  /// • Search และ Filter ตามหมวดหมู่
  /// • Add, Update, Delete สินค้า
  /// • Error handling ครบถ้วน
  
  static Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await productsCollection.get();
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  static Stream<List<Product>> getProductsStream() {
    return productsCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  static Future<Product?> getProduct(String productId) async {
    try {
      final doc = await productsCollection.doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final querySnapshot = await productsCollection
          .where('category', isEqualTo: category)
          .get();
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  static Future<List<Product>> searchProducts(String query) async {
    try {
      final querySnapshot = await productsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// ➕ เพิ่มสินค้าใหม่
  static Future<String> addProduct(Map<String, dynamic> productData) async {
    try {
      final docRef = await productsCollection.add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  /// ✏️ แก้ไขสินค้า
  static Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      await productsCollection.doc(productId).update({
        ...productData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// 🗑️ ลบสินค้า
  static Future<void> deleteProduct(String productId) async {
    try {
      await productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// 📊 ดึงสินค้าตาม ID
  static Future<Product?> getProductById(String productId) async {
    try {
      final doc = await productsCollection.doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // CART CRUD
  static Future<void> addToCart(String userId, user_model.CartItem item) async {
    try {
      final cartRef = cartCollection(userId);
      
      // Check if item already exists in cart
      final existingItem = await cartRef.doc(item.productId).get();
      
      if (existingItem.exists) {
        // Update quantity
        final currentQuantity = existingItem.data() as Map<String, dynamic>;
        final newQuantity = (currentQuantity['quantity'] ?? 0) + item.quantity;
        
        await cartRef.doc(item.productId).update({
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item
        await cartRef.doc(item.productId).set({
          ...item.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  static Future<void> updateCartItem(
      String userId, String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(userId, productId);
        return;
      }
      
      await cartCollection(userId).doc(productId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  static Future<void> removeFromCart(String userId, String productId) async {
    try {
      await cartCollection(userId).doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  static Future<List<user_model.CartItem>> getCartItems(String userId) async {
    try {
      final querySnapshot = await cartCollection(userId).get();
      return querySnapshot.docs
          .map((doc) => user_model.CartItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cart items: $e');
    }
  }

  static Stream<List<user_model.CartItem>> getCartStream(String userId) {
    return cartCollection(userId).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => user_model.CartItem.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  static Future<void> clearCart(String userId) async {
    try {
      final batch = _firestore.batch();
      final cartItems = await cartCollection(userId).get();
      
      for (final doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ORDERS CRUD
  static Future<String> createOrder(user_model.Order order) async {
    try {
      final docRef = await ordersCollection.add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  static Future<List<user_model.Order>> getUserOrders(String userId) async {
    try {
      final querySnapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => user_model.Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  static Stream<List<user_model.Order>> getUserOrdersStream(String userId) {
    // ใช้ query ง่ายๆ เพื่อหลีกเลี่ยง composite index requirement
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => user_model.Order.fromFirestore(doc))
              .toList();
          
          // เรียงตามวันที่ใน client side (ใหม่สุดขึ้นก่อน)
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return orders;
        })
        .handleError((error) {
          print('Error loading orders: $error');
          return <user_model.Order>[];
        });
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // USER PROFILE
  static Future<user_model.User?> getUserProfile(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return user_model.User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      // ใช้ set แทน update เพื่อให้สามารถสร้างเอกสารใหม่ได้หากยังไม่มี
      // SetOptions(merge: true) จะรวมข้อมูลเก่าและใหม่เข้าด้วยกัน
      await usersCollection.doc(userId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 📦 ORDER OPERATIONS (CREATE, READ, UPDATE)
  // ═══════════════════════════════════════════════════════════════

  /// สร้าง Order ใหม่หลังจากชำระเงินสำเร็จ (แทนที่ method เดิม)
  /// 
  /// Parameters:
  /// - userId: ID ของผู้ใช้ที่สั่งซื้อ
  /// - cartItems: รายการสินค้าในตะกร้า
  /// - orderData: ข้อมูล order (shipping, payment, etc.)
  /// 
  /// Returns: Order ID ที่สร้างใหม่
  static Future<String> createOrderWithPayment(String userId, List<user_model.CartItem> cartItems, Map<String, dynamic> orderData) async {
    try {
      // คำนวณราคารวม
      final originalTotal = cartItems.fold<double>(0, (sum, item) => sum + item.total);
      final discountAmount = orderData['discountAmount'] ?? 0.0;
      final subtotalAfterDiscount = originalTotal - discountAmount;
      final taxRate = 0.08; // 8% tax
      final taxAmount = subtotalAfterDiscount * taxRate;
      final finalTotal = orderData['finalTotal'] ?? (subtotalAfterDiscount + taxAmount);

      // สร้าง Order document
      final orderRef = ordersCollection.doc();
      final order = user_model.Order(
        id: orderRef.id,
        userId: userId,
        items: cartItems,
        subtotal: originalTotal,
        tax: taxAmount,
        total: finalTotal,
        status: 'confirmed',
        paymentMethod: orderData['paymentMethod'] ?? 'credit_card',
        shippingAddress: orderData['shippingAddress'] ?? {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        couponCode: orderData['couponCode'],
        couponId: orderData['couponId'],
        discountAmount: discountAmount,
      );

      // บันทึกลง Firestore
      await orderRef.set(order.toFirestore());

      // ลดจำนวนสินค้าในคลัง
      for (final item in cartItems) {
        await _updateProductStock(item.productId, item.quantity);
      }

      // ล้างตะกร้าหลังจากสั่งซื้อสำเร็จ
      await clearCart(userId);

      print('✅ Order created successfully: ${orderRef.id}');
      return orderRef.id;
    } catch (e) {
      print('❌ Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  /// อัปเดตจำนวนสินค้าในคลังหลังจากสั่งซื้อ
  static Future<void> _updateProductStock(String productId, int quantity) async {
    try {
      final productRef = productsCollection.doc(productId);
      await productRef.update({
        'stock': FieldValue.increment(-quantity),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('⚠️ Warning: Failed to update stock for product $productId: $e');
      // ไม่ throw error เพราะไม่อยากให้ order ล้มเหลวเพราะ stock update
    }
  }

  /// ดึงรายการ Orders ของผู้ใช้ (แทนที่ method เดิม)
  /// 
  /// Parameters:
  /// - userId: ID ของผู้ใช้
  /// - limit: จำนวน orders ที่ต้องการ (default: 10)
  /// 
  /// Returns: List<Order> เรียงตามวันที่ล่าสุดก่อน
  static Future<List<user_model.Order>> getUserOrdersWithDetails(String userId, {int limit = 10}) async {
    try {
      final querySnapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final orders = querySnapshot.docs
          .map((doc) => user_model.Order.fromFirestore(doc))
          .toList();

      print('✅ Fetched ${orders.length} orders for user: $userId');
      return orders;
    } catch (e) {
      print('❌ Error fetching user orders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// ดึงข้อมูล Order ตาม ID
  static Future<user_model.Order?> getOrderById(String orderId) async {
    try {
      final doc = await ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return user_model.Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching order: $e');
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// อัปเดตสถานะ Order
  static Future<void> updateOrderStatusById(String orderId, String status) async {
    try {
      await ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Order $orderId status updated to: $status');
    } catch (e) {
      print('❌ Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Stream สำหรับติดตาม Orders แบบ Real-time (สำหรับ Admin)
  static Stream<List<user_model.Order>> getAllOrdersStream() {
    return ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => user_model.Order.fromFirestore(doc))
            .toList());
  }

  /// Stream สำหรับติดตาม Orders แบบ Real-time (สำหรับ User)
  static Stream<List<user_model.Order>> watchUserOrdersStream(String userId, {int limit = 10}) {
    try {
      // ลองใช้ query แบบซับซ้อนก่อน
      return ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => user_model.Order.fromFirestore(doc))
              .toList());
    } catch (e) {
      // ถ้า composite index ไม่มี ใช้ query ง่ายๆ แล้วเรียงใน client side
      return ordersCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            final orders = snapshot.docs
                .map((doc) => user_model.Order.fromFirestore(doc))
                .toList();
            
            // เรียงตามวันที่ใน client side
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            // จำกัดจำนวน
            return orders.take(limit).toList();
          });
    }
  }
}