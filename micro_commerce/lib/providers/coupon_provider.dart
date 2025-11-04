import 'package:flutter/foundation.dart';
import '../models/coupon.dart';
import '../services/coupon_service.dart';

/// 🎟️ CouponProvider - จัดการสถานะคูปองส่วนลด
/// 
/// ฟีเจอร์:
/// • จัดการรายการคูปอง
/// • ตรวจสอบและใช้คูปอง
/// • สร้าง/แก้ไข/ลบคูปอง (Admin)
/// • แสดงสถิติการใช้งาน
class CouponProvider with ChangeNotifier {
  List<Coupon> _coupons = [];
  bool _isLoading = false;
  String? _error;
  
  // Applied coupon for current cart/order
  Coupon? _appliedCoupon;  
  double _discountAmount = 0.0;
  
  // Coupon validation state
  bool _isValidating = false;
  String? _validationMessage;

  // Constructor - โหลดข้อมูลเริ่มต้น
  CouponProvider() {
    loadCoupons();
  }

  // Getters
  List<Coupon> get coupons => _coupons;
  List<Coupon> get activeCoupons => _coupons.where((c) => c.status == CouponStatus.active).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Coupon? get appliedCoupon => _appliedCoupon;
  double get discountAmount => _discountAmount;
  bool get hasAppliedCoupon => _appliedCoupon != null;
  
  bool get isValidating => _isValidating;
  String? get validationMessage => _validationMessage;

  /// โหลดรายการคูปองทั้งหมด
  Future<void> loadCoupons() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Listen to coupon stream
      CouponService.getCoupons().listen(
        (coupons) {
          _coupons = coupons;
          _setLoading(false);
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load coupons: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Failed to load coupons: $e');
      _setLoading(false);
    }
  }

  /// โหลดเฉพาะคูปองที่ใช้งานได้
  Future<void> loadActiveCoupons() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Listen to active coupon stream
      CouponService.getActiveCoupons().listen(
        (coupons) {
          _coupons = coupons;
          _setLoading(false);
          notifyListeners();
        },
        onError: (error) {
          _setError('Failed to load active coupons: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Failed to load active coupons: $e');
      _setLoading(false);
    }
  }

  /// ตรวจสอบและใช้คูปอง
  Future<bool> applyCoupon(String code, double orderAmount) async {
    if (code.trim().isEmpty) {
      _setValidationMessage('Please enter a coupon code');
      return false;
    }

    _setValidating(true);
    _clearValidationMessage();
    
    try {
      final result = await CouponService.validateAndApplyCoupon(code, orderAmount);
      
      if (result.isValid && result.coupon != null) {
        _appliedCoupon = result.coupon;
        _discountAmount = result.discountAmount;
        _setValidationMessage(result.message);
        _setValidating(false);
        notifyListeners();
        return true;
      } else {
        _setValidationMessage(result.message);
        _setValidating(false);
        return false;
      }
    } catch (e) {
      _setValidationMessage('Failed to apply coupon: $e');
      _setValidating(false);
      return false;
    }
  }

  /// ใช้คูปองโดยตรงจาก Coupon object
  bool applyCouponDirect(Coupon coupon, double orderAmount) {
    if (!coupon.canBeUsed(orderAmount)) {
      _setValidationMessage('ไม่สามารถใช้คูปองนี้ได้');
      return false;
    }

    _appliedCoupon = coupon;
    _discountAmount = coupon.calculateDiscount(orderAmount);
    _clearValidationMessage();
    notifyListeners();
    return true;
  }

  /// ยกเลิกคูปอง
  void removeCoupon() {
    _appliedCoupon = null;
    _discountAmount = 0.0;
    _clearValidationMessage();
    notifyListeners();
  }

  /// คำนวณราคาหลังหักส่วนลด
  double calculateFinalAmount(double originalAmount) {
    if (_appliedCoupon == null) return originalAmount;
    return (originalAmount - _discountAmount).clamp(0.0, double.infinity);
  }

  /// คำนวณราคาหลังหักส่วนลดพร้อม tax
  double calculateFinalAmountWithTax(double originalAmount, {double taxRate = 0.08}) {
    final subtotalAfterDiscount = calculateFinalAmount(originalAmount);
    final taxAmount = subtotalAfterDiscount * taxRate;
    return subtotalAfterDiscount + taxAmount;
  }

