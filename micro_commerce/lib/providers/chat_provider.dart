import 'package:flutter/foundation.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../models/user.dart' as user_model;
import '../utils/logger.dart';

/// 💬 ChatProvider - จัดการ State ของระบบแชท
/// 
/// Features:
/// • Real-time chat rooms
/// • Current active room
/// • Unread message counts
/// • User typing indicators
/// • Message sending status
class ChatProvider with ChangeNotifier {
  List<ChatRoom> _chatRooms = [];
  List<ChatMessage> _currentMessages = [];
  ChatRoom? _currentRoom;
  bool _isLoading = false;
  String? _error;
  user_model.User? _currentUser;
  
  // Typing indicators
  final Map<String, bool> _typingUsers = {};
  final Map<String, DateTime> _lastTypingTime = {};

  // Getters
  List<ChatRoom> get chatRooms => _chatRooms;
  List<ChatMessage> get currentMessages => _currentMessages;
  ChatRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;
  user_model.User? get currentUser => _currentUser;
  Map<String, bool> get typingUsers => _typingUsers;

  /// 👤 ตั้งค่า current user
  void setCurrentUser(user_model.User? user) {
    _currentUser = user;
    notifyListeners();
    
    // Use Future.microtask to avoid setState during build
    Future.microtask(() {
      if (user != null) {
        _loadUserChatRooms();
      } else {
        _clearAllData();
      }
    });
  }

  /// 📋 โหลดรายการห้องแชทของ user
  void _loadUserChatRooms() {
    if (_currentUser == null) return;

    _setLoading(true);
    
    // ตรวจสอบว่าเป็น Admin/Moderator หรือไม่
    final isAdminOrModerator = _currentUser!.role.toString().contains('admin') || 
                               _currentUser!.role.toString().contains('moderator');
    
    Logger.info('ChatProvider: Loading rooms for ${_currentUser!.role} (isAdmin: $isAdminOrModerator)');
    
    final stream = isAdminOrModerator 
        ? ChatService.getAllChatRooms()  // Admin ดูห้องทั้งหมด
        : ChatService.getUserChatRooms(_currentUser!.uid);  // Customer ดูห้องของตัวเอง
    
    stream.listen(
      (rooms) {
        Logger.debug('ChatProvider: Loaded ${rooms.length} chat rooms for ${_currentUser!.role}');
        _chatRooms = rooms;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        Logger.error('ChatProvider Error', error: error);
        _setError('Failed to load chat rooms: $error');
        _setLoading(false);
      },
    );
  }

