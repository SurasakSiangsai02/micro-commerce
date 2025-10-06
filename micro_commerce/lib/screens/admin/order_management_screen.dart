import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../models/user.dart' as user_model;
import '../../services/database_service.dart';

/// 📦 OrderManagementScreen - หน้าจัดการคำสั่งซื้อสำหรับ Admin
/// 
/// ฟีเจอร์:
/// • แสดงรายการคำสั่งซื้อทั้งหมด
/// • เปลี่ยนสถานะคำสั่งซื้อ
/// • ดูรายละเอียดคำสั่งซื้อ
/// • กรองตามสถานะ
/// • ค้นหาคำสั่งซื้อ
class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'ทั้งหมด';
  
  final List<String> _orderStatuses = [
    'ทั้งหมด',
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  final Map<String, String> _statusDisplayNames = {
    'pending': 'รอดำเนินการ',
    'confirmed': 'ยืนยันแล้ว',
    'processing': 'กำลังเตรียม',
    'shipped': 'จัดส่งแล้ว',
    'delivered': 'ส่งเรียบร้อย',
    'cancelled': 'ยกเลิก',
  };

  final Map<String, Color> _statusColors = {
    'pending': Colors.orange,
    'confirmed': Colors.blue,
    'processing': Colors.purple,
    'shipped': Colors.indigo,
    'delivered': Colors.green,
    'cancelled': Colors.red,
  };

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
            title: const Text('📦 จัดการคำสั่งซื้อ'),
            backgroundColor: AppTheme.lightGreen,
            foregroundColor: AppTheme.white,
          ),
          body: Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'ค้นหาคำสั่งซื้อ (ID, ชื่อลูกค้า)...',
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
                    
                    const SizedBox(height: 12),
                    
                    // Status Filter
                    Row(
                      children: [
                        const Text(
                          'สถานะ: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                            items: _orderStatuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status == 'ทั้งหมด' 
                                    ? status 
                                    : _statusDisplayNames[status] ?? status,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Orders List
              Expanded(
                child: StreamBuilder<List<user_model.Order>>(
                  stream: DatabaseService.getAllOrdersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('ลองใหม่'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final orders = snapshot.data ?? [];
                    final filteredOrders = _filterOrders(orders);
                    
                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty || _selectedStatus != 'ทั้งหมด'
                                  ? Icons.search_off
                                  : Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _selectedStatus != 'ทั้งหมด'
                                  ? 'ไม่พบคำสั่งซื้อที่ตรงกับการกรอง'
                                  : 'ยังไม่มีคำสั่งซื้อในระบบ',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<user_model.Order> _filterOrders(List<user_model.Order> orders) {
    return orders.where((order) {
      final matchesSearch = _searchQuery.isEmpty ||
          order.id.toLowerCase().contains(_searchQuery) ||
          order.userId.toLowerCase().contains(_searchQuery);
          
      final matchesStatus = _selectedStatus == 'ทั้งหมด' ||
          order.status == _selectedStatus;
          
      return matchesSearch && matchesStatus;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
  }

  Widget _buildOrderCard(user_model.Order order) {
    final statusColor = _statusColors[order.status] ?? Colors.grey;
    final statusDisplayName = _statusDisplayNames[order.status] ?? order.status;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'คำสั่งซื้อ #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'วันที่: ${_formatDate(order.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusDisplayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Order Summary
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'จำนวนสินค้า: ${order.items.length} รายการ',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ยอดรวม: ฿${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () => _viewOrderDetails(order),
                      tooltip: 'ดูรายละเอียด',
                    ),
                    if (order.status != 'delivered' && order.status != 'cancelled')
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'เปลี่ยนสถานะ',
                        onSelected: (newStatus) => _updateOrderStatus(order, newStatus),
                        itemBuilder: (context) => _getAvailableStatuses(order.status)
                            .map((status) => PopupMenuItem(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: _statusColors[status],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_statusDisplayNames[status] ?? status),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ],
            ),
            
            // Items Preview
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'สินค้าในคำสั่งซื้อ:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text('• ${item.productName}'),
                    const Spacer(),
                    Text('x${item.quantity}'),
                    const SizedBox(width: 8),
                    Text('฿${(item.price * item.quantity).toStringAsFixed(2)}'),
                  ],
                ),
              )),
              if (order.items.length > 2)
                Text(
                  '... และอีก ${order.items.length - 2} รายการ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['processing', 'cancelled'];
      case 'processing':
        return ['shipped', 'cancelled'];
      case 'shipped':
        return ['delivered'];
      default:
        return [];
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  void _viewOrderDetails(user_model.Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('รายละเอียดคำสั่งซื้อ #${order.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('วันที่สั่งซื้อ', _formatDate(order.createdAt)),
              _buildDetailRow('สถานะ', _statusDisplayNames[order.status] ?? order.status),
              _buildDetailRow('ชำระเงินผ่าน', order.paymentMethod),
              const SizedBox(height: 16),
              const Text(
                'รายการสินค้า:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName),
                          Text(
                            '฿${item.price.toStringAsFixed(2)} x ${item.quantity}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('฿${(item.price * item.quantity).toStringAsFixed(2)}'),
                  ],
                ),
              )),
              const Divider(),
              _buildDetailRow('ยอดรวมสินค้า', '฿${order.subtotal.toStringAsFixed(2)}'),
              _buildDetailRow('ภาษี', '฿${order.tax.toStringAsFixed(2)}'),
              _buildDetailRow(
                'ยอดรวมทั้งหมด', 
                '฿${order.total.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.lightGreen : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(user_model.Order order, String newStatus) async {
    try {
      await DatabaseService.updateOrderStatus(order.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'อัปเดตสถานะเป็น "${_statusDisplayNames[newStatus]}" สำเร็จ',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
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
              'คุณไม่มีสิทธิ์จัดการคำสั่งซื้อ',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}