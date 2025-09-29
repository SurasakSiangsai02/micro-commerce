import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final int stock;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Mock data for testing UI
  static List<Product> mockProducts = [
    Product(
      id: '1',
      name: 'Gaming Laptop',
      description: 'High performance gaming laptop with RTX 3080',
      price: 1499.99,
      images: [
        'https://picsum.photos/400/400',
        'https://picsum.photos/400/401',
      ],
      category: 'Electronics',
      stock: 10,
      rating: 4.5,
      reviewCount: 128,
    ),
    Product(
      id: '2',
      name: 'Wireless Earbuds',
      description: 'True wireless earbuds with noise cancellation',
      price: 199.99,
      images: [
        'https://picsum.photos/400/402',
        'https://picsum.photos/400/403',
      ],
      category: 'Electronics',
      stock: 50,
      rating: 4.8,
      reviewCount: 256,
    ),
    Product(
      id: '3',
      name: 'Smart Watch',
      description: 'Fitness tracking smart watch',
      price: 299.99,
      images: [
        'https://picsum.photos/400/404',
        'https://picsum.photos/400/405',
      ],
      category: 'Electronics',
      stock: 25,
      rating: 4.2,
      reviewCount: 89,
    ),
    // Add more mock products here
  ];
}