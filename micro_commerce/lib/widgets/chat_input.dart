import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// ⌨️ ChatInput - Input field สำหรับพิมพ์ข้อความและแนบไฟล์
/// 
/// Features:
/// • Text input with emoji support
/// • Image attachment
/// • File attachment
/// • Send button
/// • Typing indicator
/// • Reply mode
class ChatInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool enabled;
  final VoidCallback? onSend;
  final Function(String)? onTextChanged;
  final Function(String)? onImageSelected;
  final Function(String, String, int)? onFileSelected; // (path, name, size)
  final VoidCallback? onTypingStart;
  final VoidCallback? onTypingStop;
  final Widget? replyWidget;
  final VoidCallback? onCancelReply;

  const ChatInput({
    super.key,
    this.controller,
    this.hintText = 'Type a message...',
    this.enabled = true,
    this.onSend,
    this.onTextChanged,
    this.onImageSelected,
    this.onFileSelected,
    this.onTypingStart,
    this.onTypingStop,
    this.replyWidget,
    this.onCancelReply,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  late TextEditingController _controller;
  bool _isTyping = false;
  bool _showAttachmentOptions = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text.trim();
    final wasTyping = _isTyping;
    final isTyping = text.isNotEmpty;

    if (wasTyping != isTyping) {
      setState(() => _isTyping = isTyping);
      
      if (isTyping) {
        widget.onTypingStart?.call();
      } else {
        widget.onTypingStop?.call();
      }
    }

    widget.onTextChanged?.call(text);
  }

  void _onSend() {
    final text = _controller.text.trim();
    print('🎯 ChatInput: Send button pressed, text="$text"');
    
    if (text.isNotEmpty && widget.enabled) {
      print('✅ ChatInput: Text is not empty and enabled, calling onSend');
      setState(() => _isTyping = false);
      widget.onTypingStop?.call();
      widget.onSend?.call(); // เรียก onSend ก่อน แล้วให้ parent เป็นคนทำ clear
    } else {
      print('⚠️ ChatInput: Cannot send - text empty or disabled');
    }
  }

  Future<void> _pickImage() async {
    try {
      // ขอ permission ตาม Android version
      bool hasPermission = false;
      
      if (Platform.isAndroid) {
        // Android 13+ ใช้ READ_MEDIA_IMAGES
        final mediaPermission = await Permission.photos.request();
        final storagePermission = await Permission.storage.request();
        
        hasPermission = mediaPermission.isGranted || storagePermission.isGranted;
        
        if (!hasPermission) {
          _showErrorSnackBar('กรุณาอนุญาตการเข้าถึงรูปภาพในการตั้งค่าแอป');
          return;
        }
      } else {
        hasPermission = true; // iOS จัดการ permission เอง
      }

      print('📷 Starting image picker...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        print('📷 Image selected: ${image.path}');
        // ตรวจสอบว่าไฟล์มีอยู่จริง
        final file = File(image.path);
        if (await file.exists()) {
          print('📷 File exists, size: ${await file.length()} bytes');
          widget.onImageSelected?.call(image.path);
        } else {
          print('❌ File does not exist');
          _showErrorSnackBar('ไม่สามารถเข้าถึงไฟล์รูปภาพได้');
        }
        setState(() => _showAttachmentOptions = false);
      } else {
        print('📷 No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      // ขอ camera permission
      if (Platform.isAndroid) {
        final cameraPermission = await Permission.camera.request();
        if (!cameraPermission.isGranted) {
          _showErrorSnackBar('กรุณาอนุญาตการเข้าถึงกล้องในการตั้งค่าแอป');
          return;
        }
      }

      print('📷 Starting camera...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        print('📷 Photo taken: ${image.path}');
        // ตรวจสอบว่าไฟล์มีอยู่จริง
        final file = File(image.path);
        if (await file.exists()) {
          print('📷 File exists, size: ${await file.length()} bytes');
          widget.onImageSelected?.call(image.path);
        } else {
          print('❌ File does not exist');
          _showErrorSnackBar('ไม่สามารถบันทึกรูปภาพได้');
        }
        setState(() => _showAttachmentOptions = false);
      } else {
        print('📷 No photo taken');
      }
    } catch (e) {
      print('Error taking photo: $e');
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();

        widget.onFileSelected?.call(result.files.single.path!, fileName, fileSize);
        setState(() => _showAttachmentOptions = false);
      }
    } catch (e) {
      print('Error picking file: $e');
      _showErrorSnackBar('Failed to pick file');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reply widget
        if (widget.replyWidget != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: widget.replyWidget!),
                IconButton(
                  onPressed: widget.onCancelReply,
                  icon: const Icon(Icons.close, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],

        // Attachment options
        if (_showAttachmentOptions)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: _pickImage,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: _takePhoto,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildAttachmentOption(
                  icon: Icons.attach_file,
                  label: 'File',
                  onTap: _pickFile,
                  color: Colors.orange,
                ),
              ],
            ),
          ),

        // Input area
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.enabled 
                      ? () => setState(() => _showAttachmentOptions = !_showAttachmentOptions)
                      : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _showAttachmentOptions ? Icons.close : Icons.add,
                        color: widget.enabled 
                          ? Colors.grey.shade600 
                          : Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Text input
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: widget.enabled,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      onSubmitted: widget.enabled ? (_) => _onSend() : null,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.enabled && _controller.text.trim().isNotEmpty ? _onSend : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.enabled && _controller.text.trim().isNotEmpty
                          ? Colors.blue 
                          : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.send,
                        color: widget.enabled && _controller.text.trim().isNotEmpty
                          ? Colors.white 
                          : Colors.grey.shade500,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 📎 Attachment option button
  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}