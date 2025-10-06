import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/product.dart';
import '../../utils/theme.dart';
import '../../services/database_service.dart';

/// 📝 ProductFormScreen - หน้าฟอร์มเพิ่ม/แก้ไขสินค้า
/// 
/// ฟีเจอร์:
/// • เพิ่มสินค้าใหม่
/// • แก้ไขสินค้าที่มีอยู่
/// • อัปโหลดรูปภาพสินค้า
/// • จัดการ stock และ category
/// • Validation ฟอร์ม
class ProductFormScreen extends StatefulWidget {
  final Product? product; // null = เพิ่มใหม่, มีค่า = แก้ไข
  
  const ProductFormScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  List<String> _imageUrls = [];
  bool _isLoading = false;
  
  // Predefined categories (แก้ไขได้)
  List<String> _predefinedCategories = [
    'เสื้อผ้า',
    'รองเท้า',
    'กระเป๋า',
    'เครื่องประดับ',
    'เครื่องสำอาง',
    'เครื่องใช้ไฟฟ้า',
    'หนังสือ',
    'ของเล่น',
    'กีฬา',
    'อื่นๆ',
  ];
  
  bool get _isEditing => widget.product != null;
  
  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }
  
  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();
    
    // ตรวจสอบว่า category ของสินค้าอยู่ใน predefined categories หรือไม่
    if (_predefinedCategories.contains(product.category)) {
      _categoryController.text = product.category;
    } else {
      // ถ้าไม่มี ให้เพิ่มเข้าไปใน list และใช้ค่านั้น
      if (product.category.isNotEmpty && !_predefinedCategories.contains(product.category)) {
        _predefinedCategories.add(product.category);
      }
      _categoryController.text = product.category;
    }
    
    _imageUrls = List.from(product.images);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '✏️ แก้ไขสินค้า' : '➕ เพิ่มสินค้าใหม่'),
        backgroundColor: AppTheme.lightBlue,
        foregroundColor: AppTheme.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDelete,
              tooltip: 'ลบสินค้า',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images Section
              _buildImageSection(),
              
              const SizedBox(height: 24),
              
              // Basic Information
              Text(
                '📋 ข้อมูลพื้นฐาน',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อสินค้า *',
                  hintText: 'กรอกชื่อสินค้า',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อสินค้า';
                  }
                  if (value.trim().length < 3) {
                    return 'ชื่อสินค้าต้องมีอย่างน้อย 3 ตัวอักษร';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty || !_predefinedCategories.contains(_categoryController.text) 
                    ? null 
                    : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่ *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _predefinedCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณาเลือกหมวดหมู่';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียดสินค้า',
                  hintText: 'กรอกรายละเอียดสินค้า',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return 'รายละเอียดต้องไม่เกิน 500 ตัวอักษร';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Pricing & Stock
              Text(
                '💰 ราคาและสต็อก',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  // Price
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'ราคา (บาท) *',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: '฿',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกราคา';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'ราคาต้องมากกว่า 0';
                        }
                        if (price > 999999) {
                          return 'ราคาต้องไม่เกิน 999,999 บาท';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Stock
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'จำนวนสต็อก *',
                        hintText: '0',
                        prefixIcon: Icon(Icons.inventory),
                        suffixText: 'ชิ้น',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'กรุณากรอกจำนวน';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null || stock < 0) {
                          return 'จำนวนต้องเป็น 0 หรือมากกว่า';
                        }
                        if (stock > 99999) {
                          return 'จำนวนต้องไม่เกิน 99,999';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProduct,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(_isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มสินค้า'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightBlue,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              if (_isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('ลบสินค้า', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📷 รูปภาพสินค้า',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Quick image suggestions
        Text(
          '🖼️ รูปภาพตัวอย่าง (คลิกเพื่อเพิ่ม)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSampleImage('https://images.pexels.com/photos/1464625/pexels-photo-1464625.jpeg?auto=compress&cs=tinysrgb&w=400', 'เสื้อ'),
              _buildSampleImage('https://images.pexels.com/photos/267301/pexels-photo-267301.jpeg?auto=compress&cs=tinysrgb&w=400', 'รองเท้า'),
              _buildSampleImage('https://images.pexels.com/photos/1055691/pexels-photo-1055691.jpeg?auto=compress&cs=tinysrgb&w=400', 'กระเป๋า'),
              _buildSampleImage('https://images.pexels.com/photos/1927259/pexels-photo-1927259.jpeg?auto=compress&cs=tinysrgb&w=400', 'หูฟัง'),
              _buildSampleImage('https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg?auto=compress&cs=tinysrgb&w=400', 'นาฬิกา'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Add Image URL input
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL รูปภาพ',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'URL ไม่ถูกต้อง';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _addImageUrl,
              child: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('เพิ่ม'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Display images
        if (_imageUrls.isNotEmpty) ...[
          Text(
            'รูปภาพที่เพิ่มแล้ว (${_imageUrls.length} รูป)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrls[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, color: Colors.red),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ไม่สามารถ\nโหลดได้',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 18),
                                  SizedBox(width: 8),
                                  Text('ดูภาพเต็ม'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'copy',
                              child: Row(
                                children: [
                                  Icon(Icons.copy, size: 18),
                                  SizedBox(width: 8),
                                  Text('คัดลอก URL'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text('ลบ', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) => _handleImageAction(value, index),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...[
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'ยังไม่มีรูปภาพ',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _addImageUrl() async {
    final url = _imageUrlController.text.trim();
    if (url.isEmpty) return;
    
    // ตรวจสอบว่า URL ซ้ำหรือไม่
    if (_imageUrls.contains(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รูปภาพนี้ถูกเพิ่มแล้ว'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // แสดง loading
    setState(() => _isLoading = true);
    
    try {
      // ทดสอบว่า URL ใช้งานได้หรือไม่
      final uri = Uri.parse(url);
      final response = await HttpClient().headUrl(uri);
      final request = await response.close();
      
      if (request.statusCode == 200) {
        setState(() {
          _imageUrls.add(url);
          _imageUrlController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มรูปภาพสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('รูปภาพไม่สามารถโหลดได้ (${request.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถโหลดรูปภาพได้: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  /// 🎯 จัดการ action ของรูปภาพ
  void _handleImageAction(String action, int index) {
    switch (action) {
      case 'view':
        _viewFullImage(index);
        break;
      case 'copy':
        _copyImageUrl(index);
        break;
      case 'delete':
        _confirmDeleteImage(index);
        break;
    }
  }

  /// 👁️ ดูภาพเต็ม
  void _viewFullImage(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('รูปภาพที่ ${index + 1}'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: Image.network(
                _imageUrls[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64, color: Colors.red),
                          SizedBox(height: 8),
                          Text('ไม่สามารถโหลดภาพได้'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 คัดลอก URL
  void _copyImageUrl(int index) {
    Clipboard.setData(ClipboardData(text: _imageUrls[index]));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอก URL แล้ว'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 🗑️ ยืนยันการลบรูปภาพ
  void _confirmDeleteImage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบรูปภาพนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeImage(index);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ลบรูปภาพแล้ว'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'category': _categoryController.text.trim(),
        'stock': int.parse(_stockController.text),
        'images': _imageUrls,
        'rating': _isEditing ? widget.product!.rating : 0.0,
        'reviewCount': _isEditing ? widget.product!.reviewCount : 0,
        'updatedAt': DateTime.now(),
      };

      if (_isEditing) {
        // แก้ไขสินค้าที่มีอยู่แล้ว
        await DatabaseService.updateProduct(widget.product!.id, productData);
      } else {
        // เพิ่มสินค้าใหม่
        await DatabaseService.addProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'แก้ไขสินค้าสำเร็จ' : 'เพิ่มสินค้าสำเร็จ'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context, true); // ส่ง true กลับบอกว่าบันทึกสำเร็จ
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDelete() {
    if (!_isEditing) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบสินค้า "${widget.product!.name}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteProduct();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    setState(() => _isLoading = true);
    
    try {
      // ลบสินค้าจาก Firestore
      await DatabaseService.deleteProduct(widget.product!.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบสินค้า "${widget.product!.name}" สำเร็จ'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context, true); // ส่ง true บอกว่าลบสำเร็จ
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 🖼️ สร้าง Widget รูปภาพตัวอย่าง
  Widget _buildSampleImage(String url, String label) {
    return GestureDetector(
      onTap: () {
        if (!_imageUrls.contains(url)) {
          setState(() {
            _imageUrls.add(url);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เพิ่มรูป$label แล้ว'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('รูปภาพนี้ถูกเพิ่มแล้ว'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                width: 80,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 30),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}