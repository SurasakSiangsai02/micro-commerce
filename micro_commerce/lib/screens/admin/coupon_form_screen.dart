import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/coupon.dart';
import '../../utils/theme.dart';

/// 🎟️ CouponFormScreen - ฟอร์มสร้าง/แก้ไขคูปอง
/// 
/// ฟีเจอร์:
/// • สร้างคูปองใหม่
/// • แก้ไขคูปองที่มีอยู่
/// • เลือกประเภทส่วนลด
/// • ตั้งค่าเงื่อนไขการใช้งาน
/// • สร้างรหัสอัตโนมัติ
class CouponFormScreen extends StatefulWidget {
  final Coupon? coupon;

  const CouponFormScreen({super.key, this.coupon});

  @override
  State<CouponFormScreen> createState() => _CouponFormScreenState();
}

class _CouponFormScreenState extends State<CouponFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  final _minimumAmountController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _descriptionController = TextEditingController();

  CouponType _selectedType = CouponType.percentage;
  DateTime? _expiryDate;
  bool _isActive = true;
  bool _isUnlimited = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      _loadCouponData();
    }
  }

  void _loadCouponData() {
    final coupon = widget.coupon!;
    _codeController.text = coupon.code;
    _discountController.text = coupon.discountValue.toString();
    _minimumAmountController.text = coupon.minimumOrderAmount.toString();
    _usageLimitController.text = coupon.usageLimit >= 0 ? coupon.usageLimit.toString() : '';
    _descriptionController.text = coupon.description ?? '';
    
    _selectedType = coupon.type;
    _expiryDate = coupon.expiryDate;
    _isActive = coupon.isActive;
    _isUnlimited = coupon.usageLimit < 0;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    _minimumAmountController.dispose();
    _usageLimitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.coupon != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '✏️ แก้ไขคูปอง' : '➕ สร้างคูปองใหม่'),
        backgroundColor: AppTheme.lightPurple,
        foregroundColor: Colors.white,
        actions: [
          if (!isEditing)
            IconButton(
              onPressed: _generateRandomCode,
              icon: const Icon(Icons.shuffle),
              tooltip: 'สร้างรหัสแบบสุ่ม',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coupon Code
              _buildSectionTitle('รหัสคูปอง'),
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'รหัสคูปอง',
                  hintText: 'เช่น SAVE20, WELCOME10',
                  prefixIcon: const Icon(Icons.local_offer),
                  border: const OutlineInputBorder(),
                  suffixIcon: !isEditing ? IconButton(
                    onPressed: _generateRandomCode,
                    icon: const Icon(Icons.shuffle),
                    tooltip: 'สร้างรหัสแบบสุ่ม',
                  ) : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณาใส่รหัสคูปอง';
                  }
                  if (value.length < 3 || value.length > 20) {
                    return 'รหัสคูปองต้องมีความยาว 3-20 ตัวอักษร';
                  }
                  final regex = RegExp(r'^[A-Z0-9]+$');
                  if (!regex.hasMatch(value.toUpperCase())) {
                    return 'รหัสคูปองต้องเป็นตัวอักษรภาษาอังกฤษและตัวเลขเท่านั้น';
                  }
                  return null;
                },
                onChanged: (value) {
                  _codeController.text = value.toUpperCase();
                  _codeController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _codeController.text.length),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Discount Type and Value
              _buildSectionTitle('ประเภทส่วนลด'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<CouponType>(
                      title: const Text('เปอร์เซ็นต์'),
                      subtitle: const Text('% ของยอดรวม'),
                      value: CouponType.percentage,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<CouponType>(
                      title: const Text('จำนวนเงิน'),
                      subtitle: const Text('บาทคงที่'),
                      value: CouponType.fixedAmount,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _selectedType == CouponType.percentage 
                    ? 'เปอร์เซ็นต์ส่วนลด'
                    : 'จำนวนเงินส่วนลด',
                  hintText: _selectedType == CouponType.percentage 
                    ? '10 (สำหรับ 10%)'
                    : '50 (สำหรับ 50 บาท)',
                  prefixIcon: Icon(_selectedType == CouponType.percentage 
                    ? Icons.percent 
                    : Icons.attach_money),
                  border: const OutlineInputBorder(),
                  suffixText: _selectedType == CouponType.percentage ? '%' : 'บาท',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณาใส่มูลค่าส่วนลด';
                  }
                  final discount = double.tryParse(value);
                  if (discount == null || discount <= 0) {
                    return 'มูลค่าส่วนลดต้องมากกว่า 0';
                  }
                  if (_selectedType == CouponType.percentage && discount > 100) {
                    return 'เปอร์เซ็นต์ส่วนลดต้องไม่เกิน 100%';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Minimum Order Amount
              _buildSectionTitle('เงื่อนไขการใช้งาน'),
              TextFormField(
                controller: _minimumAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ยอดขั้นต่ำ (ไม่บังคับ)',
                  hintText: '0 หรือว่างเปล่า (ไม่มีขั้นต่ำ)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  suffixText: 'บาท',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'ยอดขั้นต่ำต้องเป็นตัวเลขไม่ติดลบ';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Usage Limit
              Row(
                children: [
                  Checkbox(
                    value: _isUnlimited,
                    onChanged: (value) {
                      setState(() {
                        _isUnlimited = value!;
                        if (_isUnlimited) {
                          _usageLimitController.clear();
                        }
                      });
                    },
                  ),
                  const Text('ไม่จำกัดจำนวนครั้งที่ใช้'),
                ],
              ),

              if (!_isUnlimited) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _usageLimitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'จำนวนครั้งที่ใช้ได้',
                    hintText: 'เช่น 100',
                    prefixIcon: Icon(Icons.confirmation_number),
                    border: OutlineInputBorder(),
                    suffixText: 'ครั้ง',
                  ),
                  validator: (value) {
                    if (!_isUnlimited) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณาใส่จำนวนครั้งที่ใช้ได้';
                      }
                      final limit = int.tryParse(value);
                      if (limit == null || limit <= 0) {
                        return 'จำนวนครั้งต้องมากกว่า 0';
                      }
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Expiry Date
              _buildSectionTitle('วันหมดอายุ (ไม่บังคับ)'),
              InkWell(
                onTap: _selectExpiryDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _expiryDate != null
                          ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                          : 'เลือกวันหมดอายุ (ไม่บังคับ)',
                        style: TextStyle(
                          color: _expiryDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      if (_expiryDate != null)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _expiryDate = null;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          tooltip: 'ลบวันหมดอายุ',
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Description
              _buildSectionTitle('คำอธิบาย (ไม่บังคับ)'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'คำอธิบายคูปอง',
                  hintText: 'เช่น ส่วนลดพิเศษสำหรับลูกค้าใหม่',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Active Status
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value!;
                      });
                    },
                  ),
                  const Text('เปิดใช้งานทันที'),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'บันทึกการแก้ไข' : 'สร้างคูปอง',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _generateRandomCode() {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final randomCode = couponProvider.generateCouponCode();
    _codeController.text = randomCode;
  }

  void _selectExpiryDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  void _saveCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      bool success;
      
      if (widget.coupon != null) {
        // Update existing coupon
        final updatedCoupon = widget.coupon!.copyWith(
          code: _codeController.text.toUpperCase(),
          type: _selectedType,
          discountValue: double.parse(_discountController.text),
          minimumOrderAmount: _minimumAmountController.text.isEmpty 
            ? 0.0 
            : double.parse(_minimumAmountController.text),
          usageLimit: _isUnlimited 
            ? -1 
            : int.parse(_usageLimitController.text),
          expiryDate: _expiryDate,
          isActive: _isActive,
          description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
          updatedAt: DateTime.now(),
        );
        
        success = await couponProvider.updateCoupon(widget.coupon!.id, updatedCoupon);
      } else {
        // Create new coupon
        success = await couponProvider.createCoupon(
          code: _codeController.text.toUpperCase(),
          type: _selectedType,
          discountValue: double.parse(_discountController.text),
          minimumOrderAmount: _minimumAmountController.text.isEmpty 
            ? 0.0 
            : double.parse(_minimumAmountController.text),
          usageLimit: _isUnlimited 
            ? -1 
            : int.parse(_usageLimitController.text),
          expiryDate: _expiryDate,
          isActive: _isActive,
          createdBy: authProvider.userProfile?.uid ?? 'unknown',
          description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.coupon != null 
                ? 'แก้ไขคูปองเรียบร้อยแล้ว!' 
                : 'สร้างคูปองเรียบร้อยแล้ว!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(couponProvider.error ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}