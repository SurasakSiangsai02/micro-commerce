import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// 🎯 Confirmation Dialog Widget
/// 
/// Reusable confirmation dialog สำหรับการยืนยันการกระทำต่างๆ
/// เช่น ลบสินค้า, ลบข้อมูล, ออกจากระบบ, etc.
/// 
/// Features:
/// • Customizable title, message, และ actions
/// • Beautiful UI with icons and colors
/// • Accessibility support
/// • Consistent design across the app
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmButtonColor;
  final bool isDanger;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'ยืนยัน',
    this.cancelText = 'ยกเลิก',
    this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmButtonColor,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = isDanger ? AppTheme.errorRed : AppTheme.warningAmber;
    final defaultConfirmColor = isDanger ? AppTheme.errorRed : AppTheme.darkGreen;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Column(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? defaultIconColor).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor ?? defaultIconColor,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Text(
            cancelText,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Confirm Button
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor ?? defaultConfirmColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: Text(
            confirmText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// 🎯 Confirmation Dialog Utilities
/// 
/// Helper functions สำหรับแสดง confirmation dialogs ประเภทต่างๆ
class ConfirmationDialogs {
  
  /// แสดง confirmation dialog ทั่วไป
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'ยืนยัน',
    String cancelText = 'ยกเลิก',
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          icon: icon,
          iconColor: iconColor,
          confirmButtonColor: confirmButtonColor,
          isDanger: isDanger,
        );
      },
    );
  }

  /// แสดง dialog สำหรับลบสินค้าจากตะกร้า
  static Future<bool?> showDeleteFromCartDialog({
    required BuildContext context,
    required String productName,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ลบสินค้าออกจากตะกร้า',
      message: 'คุณต้องการลบ "$productName" ออกจากตะกร้าหรือไม่?',
      confirmText: 'ลบออก',
      cancelText: 'ยกเลิก',
      icon: Icons.remove_shopping_cart_outlined,
      isDanger: true,
    );
  }

  /// แสดง dialog สำหรับลบสินค้าทั้งหมดจากตะกร้า
  static Future<bool?> showClearCartDialog({
    required BuildContext context,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ล้างตะกร้าสินค้า',
      message: 'คุณต้องการลบสินค้าทั้งหมดออกจากตะกร้าหรือไม่?\n\nการดำเนินการนี้ไม่สามารถยกเลิกได้',
      confirmText: 'ล้างทั้งหมด',
      cancelText: 'ยกเลิก',
      icon: Icons.delete_sweep_outlined,
      isDanger: true,
    );
  }

  /// แสดง dialog สำหรับยืนยันการสั่งซื้อ
  static Future<bool?> showCheckoutConfirmDialog({
    required BuildContext context,
    required double totalAmount,
    required String paymentMethod,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ยืนยันการสั่งซื้อ',
      message: 'ยอดรวม: \$${totalAmount.toStringAsFixed(2)}\n'
              'วิธีการชำระเงิน: $paymentMethod\n\n'
              'คุณต้องการดำเนินการสั่งซื้อหรือไม่?',
      confirmText: 'สั่งซื้อ',
      cancelText: 'ยกเลิก',
      icon: Icons.payment_outlined,
      iconColor: AppTheme.successGreen,
      confirmButtonColor: AppTheme.successGreen,
      isDanger: false,
    );
  }

  /// แสดง dialog สำหรับออกจากระบบ
  static Future<bool?> showLogoutDialog({
    required BuildContext context,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ออกจากระบบ',
      message: 'คุณต้องการออกจากระบบหรือไม่?',
      confirmText: 'ออกจากระบบ',
      cancelText: 'ยกเลิก',
      icon: Icons.logout_outlined,
      iconColor: AppTheme.warningAmber,
      confirmButtonColor: AppTheme.warningAmber,
      isDanger: false,
    );
  }

  /// แสดง dialog สำหรับลบผลิตภัณฑ์ (Admin)
  static Future<bool?> showDeleteProductDialog({
    required BuildContext context,
    required String productName,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ลบสินค้า',
      message: 'คุณต้องการลบสินค้า "$productName" หรือไม่?\n\n'
              'การดำเนินการนี้ไม่สามารถยกเลิกได้',
      confirmText: 'ลบสินค้า',
      cancelText: 'ยกเลิก',
      icon: Icons.delete_forever_outlined,
      isDanger: true,
    );
  }

  /// แสดง dialog สำหรับลบผู้ใช้ (Admin)
  static Future<bool?> showDeleteUserDialog({
    required BuildContext context,
    required String userName,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ลบผู้ใช้',
      message: 'คุณต้องการลบผู้ใช้ "$userName" หรือไม่?\n\n'
              'การดำเนินการนี้ไม่สามารถยกเลิกได้',
      confirmText: 'ลบผู้ใช้',
      cancelText: 'ยกเลิก',
      icon: Icons.person_remove_outlined,
      isDanger: true,
    );
  }

  /// แสดง dialog สำหรับยกเลิกคำสั่งซื้อ
  static Future<bool?> showCancelOrderDialog({
    required BuildContext context,
    required String orderId,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ยกเลิกคำสั่งซื้อ',
      message: 'คุณต้องการยกเลิกคำสั่งซื้อ #$orderId หรือไม่?\n\n'
              'หากชำระเงินแล้ว จะทำการคืนเงินภายใน 5-7 วันทำการ',
      confirmText: 'ยกเลิกคำสั่งซื้อ',
      cancelText: 'เก็บไว้',
      icon: Icons.cancel_outlined,
      iconColor: AppTheme.warningAmber,
      confirmButtonColor: AppTheme.warningAmber,
      isDanger: false,
    );
  }

  /// แสดง dialog สำหรับลบห้องแชท
  static Future<bool?> showDeleteChatRoomDialog({
    required BuildContext context,
    String? customerName,
  }) {
    final displayName = customerName?.isNotEmpty == true ? customerName! : 'ร้านค้า';
    
    return showConfirmDialog(
      context: context,
      title: 'ลบการสนทนา',
      message: 'คุณต้องการลบการสนทนากับ "$displayName" หรือไม่?\n\n'
              'การสนทนาจะหายไปจากรายการของคุณ แต่ร้านค้ายังสามารถดูได้',
      confirmText: 'ลบการสนทนา',
      cancelText: 'ยกเลิก',
      icon: Icons.chat_bubble_outline,
      iconColor: AppTheme.errorRed,
      confirmButtonColor: AppTheme.errorRed,
      isDanger: true,
    );
  }

  /// แสดง dialog สำหรับลบข้อความในแชท
  static Future<bool?> showDeleteChatMessageDialog({
    required BuildContext context,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ลบข้อความ',
      message: 'คุณต้องการลบข้อความนี้หรือไม่?\n\nข้อความจะถูกลบออกจากการสนทนา',
      confirmText: 'ลบข้อความ',
      cancelText: 'ยกเลิก',
      icon: Icons.delete_outline,
      isDanger: true,
    );
  }

  /// แสดง dialog สำหรับออกจากห้องแชท
  static Future<bool?> showLeaveChatRoomDialog({
    required BuildContext context,
  }) {
    return showConfirmDialog(
      context: context,
      title: 'ออกจากการสนทนา',
      message: 'คุณต้องการออกจากการสนทนานี้หรือไม่?\n\nคุณสามารถกลับมาสนทนาได้ใหม่ภายหลัง',
      confirmText: 'ออกจากการสนทนา',
      cancelText: 'อยู่ต่อ',
      icon: Icons.exit_to_app_outlined,
      iconColor: AppTheme.warningAmber,
      confirmButtonColor: AppTheme.warningAmber,
      isDanger: false,
    );
  }
}