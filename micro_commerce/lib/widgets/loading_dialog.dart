import 'package:flutter/material.dart';

/// 🚨 LoadingDialog - Dialog สำหรับแสดง loading state
/// 
/// ฟีเจอร์:
/// • แสดง CircularProgressIndicator
/// • ป้องกันการปิด dialog โดยการกด back
/// • รองรับ custom message และ timeout
/// • จัดการ context อย่างปลอดภัย
class LoadingDialog {
  static bool _isShowing = false;
  static late BuildContext _dialogContext;

  /// แสดง loading dialog
  static void show(
    BuildContext context, {
    String message = 'กำลังดำเนินการ...',
    Duration? timeout,
  }) {
    if (_isShowing) return; // ป้องกันการแสดง dialog ซ้ำ
    
    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return PopScope(
          canPop: false, // ป้องกันการปิด dialog โดยการกด back
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Auto close หาก timeout
    if (timeout != null) {
      Future.delayed(timeout, () {
        if (_isShowing) {
          hide();
        }
      });
    }
  }

  /// ปิด loading dialog
  static void hide() {
    if (!_isShowing) return;
    
    try {
      _isShowing = false;
      Navigator.pop(_dialogContext);
    } catch (e) {
      // Dialog อาจถูกปิดไปแล้ว
      _isShowing = false;
    }
  }

  /// ตรวจสอบว่า dialog กำลังแสดงอยู่หรือไม่
  static bool get isShowing => _isShowing;
}