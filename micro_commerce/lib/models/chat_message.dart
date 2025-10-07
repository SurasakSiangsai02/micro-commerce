import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// 📨 Message Types
enum MessageType {
  text,
  image,
  file,
  system,
}

/// 📨 ChatMessage Model - ข้อความในระบบแชท
/// 
/// Types:
/// • text: ข้อความธรรมดา
/// • image: รูปภาพ
/// • file: ไฟล์อื่นๆ
/// • system: ข้อความระบบ (เช่น user joined, left)
class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String senderRole; // customer, admin, moderator
  final String type; // text, image, file, system
  final String? imageUrl; // สำหรับรูปภาพ
  final String content; // ข้อความหรือ URL
  final String? fileName; // สำหรับไฟล์
  final int? fileSize; // ขนาดไฟล์ (bytes)
  final DateTime timestamp;
  final List<String> readBy; // userId ที่อ่านแล้ว
  final bool isEdited;
  final DateTime? editedAt;
  final String? replyToMessageId; // ตอบกลับข้อความไหน
  
  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.senderRole,
    this.type = 'text',
    required this.content,
    this.imageUrl,
    this.fileName,
    this.fileSize,
    required this.timestamp,
    this.readBy = const [],
    this.isEdited = false,
    this.editedAt,
    this.replyToMessageId,
  });

  /// 📥 สร้าง ChatMessage จาก Firestore document
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ChatMessage(
      id: doc.id,
      roomId: data['roomId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      senderAvatar: data['senderAvatar'],
      senderRole: data['senderRole'] ?? 'customer',
      type: data['type'] ?? 'text',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      fileName: data['fileName'],
      fileSize: data['fileSize'],
      timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt']?.toDate(),
      replyToMessageId: data['replyToMessageId'],
    );
  }

  /// 📤 แปลง ChatMessage เป็น Map สำหรับ Firestore
  Map<String, dynamic> toMap() {
    return {
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
      'timestamp': timestamp,
      'readBy': readBy,
      'isEdited': isEdited,
      'editedAt': editedAt,
      'replyToMessageId': replyToMessageId,
    };
  }

  /// 🔄 สร้าง copy พร้อมการเปลี่ยนแปลง
  ChatMessage copyWith({
    String? content,
    List<String>? readBy,
    bool? isEdited,
    DateTime? editedAt,
  }) {
    return ChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      senderRole: senderRole,
      type: type,
      content: content ?? this.content,
      fileName: fileName,
      fileSize: fileSize,
      timestamp: timestamp,
      readBy: readBy ?? this.readBy,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId,
    );
  }

  /// 👁️ ตรวจสอบว่า user อ่านแล้วหรือไม่
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  /// 🖼️ เป็นข้อความรูปภาพหรือไม่
  bool get isImageMessage => type == 'image';
  
  /// 📁 เป็นข้อความไฟล์หรือไม่
  bool get isFileMessage => type == 'file';
  
  /// 💬 เป็นข้อความธรรมดาหรือไม่
  bool get isTextMessage => type == 'text';
  
  /// 🤖 เป็นข้อความระบบหรือไม่
  bool get isSystemMessage => type == 'system';
  
  /// 🔙 เป็นข้อความตอบกลับหรือไม่
  bool get isReplyMessage => replyToMessageId != null;

  /// 📏 ขนาดไฟล์ในรูปแบบที่อ่านได้
  String get formattedFileSize {
    if (fileSize == null) return '';
    
    if (fileSize! < 1024) {
      return '${fileSize} B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// ⏰ เวลาในรูปแบบที่แสดงผล
  String get formattedTime {
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

  /// 👤 ได้สีของ sender role
  static Color getStaticRoleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFFF6B6B); // Red
      case 'moderator':
        return const Color(0xFF4ECDC4); // Teal
      case 'customer':
      default:
        return const Color(0xFF45B7D1); // Blue
    }
  }

  /// 🏷️ ได้ label ของ sender role
  static String getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return '👑 Admin';
      case 'moderator':
        return '🛡️ Moderator';
      case 'customer':
      default:
        return '👤 Customer';
    }
  }

  /// 📷 Get message type
  MessageType get messageType {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      case 'text':
      default:
        return MessageType.text;
    }
  }

  /// 🎨 Get role color for current message
  Color getRoleColor() {
    return ChatMessage.getStaticRoleColor(senderRole);
  }

  /// 📄 Format file size
  String getFormattedFileSize() {
    if (fileSize == null) return 'Unknown size';
    
    final bytes = fileSize!;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// 🕒 Format timestamp
  String getFormattedTimestamp() {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}