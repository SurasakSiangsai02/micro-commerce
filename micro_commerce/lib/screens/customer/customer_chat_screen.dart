import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/firebase_tester.dart';
import '../../utils/logger.dart';
import '../../widgets/chat_room_list.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/chat_input.dart';
import '../../widgets/product_chat_header.dart';
import '../../models/chat_message.dart';

/// 💬 CustomerChatScreen - หน้าแชทสำหรับลูกค้า
/// 
/// Features:
/// • View chat rooms list
/// • Join/create chat room
/// • Real-time messaging
/// • Image/file sharing
/// • Message actions (reply, edit, delete)
class CustomerChatScreen extends StatefulWidget {
  const CustomerChatScreen({super.key});

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  ChatMessage? _replyToMessage;
  ChatMessage? _editingMessage;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    if (authProvider.userProfile != null) {
      chatProvider.setCurrentUser(authProvider.userProfile);
    }
    
    // Run Firebase connection test for debugging
    Future.delayed(const Duration(seconds: 2), () {
      FirebaseConnectionTester.runAllTests();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Consumer2<ChatProvider, AuthProvider>(
        builder: (context, chatProvider, authProvider, child) {
          if (authProvider.userProfile == null) {
            return _buildLoginPrompt();
          }

          if (chatProvider.currentRoom == null) {
            return _buildRoomsList(chatProvider);
          } else {
            return _buildChatRoom(chatProvider);
          }
        },
      ),
    );
  }

