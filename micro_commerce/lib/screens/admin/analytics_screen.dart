import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../models/user.dart' as user_model;

/// 📊 AnalyticsScreen - หน้ารายงานและสถิติสำหรับ Admin
/// 
/// ฟีเจอร์:
/// • สถิติยอดขายรายวัน/รายเดือน
/// • สินค้าขายดี
/// • สถิติผู้ใช้
/// • สถิติคำสั่งซื้อตามสถานะ
/// • กราฟแสดงผลต่างๆ
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'วันนี้';
  final List<String> _periods = ['วันนี้', 'สัปดาห์นี้', 'เดือนนี้', 'ปีนี้'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userProfile;
        
        if (user == null || !user.isModerator) {
          return _buildAccessDenied();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('📊 รายงานและสถิติ'),
            backgroundColor: AppTheme.lightPurple,
            foregroundColor: AppTheme.white,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                },
                itemBuilder: (context) => _periods
                    .map((period) => PopupMenuItem(
                          value: period,
                          child: Row(
                            children: [
                              Icon(
                                _selectedPeriod == period
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(period),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 12),
                        Text(
                          'ข้อมูล: $_selectedPeriod',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getPeriodDescription(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sales Statistics
                Text(
                  '💰 สstatistics การขาย',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sales Cards
                StreamBuilder<QuerySnapshot>(
                  stream: _getOrdersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingCards();
                    }
                    
                    final orders = snapshot.data?.docs
                            .map((doc) => user_model.Order.fromFirestore(doc))
                            .toList() ??
                        [];
                    
                    final analytics = _calculateAnalytics(orders);
                    
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                '📦',
                                'คำสั่งซื้อ',
                                '${analytics['totalOrders']}',
                                'คำสั่ง',
                                AppTheme.lightBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                '💵',
                                'ยอดขาย',
                                '฿${analytics['totalRevenue']}',
                                'บาท',
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
                                '📈',
                                'ยอดเฉลี่ย',
                                '฿${analytics['averageOrderValue']}',
                                'ต่อคำสั่ง',
                                AppTheme.lightOrange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                '🛍️',
                                'สินค้าขาย',
                                '${analytics['totalItems']}',
                                'ชิ้น',
                                AppTheme.lightPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Order Status Distribution
                Text(
                  '📊 สถานะคำสั่งซื้อ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                StreamBuilder<QuerySnapshot>(
                  stream: _getOrdersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    
                    final orders = snapshot.data?.docs
                            .map((doc) => user_model.Order.fromFirestore(doc))
                            .toList() ??
                        [];
                    
                    final statusCounts = _getStatusCounts(orders);
                    
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: statusCounts.entries.map((entry) {
                            final status = entry.key;
                            final count = entry.value;
                            final total = orders.length;
                            final percentage = total > 0 ? (count / total * 100) : 0.0;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Text(_getStatusDisplayName(status)),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation(
                                        _getStatusColor(status),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      '$count (${percentage.toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // User Statistics
                Text(
                  '👥 สถิติผู้ใช้',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingCards();
                    }
                    
                    final users = snapshot.data?.docs
                            .map((doc) => user_model.User.fromFirestore(doc))
                            .toList() ??
                        [];
                    
                    final userStats = _calculateUserStats(users);
                    
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '👥',
                            'ผู้ใช้ทั้งหมด',
                            '${userStats['total']}',
                            'คน',
                            AppTheme.lightBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '🆕',
                            'ผู้ใช้ใหม่ $_selectedPeriod',
                            '${userStats['newUsers']}',
                            'คน',
                            AppTheme.lightGreen,
                          ),
                        ),
                      ],
                    );
                  },
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
                        onPressed: _exportReport,
                        icon: const Icon(Icons.download),
                        label: const Text('ส่งออกรายงาน'),
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
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('รีเฟรชข้อมูล'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightGreen,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
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
    String icon,
    String title,
    String value,
    String unit,
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                child: Container(
                  height: 120,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Container(
                  height: 120,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getOrdersStream() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 'วันนี้':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'สัปดาห์นี้':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'เดือนนี้':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'ปีนี้':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }
    
    return FirebaseFirestore.instance
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Map<String, dynamic> _calculateAnalytics(List<user_model.Order> orders) {
    if (orders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalRevenue': '0.00',
        'averageOrderValue': '0.00',
        'totalItems': 0,
      };
    }
    
    final totalOrders = orders.length;
    final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.total);
    final averageOrderValue = totalRevenue / totalOrders;
    final totalItems = orders.fold<int>(0, (sum, order) => 
        sum + order.items.fold<int>(0, (itemSum, item) => itemSum + item.quantity));
    
    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue.toStringAsFixed(2),
      'averageOrderValue': averageOrderValue.toStringAsFixed(2),
      'totalItems': totalItems,
    };
  }

  Map<String, int> _getStatusCounts(List<user_model.Order> orders) {
    final counts = <String, int>{
      'pending': 0,
      'confirmed': 0,
      'processing': 0,
      'shipped': 0,
      'delivered': 0,
      'cancelled': 0,
    };
    
    for (final order in orders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }
    
    return counts;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'confirmed':
        return 'ยืนยันแล้ว';
      case 'processing':
        return 'กำลังเตรียม';
      case 'shipped':
        return 'จัดส่งแล้ว';
      case 'delivered':
        return 'ส่งเรียบร้อย';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status;
    }
  }

  Map<String, int> _calculateUserStats(List<user_model.User> users) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 'วันนี้':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'สัปดาห์นี้':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'เดือนนี้':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'ปีนี้':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }
    
    final newUsers = users
        .where((user) => user.createdAt.isAfter(startDate))
        .length;
    
    return {
      'total': users.length,
      'newUsers': newUsers,
    };
  }

  String _getPeriodDescription() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'วันนี้':
        return '${now.day}/${now.month}/${now.year + 543}';
      case 'สัปดาห์นี้':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
      case 'เดือนนี้':
        return 'เดือน ${now.month}/${now.year + 543}';
      case 'ปีนี้':
        return 'ปี ${now.year + 543}';
      default:
        return '';
    }
  }

  void _exportReport() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ฟีเจอร์ส่งออกรายงานจะพัฒนาในอนาคต'),
      ),
    );
  }

  void _refreshData() {
    setState(() {
      // This will trigger a rebuild and refresh the streams
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('รีเฟรชข้อมูลแล้ว'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ไม่มีสิทธิ์เข้าถึง'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'คุณไม่มีสิทธิ์ดูรายงานและสถิติ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
}