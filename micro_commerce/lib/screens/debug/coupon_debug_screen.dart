import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/coupon.dart';

class CouponDebugScreen extends StatefulWidget {
  const CouponDebugScreen({super.key});

  @override
  State<CouponDebugScreen> createState() => _CouponDebugScreenState();
}

class _CouponDebugScreenState extends State<CouponDebugScreen> {
  final _couponController = TextEditingController();
  final _amountController = TextEditingController(text: '100.00');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<CouponProvider, CartProvider>(
        builder: (context, couponProvider, cartProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Test Order Amount
                const Text('Test Order Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter order amount (e.g., 100.00)',
                    prefixText: '\$',
                  ),
                ),
                const SizedBox(height: 20),
                
                // Coupon Input
                const Text('Coupon Code:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        decoration: const InputDecoration(
                          hintText: 'Enter coupon code',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: couponProvider.isValidating ? null : _testCoupon,
                      child: couponProvider.isValidating 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Results
                const Text('Debug Information:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cart Total: \$${cartProvider.total.toStringAsFixed(2)}'),
                      Text('Test Amount: \$${double.tryParse(_amountController.text) ?? 0}'),
                      const Divider(),
                      
                      if (couponProvider.hasAppliedCoupon) ...[
                        Text('Applied Coupon: ${couponProvider.appliedCoupon!.code}'),
                        Text('Coupon Type: ${couponProvider.appliedCoupon!.type.toString().split('.').last}'),
                        Text('Coupon Value: ${couponProvider.appliedCoupon!.discountValue}'),
                        Text('Discount Amount: \$${couponProvider.discountAmount.toStringAsFixed(2)}'),
                        Text('Final Amount: \$${couponProvider.calculateFinalAmount(double.tryParse(_amountController.text) ?? cartProvider.total).toStringAsFixed(2)}'),
                      ] else ...[
                        const Text('No coupon applied'),
                      ],
                      
                      if (couponProvider.validationMessage != null) ...[
                        const Divider(),
                        Text(
                          'Message: ${couponProvider.validationMessage}',
                          style: TextStyle(
                            color: couponProvider.hasAppliedCoupon ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Manual Calculation Test
                const Text('Manual Calculation Test:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                // Test Buttons
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _testManualCalculation('TEST20', CouponType.percentage, 20),
                      child: const Text('Test 20% Off'),
                    ),
                    ElevatedButton(
                      onPressed: () => _testManualCalculation('FLAT10', CouponType.fixedAmount, 10),
                      child: const Text('Test \$10 Off'),
                    ),
                    ElevatedButton(
                      onPressed: () => couponProvider.removeCoupon(),
                      child: const Text('Clear Coupon'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _testCoupon() async {
    final couponCode = _couponController.text.trim();
    final testAmount = double.tryParse(_amountController.text) ?? 100.0;
    
    if (couponCode.isEmpty) {
      return;
    }

    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    
    print('🧪 Testing coupon: $couponCode with amount: \$${testAmount.toStringAsFixed(2)}');
    
    final success = await couponProvider.applyCoupon(couponCode, testAmount);
    
    print('🧪 Test result: ${success ? "SUCCESS" : "FAILED"}');
    if (success) {
      print('🧪 Discount amount: \$${couponProvider.discountAmount.toStringAsFixed(2)}');
      print('🧪 Final amount: \$${couponProvider.calculateFinalAmount(testAmount).toStringAsFixed(2)}');
    }
  }

  void _testManualCalculation(String code, CouponType type, double value) {
    final testAmount = double.tryParse(_amountController.text) ?? 100.0;
    
    // Create mock coupon for testing
    final mockCoupon = Coupon(
      id: 'test',
      code: code,
      type: type,
      discountValue: value,
      minimumOrderAmount: 0,
      usageLimit: -1,
      usedCount: 0,
      expiryDate: null,
      isActive: true,
      createdBy: 'test',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final discount = mockCoupon.calculateDiscount(testAmount);
    final finalAmount = testAmount - discount;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Manual Test: $code\n'
          'Original: \$${testAmount.toStringAsFixed(2)}\n'
          'Discount: \$${discount.toStringAsFixed(2)}\n'
          'Final: \$${finalAmount.toStringAsFixed(2)}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _couponController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}