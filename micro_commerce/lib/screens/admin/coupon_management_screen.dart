import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coupon_provider.dart';
import '../../models/coupon.dart';
import '../../services/coupon_service.dart';
import '../../utils/theme.dart';
import 'coupon_form_screen.dart';

/// 🎟️ CouponManagementScreen - หน้าจัดการคูปองสำหรับ Admin
/// 
/// ฟีเจอร์:
/// • ดูรายการคูปองทั้งหมด
/// • สร้างคูปองใหม่
/// • แก้ไข/ลบคูปอง
/// • เปิด/ปิดการใช้งาน
/// • ดูสถิติการใช้งาน
class CouponManagementScreen extends StatefulWidget {
  const CouponManagementScreen({super.key});

  @override
  State<CouponManagementScreen> createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends State<CouponManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  CouponStats? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  void _loadData() {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    couponProvider.loadCoupons();
    _loadStats();
  }

  void _loadStats() async {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    final stats = await couponProvider.getCouponStats();
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('🎟️ จัดการคูปอง'),
        backgroundColor: AppTheme.lightPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addNewCoupon,
            icon: const Icon(Icons.add),
            tooltip: 'เพิ่มคูปองใหม่',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'ทั้งหมด'),
            Tab(text: 'ใช้งานได้'),
            Tab(text: 'หมดอายุ'),
            Tab(text: 'สถิติ'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ค้นหาคูปอง...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCouponList(),
                _buildActiveCouponList(),
                _buildExpiredCouponList(),
                _buildStatsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCoupon,
        backgroundColor: AppTheme.lightPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'สร้างคูปอง',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// รายการคูปองทั้งหมด
  Widget _buildCouponList() {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        if (couponProvider.isLoading && couponProvider.coupons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (couponProvider.error != null) {
          return _buildErrorState(couponProvider.error!);
        }

        final filteredCoupons = _filterCoupons(couponProvider.coupons);

        if (filteredCoupons.isEmpty) {
          return _buildEmptyState('ยังไม่มีคูปองในระบบ');
        }

        return _buildCouponGrid(filteredCoupons);
      },
    );
  }