  /// 🏠 เปิดห้องแชท
  Future<bool> openChatRoom(String roomId) async {
    try {
      _setLoading(true);
      
      // หาห้องในรายการ
      final room = _chatRooms.firstWhere(
        (r) => r.id == roomId,
        orElse: () => throw Exception('Room not found'),
      );
      
      _currentRoom = room;
      Logger.info('ChatProvider: Opening room ${room.id} for ${_currentUser?.role}');
      
      // โหลดข้อความในห้อง
      _loadRoomMessages(roomId);
      
      // ทำเครื่องหมายว่าอ่านแล้ว (เฉพาะถ้าเป็น participant ของห้อง)
      if (_currentUser != null) {
        final isParticipant = room.participants.contains(_currentUser!.uid);
        final isAdminOrModerator = _currentUser!.role.toString().contains('admin') || 
                                   _currentUser!.role.toString().contains('moderator');
        
        if (isParticipant || isAdminOrModerator) {
          try {
            await ChatService.markAllMessagesAsRead(roomId, _currentUser!.uid);
          } catch (e) {
            Logger.warning('Could not mark messages as read', error: e);
            // ไม่ต้อง throw error เพราะไม่ได้เป็น participant
          }
        }
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      Logger.error('ChatProvider: Failed to open room', error: e);
      _setError('Failed to open chat room: $e');
      _setLoading(false);
      return false;
    }
  }

  /// 📨 โหลดข้อความในห้อง
  void _loadRoomMessages(String roomId) {
    ChatService.getRoomMessages(roomId).listen(
      (messages) {
        Logger.debug('ChatProvider: Loaded ${messages.length} messages for room $roomId');
        _currentMessages = messages; // เก็บเรียงลำดับจาก Firestore (ใหม่ไปเก่า)
        notifyListeners();
      },
      onError: (error) {
        Logger.error('ChatProvider: Failed to load messages', error: error);
        _setError('Failed to load messages: $error');
      },
    );
  }

  /// ➕ สร้างห้องแชทใหม่
  Future<String?> createChatRoom({
    String? productId,
    String? productName,
    String? productImage,
    double? productPrice,
  }) async {
    if (_currentUser == null) {
      _setError('User not logged in');
      return null;
    }

    try {
      _setLoading(true);
      
      final roomId = await ChatService.createChatRoom(
        customerId: _currentUser!.uid,
        customerName: _currentUser!.name,
        customerEmail: _currentUser!.email,
        customerAvatar: _currentUser!.photoUrl,
        productId: productId,
        productName: productName,
        productImage: productImage,
        productPrice: productPrice,
      );
      
      _setLoading(false);
      return roomId;
    } catch (e) {
      _setError('Failed to create chat room: $e');
      _setLoading(false);
      return null;
    }
  }

  /// 📤 ส่งข้อความ
  Future<bool> sendMessage(String content, {String? replyToMessageId}) async {
    if (_currentRoom == null || _currentUser == null || content.trim().isEmpty) {
      Logger.warning('Cannot send message: room=${_currentRoom?.id}, user=${_currentUser?.uid}, content="$content"');
      return false;
    }

    try {
      Logger.debug('Sending message: "${content.trim()}" to room ${_currentRoom!.id}');
      
      final messageId = await ChatService.sendMessage(
        roomId: _currentRoom!.id,
        senderId: _currentUser!.uid,
        senderName: _currentUser!.name,
        senderAvatar: _currentUser!.photoUrl,
        senderRole: _currentUser!.role.toString().split('.').last,
        content: content.trim(),
        replyToMessageId: replyToMessageId,
      );
      
      Logger.info('Message sent successfully with ID: $messageId');
      
      // หยุด typing indicator
      _stopTyping();
      
      return true;
    } catch (e) {
      Logger.error('Failed to send message', error: e);
      _setError('Failed to send message: $e');
      return false;
    }
  }

  /// 📷 ส่งรูปภาพ
  Future<bool> sendImageMessage(String imageUrl, {String? caption}) async {
    if (_currentRoom == null || _currentUser == null) {
      return false;
    }

    // Debug: Log the image URL being sent
    Logger.info('ChatProvider: Sending image message with URL: $imageUrl');
    
    try {
      await ChatService.sendImageMessage(
        roomId: _currentRoom!.id,
        senderId: _currentUser!.uid,
        senderName: _currentUser!.name,
        senderAvatar: _currentUser!.photoUrl,
        senderRole: _currentUser!.role.toString().split('.').last,
        imageUrl: imageUrl,
        caption: caption,
      );
      
      Logger.info('ChatProvider: Image message sent successfully');
      return true;
    } catch (e) {
      Logger.error('ChatProvider: Failed to send image', error: e);
      _setError('Failed to send image: $e');
      return false;
    }
  }

  /// 📁 ส่งไฟล์
  Future<bool> sendFileMessage(String fileUrl, String fileName, int fileSize) async {
    if (_currentRoom == null || _currentUser == null) {
      return false;
    }

    try {
      await ChatService.sendFileMessage(
        roomId: _currentRoom!.id,
        senderId: _currentUser!.uid,
        senderName: _currentUser!.name,
        senderAvatar: _currentUser!.photoUrl,
        senderRole: _currentUser!.role.toString().split('.').last,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
      
      return true;
    } catch (e) {
      _setError('Failed to send file: $e');
      return false;
    }
  }

  /// ✏️ แก้ไขข้อความ
  Future<bool> editMessage(String messageId, String newContent) async {
    if (_currentRoom == null || newContent.trim().isEmpty) {
      return false;
    }

    try {
      await ChatService.editMessage(_currentRoom!.id, messageId, newContent.trim());
      return true;
    } catch (e) {
      _setError('Failed to edit message: $e');
      return false;
    }
  }

  /// 🗑️ ลบข้อความ
  Future<bool> deleteMessage(String messageId) async {
    if (_currentRoom == null) return false;

    try {
      await ChatService.deleteMessage(_currentRoom!.id, messageId);
      return true;
    } catch (e) {
      _setError('Failed to delete message: $e');
      return false;
    }
  }

  /// 👁️ ทำเครื่องหมายข้อความว่าอ่านแล้ว
  Future<void> markMessageAsRead(String messageId) async {
    if (_currentRoom == null || _currentUser == null) return;

    try {
      await ChatService.markMessageAsRead(_currentRoom!.id, messageId, _currentUser!.uid);
    } catch (e) {
      Logger.warning('Failed to mark message as read', error: e);
    }
  }

  /// ⌨️ เริ่ม typing
  void startTyping() {
    if (_currentUser == null) return;
    
    _typingUsers[_currentUser!.uid] = true;
    _lastTypingTime[_currentUser!.uid] = DateTime.now();
    notifyListeners();
    
    // หยุด typing หลัง 3 วินาที
    Future.delayed(const Duration(seconds: 3), () {
      _stopTyping();
    });
  }

  /// ⌨️ หยุด typing
  void _stopTyping() {
    if (_currentUser == null) return;
    
    _typingUsers[_currentUser!.uid] = false;
    notifyListeners();
  }

  /// 📊 ได้จำนวนข้อความที่ยังไม่อ่านทั้งหมด
  int get totalUnreadCount {
    if (_currentUser == null) return 0;
    
    return _chatRooms.fold(0, (total, room) {
      return total + room.getUnreadCountForUser(_currentUser!.uid);
    });
  }

  /// 🏠 ออกจากห้องปัจจุบัน
  void leaveChatRoom() {
    _currentRoom = null;
    _currentMessages.clear();
    notifyListeners();
  }

  /// 🧹 ล้างข้อมูลทั้งหมด
  void _clearAllData() {
    _chatRooms.clear();
    _currentMessages.clear();
    _currentRoom = null;
    _typingUsers.clear();
    _lastTypingTime.clear();
    _error = null;
    notifyListeners();
  }

  /// 🔄 รีเฟรชข้อมูล
  Future<void> refresh() async {
    if (_currentUser != null) {
      _loadUserChatRooms();
    }
  }

  /// === UTILITIES ===

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 🗑️ ลบห้องแชท (สำหรับ User และ Admin)
  Future<void> deleteChatRoom(String roomId) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      _setLoading(true);

      // ตรวจสอบว่าเป็น Admin/Moderator หรือไม่
      final isAdminOrModerator = _currentUser!.role.toString().contains('admin') || 
                                 _currentUser!.role.toString().contains('moderator');

      // เรียกใช้ ChatService เพื่อลบห้องแชท
      if (isAdminOrModerator) {
        // Admin ลบได้โดยไม่ต้องเป็น participant
        await ChatService.deleteChatRoomByAdmin(roomId, _currentUser!.uid);
      } else {
        // User ต้องเป็น participant
        await ChatService.deleteChatRoomByUser(roomId, _currentUser!.uid);
      }

      // ถ้าห้องที่ถูกลบเป็นห้องปัจจุบัน ให้ออกจากห้อง
      if (_currentRoom?.id == roomId) {
        leaveChatRoom();
      }

      // Refresh รายการห้องแชท
      _loadUserChatRooms();

      Logger.info('Chat room deleted successfully: $roomId');
    } catch (e) {
      final errorMessage = 'Failed to delete chat room: $e';
      Logger.error(errorMessage);
      _setError(errorMessage);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _clearAllData();
    super.dispose();
  }
}