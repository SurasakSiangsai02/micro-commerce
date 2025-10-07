import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coupon.dart';

/// 🎟️ CouponService - บริการจัดการคูปองส่วนลด
/// 
/// ฟีเจอร์:
/// • สร้าง/แก้ไข/ลบคูปอง (Admin)
/// • ค้นหาและตรวจสอบคูปอง
/// • คำนวณส่วนลด
/// • เพิ่มจำนวนการใช้งาน
/// • ดูสถิติการใช้งาน
class CouponService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'coupons';

  /// ดึงข้อมูลคูปองทั้งหมด
  static Stream<List<Coupon>> getCoupons() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Coupon.fromFirestore(doc))
            .toList());
  }

  /// ดึงข้อมูลคูปองที่ใช้งานได้
  static Stream<List<Coupon>> getActiveCoupons() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Coupon.fromFirestore(doc))
            .where((coupon) => coupon.canBeUsed(0)) // ตรวจสอบเงื่อนไขอื่น
            .toList());
  }

  /// ค้นหาคูปองด้วยรหัส
  static Future<Coupon?> getCouponByCode(String code) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return Coupon.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('Error getting coupon by code: $e');
      return null;
    }
  }

  /// ตรวจสอบและใช้คูปอง
  static Future<CouponResult> validateAndApplyCoupon(
    String code, 
    double orderAmount,
  ) async {
    try {
      final coupon = await getCouponByCode(code);
      
      if (coupon == null) {
        return CouponResult.error('Invalid coupon code');
      }

      // ตรวจสอบว่าใช้คูปองได้หรือไม่
      if (!coupon.canBeUsed(orderAmount)) {
        if (!coupon.isActive) {
          return CouponResult.error('This coupon is no longer active');
        } else if (coupon.isExpired) {
          return CouponResult.error('This coupon has expired');
        } else if (coupon.isUsedUp) {
          return CouponResult.error('This coupon has reached its usage limit');
        } else if (orderAmount < coupon.minimumOrderAmount) {
          return CouponResult.error(
            'Minimum order amount is \$${coupon.minimumOrderAmount.toStringAsFixed(2)}'
          );
        } else {
          return CouponResult.error('This coupon cannot be used');
        }
      }

      // คำนวณส่วนลด
      final discountAmount = coupon.calculateDiscount(orderAmount);
      
      return CouponResult.success(coupon, discountAmount);
    } catch (e) {
      print('Error validating coupon: $e');
      return CouponResult.error('Failed to validate coupon');
    }
  }

  /// เพิ่มจำนวนการใช้งานคูปอง
  static Future<bool> incrementCouponUsage(String couponId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final couponRef = _firestore.collection(_collection).doc(couponId);
        final couponDoc = await transaction.get(couponRef);
        
        if (!couponDoc.exists) {
          throw Exception('Coupon not found');
        }
        
        final coupon = Coupon.fromFirestore(couponDoc);
        final newUsedCount = coupon.usedCount + 1;
        
        transaction.update(couponRef, {
          'usedCount': newUsedCount,
          'updatedAt': Timestamp.now(),
        });
      });
      
      return true;
    } catch (e) {
      print('Error incrementing coupon usage: $e');
      return false;
    }
  }

  /// สร้างคูปองใหม่
  static Future<String?> createCoupon(Coupon coupon) async {
    try {
      // ตรวจสอบว่ารหัสคูปองซ้ำหรือไม่
      final existingCoupon = await getCouponByCode(coupon.code);
      if (existingCoupon != null) {
        throw Exception('Coupon code already exists');
      }

      final docRef = await _firestore.collection(_collection).add(coupon.toFirestore());
      
      print('✅ Created coupon: ${coupon.code} with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating coupon: $e');
      return null;
    }
  }

  /// แก้ไขคูปอง
  static Future<bool> updateCoupon(String couponId, Coupon updatedCoupon) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(couponId)
          .update(updatedCoupon.copyWith(
            id: couponId,
            updatedAt: DateTime.now(),
          ).toFirestore());
      
      print('✅ Updated coupon: $couponId');
      return true;
    } catch (e) {
      print('❌ Error updating coupon: $e');
      return false;
    }
  }

  /// ลบคูปอง
  static Future<bool> deleteCoupon(String couponId) async {
    try {
      await _firestore.collection(_collection).doc(couponId).delete();
      
      print('✅ Deleted coupon: $couponId');
      return true;
    } catch (e) {
      print('❌ Error deleting coupon: $e');
      return false;
    }
  }

  /// เปิด/ปิดการใช้งานคูปอง
  static Future<bool> toggleCouponStatus(String couponId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(couponId).update({
        'isActive': isActive,
        'updatedAt': Timestamp.now(),
      });
      
      print('✅ ${isActive ? 'Activated' : 'Deactivated'} coupon: $couponId');
      return true;
    } catch (e) {
      print('❌ Error toggling coupon status: $e');
      return false;
    }
  }

  /// ดูสถิติคูปอง
  static Future<CouponStats> getCouponStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final coupons = snapshot.docs.map((doc) => Coupon.fromFirestore(doc)).toList();
      
      int totalCoupons = coupons.length;
      int activeCoupons = coupons.where((c) => c.status == CouponStatus.active).length;
      int expiredCoupons = coupons.where((c) => c.status == CouponStatus.expired).length;
      int usedUpCoupons = coupons.where((c) => c.status == CouponStatus.usedUp).length;
      int totalUsage = coupons.fold(0, (sum, c) => sum + c.usedCount);
      
      return CouponStats(
        totalCoupons: totalCoupons,
        activeCoupons: activeCoupons,
        expiredCoupons: expiredCoupons,
        usedUpCoupons: usedUpCoupons,
        totalUsage: totalUsage,
      );
    } catch (e) {
      print('❌ Error getting coupon stats: $e');
      return CouponStats(
        totalCoupons: 0,
        activeCoupons: 0,
        expiredCoupons: 0,
        usedUpCoupons: 0,
        totalUsage: 0,
      );
    }
  }

  /// สร้างรหัสคูปองแบบสุ่ม
  static String generateCouponCode({int length = 8}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String result = '';
    
    for (int i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }
    
    return result;
  }

  /// ตรวจสอบรหัสคูปองว่าถูกต้องหรือไม่
  static bool isValidCouponCode(String code) {
    if (code.trim().isEmpty) return false;
    if (code.length < 3 || code.length > 20) return false;
    
    // อนุญาตเฉพาะตัวอักษรและตัวเลข
    final regex = RegExp(r'^[A-Z0-9]+$');
    return regex.hasMatch(code.toUpperCase());
  }
}

/// สถิติคูปอง
class CouponStats {
  final int totalCoupons;
  final int activeCoupons;
  final int expiredCoupons;
  final int usedUpCoupons;
  final int totalUsage;

  const CouponStats({
    required this.totalCoupons,
    required this.activeCoupons,
    required this.expiredCoupons,
    required this.usedUpCoupons,
    required this.totalUsage,
  });

  int get inactiveCoupons => totalCoupons - activeCoupons - expiredCoupons - usedUpCoupons;
  
  double get activePercentage => totalCoupons > 0 ? (activeCoupons / totalCoupons) * 100 : 0;
  double get usageRate => totalCoupons > 0 ? (totalUsage / totalCoupons) : 0;
}