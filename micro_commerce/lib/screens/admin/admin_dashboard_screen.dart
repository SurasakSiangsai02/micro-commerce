import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import 'product_management_screen.dart';
import 'order_management_screen.dart';
import 'user_management_screen.dart';
import 'user_role_management_screen.dart';
import 'admin_chat_screen.dart';
import 'analytics_screen.dart';
import 'coupon_management_screen.dart';

/// 🔧 AdminDashboardScreen - หน้า Dashboard สำหรับ Admin
/// 
/// ฟีเจอร์:
/// • ภาพรวมระบบ (สถิติต่างๆ)
/// • จัดการสินค้า (เพิ่ม/แก้ไข/ลบ)
/// • จัดการคำสั่งซื้อ (เปลี่ยนสถานะ)
/// • จัดการผู้ใช้ (ดู/แก้ไขข้อมูล)
/// • รายงานและสถิติ
/// 
/// สิทธิ์การเข้าถึง:
/// - Admin: เข้าถึงได้ทุกฟีเจอร์
/// - Moderator: เข้าถึงได้ยกเว้นการจัดการผู้ใช้
/// - Customer: ไม่สามารถเข้าถึงได้
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userProfile;
        
        // ตรวจสอบสิทธิ์การเข้าถึง
        if (user == null || !user.isModerator) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('ไม่มีสิทธิ์เข้าถึง'),
              backgroundColor: Colors.red,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'คุณไม่มีสิทธิ์เข้าถึงหน้านี้',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ติดต่อผู้ดูแลระบบเพื่อขอสิทธิ์',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('🔧 Admin Dashboard - ${user.role.displayName}'),
            backgroundColor: AppTheme.darkGreen,
            foregroundColor: AppTheme.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                tooltip: 'ออกจากระบบ',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.lightGreen,
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'สวัสดี, ${user.name}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text(
                                    'บทบาท: ${user.role.displayName}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ยินดีต้อนรับสู่ระบบจัดการร้าน Micro Commerce',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Stats Cards
                Text(
                  '📊 สถิติระบบ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '🛍️',
                        'สินค้าทั้งหมด',
                        '0',
                        AppTheme.lightBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '📦',
                        'คำสั่งซื้อวันนี้',
                        '0',
                        AppTheme.lightGreen,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '👥',
                        'ลูกค้าทั้งหมด',
                        '0',
                        AppTheme.lightOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '💰',
                        'ยอดขายวันนี้',
                        '฿0',
                        AppTheme.lightPurple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Management Sections
                Text(
                  '⚙️ การจัดการระบบ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Product Management
                _buildManagementCard(
                  context,
                  '🛍️ จัดการสินค้า',
                  'เพิ่ม แก้ไข ลบสินค้า และจัดการหมวดหมู่',
                  Icons.inventory_2,
                  AppTheme.lightBlue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductManagementScreen(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Order Management
                _buildManagementCard(
                  context,
                  '📦 จัดการคำสั่งซื้อ',
                  'ดูและเปลี่ยนสถานะคำสั่งซื้อ',
                  Icons.shopping_cart,
                  AppTheme.lightGreen,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderManagementScreen(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // User Management (Admin only)
                if (user.isAdmin) ...[
                  _buildManagementCard(
                    context,
                    '👥 จัดการผู้ใช้',
                    'ดูและจัดการข้อมูลผู้ใช้ในระบบ',
                    Icons.people,
                    AppTheme.lightOrange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Admin Role Management
                  _buildManagementCard(
                    context,
                    '🔐 จัดการบทบาทผู้ใช้',
                    'สร้างและจัดการบัญชี Admin/Moderator',
                    Icons.admin_panel_settings,
                    Colors.deepPurple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserRoleManagementScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Chat Management
                _buildManagementCard(
                  context,
                  '💬 จัดการแชท',
                  'ตอบกลับลูกค้า ดูประวัติการสนทนา',
                  Icons.chat,
                  AppTheme.lightBlue,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminChatScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Coupon Management
                _buildManagementCard(
                  context,
                  '🎟️ จัดการคูปอง',
                  'สร้างและจัดการคูปองส่วนลด',
                  Icons.local_offer,
                  Colors.deepOrange,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CouponManagementScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Analytics
                _buildManagementCard(
                  context,
                  '📊 รายงานและสถิติ',
                  'ดูสถิติยอดขาย รายงานต่างๆ',
                  Icons.analytics,
                  AppTheme.lightPurple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalyticsScreen(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Quick Actions
                Text(
                  '⚡ การดำเนินการด่วน',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductManagementScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('เพิ่มสินค้าใหม่'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightBlue,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderManagementScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.notifications),
                        label: const Text('คำสั่งซื้อใหม่'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightGreen,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Debug Tools (Admin only)
                if (user.isAdmin)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/admin/debug'),
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Debug Tools'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightPurple,
                            foregroundColor: AppTheme.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()), // Empty space
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}