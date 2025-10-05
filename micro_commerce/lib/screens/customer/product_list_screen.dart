import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../utils/theme.dart';
import '../../utils/error_handler.dart' as error_utils;
import '../../utils/test_data_seeder.dart';
import '../../widgets/product_card.dart';
import '../../services/database_service.dart';
import '../../providers/cart_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<String> categories = [
    'All',
    'Electronics',
    'Fashion',
    'Home',
    'Sports',
    'Books',
  ];

  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check if products exist, if not seed them
      final products = await DatabaseService.getProducts();
      if (products.isEmpty) {
        await TestDataSeeder.seedProducts();
        // Reload after seeding
        final newProducts = await DatabaseService.getProducts();
        setState(() {
          _products = newProducts;
        });
      } else {
        setState(() {
          _products = products;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = error_utils.ErrorHandler.getReadableError(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    var filtered = _products;

    // Filter by category
    if (selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar and Filter
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.darkGreen,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Categories
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = category == selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppTheme.lightGreen,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Product Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? error_utils.ErrorWidget(
                          message: _errorMessage!,
                          onRetry: _loadProducts,
                        )
                      : _filteredProducts.isEmpty
                          ? const Center(
                              child: Text('No products found'),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadProducts,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Responsive grid based on screen width
                                  final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                                  final screenWidth = constraints.maxWidth;
                                  final cardWidth = (screenWidth - (16 * (crossAxisCount + 1))) / crossAxisCount;
                                  final aspectRatio = cardWidth / (cardWidth * 1.4); // Height is 1.4x width
                                  
                                  return GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: aspectRatio,
                                    ),
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = _filteredProducts[index];
                                      return ProductCard(
                                    product: product,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/product-detail',
                                        arguments: product,
                                      );
                                    },
                                    onAddToCart: () {
                                      final cartProvider = Provider.of<CartProvider>(context, listen: false);
                                      cartProvider.addToCart(product, 1);
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Added ${product.name} to cart'),
                                          backgroundColor: AppTheme.successGreen,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}