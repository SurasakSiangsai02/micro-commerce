import 'package:flutter/material.dart';
import '../models/product_variant.dart';
import '../utils/theme.dart';

/// 🎨 ProductVariantSelector - Widget สำหรับเลือกตัวเลือกสินค้า
/// 
/// ฟีเจอร์:
/// • เลือกสี (แสดงเป็นวงกลมสี)
/// • เลือกขนาด (แสดงเป็นปุ่ม)
/// • เลือกแบบ/สไตล์ (แสดงเป็น dropdown หรือ chips)
/// • แสดงราคาและสต็อกของตัวเลือกที่เลือก
/// • ตรวจสอบการมีสต็อก
class ProductVariantSelector extends StatefulWidget {
  final ProductWithVariants product;
  final Map<String, String> selectedAttributes;
  final ValueChanged<Map<String, String>> onSelectionChanged;
  final ValueChanged<ProductVariant?> onVariantSelected;

  const ProductVariantSelector({
    super.key,
    required this.product,
    required this.selectedAttributes,
    required this.onSelectionChanged,
    required this.onVariantSelected,
  });

  @override
  State<ProductVariantSelector> createState() => _ProductVariantSelectorState();
}

class _ProductVariantSelectorState extends State<ProductVariantSelector> {
  late Map<String, String> _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = Map.from(widget.selectedAttributes);
    _updateVariantSelection();
  }

  @override
  void didUpdateWidget(ProductVariantSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAttributes != widget.selectedAttributes) {
      _currentSelection = Map.from(widget.selectedAttributes);
      _updateVariantSelection();
    }
  }

  void _updateVariantSelection() {
    try {
      final variant = widget.product.findVariant(_currentSelection);
      widget.onVariantSelected(variant);
    } catch (e) {
      widget.onVariantSelected(null);
    }
  }

  void _updateSelection(String type, String value) {
    setState(() {
      _currentSelection[type] = value;
    });
    widget.onSelectionChanged(_currentSelection);
    _updateVariantSelection();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.product.hasVariants) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.product.variantOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildVariantOption(option),
          );
        }),
        
        // แสดงข้อมูลตัวเลือกที่เลือก
        _buildSelectedVariantInfo(),
      ],
    );
  }

  Widget _buildVariantOption(VariantOption option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          option.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        if (option.type == 'color')
          _buildColorSelector(option)
        else if (option.type == 'size')
          _buildSizeSelector(option)
        else
          _buildDefaultSelector(option),
      ],
    );
  }

  Widget _buildColorSelector(VariantOption option) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: option.values.map((value) {
        final isSelected = _currentSelection[option.type] == value.value;
        final isAvailable = _isValueAvailable(option.type, value.value);
        
        return GestureDetector(
          onTap: isAvailable ? () => _updateSelection(option.type, value.value) : null,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value.colorCode != null
                  ? Color(int.parse(value.colorCode!.replaceFirst('#', '0xff')))
                  : Colors.grey,
              border: Border.all(
                color: isSelected ? AppTheme.darkGreen : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeSelector(VariantOption option) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: option.values.map((value) {
        final isSelected = _currentSelection[option.type] == value.value;
        final isAvailable = _isValueAvailable(option.type, value.value);
        
        return GestureDetector(
          onTap: isAvailable ? () => _updateSelection(option.type, value.value) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.darkGreen : Colors.white,
              border: Border.all(
                color: isSelected ? AppTheme.darkGreen : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isAvailable ? Colors.black : Colors.grey),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDefaultSelector(VariantOption option) {
    final selectedValue = _currentSelection[option.type];
    
    // ตรวจสอบว่า selectedValue อยู่ใน available options หรือไม่
    final availableValues = option.values.where((v) => _isValueAvailable(option.type, v.value)).map((v) => v.value).toList();
    final validSelectedValue = (selectedValue != null && availableValues.contains(selectedValue)) ? selectedValue : null;
    
    return DropdownButton<String>(
      value: validSelectedValue,
      hint: Text('เลือก${option.name}'),
      isExpanded: true,
      onChanged: (value) {
        if (value != null && _isValueAvailable(option.type, value)) {
          _updateSelection(option.type, value);
        }
      },
      items: option.values.map((value) {
        final isAvailable = _isValueAvailable(option.type, value.value);
        
        return DropdownMenuItem<String>(
          value: value.value,
          enabled: isAvailable,
          child: Text(
            value.label,
            style: TextStyle(
              color: isAvailable ? Colors.black : Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedVariantInfo() {
    try {
      final variant = widget.product.findVariant(_currentSelection);
      if (variant == null) {
        throw Exception('Variant not found');
      }
      final finalPrice = variant.getFinalPrice(widget.product.basePrice);
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ตัวเลือกที่เลือก:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '฿${finalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              variant.displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  size: 16,
                  color: variant.inStock ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  variant.inStock
                      ? 'คงเหลือ: ${variant.stock} ชิ้น'
                      : 'สินค้าหมด',
                  style: TextStyle(
                    color: variant.inStock ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (variant.isLowStock) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'สต็อกต่ำ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'กรุณาเลือกตัวเลือกให้ครบถ้วน',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  bool _isValueAvailable(String optionType, String value) {
    // สร้าง temporary selection
    final tempSelection = Map<String, String>.from(_currentSelection);
    tempSelection[optionType] = value;
    
    // ตรวจสอบว่ามี variant ที่มีตัวเลือกนี้และมีสต็อกหรือไม่
    return widget.product.variants.any((variant) {
      // ตรวจสอบว่า variant นี้ตรงกับ selection หรือไม่
      bool matches = true;
      for (final entry in tempSelection.entries) {
        if (variant.attributes[entry.key] != entry.value) {
          matches = false;
          break;
        }
      }
      
      return matches && variant.isAvailable && variant.inStock;
    });
  }
}

/// 📋 VariantOptionChip - Chip สำหรับแสดงตัวเลือกเดี่ยว
class VariantOptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;
  final Color? color;

  const VariantOptionChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.isAvailable = true,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppTheme.darkGreen)
              : (isAvailable ? Colors.white : Colors.grey[100]),
          border: Border.all(
            color: isSelected
                ? (color ?? AppTheme.darkGreen)
                : (isAvailable ? Colors.grey[300]! : Colors.grey[200]!),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isAvailable ? Colors.black : Colors.grey),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}