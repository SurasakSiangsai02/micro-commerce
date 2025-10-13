import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_message.dart';
import '../models/user.dart' as user_model;

/// 💬 ChatBubble - แสดง message bubble ในแชท
/// 
/// Features:
/// • Message types: text, image, file, system
/// • Role-based styling
/// • Read receipts
/// • Reply functionality
/// • Edit/Delete for own messages
/// • Timestamp display
class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final user_model.User? currentUser;
  final bool showAvatar;
  final bool showTimestamp;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.currentUser,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final isOwnMessage = widget.currentUser?.uid == widget.message.senderId;
    final isSystemMessage = widget.message.messageType == MessageType.system;
    
    if (isSystemMessage) {
      return _buildSystemMessage();
    }

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () => setState(() => _showActions = !_showActions),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: isOwnMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar (สำหรับข้อความจากคนอื่น)
            if (!isOwnMessage && widget.showAvatar) ...[
              _buildAvatar(),
              const SizedBox(width: 8),
            ],
            
            // Message content
            Flexible(
              child: Column(
                crossAxisAlignment: isOwnMessage 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
                children: [
                  // Reply indicator
                  if (widget.message.replyToMessageId != null)
                    _buildReplyIndicator(),
                  
                  // Message bubble
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: _getBubbleColor(isOwnMessage),
                      borderRadius: _getBubbleBorderRadius(isOwnMessage),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sender name (สำหรับข้อความในกลุ่ม)
                        if (!isOwnMessage && widget.message.senderName.isNotEmpty)
                          _buildSenderName(),
                        
                        // Message content
                        _buildMessageContent(),
                        
                        // Message info (timestamp, read status)
                        _buildMessageInfo(isOwnMessage),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  if (_showActions)
                    _buildActionButtons(isOwnMessage),
                ],
              ),
            ),
            
            // Avatar (สำหรับข้อความของตัวเอง)
            if (isOwnMessage && widget.showAvatar) ...[
              const SizedBox(width: 8),
              _buildAvatar(),
            ],
          ],
        ),
      ),
    );
  }

  /// 🤖 System message
  Widget _buildSystemMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.message.content,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// 👤 Avatar
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: widget.message.getRoleColor(),
      backgroundImage: (widget.message.senderAvatar?.isNotEmpty == true)
        ? CachedNetworkImageProvider(widget.message.senderAvatar ?? '')
        : null,
      child: (widget.message.senderAvatar?.isEmpty != false)
        ? Text(
            (widget.message.senderName.isNotEmpty) 
              ? widget.message.senderName[0].toUpperCase()
              : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
    );
  }

  /// 💬 Reply indicator
  Widget _buildReplyIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            'Replying to message',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Sender name
  Widget _buildSenderName() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Text(
        widget.message.senderName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: widget.message.getRoleColor(),
        ),
      ),
    );
  }

  /// 📄 Message content
  Widget _buildMessageContent() {
    switch (widget.message.messageType) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.image:
        return _buildImageContent();
      case MessageType.file:
        return _buildFileContent();
      case MessageType.system:
        return const SizedBox.shrink(); // จัดการแล้วใน _buildSystemMessage
    }
  }

  /// 📝 Text content
  Widget _buildTextContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        widget.message.content,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// 📷 Image content
  Widget _buildImageContent() {
    final imageUrl = widget.message.imageUrl;
    
    // Debug: แสดงข้อมูล imageUrl
    if (kDebugMode) {
      print('🔍 ChatBubble Debug - Message ID: ${widget.message.id}');
      print('🔍 ChatBubble Debug - Type: ${widget.message.type}');
      print('🔍 ChatBubble Debug - Content: ${widget.message.content}');
      print('🔍 ChatBubble Debug - ImageURL: $imageUrl');
    }
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, color: Colors.grey, size: 48),
              const SizedBox(height: 8),
              Text('No image URL', style: TextStyle(color: Colors.grey)),
              if (kDebugMode) ...[
                const SizedBox(height: 4),
                Text(
                  'Type: ${widget.message.type}\nContent: ${widget.message.content.length > 30 ? widget.message.content.substring(0, 30) + '...' : widget.message.content}',
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Debug: Show image URL in debug mode
        if (kDebugMode)
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              'IMG: ${imageUrl.length > 50 ? imageUrl.substring(0, 50) + '...' : imageUrl}',
              style: const TextStyle(fontSize: 10, color: Colors.blue),
            ),
          ),
        
        // Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: _buildImageWidget(imageUrl),
        ),
        
        // Caption
        if (widget.message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              widget.message.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
      ],
    );
  }

  /// �️ Build image widget with fallbacks
  Widget _buildImageWidget(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 200,
        color: Colors.grey.shade200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('กำลังโหลดรูปภาพ...', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        // Debug log the error
        if (kDebugMode) {
          print('❌ CachedNetworkImage error: $error');
          print('❌ Failed URL: $url');
        }
        
        // Try fallback with Image.network
        return Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                        (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            if (kDebugMode) {
              print('❌ Image.network also failed: $error');
              print('❌ Stack: $stackTrace');
            }
            
            return Container(
              height: 200,
              color: Colors.red.shade50,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    const Text('ไม่สามารถโหลดรูปภาพได้', 
                        style: TextStyle(color: Colors.red)),
                    if (kDebugMode) ...[
                      const SizedBox(height: 4),
                      Text(
                        'URL: ${imageUrl.length > 30 ? imageUrl.substring(0, 30) + '...' : imageUrl}',
                        style: const TextStyle(fontSize: 10, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// �📁 File content
  Widget _buildFileContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.insert_drive_file,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'Unknown file',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.message.getFormattedFileSize(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.download,
            color: Colors.blue.shade600,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// ℹ️ Message info (timestamp, read status)
  Widget _buildMessageInfo(bool isOwnMessage) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edited indicator
          if (widget.message.isEdited)
            Text(
              'edited • ',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          
          // Timestamp
          if (widget.showTimestamp)
            Text(
              widget.message.getFormattedTimestamp(),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          
          // Read status (สำหรับข้อความของตัวเอง)
          if (isOwnMessage) ...[
            const SizedBox(width: 4),
            Icon(
              widget.message.readBy.isNotEmpty 
                ? Icons.done_all 
                : Icons.done,
              size: 12,
              color: widget.message.readBy.isNotEmpty 
                ? Colors.blue 
                : Colors.grey.shade500,
            ),
          ],
        ],
      ),
    );
  }

  /// ⚡ Action buttons
  Widget _buildActionButtons(bool isOwnMessage) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reply
          if (widget.onReply != null)
            _buildActionButton(
              icon: Icons.reply,
              label: 'Reply',
              onTap: widget.onReply!,
            ),
          
          // Edit (เฉพาะข้อความของตัวเอง)
          if (isOwnMessage && 
              widget.onEdit != null && 
              widget.message.messageType == MessageType.text)
            _buildActionButton(
              icon: Icons.edit,
              label: 'Edit',
              onTap: widget.onEdit!,
            ),
          
          // Delete (เฉพาะข้อความของตัวเอง)
          if (isOwnMessage && widget.onDelete != null)
            _buildActionButton(
              icon: Icons.delete,
              label: 'Delete',
              onTap: widget.onDelete!,
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  /// 🔘 Action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: color ?? Colors.grey.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color ?? Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 Bubble color
  Color _getBubbleColor(bool isOwnMessage) {
    if (isOwnMessage) {
      return Colors.blue.shade500;
    } else {
      return Colors.white;
    }
  }

  /// 🔄 Bubble border radius
  BorderRadius _getBubbleBorderRadius(bool isOwnMessage) {
    if (isOwnMessage) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(16),
      );
    }
  }
}