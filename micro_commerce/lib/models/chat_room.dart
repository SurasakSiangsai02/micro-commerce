import 'package:cloud_firestore/cloud_firestore.dart';

/// 💬 ChatRoom Model - ห้องแชทระหว่างลูกค้าและร้านค้า
/// 
/// Structure:
/// • roomId: unique identifier
/// • participants: [customerId, merchantId/adminId]
/// • lastMessage: ข้อความล่าสุด
/// • lastActivity: เวลาข้อความล่าสุด
/// • unreadCount: จำนวนข้อความที่ยังไม่อ่าน (per user)
/// • status: active, archived, blocked
class ChatRoom {
  final String id;
  final List<String> participants; // [customerId, merchantId]
  final String? lastMessage;
  final DateTime? lastActivity;
  final Map<String, int> unreadCount; // userId -> count
  final String status; // active, archived, blocked
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional info
  final String customerName;
  final String customerEmail;
  final String? customerAvatar;
  
  // Product-related info (for product inquiries)
  final String? productId;
  final String? productName;
  final String? productImage;
  final double? productPrice;
  final String chatType; // 'general_support' or 'product_inquiry'

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastActivity,
    required this.unreadCount,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    required this.customerName,
    required this.customerEmail,
    this.customerAvatar,
    this.productId,
    this.productName,
    this.productImage,
    this.productPrice,
    this.chatType = 'general_support',
  });

  /// 📥 สร้าง ChatRoom จาก Firestore document
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastActivity: data['lastActivity']?.toDate(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      status: data['status'] ?? 'active',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      customerName: data['customerName'] ?? 'Unknown User',
      customerEmail: data['customerEmail'] ?? '',
      customerAvatar: data['customerAvatar'],
      productId: data['productId'],
      productName: data['productName'],
      productImage: data['productImage'],
      productPrice: data['productPrice']?.toDouble(),
      chatType: data['chatType'] ?? 'general_support',
    );
  }

  /// 📤 แปลง ChatRoom เป็น Map สำหรับ Firestore
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastActivity': lastActivity,
      'unreadCount': unreadCount,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerAvatar': customerAvatar,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'productPrice': productPrice,
      'chatType': chatType,
    };
  }

  /// 🔄 สร้าง copy พร้อมการเปลี่ยนแปลง
  ChatRoom copyWith({
    String? lastMessage,
    DateTime? lastActivity,
    Map<String, int>? unreadCount,
    String? status,
    DateTime? updatedAt,
  }) {
    return ChatRoom(
      id: id,
      participants: participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName,
      customerEmail: customerEmail,
      customerAvatar: customerAvatar,
      productId: productId,
      productName: productName,
      productImage: productImage,
      productPrice: productPrice,
      chatType: chatType,
    );
  }

  /// 🔍 ตรวจสอบว่า user นี้เป็นผู้เข้าร่วมหรือไม่
  bool hasParticipant(String userId) {
    return participants.contains(userId);
  }

  /// 📊 ได้จำนวนข้อความที่ยังไม่อ่านของ user
  int getUnreadCountForUser(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// ✅ เป็น active room หรือไม่
  bool get isActive => status == 'active';
  
  /// 🚫 ถูก block หรือไม่
  bool get isBlocked => status == 'blocked';
}