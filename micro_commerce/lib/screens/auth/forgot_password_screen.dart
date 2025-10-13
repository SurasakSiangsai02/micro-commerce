import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/theme.dart';
import '../../utils/logger.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

/// 🔐 Forgot Password Screen
/// ระบบรีเซ็ตรหัสผ่านผ่าน Email
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.resetPassword(_emailController.text.trim());
    
    if (success) {
      Logger.info('Password reset email sent successfully for: ${_emailController.text.trim()}');

      setState(() {
        _emailSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลิงก์รีเซ็ตรหัสผ่านถูกส่งไปยังอีเมลของคุณแล้ว'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      Logger.error('Failed to send password reset email: ${authProvider.errorMessage}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: ${authProvider.errorMessage ?? "ไม่สามารถส่งอีเมลได้"}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลืมรหัสผ่าน'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              const SizedBox(height: 40),
              Icon(
                _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                size: 80,
                color: AppTheme.darkGreen,
              ),
              
              const SizedBox(height: 32),
              
              Text(
                _emailSent ? 'ตรวจสอบอีเมลของคุณ' : 'รีเซ็ตรหัสผ่าน',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGreen,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _emailSent 
                    ? 'เราได้ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมล ${_emailController.text} แล้ว กรุณาตรวจสอบกล่องจดหมายและทำตามขั้นตอน'
                    : 'กรอกอีเมลที่ใช้สร้างบัญชี เราจะส่งลิงก์รีเซ็ตรหัสผ่านไปให้คุณ',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Form Section
              if (!_emailSent) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: 'อีเมล',
                        hint: 'กรอกอีเมลของคุณ',
                        validator: _validateEmail,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return CustomButton(
                            text: 'ส่งลิงก์รีเซ็ต',
                            onPressed: authProvider.isLoading 
                                ? null 
                                : _resetPassword,
                            isLoading: authProvider.isLoading,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Success Actions
                CustomButton(
                  text: 'เปิดแอปอีเมล',
                  onPressed: () {
                    Logger.info('User requested to open email app');
                  },
                  backgroundColor: AppTheme.lightBlue,
                ),
                
                const SizedBox(height: 16),
                
                CustomButton(
                  text: 'ส่งอีเมลใหม่',
                  onPressed: () {
                    setState(() {
                      _emailSent = false;
                      _emailController.clear();
                    });
                  },
                  backgroundColor: Colors.grey.shade600,
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Help Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: AppTheme.darkGreen,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ไม่ได้รับอีเมล?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ตรวจสอบในกล่อง Spam/Junk Mail\n'
                      '• ตรวจสอบให้แน่ใจว่าอีเมลถูกต้อง\n'
                      '• รออีเมลสักครู่ อาจใช้เวลา 2-3 นาที\n'
                      '• ลองส่งใหม่หากรอเกิน 5 นาที',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Back to Login Link
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'กลับไปหน้าเข้าสู่ระบบ',
                  style: TextStyle(
                    color: AppTheme.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}