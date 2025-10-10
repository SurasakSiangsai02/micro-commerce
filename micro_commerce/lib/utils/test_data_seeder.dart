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
            'https://picsum.photos/400/600',
            'https://picsum.photos/400/601',
          ],
          'category': 'Electronics',
          'stock': 60,
          'rating': 4.3,
          'reviewCount': 92,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        
        // Fashion Category
        {
          'name': 'Cotton T-Shirt',
          'description': 'Comfortable 100% cotton t-shirt in various colors. Perfect for casual wear.',
          'price': 24.99,
          'images': [
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
            'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=400',
          ],
          'category': 'Fashion',
          'stock': 80,
          'rating': 4.5,
          'reviewCount': 145,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Denim Jeans',
          'description': 'Classic blue denim jeans with modern fit and premium quality.',
          'price': 79.99,
          'images': [
            'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
            'https://images.unsplash.com/photo-1475178626620-a4d074967452?w=400',
          ],
          'category': 'Fashion',
          'stock': 45,
          'rating': 4.7,
          'reviewCount': 89,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Running Shoes',
          'description': 'Lightweight running shoes with breathable mesh and cushioned sole.',
          'price': 129.99,
          'images': [
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400',
            'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400',
          ],
          'category': 'Fashion',
          'stock': 35,
          'rating': 4.8,
          'reviewCount': 234,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        
        // Home Category
        {
          'name': 'Coffee Maker',
          'description': 'Programmable coffee maker with thermal carafe and auto-brew feature.',
          'price': 89.99,
          'images': [
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
            'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
          ],
          'category': 'Home',
          'stock': 25,
          'rating': 4.4,
          'reviewCount': 178,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Table Lamp',
          'description': 'Modern LED table lamp with adjustable brightness and USB charging port.',
          'price': 39.99,
          'images': [
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
            'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=400',
          ],
          'category': 'Home',
          'stock': 55,
          'rating': 4.6,
          'reviewCount': 67,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Throw Pillow Set',
          'description': 'Set of 2 decorative throw pillows with removable covers.',
          'price': 34.99,
          'images': [
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
            'https://images.unsplash.com/photo-1540932239986-30128078f3c5?w=400',
          ],
          'category': 'Home',
          'stock': 40,
          'rating': 4.3,
          'reviewCount': 95,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        
        // Sports Category
        {
          'name': 'Yoga Mat',
          'description': 'Non-slip yoga mat with extra thickness for comfort and support.',
          'price': 29.99,
          'images': [
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
          ],
          'category': 'Sports',
          'stock': 65,
          'rating': 4.7,
          'reviewCount': 123,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Dumbbells Set',
          'description': 'Adjustable dumbbells set with multiple weight options for home workout.',
          'price': 199.99,
          'images': [
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
            'https://images.unsplash.com/photo-1434682881908-b43d0467b798?w=400',
          ],
          'category': 'Sports',
          'stock': 15,
          'rating': 4.8,
          'reviewCount': 76,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Water Bottle',
          'description': 'Insulated stainless steel water bottle that keeps drinks cold for 24 hours.',
          'price': 19.99,
          'images': [
            'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400',
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400',
          ],
          'category': 'Sports',
          'stock': 90,
          'rating': 4.5,
          'reviewCount': 187,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        
        // Books Category
        {
          'name': 'Programming Book',
          'description': 'Complete guide to modern programming with practical examples and exercises.',
          'price': 45.99,
          'images': [
            'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
          ],
          'category': 'Books',
          'stock': 30,
          'rating': 4.6,
          'reviewCount': 245,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Cookbook',
          'description': 'Collection of healthy recipes with step-by-step instructions and photos.',
          'price': 32.99,
          'images': [
            'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          ],
          'category': 'Books',
          'stock': 20,
          'rating': 4.4,
          'reviewCount': 156,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Novel',
          'description': 'Bestselling fiction novel with engaging characters and captivating storyline.',
          'price': 16.99,
          'images': [
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
            'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400',
          ],
          'category': 'Books',
          'stock': 50,
          'rating': 4.7,
          'reviewCount': 389,
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
      print('Successfully seeded ${testProducts.length} test products across multiple categories!');
    } catch (e) {
      print('Error seeding test products: $e');
    }
  }

  /// Force reseed all products (clear and recreate)
  static Future<void> reseedProducts() async {
    try {
      // Clear existing products first
      final productsSnapshot = await _firestore.collection('products').get();
      final productsBatch = _firestore.batch();
      for (final doc in productsSnapshot.docs) {
        productsBatch.delete(doc.reference);
      }
      await productsBatch.commit();
      print('Cleared existing products');

      // Now seed new products
      await seedProducts();
    } catch (e) {
      print('Error reseeding products: $e');
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