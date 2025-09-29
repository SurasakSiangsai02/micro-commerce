import 'package:cloud_firestore/cloud_firestore.dart';

class TestDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedProducts() async {
    try {
      // Check if products already exist
      final productsSnapshot = await _firestore.collection('products').limit(1).get();
      if (productsSnapshot.docs.isNotEmpty) {
        print('Test products already exist, skipping seed...');
        return;
      }

      final testProducts = [
        {
          'name': 'Gaming Laptop',
          'description': 'High performance gaming laptop with RTX 3080 graphics card. Perfect for gaming and professional work.',
          'price': 1499.99,
          'images': [
            'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400',
            'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=400',
          ],
          'category': 'Electronics',
          'stock': 10,
          'rating': 4.5,
          'reviewCount': 128,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Wireless Earbuds',
          'description': 'True wireless earbuds with active noise cancellation and long battery life.',
          'price': 199.99,
          'images': [
            'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=400',
            'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400',
          ],
          'category': 'Electronics',
          'stock': 50,
          'rating': 4.8,
          'reviewCount': 256,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Smart Watch',
          'description': 'Fitness tracking smart watch with heart rate monitor and GPS.',
          'price': 299.99,
          'images': [
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
            'https://images.unsplash.com/photo-1544117519-31a4b719223d?w=400',
          ],
          'category': 'Electronics',
          'stock': 25,
          'rating': 4.2,
          'reviewCount': 89,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Bluetooth Speaker',
          'description': 'Portable bluetooth speaker with premium sound quality and waterproof design.',
          'price': 79.99,
          'images': [
            'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
            'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=400',
          ],
          'category': 'Electronics',
          'stock': 75,
          'rating': 4.6,
          'reviewCount': 345,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Wireless Mouse',
          'description': 'Ergonomic wireless mouse with precision tracking and long battery life.',
          'price': 29.99,
          'images': [
            'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400',
            'https://images.unsplash.com/photo-1563297007-0686b8ac2b98?w=400',
          ],
          'category': 'Electronics',
          'stock': 100,
          'rating': 4.4,
          'reviewCount': 167,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'USB-C Hub',
          'description': 'Multi-port USB-C hub with HDMI, USB 3.0, and SD card slots.',
          'price': 49.99,
          'images': [
            'https://images.unsplash.com/photo-1591290619449-a6c8ad3e1346?w=400',
            'https://images.unsplash.com/photo-1558501524-ba15e9d5a9d1?w=400',
          ],
          'category': 'Electronics',
          'stock': 60,
          'rating': 4.3,
          'reviewCount': 92,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      // Add products to Firestore
      final batch = _firestore.batch();
      for (final productData in testProducts) {
        final docRef = _firestore.collection('products').doc();
        batch.set(docRef, productData);
      }
      
      await batch.commit();
      print('Successfully seeded ${testProducts.length} test products!');
    } catch (e) {
      print('Error seeding test products: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      // Clear products
      final productsSnapshot = await _firestore.collection('products').get();
      final productsBatch = _firestore.batch();
      for (final doc in productsSnapshot.docs) {
        productsBatch.delete(doc.reference);
      }
      await productsBatch.commit();

      // Clear users
      final usersSnapshot = await _firestore.collection('users').get();
      final usersBatch = _firestore.batch();
      for (final doc in usersSnapshot.docs) {
        usersBatch.delete(doc.reference);
      }
      await usersBatch.commit();

      // Clear orders
      final ordersSnapshot = await _firestore.collection('orders').get();
      final ordersBatch = _firestore.batch();
      for (final doc in ordersSnapshot.docs) {
        ordersBatch.delete(doc.reference);
      }
      await ordersBatch.commit();

      print('Successfully cleared all test data!');
    } catch (e) {
      print('Error clearing test data: $e');
    }
  }
}