  /// รายการคูปองที่ใช้งานได้
  Widget _buildActiveCouponList() {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        final activeCoupons = _filterCoupons(
          couponProvider.coupons.where((c) => c.status == CouponStatus.active).toList(),
        );

        if (activeCoupons.isEmpty) {
          return _buildEmptyState('ไม่มีคูปองที่ใช้งานได้');
        }

        return _buildCouponGrid(activeCoupons);
      },
    );
  }

  /// รายการคูปองที่หมดอายุ
  Widget _buildExpiredCouponList() {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, child) {
        final expiredCoupons = _filterCoupons(
          couponProvider.coupons.where((c) => c.status == CouponStatus.expired).toList(),
        );

        if (expiredCoupons.isEmpty) {
          return _buildEmptyState('ไม่มีคูปองที่หมดอายุ');
        }

        return _buildCouponGrid(expiredCoupons);
      },
    );
  }

  /// แท็บสถิติ
  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 สถิติคูปอง',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_stats != null) ...[
            // Overall Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '📋',
                    'คูปองทั้งหมด',
                    '${_stats!.totalCoupons}',
                    'รายการ',
                    AppTheme.lightBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '✅',
                    'ใช้งานได้',
                    '${_stats!.activeCoupons}',
                    'รายการ',
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
                    '⏰',
                    'หมดอายุ',
                    '${_stats!.expiredCoupons}',
                    'รายการ',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '🏆',
                    'ใช้ครบแล้ว',
                    '${_stats!.usedUpCoupons}',
                    'รายการ',
                    AppTheme.lightPurple,
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
                    'การใช้งานรวม',
                    '${_stats!.totalUsage}',
                    'ครั้ง',
                    Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '📊',
                    'อัตราการใช้',
                    '${_stats!.usageRate.toStringAsFixed(1)}',
                    'ครั้ง/คูปอง',
                    Colors.teal,
                  ),
                ),
              ],
            ),
          ] else ...[
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Text(
            '⚡ การดำเนินการด่วน',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNewCoupon,
              icon: const Icon(Icons.add),
              label: const Text('สร้างคูปองใหม่'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('รีเฟรชข้อมูล'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// กรองคูปองตามคำค้นหา
  List<Coupon> _filterCoupons(List<Coupon> coupons) {
    if (_searchQuery.isEmpty) return coupons;
    
    return coupons.where((coupon) {
      return coupon.code.toLowerCase().contains(_searchQuery) ||
             (coupon.description?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  /// Grid แสดงคูปอง
  Widget _buildCouponGrid(List<Coupon> coupons) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          return _buildCouponCard(coupon);
        },
      ),
    );
  }

  /// การ์ดคูปอง
  Widget _buildCouponCard(Coupon coupon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _editCoupon(coupon),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Code
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.lightPurple),
                    ),
                    child: Text(
                      coupon.code,
                      style: TextStyle(
                        color: AppTheme.lightPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Status
                  _buildStatusChip(coupon.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Discount Info
              Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    coupon.discountText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              if (coupon.description != null && coupon.description!.isNotEmpty)
                Text(
                  coupon.description!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (coupon.minimumOrderAmount > 0)
                          _buildDetailRow(
                            Icons.attach_money,
                            'ขั้นต่ำ: \$${coupon.minimumOrderAmount.toStringAsFixed(2)}',
                          ),
                        if (coupon.usageLimit >= 0)
                          _buildDetailRow(
                            Icons.confirmation_number,
                            'ใช้ได้: ${coupon.usedCount}/${coupon.usageLimit}',
                          ),
                        if (coupon.expiryDate != null)
                          _buildDetailRow(
                            Icons.schedule,
                            'หมดอายุ: ${coupon.expiryDate!.day}/${coupon.expiryDate!.month}/${coupon.expiryDate!.year}',
                          ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _editCoupon(coupon),
                        icon: const Icon(Icons.edit),
                        color: AppTheme.lightBlue,
                        tooltip: 'แก้ไข',
                      ),
                      IconButton(
                        onPressed: () => _toggleCouponStatus(coupon),
                        icon: Icon(
                          coupon.isActive ? Icons.pause : Icons.play_arrow,
                        ),
                        color: coupon.isActive ? Colors.orange : Colors.green,
                        tooltip: coupon.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน',
                      ),
                      IconButton(
                        onPressed: () => _deleteCoupon(coupon),
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        tooltip: 'ลบ',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// รายละเอียดย่อย
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// ชิปสถานะ
  Widget _buildStatusChip(CouponStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case CouponStatus.active:
        color = Colors.green;
        text = 'ใช้งานได้';
        break;
      case CouponStatus.inactive:
        color = Colors.grey;
        text = 'ปิดใช้งาน';
        break;
      case CouponStatus.expired:
        color = Colors.orange;
        text = 'หมดอายุ';
        break;
      case CouponStatus.usedUp:
        color = AppTheme.lightPurple;
        text = 'ใช้ครบแล้ว';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// การ์ดสถิติ
  Widget _buildStatCard(String emoji, String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const Spacer(),
              Icon(Icons.trending_up, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// สถานะว่าง
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewCoupon,
            icon: const Icon(Icons.add),
            label: const Text('สร้างคูปองแรก'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// สถานะข้อผิดพลาด
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('ลองอีกครั้ง'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// เพิ่มคูปองใหม่
  void _addNewCoupon() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CouponFormScreen(),
      ),
    ).then((_) => _loadData());
  }

  /// แก้ไขคูปอง
  void _editCoupon(Coupon coupon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CouponFormScreen(coupon: coupon),
      ),
    ).then((_) => _loadData());
  }

  /// เปิด/ปิดการใช้งานคูปอง
  void _toggleCouponStatus(Coupon coupon) async {
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    
    final success = await couponProvider.toggleCouponStatus(
      coupon.id,
      !coupon.isActive,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            coupon.isActive 
              ? 'ปิดใช้งานคูปอง ${coupon.code} แล้ว'
              : 'เปิดใช้งานคูปอง ${coupon.code} แล้ว',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadStats();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(couponProvider.error ?? 'เกิดข้อผิดพลาด'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ลบคูปอง
  void _deleteCoupon(Coupon coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณแน่ใจหรือไม่ที่จะลบคูปอง "${coupon.code}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final couponProvider = Provider.of<CouponProvider>(context, listen: false);
      
      final success = await couponProvider.deleteCoupon(coupon.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบคูปอง ${coupon.code} แล้ว'),
            backgroundColor: Colors.green,
          ),
        );
        _loadStats();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(couponProvider.error ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}