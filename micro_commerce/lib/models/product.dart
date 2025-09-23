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
  });

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