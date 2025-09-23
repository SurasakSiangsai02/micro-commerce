import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      _buildOrderDetail('Order Number', '#ORD123456'),
                      const Divider(height: 24),
                      _buildOrderDetail('Total Amount', '\$199.98'),
                      const Divider(height: 24),
                      _buildOrderDetail('Payment Method', 'Credit Card'),
                      const Divider(height: 24),
                      _buildOrderDetail(
                        'Estimated Delivery',
                        '3-5 Business Days',
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Buttons
                CustomButton(
                  text: 'Track Order',
                  onPressed: () {
                    // TODO: Implement order tracking
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}