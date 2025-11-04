import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coupon.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/cart_provider.dart';

/// 🎟️ Available Coupons Widget - แสดงคูปองที่มีให้ใช้ (ปุ่ม Toggle)
class AvailableCouponsWidget extends StatefulWidget {
  const AvailableCouponsWidget({super.key});

  @override
  State<AvailableCouponsWidget> createState() => _AvailableCouponsWidgetState();
}

class _AvailableCouponsWidgetState extends State<AvailableCouponsWidget> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CouponProvider, CartProvider>(
      builder: (context, couponProvider, cartProvider, child) {
        final availableCoupons = _getAvailableCoupons(
          couponProvider.activeCoupons,
          cartProvider.subtotal,
        );

        if (availableCoupons.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'ไม่มีคูปองส่วนลดในขณะนี้',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Toggle Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
                icon: Icon(_isVisible ? Icons.close : Icons.local_offer),
                label: Text(
                  _isVisible 
                    ? 'ปิดคูปอง' 
                    : 'ดูคูปองที่ใช้ได้ (${availableCoupons.length})',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVisible ? Colors.grey[300] : Colors.orange[100],
                  foregroundColor: _isVisible ? Colors.black87 : Colors.orange[800],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            // Coupons List (only show when visible)
            if (_isVisible)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: availableCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = availableCoupons[index];
                      return _buildCompactCouponCard(coupon, cartProvider);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// กรองคูปองที่ใช้ได้กับยอดสั่งซื้อปัจจุบัน
  List<Coupon> _getAvailableCoupons(List<Coupon> allCoupons, double orderAmount) {
    return allCoupons.where((coupon) {
      // ตรวจสอบว่าคูปองใช้ได้กับยอดสั่งซื้อปัจจุบัน
      return coupon.canBeUsed(orderAmount);
    }).toList()
      ..sort((a, b) {
        // เรียงตามมูลค่าส่วนลดจากมากไปน้อย
        final discountA = a.calculateDiscount(orderAmount);
        final discountB = b.calculateDiscount(orderAmount);
        return discountB.compareTo(discountA);
      });
  }

  /// สร้างการ์ดคูปอง (รูปแบบกะทัดรัด)
  Widget _buildCompactCouponCard(Coupon coupon, CartProvider cartProvider) {
    final discount = coupon.calculateDiscount(cartProvider.subtotal);
    final isApplied = context.read<CouponProvider>().appliedCoupon?.id == coupon.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isApplied 
            ? [Colors.green.shade50, Colors.green.shade100]
            : [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isApplied 
            ? Colors.green.shade300 
            : Colors.orange.shade300,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Coupon Code Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isApplied ? Colors.green.shade700 : Colors.orange.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                coupon.code,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Discount Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ประหยัด \$${discount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isApplied ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getConditionsText(coupon),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Apply Button
            SizedBox(
              width: 60,
              height: 32,
              child: ElevatedButton(
                onPressed: isApplied 
                  ? () => _removeCoupon(context)
                  : () => _applyCoupon(context, coupon),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApplied ? Colors.red.shade600 : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  isApplied ? 'ยกเลิก' : 'ใช้',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getConditionsText(Coupon coupon) {
    if (coupon.minimumOrderAmount > 0) {
      return 'ซื้อขั้นต่ำ \$${coupon.minimumOrderAmount.toStringAsFixed(0)}';
    }
    return 'ใช้ได้ทุกยอด';
  }

  void _applyCoupon(BuildContext context, Coupon coupon) {
    final couponProvider = context.read<CouponProvider>();
    final cartProvider = context.read<CartProvider>();
    
    final success = couponProvider.applyCouponDirect(coupon, cartProvider.subtotal);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ใช้คูปอง ${coupon.code} สำเร็จ'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถใช้คูปอง ${coupon.code} ได้'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeCoupon(BuildContext context) {
    final couponProvider = context.read<CouponProvider>();
    final couponCode = couponProvider.appliedCoupon?.code;
    
    couponProvider.removeCoupon();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ยกเลิกคูปอง $couponCode แล้ว'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}