import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat_room_list.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/chat_input.dart';
import '../../widgets/product_chat_header.dart';
import '../../models/chat_message.dart';
import '../../models/chat_room.dart';


/// 👨‍💼 AdminChatScreen - หน้าจัดการแชทสำหรับ Admin/Moderator
/// 
/// Features:
/// • View all chat rooms
/// • Monitor customer conversations
/// • Join customer chats
/// • Admin messaging capabilities
/// • Chat statistics
/// • Room management (close, archive)
class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  ChatMessage? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeChat();
  }

  void _initializeChat() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    if (authProvider.userProfile != null) {
      chatProvider.setCurrentUser(authProvider.userProfile);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Chat Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Active Chats'),
            Tab(icon: Icon(Icons.chat), text: 'Current Chat'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      body: Consumer2<ChatProvider, AuthProvider>(
        builder: (context, chatProvider, authProvider, child) {
          if (authProvider.userProfile == null) {
            return _buildLoginPrompt();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllChatsTab(chatProvider),
              _buildCurrentChatTab(chatProvider),
              _buildStatisticsTab(),
            ],
          );
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
            Icons.admin_panel_settings,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Admin access required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please login as Admin or Moderator',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 📋 All chats tab
  Widget _buildAllChatsTab(ChatProvider chatProvider) {
    return Column(
      children: [
        // Search and filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  // TODO: Implement filters
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'active',
                    child: Text('Active Chats'),
                  ),
                  const PopupMenuItem(
                    value: 'waiting',
                    child: Text('Waiting for Response'),
                  ),
                  const PopupMenuItem(
                    value: 'closed',
                    child: Text('Closed Chats'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chat rooms list
        Expanded(
          child: ChatRoomList(
            rooms: chatProvider.chatRooms,
            currentUser: chatProvider.currentUser,
            onRoomTap: (room) {
              chatProvider.openChatRoom(room.id);
              _tabController.animateTo(1); // Switch to Current Chat tab
            },
            onRefresh: () {
              chatProvider.refresh();
            },
            onCreateRoom: null, // Admins don't create rooms directly
            isLoading: chatProvider.isLoading,
            error: chatProvider.error,
          ),
        ),
      ],
    );
  }

  /// 💬 Current chat tab
  Widget _buildCurrentChatTab(ChatProvider chatProvider) {
    if (chatProvider.currentRoom == null) {
      return _buildNoChatSelected();
    }

    final room = chatProvider.currentRoom!;
    
    return Column(
      children: [
        // Chat header with room info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              // Customer avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  room.customerName.isNotEmpty 
                    ? room.customerName[0].toUpperCase()
                    : '?',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Customer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.customerName.isNotEmpty 
                        ? room.customerName 
                        : 'Unknown Customer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      room.customerEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Room actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  _handleRoomAction(value, room);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 20),
                        SizedBox(width: 8),
                        Text('Room Info'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'close',
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 20),
                        SizedBox(width: 8),
                        Text('Close Chat'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive, size: 20, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Archive'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Product info header (ถ้าเป็นการแชทเกี่ยวกับสินค้า)
        ProductChatHeader(
          room: room,
          onProductTap: () {
            // TODO: Navigate to product detail (Admin view)
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
                    chatProvider.error!,
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
            : ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: chatProvider.currentMessages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.currentMessages[index];
                  return ChatBubble(
                    message: message,
                    currentUser: chatProvider.currentUser,
                    onReply: () => _setReplyMessage(message),
                    onDelete: message.senderId == chatProvider.currentUser?.uid
                      ? () => _deleteMessage(message)
                      : null,
                    onTap: () => _markMessageAsRead(message),
                  );
                },
              ),
        ),

        // Admin chat input
        ChatInput(
          controller: _messageController,
          enabled: !chatProvider.isLoading,
          hintText: 'Type your response...',
          onSend: _sendMessage,
          onImageSelected: _sendImage,
          onFileSelected: _sendFile,
          onTypingStart: chatProvider.startTyping,
          replyWidget: _replyToMessage != null ? _buildReplyWidget() : null,
          onCancelReply: _cancelReply,
        ),
      ],
    );
  }

  /// 📊 Statistics tab
  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Statistics cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.chat_bubble,
                  label: 'Total Chats',
                  value: '0', // TODO: Get from ChatService
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  label: 'Active Chats',
                  value: '0', // TODO: Get from ChatService
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  label: 'Customers',
                  value: '0', // TODO: Get from ChatService
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.message,
                  label: 'Messages',
                  value: '0', // TODO: Get from ChatService
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Recent activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'No recent activity',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 Statistics card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// ❌ No chat selected
  Widget _buildNoChatSelected() {
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
            'No chat selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select a chat from the Active Chats tab',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
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
                  'Replying to ${_replyToMessage!.senderName}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyToMessage!.content,
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
    
    if (content.isEmpty) return;

    final success = await chatProvider.sendMessage(
      content,
      replyToMessageId: _replyToMessage?.id,
    );
    
    if (success) {
      _messageController.clear();
      _cancelReply();
    }
  }

  /// 📷 Send image
  Future<void> _sendImage(String imagePath) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // TODO: Upload image to Firebase Storage
    const imageUrl = 'https://via.placeholder.com/300x200';
    
    await chatProvider.sendImageMessage(imageUrl, caption: 'Admin sent an image');
  }

  /// 📁 Send file
  Future<void> _sendFile(String filePath, String fileName, int fileSize) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // TODO: Upload file to Firebase Storage
    const fileUrl = 'https://example.com/admin-file.pdf';
    
    await chatProvider.sendFileMessage(fileUrl, fileName, fileSize);
  }

  /// 💬 Set reply message
  void _setReplyMessage(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  /// ❌ Cancel reply
  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
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

  /// ⚡ Handle room actions
  void _handleRoomAction(String action, ChatRoom room) {
    switch (action) {
      case 'info':
        _showRoomInfo(room);
        break;
      case 'close':
        _closeRoom(room);
        break;
      case 'archive':
        _archiveRoom(room);
        break;
    }
  }

  /// ℹ️ Show room info
  void _showRoomInfo(ChatRoom room) {
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
            _buildInfoRow('Participants', '${room.participants.length}'),
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

  /// 🔒 Close room
  Future<void> _closeRoom(ChatRoom room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Chat'),
        content: const Text('Are you sure you want to close this chat room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement close room functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room closed successfully')),
      );
    }
  }

  /// 📦 Archive room
  Future<void> _archiveRoom(ChatRoom room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Chat'),
        content: const Text('Are you sure you want to archive this chat room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement archive room functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room archived successfully')),
      );
    }
  }

  /// ℹ️ Info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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