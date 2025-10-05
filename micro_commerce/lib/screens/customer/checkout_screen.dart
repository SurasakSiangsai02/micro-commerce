import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
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
  
  String _selectedPaymentMethod = 'creditCard';
  bool _isLoading = false;

  void _handleCheckout() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        
        // ตรวจสอบว่าผู้ใช้ล็อกอินแล้วและมีสินค้าในตะกร้า
        if (authProvider.firebaseUser == null) {
          throw Exception('Please login to continue');
        }
        
        if (cartProvider.items.isEmpty) {
          throw Exception('Your cart is empty');
        }
        
        final userId = authProvider.firebaseUser!.uid;
        final cartItems = cartProvider.items;
        final total = cartProvider.total;
        
        // เตรียมข้อมูล shipping address
        final shippingAddress = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        };
        
        // ข้อมูล order
        final orderData = {
          'paymentMethod': _selectedPaymentMethod,
          'shippingAddress': shippingAddress,
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
            amount: total,
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
        
        // สร้าง order object สำหรับส่งไป order confirmation (ใช้ข้อมูลพื้นฐาน)
        user_model.Order? createdOrder;
        createdOrder = user_model.Order(
          id: orderId,
          userId: userId,
          items: cartItems,
          subtotal: cartProvider.subtotal,
          tax: cartProvider.tax,
          total: cartProvider.total,
          status: 'pending',
          paymentMethod: _selectedPaymentMethod == 'creditCard' ? 'Credit Card' : 'Other',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          shippingAddress: {
            'fullName': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
          },
        );
        
        if (mounted) {
          setState(() => _isLoading = false);
          
          // Clear cart หลังจากสั่งซื้อสำเร็จ
          cartProvider.clearCart();
          
          // นำทางไปหน้า order confirmation พร้อมข้อมูล order
          Navigator.pushReplacementNamed(
            context,
            '/order-confirmation',
            arguments: {
              'order': createdOrder,
              'totalAmount': cartProvider.total,
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
                child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return Column(
                      children: [
                        // Order Summary
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
                              '\$${cartProvider.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGreen,
                              ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }
}