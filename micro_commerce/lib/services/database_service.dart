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

  /// === 🛍️ PRODUCTS CRUD (READ-ONLY) ===
  /// อ่านข้อมูลสินค้าจาก Firestore
  /// • รองรับ Real-time updates
  /// • Search และ Filter ตามหมวดหมู่
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
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => user_model.Order.fromFirestore(doc))
            .toList());
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
}