import 'package:flutter/material.dart';
import '../../utils/admin_test_data_seeder.dart';

/// 🛠️ AdminDebugScreen - หน้าจอสำหรับดีบักและทดสอบระบบ Admin
/// 
/// ฟีเจอร์:
/// • สร้างข้อมูลทดสอบ Admin/Moderator users
/// • สร้างสินค้าที่มี Product Variants
/// • สร้างคำสั่งซื้อตัวอย่าง
/// • ลบข้อมูลทดสอบ
class AdminDebugScreen extends StatefulWidget {
  const AdminDebugScreen({super.key});

  @override
  State<AdminDebugScreen> createState() => _AdminDebugScreenState();
}

class _AdminDebugScreenState extends State<AdminDebugScreen> {
  bool _isSeeding = false;
  bool _isClearing = false;

  /// 🌱 สร้างข้อมูลทดสอบทั้งหมด
  Future<void> _seedTestData() async {
    setState(() {
      _isSeeding = true;
    });

    try {
      await AdminTestDataSeeder.seedAllTestData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ สร้างข้อมูลทดสอบเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  /// 🧹 ลบข้อมูลทดสอบทั้งหมด
  Future<void> _clearTestData() async {
    // แสดง confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ยืนยันการลบข้อมูล'),
        content: const Text(
          'คุณต้องการลบข้อมูลทดสอบทั้งหมดใช่หรือไม่?\n\n'
          'การดำเนินการนี้ไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ลบข้อมูล'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isClearing = true;
    });

    try {
      await AdminTestDataSeeder.clearTestData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ลบข้อมูลทดสอบเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠️ Admin Debug Tools'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.bug_report,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin Debug Tools',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เครื่องมือสำหรับสร้างและจัดการข้อมูลทดสอบ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Data Section
            Text(
              '📊 จัดการข้อมูลทดสอบ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Seed Test Data Button
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: const Text('สร้างข้อมูลทดสอบ'),
                subtitle: const Text(
                  'สร้าง Admin/Moderator users, สินค้าที่มี variants, และคำสั่งซื้อตัวอย่าง',
                ),
                trailing: _isSeeding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap: _isSeeding ? null : _seedTestData,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Clear Test Data Button
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('ลบข้อมูลทดสอบ'),
                subtitle: const Text(
                  'ลบข้อมูลทดสอบทั้งหมดออกจากระบบ',
                ),
                trailing: _isClearing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap: _isClearing ? null : _clearTestData,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'ข้อมูลที่จะถูกสร้าง',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('👤 Admin User: admin@microcommerce.com'),
                    const Text('👥 Moderator User: moderator@microcommerce.com'),
                    const Text('👕 เสื้อยืดที่มี variants (สี, ขนาด)'),
                    const Text('👟 รองเท้าที่มี variants (สี, ขนาด)'),
                    const Text('📦 คำสั่งซื้อตัวอย่าง 3 รายการ'),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Warning Card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⚠️ เครื่องมือนี้ใช้สำหรับการทดสอบเท่านั้น\nไม่ควรใช้ในระบบจริง',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}