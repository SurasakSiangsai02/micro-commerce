import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../models/user.dart' as user_model;

/// 👥 UserManagementScreen - หน้าจัดการผู้ใช้สำหรับ Admin
/// 
/// ฟีเจอร์:
/// • แสดงรายการผู้ใช้ทั้งหมด
/// • ค้นหาผู้ใช้
/// • เปลี่ยนบทบาทผู้ใช้
/// • ดูข้อมูลผู้ใช้
/// • บล็อค/ปลดบล็อคผู้ใช้
/// 
/// สิทธิ์: Admin เท่านั้น
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  user_model.UserRole? _selectedRoleFilter;
  
  final List<user_model.UserRole> _roleFilters = [
    user_model.UserRole.customer,
    user_model.UserRole.moderator,
    user_model.UserRole.admin,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.userProfile;
        
        // Only admin can access user management
        if (currentUser == null || !currentUser.isAdmin) {
          return _buildAccessDenied();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('👥 จัดการผู้ใช้'),
            backgroundColor: AppTheme.lightOrange,
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
                        hintText: 'ค้นหาผู้ใช้ (ชื่อ, อีเมล)...',
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
                    
                    // Role Filter
                    Row(
                      children: [
                        const Text(
                          'บทบาท: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: DropdownButton<user_model.UserRole?>(
                            value: _selectedRoleFilter,
                            isExpanded: true,
                            hint: const Text('ทั้งหมด'),
                            onChanged: (value) {
                              setState(() {
                                _selectedRoleFilter = value;
                              });
                            },
                            items: [
                              const DropdownMenuItem<user_model.UserRole?>(
                                value: null,
                                child: Text('ทั้งหมด'),
                              ),
                              ..._roleFilters.map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role.displayName),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Users List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
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
                    
                    final userDocs = snapshot.data?.docs ?? [];
                    final users = userDocs
                        .map((doc) => user_model.User.fromFirestore(doc))
                        .toList();
                    final filteredUsers = _filterUsers(users);
                    
                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty || _selectedRoleFilter != null
                                  ? Icons.search_off
                                  : Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _selectedRoleFilter != null
                                  ? 'ไม่พบผู้ใช้ที่ตรงกับการกรอง'
                                  : 'ยังไม่มีผู้ใช้ในระบบ',
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
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return _buildUserCard(user, currentUser);
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

  List<user_model.User> _filterUsers(List<user_model.User> users) {
    return users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery);
          
      final matchesRole = _selectedRoleFilter == null ||
          user.role == _selectedRoleFilter;
          
      return matchesSearch && matchesRole;
    }).toList();
  }

  Widget _buildUserCard(user_model.User user, user_model.User currentUser) {
    final isCurrentUser = user.uid == currentUser.uid;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.lightGreen,
                  backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                
                const SizedBox(width: 16),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCurrentUser)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'คุณ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.lightBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getRoleColor(user.role)),
                            ),
                            child: Text(
                              user.role.displayName,
                              style: TextStyle(
                                color: _getRoleColor(user.role),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'สมัครเมื่อ: ${_formatDate(user.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions Menu
                if (!isCurrentUser)
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleUserAction(value, user),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 16),
                            SizedBox(width: 8),
                            Text('ดูรายละเอียด'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'change_role',
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, size: 16),
                            SizedBox(width: 8),
                            Text('เปลี่ยนบทบาท'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            
            // Additional Info
            if (user.phone != null && user.phone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    user.phone!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            
            if (user.address != null && user.address!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.address!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(user_model.UserRole role) {
    switch (role) {
      case user_model.UserRole.admin:
        return Colors.red;
      case user_model.UserRole.moderator:
        return Colors.orange;
      case user_model.UserRole.customer:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  void _handleUserAction(String action, user_model.User user) {
    switch (action) {
      case 'view':
        _viewUserDetails(user);
        break;
      case 'change_role':
        _changeUserRole(user);
        break;
    }
  }

  void _viewUserDetails(user_model.User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('รายละเอียดผู้ใช้: ${user.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('อีเมล', user.email),
              _buildDetailRow('บทบาท', user.role.displayName),
              if (user.phone != null && user.phone!.isNotEmpty)
                _buildDetailRow('เบอร์โทรศัพท์', user.phone!),
              if (user.address != null && user.address!.isNotEmpty)
                _buildDetailRow('ที่อยู่', user.address!),
              _buildDetailRow('สมัครสมาชิกเมื่อ', _formatDate(user.createdAt)),
              _buildDetailRow('อัปเดตล่าสุด', _formatDate(user.updatedAt)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _changeUserRole(user_model.User user) {
    user_model.UserRole? selectedRole = user.role;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('เปลี่ยนบทบาท: ${user.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('บทบาทปัจจุบัน: ${user.role.displayName}'),
              const SizedBox(height: 16),
              const Text(
                'เลือกบทบาทใหม่:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...user_model.UserRole.values.map((role) {
                return RadioListTile<user_model.UserRole>(
                  title: Text(role.displayName),
                  value: role,
                  groupValue: selectedRole,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value;
                    });
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: selectedRole == user.role
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _updateUserRole(user, selectedRole!);
                    },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserRole(user_model.User user, user_model.UserRole newRole) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'role': newRole.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เปลี่ยนบทบาทของ ${user.name} เป็น ${newRole.displayName} สำเร็จ',
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
              'คุณไม่มีสิทธิ์จัดการผู้ใช้',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'เฉพาะ Admin เท่านั้นที่สามารถเข้าถึงได้',
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