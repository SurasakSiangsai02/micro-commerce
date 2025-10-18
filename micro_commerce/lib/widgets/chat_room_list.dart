import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_room.dart';
import '../models/user.dart' as user_model;
import '../widgets/confirmation_dialog.dart';

enum RoomStatus { active, waiting, closed }

/// 📋 ChatRoomList - แสดงรายการห้องแชท
/// 
/// Features:
/// • Room list with last message preview
/// • Unread message counts
/// • Room status indicators
/// • Pull to refresh
/// • Empty state
/// • Room selection
class ChatRoomList extends StatelessWidget {
  final List<ChatRoom> rooms;
  final user_model.User? currentUser;
  final Function(ChatRoom)? onRoomTap;
  final Function(ChatRoom)? onDeleteRoom;
  final VoidCallback? onRefresh;
  final VoidCallback? onCreateRoom;
  final bool isLoading;
  final String? error;

  const ChatRoomList({
    super.key,
    required this.rooms,
    this.currentUser,
    this.onRoomTap,
    this.onDeleteRoom,
    this.onRefresh,
    this.onCreateRoom,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _buildErrorState(context);
    }

    if (isLoading && rooms.isEmpty) {
      return _buildLoadingState();
    }

    if (rooms.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return _buildRoomTile(context, room);
        },
      ),
    );
  }

  /// 🏠 Room tile
  Widget _buildRoomTile(BuildContext context, ChatRoom room) {
    final unreadCount = currentUser != null 
      ? room.getUnreadCountForUser(currentUser!.uid)
      : 0;
    
    final otherParticipant = _getOtherParticipant(room);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Dismissible(
        key: Key(room.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 24),
              SizedBox(height: 4),
              Text(
                'ลบ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await _handleDeleteRoom(context, room);
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onRoomTap?.call(room),
            onLongPress: () => _showRoomOptions(context, room),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
              children: [
                // Avatar
                _buildAvatar(otherParticipant),
                
                const SizedBox(width: 12),
                
                // Room info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room title and status
                      Row(
                        children: [
                          // Title
                          Expanded(
                            child: Text(
                              _getRoomTitle(room, otherParticipant),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Status indicator
                          _buildStatusIndicator(_getStatusFromString(room.status)),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Last message preview
                      if (room.lastMessage != null && room.lastMessage!.isNotEmpty)
                        Text(
                          room.lastMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: unreadCount > 0 
                              ? Colors.black87 
                              : Colors.grey.shade600,
                            fontWeight: unreadCount > 0 
                              ? FontWeight.w500 
                              : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // Product info badge (ถ้าเป็นการแชทเกี่ยวกับสินค้า)
                      if (room.chatType == 'product_inquiry' && room.productPrice != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 12,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '\$${room.productPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Timestamp and participants
                      Row(
                        children: [
                          // Last message time
                          if (room.lastActivity != null)
                            Text(
                              _formatTimestamp(room.lastActivity!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          
                          const Spacer(),
                          
                          // Product inquiry badge
                          if (room.chatType == 'product_inquiry')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Product Chat',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          // Participants count
                          else if (room.participants.length > 2)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${room.participants.length} members',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Unread count
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 👤 Avatar
  Widget _buildAvatar(Map<String, String>? participant) {
    final avatarUrl = participant?['avatar'] ?? '';
    final name = participant?['name'] ?? 'Unknown';
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.blue.shade100,
      backgroundImage: avatarUrl.isNotEmpty
        ? CachedNetworkImageProvider(avatarUrl)
        : null,
      child: avatarUrl.isEmpty
        ? Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
    );
  }

  /// 🔴 Status indicator
  Widget _buildStatusIndicator(RoomStatus status) {
    Color color;
    IconData icon;
    String tooltip;

    switch (status) {
      case RoomStatus.active:
        color = Colors.green;
        icon = Icons.circle;
        tooltip = 'Active';
        break;
      case RoomStatus.waiting:
        color = Colors.orange;
        icon = Icons.access_time;
        tooltip = 'Waiting for response';
        break;
      case RoomStatus.closed:
        color = Colors.grey;
        icon = Icons.lock;
        tooltip = 'Closed';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: 12,
        color: color,
      ),
    );
  }

  /// 🕒 Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// 👥 Get other participant
  Map<String, String>? _getOtherParticipant(ChatRoom room) {
    if (currentUser == null) return null;
    
    // ใช้ข้อมูลลูกค้าจาก ChatRoom
    if (room.customerName.isNotEmpty && currentUser!.uid != room.participants.first) {
      return {
        'name': room.customerName,
        'email': room.customerEmail,
        'avatar': room.customerAvatar ?? '',
      };
    }
    
    return {
      'name': 'Customer Support',
      'email': 'support@microcommerce.com',
      'avatar': '',
    };
  }

  /// 📝 Get room title
  String _getRoomTitle(ChatRoom room, Map<String, String>? otherParticipant) {
    // ถ้าเป็นการแชทเกี่ยวกับสินค้า แสดงชื่อสินค้า
    if (room.chatType == 'product_inquiry' && room.productName != null) {
      return 'Product: ${room.productName}';
    }
    
    if (otherParticipant != null) {
      return otherParticipant['name'] ?? 'Unknown User';
    }
    
    return 'Chat Room';
  }

  /// 🔄 Convert status string to enum
  RoomStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return RoomStatus.active;
      case 'waiting':
        return RoomStatus.waiting;
      case 'closed':
      case 'archived':
      case 'blocked':
        return RoomStatus.closed;
      default:
        return RoomStatus.active;
    }
  }

  /// 🔄 Loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading chat rooms...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// 📭 Empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีการสนทนา',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เริ่มสนทนากับทีมซัพพอร์ตของเรา\nหรือแชทจากหน้าสินค้าที่สนใจ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateRoom,
            icon: const Icon(Icons.support_agent),
            label: const Text('แชทซัพพอร์ตทั่วไป'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ Error state
  Widget _buildErrorState(BuildContext context) {
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
            'Failed to load chat rooms',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🗑️ Handle delete room confirmation
  Future<bool> _handleDeleteRoom(BuildContext context, ChatRoom room) async {
    final otherParticipant = _getOtherParticipant(room);
    final displayName = otherParticipant?['name'] ?? 'ร้านค้า';
    
    final shouldDelete = await ConfirmationDialogs.showDeleteChatRoomDialog(
      context: context,
      customerName: displayName,
    );
    
    if (shouldDelete == true) {
      onDeleteRoom?.call(room);
      return true;
    }
    
    return false;
  }

  /// 📋 Show room options
  void _showRoomOptions(BuildContext context, ChatRoom room) {
    final otherParticipant = _getOtherParticipant(room);
    final displayName = otherParticipant?['name'] ?? 'ร้านค้า';
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'การสนทนากับ $displayName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text(
                      'ลบการสนทนา',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('การสนทนาจะหายไปจากรายการของคุณ'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _handleDeleteRoom(context, room);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text('ยกเลิก'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}