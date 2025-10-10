import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../models/product.dart';
import '../../services/database_service.dart';
import '../../widgets/loading_dialog.dart';
import 'product_form_screen.dart';

/// 🛍️ ProductManagementScreen - หน้าจัดการสินค้าสำหรับ Admin
/// 
/// ฟีเจอร์:
/// • แสดงรายการสินค้าทั้งหมด
/// • เพิ่มสินค้าใหม่
/// • แก้ไขสินค้า  
/// • ลบสินค้า
/// • ค้นหาและกรองสินค้า
/// • จัดการ stock และ category
class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final products = await DatabaseService.getProducts();
      final categories = products
          .map((product) => product.category)
          .toSet()
          .toList();
      
      setState(() {
        _categories = ['All', ...categories]; // ใช้ภาษาอังกฤษทั้งหมด
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userProfile;
        
        if (user == null || !user.canManageProducts) {
          return _buildAccessDenied();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('🛍️ จัดการสินค้า'),
            backgroundColor: AppTheme.lightBlue,
            foregroundColor: AppTheme.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addNewProduct,
                tooltip: 'เพิ่มสินค้าใหม่',
              ),
            ],
          ),
          body: Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'ค้นหาสินค้า...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Category Filter
                    Row(
                      children: [
                        const Text(
                          'Category: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Products List
              Expanded(
                child: StreamBuilder<List<Product>>(
                  stream: DatabaseService.getProductsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('ลองใหม่'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final products = snapshot.data ?? [];
                    final filteredProducts = _filterProducts(products);
                    
                    if (filteredProducts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty || _selectedCategory != 'All'
                                  ? Icons.search_off
                                  : Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _selectedCategory != 'All'
                                  ? 'No products found matching the search criteria'
                                  : 'No products in the system yet',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_searchQuery.isEmpty && _selectedCategory == 'All')
                              ElevatedButton.icon(
                                onPressed: _addNewProduct,
                                icon: const Icon(Icons.add),
                                label: const Text('เพิ่มสินค้าแรก'),
                              ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addNewProduct,
            backgroundColor: AppTheme.lightBlue,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          product.description.toLowerCase().contains(_searchQuery);
          
      final matchesCategory = _selectedCategory == 'All' ||
          product.category == _selectedCategory;
          
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildProductCard(Product product) {
    final isLowStock = product.stock < 10;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image),
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.category}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '฿${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 16,
                            color: isLowStock ? Colors.red : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'คงเหลือ: ${product.stock}',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.grey[600],
                              fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isLowStock) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'สต็อกต่ำ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editProduct(product);
                        break;
                      case 'delete':
                        _deleteProduct(product);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('แก้ไข'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('ลบ', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (product.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                product.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ไม่มีสิทธิ์เข้าถึง'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'คุณไม่มีสิทธิ์จัดการสินค้า',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ติดต่อผู้ดูแลระบบเพื่อขอสิทธิ์',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductFormScreen(),
      ),
    ).then((result) {
      // Refresh categories and show success message
      _loadCategories();
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มสินค้าสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _editProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    ).then((result) {
      // Refresh categories and show success message  
      _loadCategories();
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('แก้ไขสินค้าสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${product.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => _performDeleteProduct(product),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteProduct(Product product) async {
    // ปิด confirmation dialog ก่อน
    Navigator.pop(context);
    
    try {
      // แสดง loading dialog พร้อม timeout
      LoadingDialog.show(
        context,
        message: 'กำลังลบสินค้า "${product.name}"...',
        timeout: const Duration(seconds: 15),
      );
      
      // เพิ่ม timeout ป้องกันการค้างนาน
      await DatabaseService.deleteProduct(product.id).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('การลบสินค้าใช้เวลานานเกินไป กรุณาลองใหม่');
        },
      );
      
      // ปิด loading dialog
      LoadingDialog.hide();
      
      // แสดงข้อความสำเร็จ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ลบสินค้า "${product.name}" สำเร็จ'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // โหลดหมวดหมู่ใหม่
        _loadCategories();
      }
    } catch (e) {
      // ปิด loading dialog
      LoadingDialog.hide();
      
      // แสดงข้อความผิดพลาด
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'ลองใหม่',
              textColor: Colors.white,
              onPressed: () => _performDeleteProduct(product),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}