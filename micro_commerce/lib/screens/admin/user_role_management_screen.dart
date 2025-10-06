import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../config/security_config.dart';

/// 🔐 หน้าจัดการบทบาทผู้ใช้ (Admin/Moderator Management)
/// 
/// Features:
/// • สร้างบัญชี Admin/Moderator ใหม่
/// • ดูรายการ Admin/Moderator ทั้งหมด
/// • เปลี่ยนบทบาทผู้ใช้
/// • ลบบัญชี Admin/Moderator (เฉพาะ Admin เท่านั้น)
/// • ความปลอดภัยระดับสูง (Admin-only access)
class UserRoleManagementScreen extends StatefulWidget {
  const UserRoleManagementScreen({super.key});

  @override
  State<UserRoleManagementScreen> createState() => _UserRoleManagementScreenState();
}

class _UserRoleManagementScreenState extends State<UserRoleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'moderator';
  bool _isLoading = false;
  bool _showPassword = false;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// ✅ ตรวจสอบสิทธิ์ Admin เท่านั้น
  bool _isAdmin() {
    final authProvider = Provider.of<auth_provider.AuthProvider>(context, listen: false);
    return authProvider.userProfile?.role == 'admin';
  }

  /// 🔐 สร้างบัญชี Admin/Moderator ใหม่
  Future<void> _createNewAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isAdmin()) {
      _showErrorDialog('ไม่มีสิทธิ์', 'เฉพาะ Admin เท่านั้นที่สามารถสร้างบัญชีใหม่ได้');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ตรวจสอบว่า email นี้มีอยู่แล้วหรือไม่
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('มีบัญชีนี้อยู่แล้วในระบบ');
      }

      // เก็บ current user เพื่อ restore ภายหลัง
      final currentUser = _auth.currentUser;
      
      // สร้างบัญชีใหม่
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final newUser = userCredential.user;
      if (newUser == null) throw Exception('ไม่สามารถสร้างบัญชีได้');

      // สร้าง user document ใน Firestore
      await _firestore.collection('users').doc(newUser.uid).set({
        'uid': newUser.uid,
        'email': newUser.email,
        'name': _nameController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUser?.uid,
        'isActive': true,
      });

      // Update display name
      await newUser.updateDisplayName(_nameController.text.trim());

      // Sign out the new user และ sign in กลับเป็น admin
      await _auth.signOut();
      
      // Re-authenticate current admin
      if (currentUser != null) {
        // ให้ admin login กลับเอง (เพื่อความปลอดภัย)
        if (mounted) {
          _showSuccessDialog(
            'สร้างบัญชีสำเร็จ!',
            'สร้างบัญชี ${_selectedRole.toUpperCase()} ใหม่เรียบร้อยแล้ว\n'
            'Email: ${_emailController.text.trim()}\n'
            'Password: ${_passwordController.text}\n\n'
            'กรุณา Login กลับเข้าระบบ',
            () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          );
        }
      }

      // Clear form
      _clearForm();

    } catch (e) {
      if (mounted) {
        _showErrorDialog('เกิดข้อผิดพลาด', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 📋 เคลียร์ฟอร์ม
  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    setState(() {
      _selectedRole = 'moderator';
      _showPassword = false;
    });
  }

  /// ⚠️ แสดง Error Dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  /// ✅ แสดง Success Dialog
  void _showSuccessDialog(String title, String message, [VoidCallback? onOk]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.green)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOk != null) onOk();
            },
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  /// 🔄 เปลี่ยนบทบาทผู้ใช้
  Future<void> _changeUserRole(String userId, String currentRole, String newRole) async {
    if (!_isAdmin()) {
      _showErrorDialog('ไม่มีสิทธิ์', 'เฉพาะ Admin เท่านั้นที่สามารถเปลี่ยนบทบาทได้');
      return;
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เปลี่ยนบทบาทจาก $currentRole เป็น $newRole สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('เกิดข้อผิดพลาด', 'ไม่สามารถเปลี่ยนบทบาทได้: $e');
      }
    }
  }

  /// 🗑️ ลบบัญชีผู้ใช้ (Admin เท่านั้น)
  Future<void> _deleteUser(String userId, String email) async {
    if (!_isAdmin()) {
      _showErrorDialog('ไม่มีสิทธิ์', 'เฉพาะ Admin เท่านั้นที่สามารถลบบัญชีได้');
      return;
    }

    // ยืนยันการลบ
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ', style: TextStyle(color: Colors.red)),
        content: Text('คุณต้องการลบบัญชี $email หรือไม่?\n\nการดำเนินการนี้ไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ลบ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // ลบ user document จาก Firestore
      await _firestore.collection('users').doc(userId).delete();
      
      // หมายเหตุ: การลบ Firebase Auth user ต้องทำผ่าน Admin SDK หรือ Cloud Functions
      // ซึ่งไม่สามารถทำได้จาก client app โดยตรง
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบบัญชี $email สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('เกิดข้อผิดพลาด', 'ไม่สามารถลบบัญชีได้: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('🔐 จัดการบทบาทผู้ใช้'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'ไม่มีสิทธิ์เข้าถึง',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'เฉพาะ Admin เท่านั้นที่สามารถจัดการบทบาทผู้ใช้ได้',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 จัดการบทบาทผู้ใช้'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ฟอร์มสร้างบัญชีใหม่
            _buildCreateAccountForm(),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // รายการ Admin/Moderator
            _buildUserList(),
          ],
        ),
      ),
    );
  }

  /// 📝 ฟอร์มสร้างบัญชีใหม่
  Widget _buildCreateAccountForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    'สร้างบัญชี Admin/Moderator ใหม่',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // ชื่อ-นามสกุล
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ-นามสกุล',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อ-นามสกุล';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอก Email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'รูปแบบ Email ไม่ถูกต้อง';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอก Password';
                  }
                  if (value.length < 6) {
                    return 'Password ต้องมีอย่างน้อย 6 ตัวอักษร';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Role Selection
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'บทบาท',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('👑 Admin (สิทธิ์เต็ม)')),
                  DropdownMenuItem(value: 'moderator', child: Text('🛡️ Moderator (จัดการสินค้า)')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              const SizedBox(height: 24),
              
              // สร้างบัญชี Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createNewAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('สร้างบัญชีใหม่', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 รายการผู้ใช้ Admin/Moderator
  Widget _buildUserList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.group, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              'รายการ Admin & Moderator',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .where('role', whereIn: ['admin', 'moderator'])
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final users = snapshot.data?.docs ?? [];

            if (users.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('ไม่มีผู้ใช้ Admin/Moderator'),
                  ),
                ),
              );
            }

            return Column(
              children: users.map((doc) {
                final userData = doc.data() as Map<String, dynamic>;
                final userId = doc.id;
                final email = userData['email'] ?? '';
                final name = userData['name'] ?? '';
                final role = userData['role'] ?? '';
                final createdAt = userData['createdAt'] as Timestamp?;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: role == 'admin' ? Colors.orange : Colors.blue,
                      child: Icon(
                        role == 'admin' ? Icons.admin_panel_settings : Icons.shield,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(name.isNotEmpty ? name : email),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📧 $email'),
                        Text('🔐 ${role.toUpperCase()}'),
                        if (createdAt != null)
                          Text('📅 ${createdAt.toDate().toString().split(' ')[0]}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.swap_horiz, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('เปลี่ยนบทบาท'),
                            ],
                          ),
                          onTap: () => _showChangeRoleDialog(userId, role),
                        ),
                        if (role != 'admin') // ไม่สามารถลบ Admin ได้
                          PopupMenuItem(
                            child: const Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('ลบบัญชี'),
                              ],
                            ),
                            onTap: () => _deleteUser(userId, email),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// 🔄 แสดง Dialog เปลี่ยนบทบาท
  void _showChangeRoleDialog(String userId, String currentRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เปลี่ยนบทบาท'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
              title: const Text('Admin'),
              subtitle: const Text('สิทธิ์เต็ม - จัดการทุกอย่าง'),
              onTap: () {
                Navigator.of(context).pop();
                _changeUserRole(userId, currentRole, 'admin');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield, color: Colors.blue),
              title: const Text('Moderator'),
              subtitle: const Text('จัดการสินค้า, ออเดอร์'),
              onTap: () {
                Navigator.of(context).pop();
                _changeUserRole(userId, currentRole, 'moderator');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }
}