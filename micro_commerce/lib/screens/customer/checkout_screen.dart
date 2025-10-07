import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/coupon_provider.dart';
import '../../services/payment_service.dart';
import '../../services/database_service.dart';
import '../../models/user.dart' as user_model;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Credit Card Controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardHolderController = TextEditingController();
  
  // Coupon Controller
  final _couponController = TextEditingController();
  
  String _selectedPaymentMethod = 'creditCard';
  bool _isLoading = false;

  void _handleCheckout() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final couponProvider = Provider.of<CouponProvider>(context, listen: false);
        
        // ตรวจสอบว่าผู้ใช้ล็อกอินแล้วและมีสินค้าในตะกร้า
        if (authProvider.firebaseUser == null) {
          throw Exception('Please login to continue');
        }
        
        if (cartProvider.items.isEmpty) {
          throw Exception('Your cart is empty');
        }
        
        final userId = authProvider.firebaseUser!.uid;
        final cartItems = cartProvider.items;
        final originalTotal = cartProvider.total;
        final discountAmount = couponProvider.discountAmount;
        final subtotalAfterDiscount = originalTotal - discountAmount;
        final taxRate = 0.08; // 8% tax
        final taxAmount = subtotalAfterDiscount * taxRate;
        final finalTotal = subtotalAfterDiscount + taxAmount;
        
        // เตรียมข้อมูล shipping address
        final shippingAddress = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        };
        
        // ข้อมูล order รวมข้อมูลคูปอง
        final orderData = {
          'paymentMethod': _selectedPaymentMethod,
          'shippingAddress': shippingAddress,
          'originalTotal': originalTotal,
          'discountAmount': discountAmount,
          'finalTotal': finalTotal,
          'couponCode': couponProvider.appliedCoupon?.code,
          'couponId': couponProvider.appliedCoupon?.id,
        };
        
        String? orderId;
        
        if (_selectedPaymentMethod == 'creditCard') {
          // ตรวจสอบว่าใส่ข้อมูลบัตรครบหรือไม่
          if (_cardNumberController.text.isEmpty || 
              _expiryController.text.isEmpty || 
              _cvcController.text.isEmpty ||
              _cardHolderController.text.isEmpty) {
            throw Exception('Please fill in all card details');
          }
          
          // Validate card number format
          final cardNumber = _cardNumberController.text.replaceAll(' ', '');
          if (cardNumber.length != 16 || !RegExp(r'^\d+$').hasMatch(cardNumber)) {
            throw Exception('Please enter a valid 16-digit card number');
          }
          
          // Validate expiry date
          final expiry = _expiryController.text;
          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) {
            throw Exception('Please enter expiry date in MM/YY format');
          }
          
          // Check if card is not expired
          final parts = expiry.split('/');
          final month = int.parse(parts[0]);
          final year = int.parse('20${parts[1]}');
          final now = DateTime.now();
          final expiryDate = DateTime(year, month + 1, 0); // Last day of expiry month
          
          if (expiryDate.isBefore(now)) {
            throw Exception('Card has expired');
          }
          
          if (month < 1 || month > 12) {
            throw Exception('Please enter a valid month (01-12)');
          }
          
          // ชำระเงินด้วย Stripe - ใช้วิธีง่ายๆ
          final userProfile = authProvider.userProfile;
          String customerId;
          
          try {
            customerId = await PaymentService.instance.createCustomer(
              email: userProfile?.email ?? authProvider.firebaseUser!.email!,
              name: userProfile?.name ?? 'User',
              phone: userProfile?.phone,
            );
          } catch (e) {
            // หาก customer มีอยู่แล้วใน Stripe ให้ใช้ email เป็น ID
            customerId = authProvider.firebaseUser!.email!;
          }
          
          // สร้าง Payment Intent
          final paymentIntentData = await PaymentService.instance.createPaymentIntent(
            amount: finalTotal,
            currency: 'usd',
            customerId: customerId,
          );
          
          // สำหรับ demo ถือว่าการชำระเงินสำเร็จเสมอ (test mode)
          orderId = await DatabaseService.createOrderWithPayment(
            userId, 
            cartItems, 
            {
              ...orderData,
              'paymentIntentId': paymentIntentData['id'],
              'paymentMethod': 'credit_card',
              'cardInfo': {
                'last4': _cardNumberController.text.substring(_cardNumberController.text.length - 4),
                'cardHolder': _cardHolderController.text.trim(),
              }
            }
          );
          
        } else {
          // การชำระเงินแบบอื่น (Bank Transfer, COD)
          orderId = await DatabaseService.createOrderWithPayment(
            userId, 
            cartItems, 
            orderData
          );
        }
        
        // ยืนยันการใช้คูปอง (เพิ่มจำนวนการใช้งาน)
        if (couponProvider.hasAppliedCoupon) {
          await couponProvider.confirmCouponUsage();
        }
        
        // สร้าง order object สำหรับส่งไป order confirmation (ใช้ข้อมูลพื้นฐาน)
        user_model.Order? createdOrder;
        createdOrder = user_model.Order(
          id: orderId,
          userId: userId,
          items: cartItems,
          subtotal: originalTotal,
          tax: taxAmount,
          total: finalTotal,
          status: 'pending',
          paymentMethod: _selectedPaymentMethod == 'creditCard' ? 'Credit Card' : 'Other',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          shippingAddress: {
            'fullName': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
          },
          couponCode: couponProvider.appliedCoupon?.code,
          couponId: couponProvider.appliedCoupon?.id,
          discountAmount: discountAmount,
        );
        
        if (mounted) {
          setState(() => _isLoading = false);
          
          // Clear cart และคูปองหลังจากสั่งซื้อสำเร็จ
          cartProvider.clearCart();
          couponProvider.removeCoupon();
          
          // นำทางไปหน้า order confirmation พร้อมข้อมูล order
          Navigator.pushReplacementNamed(
            context,
            '/order-confirmation',
            arguments: {
              'order': createdOrder,
              'totalAmount': finalTotal,
              'paymentMethod': _selectedPaymentMethod == 'creditCard' ? 'Credit Card' : 'Other',
            },
          );
        }
        
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Checkout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Widget _buildCreditCardForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGreen,
            ),
          ),
          const SizedBox(height: 16),
          
          // Card Holder Name
          CustomTextField(
            label: 'Cardholder Name',
            hint: 'Enter name on card',
            controller: _cardHolderController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Card Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Card Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 19, // 16 digits + 3 spaces
                decoration: InputDecoration(
                  hintText: '1234 5678 9012 3456',
                  counterText: '', // Hide character counter
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppTheme.darkGreen,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  // Format card number with spaces
                  String formatted = value.replaceAll(' ', '');
                  if (formatted.length > 16) {
                    formatted = formatted.substring(0, 16);
                  }
                  
                  String formattedWithSpaces = '';
                  for (int i = 0; i < formatted.length; i++) {
                    if (i > 0 && i % 4 == 0) {
                      formattedWithSpaces += ' ';
                    }
                    formattedWithSpaces += formatted[i];
                  }
                  
                  if (formattedWithSpaces != value) {
                    _cardNumberController.value = TextEditingValue(
                      text: formattedWithSpaces,
                      selection: TextSelection.collapsed(offset: formattedWithSpaces.length),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  final cleanNumber = value.replaceAll(' ', '');
                  if (cleanNumber.length != 16) {
                    return 'Card number must be 16 digits';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
                    return 'Card number must contain only digits';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // Expiry Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expiry Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      maxLength: 5, // MM/YY
                      decoration: InputDecoration(
                        hintText: 'MM/YY',
                        counterText: '', // Hide character counter
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.darkGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        // Format expiry date MM/YY
                        String formatted = value.replaceAll('/', '');
                        if (formatted.length > 4) {
                          formatted = formatted.substring(0, 4);
                        }
                        
                        if (formatted.length >= 2) {
                          formatted = '${formatted.substring(0, 2)}/${formatted.substring(2)}';
                        }
                        
                        if (formatted != value) {
                          _expiryController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return 'Format: MM/YY';
                        }
                        
                        final parts = value.split('/');
                        final month = int.tryParse(parts[0]);
                        final year = int.tryParse('20${parts[1]}');
                        
                        if (month == null || year == null) {
                          return 'Invalid date format';
                        }
                        
                        if (month < 1 || month > 12) {
                          return 'Invalid month';
                        }
                        
                        final now = DateTime.now();
                        final expiryDate = DateTime(year, month + 1, 0);
                        
                        if (expiryDate.isBefore(now)) {
                          return 'Card has expired';
                        }
                        
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // CVC
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CVC',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        hintText: '123',
                        counterText: '', // Hide character counter
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.darkGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        // Only allow numbers
                        if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
                          _cvcController.text = value.replaceAll(RegExp(r'[^\d]'), '');
                          _cvcController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _cvcController.text.length),
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVC';
                        }
                        if (value.length < 3 || value.length > 4) {
                          return 'CVC must be 3-4 digits';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'CVC must contain only digits';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.security,
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your card information is encrypted and secure',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่า CouponProvider พร้อมใช้งาน
    final couponProvider = Provider.of<CouponProvider?>(context, listen: false);
    if (couponProvider == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: AppTheme.darkGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.darkGreen,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shipping Information
                    const Text(
                      'Shipping Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter your phone number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.darkGreen,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shipping Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter your shipping address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppTheme.darkGreen,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Credit Card Option
                    Card(
                      child: Column(
                        children: [
                          RadioListTile(
                            title: const Row(
                              children: [
                                Icon(Icons.credit_card, color: AppTheme.darkGreen),
                                SizedBox(width: 12),
                                Text('Credit Card'),
                              ],
                            ),
                            subtitle: const Text('Pay with Visa, Mastercard, etc.'),
                            value: 'creditCard',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value.toString();
                              });
                            },
                          ),
                          // แสดง Card Form เมื่อเลือก Credit Card
                          if (_selectedPaymentMethod == 'creditCard')
                            _buildCreditCardForm(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Bank Transfer Option
                    Card(
                      child: RadioListTile(
                        title: const Row(
                          children: [
                            Icon(Icons.account_balance, color: AppTheme.darkGreen),
                            SizedBox(width: 12),
                            Text('Bank Transfer'),
                          ],
                        ),
                        subtitle: const Text('Transfer to bank account'),
                        value: 'bankTransfer',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value.toString();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Cash on Delivery Option
                    Card(
                      child: RadioListTile(
                        title: const Row(
                          children: [
                            Icon(Icons.payments_outlined, color: AppTheme.darkGreen),
                            SizedBox(width: 12),
                            Text('Cash on Delivery'),
                          ],
                        ),
                        subtitle: const Text('Pay when receiving products'),
                        value: 'cod',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Coupon Section
            _buildCouponSection(),

            // Order Summary and Place Order Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                child: Consumer2<CartProvider, CouponProvider>(
                  builder: (context, cartProvider, couponProvider, child) {
                    final originalTotal = cartProvider.total;
                    final discountAmount = couponProvider.discountAmount;
                    final subtotalAfterDiscount = originalTotal - discountAmount;
                    final taxRate = 0.08; // 8% tax
                    final taxAmount = subtotalAfterDiscount * taxRate;
                    final finalTotal = subtotalAfterDiscount + taxAmount;
                    
                    return Column(
                      children: [
                        // Order Summary
                        Column(
                          children: [
                            // Subtotal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '\$${originalTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            
                            // Discount (if applied)
                            if (couponProvider.hasAppliedCoupon) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Discount (${couponProvider.appliedCoupon!.code})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  Text(
                                    '-\$${discountAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            // Tax
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tax (8%)',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '\$${taxAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            
                            // Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${finalTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Place Order Button
                        CustomButton(
                          text: 'Place Order',
                          onPressed: _handleCheckout,
                          isLoading: _isLoading,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎟️ Coupon Section
  Widget _buildCouponSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      color: Colors.orange.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ใส่รหัสคูปอง',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Applied Coupon Display
                if (couponProvider.hasAppliedCoupon) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'คูปอง ${couponProvider.appliedCoupon!.code} ถูกใช้แล้ว',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                'ประหยัดได้ \$${couponProvider.discountAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            couponProvider.removeCoupon();
                            _couponController.clear();
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          tooltip: 'ยกเลิกคูปอง',
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Coupon Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'ใส่รหัสคูปอง',
                            prefixIcon: const Icon(Icons.local_offer_outlined),
                            border: const OutlineInputBorder(),
                            enabled: !couponProvider.isValidating,
                          ),
                          onChanged: (value) {
                            // Convert to uppercase automatically
                            _couponController.text = value.toUpperCase();
                            _couponController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _couponController.text.length),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: couponProvider.isValidating ? null : _applyCoupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: couponProvider.isValidating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'ใช้',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                        ),
                      ),
                    ],
                  ),

                  // Validation Message
                  if (couponProvider.validationMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: couponProvider.appliedCoupon != null
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: couponProvider.appliedCoupon != null
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            couponProvider.appliedCoupon != null
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                            size: 16,
                            color: couponProvider.appliedCoupon != null
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              couponProvider.validationMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: couponProvider.appliedCoupon != null
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🎟️ Apply Coupon
  void _applyCoupon() async {
    final couponCode = _couponController.text.trim();
    if (couponCode.isEmpty) {
      return;
    }

    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    final success = await couponProvider.applyCoupon(couponCode, cartProvider.total);
    
    if (success) {
      // Clear input on success
      _couponController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardHolderController.dispose();
    _couponController.dispose();
    super.dispose();
  }
}