  /// คำนวณ tax จากราคาหลังหักส่วนลด
  double calculateTaxAmount(double originalAmount, {double taxRate = 0.08}) {
    final subtotalAfterDiscount = calculateFinalAmount(originalAmount);
    return subtotalAfterDiscount * taxRate;
  }

  /// ยืนยันการใช้คูปอง (เรียกเมื่อสั่งซื้อสำเร็จ)
  Future<bool> confirmCouponUsage() async {
    if (_appliedCoupon == null) return true;
    
    try {
      final success = await CouponService.incrementCouponUsage(_appliedCoupon!.id);
      if (success) {
        print('✅ Coupon usage confirmed: ${_appliedCoupon!.code}');
      }
      return success;
    } catch (e) {
      print('❌ Failed to confirm coupon usage: $e');
      return false;
    }
  }

  /// สร้างคูปองใหม่ (Admin)
  Future<bool> createCoupon({
    required String code,
    required CouponType type,
    required double discountValue,
    double minimumOrderAmount = 0.0,
    int usageLimit = -1,
    DateTime? expiryDate,
    bool isActive = true,
    required String createdBy,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // ตรวจสอบรหัสคูปอง
      if (!CouponService.isValidCouponCode(code)) {
        _setError('Invalid coupon code format');
        _setLoading(false);
        return false;
      }

      final coupon = Coupon(
        id: '', // จะถูกสร้างโดย Firestore
        code: code.toUpperCase(),
        type: type,
        discountValue: discountValue,
        minimumOrderAmount: minimumOrderAmount,
        usageLimit: usageLimit,
        expiryDate: expiryDate,
        isActive: isActive,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: description,
      );

      final couponId = await CouponService.createCoupon(coupon);
      
      if (couponId != null) {
        _setLoading(false);
        // Coupons will be updated automatically via stream
        return true;
      } else {
        _setError('Failed to create coupon');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to create coupon: $e');
      _setLoading(false);
      return false;
    }
  }

  /// แก้ไขคูปอง (Admin)
  Future<bool> updateCoupon(String couponId, Coupon updatedCoupon) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await CouponService.updateCoupon(couponId, updatedCoupon);
      
      if (success) {
        _setLoading(false);
        // Coupons will be updated automatically via stream
        return true;
      } else {
        _setError('Failed to update coupon');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update coupon: $e');
      _setLoading(false);
      return false;
    }
  }

  /// ลบคูปอง (Admin)
  Future<bool> deleteCoupon(String couponId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await CouponService.deleteCoupon(couponId);
      
      if (success) {
        _setLoading(false);
        // Coupons will be updated automatically via stream
        return true;
      } else {
        _setError('Failed to delete coupon');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete coupon: $e');
      _setLoading(false);
      return false;
    }
  }

  /// เปิด/ปิดการใช้งานคูปอง (Admin)
  Future<bool> toggleCouponStatus(String couponId, bool isActive) async {
    try {
      final success = await CouponService.toggleCouponStatus(couponId, isActive);
      
      if (success) {
        // Coupons will be updated automatically via stream
        return true;
      } else {
        _setError('Failed to toggle coupon status');
        return false;
      }
    } catch (e) {
      _setError('Failed to toggle coupon status: $e');
      return false;
    }
  }

  /// ดูสถิติคูปอง (Admin)
  Future<CouponStats?> getCouponStats() async {
    try {
      return await CouponService.getCouponStats();
    } catch (e) {
      _setError('Failed to get coupon stats: $e');
      return null;
    }
  }

  /// สร้างรหัสคูปองแบบสุ่ม
  String generateCouponCode({int length = 8}) {
    return CouponService.generateCouponCode(length: length);
  }

  /// ค้นหาคูปองตามรหัส
  Coupon? findCouponByCode(String code) {
    try {
      return _coupons.firstWhere(
        (coupon) => coupon.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// ค้นหาคูปองที่สามารถใช้ได้กับยอดเงินที่กำหนด
  List<Coupon> getUsableCoupons(double orderAmount) {
    return _coupons.where((coupon) => coupon.canBeUsed(orderAmount)).toList();
  }

  /// รีเซ็ตสถานะทั้งหมด
  void reset() {
    _coupons = [];
    _appliedCoupon = null;
    _discountAmount = 0.0;
    _isLoading = false;
    _isValidating = false;
    _error = null;
    _validationMessage = null;
    notifyListeners();
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setValidating(bool validating) {
    _isValidating = validating;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setValidationMessage(String message) {
    _validationMessage = message;
    notifyListeners();
  }

  void _clearValidationMessage() {
    _validationMessage = null;
  }
}