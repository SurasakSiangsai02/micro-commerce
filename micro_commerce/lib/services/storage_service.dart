import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';

/// 🗄️ Firebase Storage Service
/// 
/// รับผิดชอบการจัดการไฟล์และรูปภาพบน Firebase Storage
/// - อัพโหลดรูปภาพสำหรับแชท
/// - อัพโหลดไฟล์เอกสาร
/// - จัดการ URL และ metadata
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  /// 📱 อัพโหลดรูปภาพสำหรับแชท
  static Future<String?> uploadChatImage({
    required String filePath,
    required String userId,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        Logger.error('File does not exist: $filePath');
        return null;
      }
      
      final fileName = 'chat_images/${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Logger.info('Starting chat image upload: $fileName');
      Logger.info('File size: ${await file.length()} bytes');
      Logger.info('User ID: $userId');
      
      // Upload file to Firebase Storage
      final ref = _storage.ref().child(fileName);
      final uploadTask = ref.putFile(file);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        Logger.info('Upload progress: ${progress.toStringAsFixed(1)}%');
      });
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Validate URL
      if (downloadUrl.isEmpty) {
        Logger.error('Empty download URL received');
        return null;
      }
      
      Logger.business('Chat image uploaded successfully', {
        'userId': userId,
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'fileSize': snapshot.totalBytes,
      });
      
      Logger.info('✅ Final download URL: $downloadUrl');
      
      return downloadUrl;
      
    } catch (e, stackTrace) {
      Logger.error('Failed to upload chat image', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 📄 อัพโหลดไฟล์เอกสารสำหรับแชท
  static Future<String?> uploadChatFile({
    required String filePath,
    required String userId,
    String? customFileName,
  }) async {
    try {
      final file = File(filePath);
      final originalName = customFileName ?? path.basename(filePath);
      final extension = path.extension(originalName);
      final fileName = 'chat_files/${userId}/${DateTime.now().millisecondsSinceEpoch}$extension';
      
      Logger.info('Starting chat file upload: $fileName');
      
      // Upload file to Firebase Storage
      final ref = _storage.ref().child(fileName);
      final uploadTask = ref.putFile(file);
      
      // Set metadata
      await ref.updateMetadata(SettableMetadata(
        customMetadata: {
          'originalName': originalName,
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      ));
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      Logger.business('Chat file uploaded successfully', {
        'userId': userId,
        'fileName': fileName,
        'originalName': originalName,
        'downloadUrl': downloadUrl,
        'fileSize': snapshot.totalBytes,
      });
      
      return downloadUrl;
      
    } catch (e, stackTrace) {
      Logger.error('Failed to upload chat file', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 📱 อัพโหลดรูปภาพสำหรับสินค้า (สำหรับแอดมิน)
  static Future<String?> uploadProductImage({
    required String filePath,
    required String productId,
  }) async {
    try {
      final file = File(filePath);
      final fileName = 'products/${productId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Logger.info('Starting product image upload: $fileName');
      
      // Upload file to Firebase Storage
      final ref = _storage.ref().child(fileName);
      final uploadTask = ref.putFile(file);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      Logger.business('Product image uploaded successfully', {
        'productId': productId,
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'fileSize': snapshot.totalBytes,
      });
      
      return downloadUrl;
      
    } catch (e, stackTrace) {
      Logger.error('Failed to upload product image', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 🗑️ ลบไฟล์จาก Firebase Storage
  static Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      
      Logger.info('File deleted successfully: $downloadUrl');
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('Failed to delete file', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// 📊 ดึงข้อมูล metadata ของไฟล์
  static Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
      
    } catch (e, stackTrace) {
      Logger.error('Failed to get file metadata', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 🔗 สร้าง signed URL สำหรับไฟล์ที่มีระยะเวลาจำกัด
  static Future<String?> getSignedUrl(String downloadUrl, Duration expiry) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final signedUrl = await ref.getDownloadURL();
      
      Logger.info('Generated signed URL for file');
      return signedUrl;
      
    } catch (e, stackTrace) {
      Logger.error('Failed to generate signed URL', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 🔧 Helper: ตรวจสอบว่าไฟล์เป็นรูปภาพหรือไม่
  static bool isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(extension);
  }
  
  /// 🔧 Helper: ตรวจสอบขนาดไฟล์
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      Logger.warning('Could not get file size for: $filePath');
      return 0;
    }
  }
  
  /// 🔧 Helper: ตรวจสอบว่าไฟล์เกิน limit หรือไม่
  static Future<bool> isFileSizeValid(String filePath, {int maxSizeInMB = 10}) async {
    final fileSize = await getFileSize(filePath);
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSize <= maxSizeInBytes;
  }
}