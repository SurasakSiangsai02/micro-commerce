import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';

/// 💬 ChatService - จัดการข้อมูล Chat ใน Firestore
/// 
/// Collections Structure:
/// • chatRooms/                 - ห้องแชททั้งหมด
/// • chatRooms/{roomId}/messages/ - ข้อความในแต่ละห้อง
/// 
/// Features:
/// • Real-time messaging
/// • File/Image sharing
/// • Read receipts
/// • Room management
class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// === COLLECTIONS ===
  static CollectionReference get chatRoomsCollection =>
      _firestore.collection('chatRooms');

  static CollectionReference messagesCollection(String roomId) =>
      chatRoomsCollection.doc(roomId).collection('messages');

  /// === 🏠 CHAT ROOMS ===

  /// 📋 ดึงรายการห้องแชทของ user (Real-time)
  static Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return chatRoomsCollection
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          var rooms = snapshot.docs
              .map((doc) => ChatRoom.fromFirestore(doc))
              .where((room) => room.status == 'active') // Filter active rooms
              .toList();
          
          // Sort by lastActivity (most recent first) - client side
          rooms.sort((a, b) {
            if (a.lastActivity == null && b.lastActivity == null) return 0;
            if (a.lastActivity == null) return 1;
            if (b.lastActivity == null) return -1;
            return b.lastActivity!.compareTo(a.lastActivity!);
          });
          
          return rooms;
        });
  }

  /// 📋 ดึงรายการห้องแชททั้งหมด (สำหรับ Admin/Moderator)
  static Stream<List<ChatRoom>> getAllChatRooms() {
    return chatRoomsCollection
        .snapshots()
        .map((snapshot) {
          var rooms = snapshot.docs
              .map((doc) => ChatRoom.fromFirestore(doc))
              .where((room) => room.status == 'active') // Filter active rooms
              .toList();
          
          // Sort by lastActivity (most recent first) - client side
          rooms.sort((a, b) {
            if (a.lastActivity == null && b.lastActivity == null) return 0;
            if (a.lastActivity == null) return 1;
            if (b.lastActivity == null) return -1;
            return b.lastActivity!.compareTo(a.lastActivity!);
          });
          
          print('🔥 ChatService: Loaded ${rooms.length} chat rooms for admin');
          return rooms;
        });
  }

  /// 🔍 หาห้องแชทระหว่าง customer กับ merchant
  static Future<ChatRoom?> findExistingRoom(String customerId, String merchantId) async {
    try {
      final querySnapshot = await chatRoomsCollection
          .where('participants', arrayContains: customerId)
          .get();

      for (var doc in querySnapshot.docs) {
        final room = ChatRoom.fromFirestore(doc);
        if (room.status == 'active' && room.participants.contains(merchantId)) {
          return room;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find existing room: $e');
    }
  }

  /// ➕ สร้างห้องแชทใหม่
  static Future<String> createChatRoom({
    required String customerId,
    required String customerName,
    required String customerEmail,
    String? customerAvatar,
    String merchantId = 'support', // Default support ID
    String? productId,        // ID ของสินค้าที่แชทเกี่ยวข้อง
    String? productName,      // ชื่อสินค้าที่แชทเกี่ยวข้อง  
    String? productImage,     // รูปสินค้าที่แชทเกี่ยวข้อง
    double? productPrice,     // ราคาสินค้าที่แชทเกี่ยวข้อง
  }) async {
    try {
      // ตรวจสอบว่ามีห้องอยู่แล้วหรือไม่
      final existingRoom = await findExistingRoom(customerId, merchantId);
      if (existingRoom != null) {
        return existingRoom.id;
      }

      final now = DateTime.now();
      final roomData = {
        'participants': [customerId, merchantId],
        'lastMessage': null,
        'lastActivity': now,
        'unreadCount': {
          customerId: 0,
          merchantId: 0,
        },
        'status': 'active',
        'createdAt': now,
        'updatedAt': now,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'customerAvatar': customerAvatar,
        // ข้อมูลสินค้าที่เกี่ยวข้อง (ถ้ามี)
        'productId': productId,
        'productName': productName,
        'productImage': productImage,
        'productPrice': productPrice,
        'chatType': productId != null ? 'product_inquiry' : 'general_support',
      };

      final docRef = await chatRoomsCollection.add(roomData);
      
      // สร้างข้อความต้อนรับ
      final welcomeMessage = productId != null 
        ? 'สวัสดีครับ! ยินดีต้อนรับสู่ระบบแชท Micro Commerce 🎉\n\nเห็นว่าคุณสนใจสินค้า "$productName" นะครับ\nมีคำถามอะไรเกี่ยวกับสินค้านี้ไหมครับ? 😊'
        : 'สวัสดีครับ! ยินดีต้อนรับสู่ระบบแชท Micro Commerce 🎉\nมีอะไรให้ช่วยเหลือไหมครับ?';
        
      await sendSystemMessage(
        roomId: docRef.id,
        content: welcomeMessage,
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  /// 📊 อัปเดตข้อมูลห้องแชท
  static Future<void> updateChatRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await chatRoomsCollection.doc(roomId).update({
        ...data,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update chat room: $e');
    }
  }

  /// 🚫 บล็อกห้องแชท (Admin only)
  static Future<void> blockChatRoom(String roomId) async {
    try {
      await updateChatRoom(roomId, {'status': 'blocked'});
    } catch (e) {
      throw Exception('Failed to block chat room: $e');
    }
  }

  /// ✅ เปิดห้องแชท
  static Future<void> unblockChatRoom(String roomId) async {
    try {
      await updateChatRoom(roomId, {'status': 'active'});
    } catch (e) {
      throw Exception('Failed to unblock chat room: $e');
    }
  }

  /// === 💬 MESSAGES ===

  /// 📋 ดึงข้อความในห้องแชท (Real-time)
  static Stream<List<ChatMessage>> getRoomMessages(String roomId, {int limit = 50}) {
    return messagesCollection(roomId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  /// 📨 ส่งข้อความ
  static Future<String> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String senderRole,
    required String content,
    String type = 'text',
    String? imageUrl,
    String? fileName,
    int? fileSize,
    String? replyToMessageId,
  }) async {
    try {
      print('🔧 ChatService: Preparing to send message to room $roomId');
      
      final now = DateTime.now();
      final messageData = {
        'roomId': roomId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'senderRole': senderRole,
        'type': type,
        'content': content,
        'imageUrl': imageUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'timestamp': now,
        'readBy': [senderId], // ผู้ส่งอ่านแล้วเสมอ
        'isEdited': false,
        'editedAt': null,
        'replyToMessageId': replyToMessageId,
      };

      print('📝 ChatService: Message data prepared: ${messageData['content']}');
      
      // Debug สำหรับ image messages
      if (type == 'image') {
        print('🖼️ ChatService: Image message debug');
        print('🖼️ ImageURL: ${messageData['imageUrl']}');
        print('🖼️ Content: ${messageData['content']}');
        print('🖼️ Type: ${messageData['type']}');
      }

      // เพิ่มข้อความ
      final docRef = await messagesCollection(roomId).add(messageData);
      print('✅ ChatService: Message added to Firestore with ID: ${docRef.id}');

      // เพิ่ม sender เป็น participant ถ้ายังไม่ได้อยู่ในห้อง (สำหรับ Admin/Moderator)
      await _ensureParticipant(roomId, senderId, senderRole);

      // อัปเดตห้องแชท
      await _updateRoomAfterMessage(roomId, content, senderId, now);
      print('🔄 ChatService: Room updated after message');

      return docRef.id;
    } catch (e) {
      print('❌ ChatService: Failed to send message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  /// 🤖 ส่งข้อความระบบ
  static Future<String> sendSystemMessage({
    required String roomId,
    required String content,
  }) async {
    return await sendMessage(
      roomId: roomId,
      senderId: 'system',
      senderName: 'System',
      senderRole: 'system',
      content: content,
      type: 'system',
    );
  }

  /// 📷 ส่งรูปภาพ
  static Future<String> sendImageMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String senderRole,
    required String imageUrl,
    String? caption,
  }) async {
    final content = caption?.isNotEmpty == true ? caption! : '';
    
    print('🖼️ sendImageMessage Debug:');
    print('🖼️ imageUrl: $imageUrl');  
    print('🖼️ caption: $caption');
    print('🖼️ content: $content');
    
    return await sendMessage(
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      senderRole: senderRole,
      content: content,
      type: 'image',
      imageUrl: imageUrl,
    );
  }

  /// 📁 ส่งไฟล์
  static Future<String> sendFileMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String senderRole,
    required String fileUrl,
    required String fileName,
    required int fileSize,
  }) async {
    return await sendMessage(
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      senderRole: senderRole,
      content: fileUrl,
      type: 'file',
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  /// ✏️ แก้ไขข้อความ
  static Future<void> editMessage(String roomId, String messageId, String newContent) async {
    try {
      await messagesCollection(roomId).doc(messageId).update({
        'content': newContent,
        'isEdited': true,
        'editedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  /// 🗑️ ลบข้อความ
  static Future<void> deleteMessage(String roomId, String messageId) async {
    try {
      await messagesCollection(roomId).doc(messageId).delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  /// 👁️ ทำเครื่องหมายว่าอ่านแล้ว
  static Future<void> markMessageAsRead(String roomId, String messageId, String userId) async {
    try {
      final messageDoc = await messagesCollection(roomId).doc(messageId).get();
      if (messageDoc.exists) {
        final message = ChatMessage.fromFirestore(messageDoc);
        if (!message.isReadBy(userId)) {
          await messagesCollection(roomId).doc(messageId).update({
            'readBy': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  /// 📚 ทำเครื่องหมายข้อความทั้งหมดในห้องว่าอ่านแล้ว
  static Future<void> markAllMessagesAsRead(String roomId, String userId) async {
    try {
      // ดึงข้อความทั้งหมดแล้วกรองฝั่ง client
      final allMessages = await messagesCollection(roomId)
          .orderBy('timestamp', descending: true)
          .limit(100) // จำกัดจำนวนเพื่อประสิทธิภาพ
          .get();

      // กรองข้อความที่ยังไม่อ่าน (client-side filtering)
      final unreadMessages = allMessages.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final readBy = List<String>.from(data?['readBy'] ?? []);
        return !readBy.contains(userId);
      }).toList();

      // อัปเดตทีละข้อความ
      final batch = _firestore.batch();
      for (var doc in unreadMessages) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
      
      if (unreadMessages.isNotEmpty) {
        await batch.commit();
      }

      // อัปเดต unread count ในห้อง
      await chatRoomsCollection.doc(roomId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      throw Exception('Failed to mark all messages as read: $e');
    }
  }

  /// === 📊 UTILITIES ===

  /// � เพิ่ม participant ให้กับห้องแชท (สำหรับ Admin/Moderator)
  static Future<void> _ensureParticipant(String roomId, String userId, String userRole) async {
    try {
      // ตรวจสอบว่าเป็น Admin/Moderator หรือไม่
      if (userRole.toLowerCase().contains('admin') || userRole.toLowerCase().contains('moderator')) {
        final roomDoc = await chatRoomsCollection.doc(roomId).get();
        if (roomDoc.exists) {
          final roomData = roomDoc.data() as Map<String, dynamic>;
          final participants = List<String>.from(roomData['participants'] ?? []);
          
          // เพิ่ม Admin/Moderator เป็น participant ถ้ายังไม่ได้อยู่
          if (!participants.contains(userId)) {
            participants.add(userId);
            await chatRoomsCollection.doc(roomId).update({
              'participants': participants,
              'unreadCount.$userId': 0, // เริ่มต้นด้วย 0 unread
            });
            print('👥 ChatService: Added $userRole $userId as participant to room $roomId');
          }
        }
      }
    } catch (e) {
      print('⚠️ ChatService: Failed to ensure participant: $e');
      // Don't throw error - this is not critical
    }
  }

  /// �🔄 อัปเดตห้องแชทหลังส่งข้อความ
  static Future<void> _updateRoomAfterMessage(
    String roomId,
    String lastMessage,
    String senderId,
    DateTime timestamp,
  ) async {
    try {
      // ดึงข้อมูลห้องปัจจุบัน
      final roomDoc = await chatRoomsCollection.doc(roomId).get();
      if (!roomDoc.exists) return;

      final room = ChatRoom.fromFirestore(roomDoc);
      final newUnreadCount = Map<String, int>.from(room.unreadCount);

      // เพิ่ม unread count สำหรับคนอื่นที่ไม่ใช่ผู้ส่ง
      for (String participantId in room.participants) {
        if (participantId != senderId) {
          newUnreadCount[participantId] = (newUnreadCount[participantId] ?? 0) + 1;
        }
      }

      // อัปเดตห้อง
      await chatRoomsCollection.doc(roomId).update({
        'lastMessage': lastMessage.length > 100 
            ? '${lastMessage.substring(0, 100)}...' 
            : lastMessage,
        'lastActivity': timestamp,
        'unreadCount': newUnreadCount,
      });
    } catch (e) {
      // Ignore error - ไม่ให้กระทบต่อการส่งข้อความ
      print('Failed to update room after message: $e');
    }
  }

  /// 📈 ดึงสถิติการแชท (สำหรับ Admin)
  static Future<Map<String, dynamic>> getChatStatistics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeek = today.subtract(const Duration(days: 7));

      // นับห้องแชททั้งหมด
      final totalRooms = await chatRoomsCollection
          .where('status', isEqualTo: 'active')
          .count()
          .get();

      // นับห้องแชทวันนี้
      final todayRooms = await chatRoomsCollection
          .where('createdAt', isGreaterThanOrEqualTo: today)
          .count()
          .get();

      // นับห้องแชทสัปดาห์นี้
      final weekRooms = await chatRoomsCollection
          .where('createdAt', isGreaterThanOrEqualTo: thisWeek)
          .count()
          .get();

      return {
        'totalRooms': totalRooms.count,
        'todayRooms': todayRooms.count,
        'weekRooms': weekRooms.count,
        'updatedAt': now,
      };
    } catch (e) {
      throw Exception('Failed to get chat statistics: $e');
    }
  }

  /// 🔍 ค้นหาห้องแชท (สำหรับ Admin)
  static Future<List<ChatRoom>> searchChatRooms(String query) async {
    try {
      // ดึงห้องทั้งหมดแล้วกรองฝั่ง client เพื่อหลีกเลี่ยง composite index
      final snapshot = await chatRoomsCollection
          .where('status', isEqualTo: 'active')
          .limit(100)
          .get();

      // กรองและค้นหาฝั่ง client
      final filteredRooms = snapshot.docs
          .map((doc) => ChatRoom.fromFirestore(doc))
          .where((room) => 
            room.customerName.toLowerCase().contains(query.toLowerCase()) ||
            room.customerEmail.toLowerCase().contains(query.toLowerCase()))
          .take(20)
          .toList();

      return filteredRooms;
    } catch (e) {
      throw Exception('Failed to search chat rooms: $e');
    }
  }
}