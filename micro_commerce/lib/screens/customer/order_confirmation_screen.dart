import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../models/user.dart' as user_model;

class OrderConfirmationScreen extends StatelessWidget {
  final user_model.Order? order;
  final double? totalAmount;
  final String? paymentMethod;
  
  const OrderConfirmationScreen({
    super.key,
    this.order,
    this.totalAmount,
    this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 48,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Add minimal top spacing
                  const SizedBox(height: 20),
                // Success Icon
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 100,
                ),
                const SizedBox(height: 24),

                // Success Message
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thank you for your purchase. Your order will be delivered soon.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Order Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildOrderDetail(
                        'Order Number', 
                        order?.id != null ? '#${order!.id.substring(0, 8).toUpperCase()}' : '#ORD123456'
                      ),
                      const Divider(height: 24),
                      // Order Summary with breakdown
                      if (order != null) ...[
                        _buildOrderDetail('Subtotal', '\$${order!.subtotal.toStringAsFixed(2)}'),
                        if (order!.hasCoupon) ...[
                          const Divider(height: 16),
                          _buildOrderDetail(
                            'Discount (${order!.couponCode})', 
                            '-\$${order!.discountAmount.toStringAsFixed(2)}',
                            valueColor: Colors.green.shade600,
                          ),
                        ],
                        const Divider(height: 16),
                        _buildOrderDetail('Tax', '\$${order!.tax.toStringAsFixed(2)}'),
                        const Divider(height: 16),
                        _buildOrderDetail(
                          'Total Amount', 
                          '\$${totalAmount != null ? totalAmount!.toStringAsFixed(2) : order!.total.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ] else ...[
                        _buildOrderDetail(
                          'Total Amount', 
                          totalAmount != null ? '\$${totalAmount!.toStringAsFixed(2)}' : '\$0.00'
                        ),
                      ],
                      const Divider(height: 24),
                      _buildOrderDetail(
                        'Payment Method', 
                        paymentMethod ?? 'Credit Card'
                      ),
                      const Divider(height: 24),
                      _buildOrderDetail(
                        'Order Date',
                        order?.createdAt != null 
                            ? DateFormat('dd/MM/yyyy HH:mm').format(order!.createdAt)
                            : DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                      ),
                      const Divider(height: 24),
                      _buildOrderDetail(
                        'Status',
                        order?.status ?? 'Pending',
                      ),
                      const Divider(height: 24),
                      _buildOrderDetail(
                        'Estimated Delivery',
                        '3-5 Business Days',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Order Items (if available)
                if (order?.items != null && order!.items.isNotEmpty) ...
                [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...(order?.items ?? []).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productName} x${item.quantity}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                '\฿${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Add spacing before buttons
                const SizedBox(height: 40),

                // Buttons
                CustomButton(
                  text: 'Track Order',
                  onPressed: () {
                    Navigator.pushNamed(context, '/order-history');
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Continue Shopping',
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  backgroundColor: Colors.white,
                  textColor: AppTheme.darkGreen,
                ),
                // Bottom padding to prevent overflow
                const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value, {Color? valueColor, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isTotal ? AppTheme.darkGreen : Colors.black),
            fontSize: isTotal ? 16 : 14,
          ),
        ),
      ],
    );
  }
}