  /// 🔐 Login prompt
  Widget _buildLoginPrompt() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Please login to start chatting',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Login to get support from our team',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 Rooms list
  Widget _buildRoomsList(ChatProvider chatProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          // Unread count badge
          if (chatProvider.totalUnreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${chatProvider.totalUnreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: ChatRoomList(
        rooms: chatProvider.chatRooms,
        currentUser: chatProvider.currentUser,
        onRoomTap: (room) {
          chatProvider.openChatRoom(room.id);
        },
        onRefresh: () {
          chatProvider.refresh();
        },
        onCreateRoom: _createGeneralSupportChat,
        isLoading: chatProvider.isLoading,
        error: chatProvider.error,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGeneralSupportChat,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: const Text(
          'Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// 💬 Chat room
  Widget _buildChatRoom(ChatProvider chatProvider) {
    final room = chatProvider.currentRoom;
    
    if (room == null) {
      return const Scaffold(
        body: Center(
          child: Text('No room selected'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.customerName.isNotEmpty ? room.customerName : 'Customer Support',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              'Online • Tap for info',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            chatProvider.leaveChatRoom();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showRoomInfo(room);
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // Product info header (ถ้าเป็นการแชทเกี่ยวกับสินค้า)
          ProductChatHeader(
            room: room,
            onProductTap: () {
              // TODO: Navigate to product detail
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product details coming soon!'),
                ),
              );
            },
          ),
          
          // Error message
          if (chatProvider.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatProvider.error ?? 'Unknown error',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  TextButton(
                    onPressed: chatProvider.clearError,
                    child: Text('Dismiss', style: TextStyle(color: Colors.red.shade700)),
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: chatProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : chatProvider.currentMessages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                  reverse: true, // ข้อความใหม่อยู่ด้านล่าง (messages จาก Firestore เรียงใหม่ไปเก่าอยู่แล้ว)
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: chatProvider.currentMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.currentMessages[index];
                    return ChatBubble(
                      message: message,
                      currentUser: chatProvider.currentUser,
                      onReply: () => _setReplyMessage(message),
                      onEdit: message.senderId == chatProvider.currentUser?.uid
                        ? () => _editMessage(message)
                        : null,
                      onDelete: message.senderId == chatProvider.currentUser?.uid
                        ? () => _deleteMessage(message)
                        : null,
                      onTap: () => _markMessageAsRead(message),
                    );
                  },
                ),
          ),

          // Chat input
          ChatInput(
            controller: _messageController,
            enabled: !chatProvider.isLoading,
            onSend: _sendMessage,
            onImageSelected: _sendImage,
            onFileSelected: _sendFile,
            onTypingStart: chatProvider.startTyping,
            onTypingStop: () {}, // จัดการใน ChatProvider
            replyWidget: _replyToMessage != null ? _buildReplyWidget() : null,
            onCancelReply: _cancelReply,
          ),
        ],
      ),
    );
  }

  /// 💬 Reply widget
  Widget _buildReplyWidget() {
    if (_replyToMessage == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToMessage?.senderName ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyToMessage?.content ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 📤 Send message
  Future<void> _sendMessage() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final content = _messageController.text.trim();
    
    print('🎯 CustomerChatScreen: Attempting to send message: "$content"');
    print('🏠 Current room: ${chatProvider.currentRoom?.id}');
    print('👤 Current user: ${chatProvider.currentUser?.uid}');
    
    if (content.isEmpty) {
      print('⚠️ Message content is empty, not sending');
      return;
    }

    if (_editingMessage != null) {
      // Edit existing message
      print('✏️ Editing existing message');
      final success = await chatProvider.editMessage(_editingMessage!.id, content);
      if (success) {
        print('✅ Message edited successfully');
        _cancelEdit();
      } else {
        print('❌ Failed to edit message');
      }
    } else {
      // Send new message
      print('📤 Sending new message');
      final success = await chatProvider.sendMessage(
        content,
        replyToMessageId: _replyToMessage?.id,
      );
      if (success) {
        print('✅ Message sent successfully, clearing input');
        _messageController.clear();
        _cancelReply();
      } else {
        print('❌ Failed to send message');
      }
    }
  }

  /// 📷 Send image
  Future<void> _sendImage(String imagePath) async {
    if (!mounted) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.userProfile;
    
    if (currentUser == null) {
      Logger.warning('Cannot send image: user not authenticated');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนส่งรูปภาพ')),
        );
      }
      return;
    }

    // Debug: Check authentication status
    final firebaseUser = authProvider.firebaseUser;
    Logger.info('Current user: ${currentUser.uid}, Firebase user: ${firebaseUser?.uid}');
    
    if (firebaseUser == null) {
      Logger.error('Firebase user is null but userProfile exists');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาดการยืนยันตัวตน กรุณาเข้าสู่ระบบใหม่')),
        );
      }
      return;
    }
    
    try {
      // Check file size first
      final isValidSize = await StorageService.isFileSizeValid(imagePath, maxSizeInMB: 5);
      if (!isValidSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ขนาดไฟล์ใหญ่เกินไป (สูงสุด 5MB)')),
          );
        }
        return;
      }
      
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กำลังอัพโหลดรูปภาพ...'), duration: Duration(seconds: 2)),
        );
      }
      
      // Upload image to Firebase Storage
      Logger.info('Uploading image for user: ${currentUser.uid}');
      final imageUrl = await StorageService.uploadChatImage(
        filePath: imagePath,
        userId: currentUser.uid,
      );
      
      if (imageUrl != null) {
        // Send image message with actual URL
        await chatProvider.sendImageMessage(imageUrl, caption: 'ส่งรูปภาพ');
        Logger.business('Image message sent successfully', {'userId': currentUser.uid});
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ส่งรูปภาพสำเร็จ'), duration: Duration(seconds: 1)),
          );
        }
      } else {
        throw Exception('Failed to upload image');
      }
      
    } catch (e, stackTrace) {
      Logger.error('Failed to send image message', error: e, stackTrace: stackTrace);
      
      String errorMessage = 'ไม่สามารถส่งรูปภาพได้ กรุณาลองใหม่';
      
      // Provide specific error messages
      if (e.toString().contains('unauthorized')) {
        errorMessage = 'ไม่มีสิทธิ์อัพโหลดไฟล์ กรุณาตรวจสอบการเข้าสู่ระบบ';
      } else if (e.toString().contains('network')) {
        errorMessage = 'ปัญหาการเชื่อมต่อเครือข่าย กรุณาลองใหม่';
      } else if (e.toString().contains('too-large')) {
        errorMessage = 'ไฟล์มีขนาดใหญ่เกินไป';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), duration: const Duration(seconds: 4)),
        );
      }
    }
  }

  /// 📁 Send file
  Future<void> _sendFile(String filePath, String fileName, int fileSize) async {
    if (!mounted) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.userProfile;
    
    if (currentUser == null) {
      Logger.warning('Cannot send file: user not authenticated');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนส่งไฟล์')),
        );
      }
      return;
    }
    
    try {
      // Check file size first
      final isValidSize = await StorageService.isFileSizeValid(filePath, maxSizeInMB: 10);
      if (!isValidSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ขนาดไฟล์ใหญ่เกินไป (สูงสุด 10MB)')),
          );
        }
        return;
      }
      
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กำลังอัพโหลดไฟล์...'), duration: Duration(seconds: 2)),
        );
      }
      
      // Upload file to Firebase Storage
      Logger.info('Uploading file for user: ${currentUser.uid}');
      final fileUrl = await StorageService.uploadChatFile(
        filePath: filePath,
        userId: currentUser.uid,
        customFileName: fileName,
      );
      
      if (fileUrl != null) {
        // Send file message with actual URL
        await chatProvider.sendFileMessage(fileUrl, fileName, fileSize);
        Logger.business('File message sent successfully', {'userId': currentUser.uid, 'fileName': fileName});
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ส่งไฟล์สำเร็จ'), duration: Duration(seconds: 1)),
          );
        }
      } else {
        throw Exception('Failed to upload file');
      }
      
    } catch (e, stackTrace) {
      Logger.error('Failed to send file message', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถส่งไฟล์ได้ กรุณาลองใหม่')),
        );
      }
    }
  }

  /// 💬 Set reply message
  void _setReplyMessage(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
      _editingMessage = null;
    });
  }

  /// ❌ Cancel reply
  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  /// ✏️ Edit message
  void _editMessage(ChatMessage message) {
    setState(() {
      _editingMessage = message;
      _replyToMessage = null;
      _messageController.text = message.content;
    });
  }

  /// ❌ Cancel edit
  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  /// 🗑️ Delete message
  Future<void> _deleteMessage(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.deleteMessage(message.id);
    }
  }

  /// 👁️ Mark message as read
  Future<void> _markMessageAsRead(ChatMessage message) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.markMessageAsRead(message.id);
  }

  /// 🎧 Create general support chat
  Future<void> _createGeneralSupportChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Connecting to support...'),
          ],
        ),
      ),
    );
    
    try {
      final roomId = await chatProvider.createChatRoom();
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (roomId != null) {
        final success = await chatProvider.openChatRoom(roomId);
        if (success && mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connected to support! 🎧'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Show error if support connection failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(chatProvider.error ?? 'Failed to connect to support'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to support: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ℹ️ Show room info
  void _showRoomInfo(room) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Room ID', room.id),
            _buildInfoRow('Customer', room.customerName),
            _buildInfoRow('Email', room.customerEmail),
            _buildInfoRow('Status', room.status),
            _buildInfoRow('Created', room.createdAt.toString().split('.')[0]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ℹ️ Info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}