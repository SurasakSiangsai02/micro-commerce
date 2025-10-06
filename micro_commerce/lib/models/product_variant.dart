/// 🎨 ProductVariant - โมเดลสำหรับตัวเลือกสินค้า (สี, ขนาด, แบบ)
/// 
/// ฟีเจอร์:
/// • สีสินค้า (Color variations)
/// • ขนาดสินค้า (Size variations)
/// • ราคาที่แตกต่างกันตามตัวเลือก
/// • สต็อกแยกตามตัวเลือก
/// • รูปภาพเฉพาะตัวเลือก

class ProductVariant {
  final String id;
  final String productId;
  final String name; // เช่น "สีแดง-ขนาด M"
  final Map<String, String> attributes; // เช่น {"color": "แดง", "size": "M"}
  final double? priceAdjustment; // ปรับราคาจากราคาหลัก (+/-) หรือ null ถ้าราคาเท่าเดิม
  final int stock; // สต็อกเฉพาะตัวเลือกนี้
  final List<String> images; // รูปภาพเฉพาะตัวเลือก
  final bool isAvailable; // พร้อมขายหรือไม่
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.name,
    required this.attributes,
    this.priceAdjustment,
    required this.stock,
    this.images = const [],
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // สำหรับคำนวณราคาจริงของตัวเลือกนี้
  double getFinalPrice(double basePrice) {
    if (priceAdjustment == null) return basePrice;
    return basePrice + priceAdjustment!;
  }

  // แปลง attributes เป็น string สำหรับแสดงผล
  String get displayName {
    if (attributes.isEmpty) return name;
    
    final parts = <String>[];
    if (attributes.containsKey('color')) {
      parts.add('สี${attributes['color']}');
    }
    if (attributes.containsKey('size')) {
      parts.add('ขนาด ${attributes['size']}');
    }
    if (attributes.containsKey('style')) {
      parts.add('แบบ ${attributes['style']}');
    }
    
    return parts.isNotEmpty ? parts.join(' - ') : name;
  }

  // ตรวจสอบว่าตัวเลือกนี้มีสต็อกหรือไม่
  bool get inStock => stock > 0;

  // ตรวจสอบว่าสต็อกต่ำหรือไม่
  bool get isLowStock => stock > 0 && stock < 5;

  factory ProductVariant.fromMap(Map<String, dynamic> data) {
    return ProductVariant(
      id: data['id'] ?? '',
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      attributes: Map<String, String>.from(data['attributes'] ?? {}),
      priceAdjustment: data['priceAdjustment']?.toDouble(),
      stock: data['stock'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'attributes': attributes,
      'priceAdjustment': priceAdjustment,
      'stock': stock,
      'images': images,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ProductVariant copyWith({
    String? id,
    String? productId,
    String? name,
    Map<String, String>? attributes,
    double? priceAdjustment,
    int? stock,
    List<String>? images,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      attributes: attributes ?? this.attributes,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 🎛️ VariantOption - ตัวเลือกที่เป็นไปได้ (เช่น สีต่างๆ, ขนาดต่างๆ)
class VariantOption {
  final String type; // เช่น 'color', 'size', 'style'
  final String name; // เช่น 'สี', 'ขนาด', 'แบบ'
  final List<VariantValue> values; // รายการค่าที่เป็นไปได้

  VariantOption({
    required this.type,
    required this.name,
    required this.values,
  });

  factory VariantOption.fromMap(Map<String, dynamic> data) {
    return VariantOption(
      type: data['type'] ?? '',
      name: data['name'] ?? '',
      values: (data['values'] as List<dynamic>?)
          ?.map((value) => VariantValue.fromMap(value as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'values': values.map((value) => value.toMap()).toList(),
    };
  }
}

/// 🏷️ VariantValue - ค่าของตัวเลือกแต่ละตัว
class VariantValue {
  final String value; // เช่น 'แดง', 'M', 'แบบ A'
  final String? displayName; // ชื่อสำหรับแสดงผล (optional)
  final String? colorCode; // รหัสสีสำหรับตัวเลือกสี (hex)
  final String? imageUrl; // รูปตัวอย่างสำหรับตัวเลือก

  VariantValue({
    required this.value,
    this.displayName,
    this.colorCode,
    this.imageUrl,
  });

  String get label => displayName ?? value;

  factory VariantValue.fromMap(Map<String, dynamic> data) {
    return VariantValue(
      value: data['value'] ?? '',
      displayName: data['displayName'],
      colorCode: data['colorCode'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'displayName': displayName,
      'colorCode': colorCode,
      'imageUrl': imageUrl,
    };
  }
}

/// 📋 ProductWithVariants - สินค้าพร้อมตัวเลือกทั้งหมด
class ProductWithVariants {
  final String productId;
  final String name;
  final String description;
  final double basePrice;
  final String category;
  final List<String> images;
  final List<VariantOption> variantOptions; // ตัวเลือกที่มี
  final List<ProductVariant> variants; // รายการตัวเลือกทั้งหมด
  final bool hasVariants; // มีตัวเลือกหรือไม่
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductWithVariants({
    required this.productId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.category,
    this.images = const [],
    this.variantOptions = const [],
    this.variants = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : hasVariants = variantOptions.isNotEmpty;

  // หาตัวเลือกตาม attributes
  ProductVariant? findVariant(Map<String, String> attributes) {
    try {
      return variants.firstWhere(
        (variant) => _attributesMatch(variant.attributes, attributes),
      );
    } catch (e) {
      return null;
    }
  }

  // ตรวจสอบว่า attributes ตรงกันหรือไม่
  bool _attributesMatch(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  // หาราคาต่ำสุดและสูงสุด
  Map<String, double> get priceRange {
    if (!hasVariants || variants.isEmpty) {
      return {'min': basePrice, 'max': basePrice};
    }

    final prices = variants
        .where((variant) => variant.isAvailable)
        .map((variant) => variant.getFinalPrice(basePrice))
        .toList();

    if (prices.isEmpty) {
      return {'min': basePrice, 'max': basePrice};
    }

    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }

  // หาสต็อกรวม
  int get totalStock {
    if (!hasVariants || variants.isEmpty) return 0;
    return variants.fold(0, (sum, variant) => sum + variant.stock);
  }

  // ตรวจสอบว่ามีสินค้าในสต็อกหรือไม่
  bool get inStock => totalStock > 0;

  // หาตัวเลือกที่มีสต็อก
  List<ProductVariant> get availableVariants {
    return variants.where((variant) => 
        variant.isAvailable && variant.inStock).toList();
  }

  factory ProductWithVariants.fromMap(Map<String, dynamic> data) {
    return ProductWithVariants(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      variantOptions: (data['variantOptions'] as List<dynamic>?)
          ?.map((option) => VariantOption.fromMap(option as Map<String, dynamic>))
          .toList() ?? [],
      variants: (data['variants'] as List<dynamic>?)
          ?.map((variant) => ProductVariant.fromMap(variant as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'category': category,
      'images': images,
      'variantOptions': variantOptions.map((option) => option.toMap()).toList(),
      'variants': variants.map((variant) => variant.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}