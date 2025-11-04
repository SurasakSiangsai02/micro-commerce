import 'package:cloud_firestore/cloud_firestore.dart';

/// 🎟️ Coupon Model - โมเดลคูปองส่วนลด
/// 
/// ฟีเจอร์:
/// • รหัสคูปอง (code)
/// • ประเภทส่วนลด (percentage/fixed amount)
/// • มูลค่าส่วนลด
/// • ยอดขั้นต่ำสำหรับใช้คูปอง
/// • จำนวนครั้งที่ใช้ได้
/// • วันหมดอายุ
/// • สถานะการใช้งาน
/// • สถิติการใช้งาน
class Coupon {
  final String id;
  final String code;
  final CouponType type;
  final double discountValue;
  final double minimumOrderAmount;
  final int usageLimit;
  final int usedCount;
  final DateTime? expiryDate;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;

  const Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.discountValue,
    this.minimumOrderAmount = 0.0,
    this.usageLimit = -1, // -1 = unlimited
    this.usedCount = 0,
    this.expiryDate,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  /// Factory constructor from Firestore document
  factory Coupon.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Coupon(
      id: doc.id,
      code: data['code'] ?? '',
      type: CouponType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => CouponType.percentage,
      ),
      discountValue: (data['discountValue'] ?? 0.0).toDouble(),
      minimumOrderAmount: (data['minimumOrderAmount'] ?? 0.0).toDouble(),
      usageLimit: data['usageLimit'] ?? -1,
      usedCount: data['usedCount'] ?? 0,
      expiryDate: data['expiryDate'] != null 
        ? (data['expiryDate'] as Timestamp).toDate()
        : null,
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'type': type.toString().split('.').last,
      'discountValue': discountValue,
      'minimumOrderAmount': minimumOrderAmount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'description': description,
    };
  }

  /// คำนวณส่วนลด
  double calculateDiscount(double orderAmount) {
    if (!canBeUsed(orderAmount)) {
      return 0.0;
    }

    double discount;
    switch (type) {
      case CouponType.percentage:
        discount = orderAmount * (discountValue / 100);
        break;
      case CouponType.fixedAmount:
        discount = discountValue;
        break;
    }
    
    // ตรวจสอบว่าส่วนลดไม่เกินยอดสั่งซื้อ (เหลือยอดขั้นต่ำ $0.01)
    return discount.clamp(0.0, orderAmount - 0.01);
  }

  /// ตรวจสอบว่าใช้คูปองได้หรือไม่
  bool canBeUsed(double orderAmount) {
    // ตรวจสอบสถานะ
    if (!isActive) return false;
    
    // ตรวจสอบวันหมดอายุ
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) {
      return false;
    }
    
    // ตรวจสอบยอดขั้นต่ำ
    if (orderAmount < minimumOrderAmount) return false;
    
    // ตรวจสอบจำนวนครั้งที่ใช้
    if (usageLimit >= 0 && usedCount >= usageLimit) return false;
    
    return true;
  }

  /// ตรวจสอบว่าหมดอายุหรือไม่
  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// ตรวจสอบว่าใช้ครบแล้วหรือไม่
  bool get isUsedUp {
    if (usageLimit < 0) return false; // unlimited
    return usedCount >= usageLimit;
  }

  /// สถานะของคูปอง
  CouponStatus get status {
    if (!isActive) return CouponStatus.inactive;
    if (isExpired) return CouponStatus.expired;
    if (isUsedUp) return CouponStatus.usedUp;
    return CouponStatus.active;
  }

  /// ข้อความแสดงสถานะ
  String get statusText {
    switch (status) {
      case CouponStatus.active:
        return 'Active';
      case CouponStatus.inactive:
        return 'Inactive';
      case CouponStatus.expired:
        return 'Expired';
      case CouponStatus.usedUp:
        return 'Used Up';
    }
  }

  /// ข้อความแสดงส่วนลด
  String get discountText {
    switch (type) {
      case CouponType.percentage:
        return '${discountValue.toInt()}% OFF';
      case CouponType.fixedAmount:
        return '\$${discountValue.toStringAsFixed(2)} OFF';
    }
  }

  /// วันเหลือก่อนหมดอายุ
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final difference = expiryDate!.difference(DateTime.now());
    return difference.inDays;
  }

  /// Copy with method
  Coupon copyWith({
    String? id,
    String? code,
    CouponType? type,
    double? discountValue,
    double? minimumOrderAmount,
    int? usageLimit,
    int? usedCount,
    DateTime? expiryDate,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      discountValue: discountValue ?? this.discountValue,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Coupon{id: $id, code: $code, type: $type, discountValue: $discountValue, status: $statusText}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coupon &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// ประเภทส่วนลด
enum CouponType {
  percentage,   // ส่วนลดเป็นเปอร์เซ็นต์
  fixedAmount,  // ส่วนลดเป็นจำนวนเงินคงที่
}

/// สถานะคูปอง
enum CouponStatus {
  active,    // ใช้งานได้
  inactive,  // หยุดใช้งาน
  expired,   // หมดอายุ
  usedUp,    // ใช้ครบจำนวนแล้ว
}

/// ผลลัพธ์การใช้คูปอง
class CouponResult {
  final bool isValid;
  final double discountAmount;
  final String message;
  final Coupon? coupon;

  const CouponResult({
    required this.isValid,
    required this.discountAmount,
    required this.message,
    this.coupon,
  });

  factory CouponResult.success(Coupon coupon, double discountAmount) {
    return CouponResult(
      isValid: true,
      discountAmount: discountAmount,
      message: 'Coupon applied successfully! You saved \$${discountAmount.toStringAsFixed(2)}',
      coupon: coupon,
    );
  }

  factory CouponResult.error(String message) {
    return CouponResult(
      isValid: false,
      discountAmount: 0.0,
      message: message,
    );
  }
}