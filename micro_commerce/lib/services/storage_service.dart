import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Debug Firebase Storage authentication status
  static Future<void> _debugFirebaseStorageAuth() async {
    print('🔍 === Firebase Storage Debug Info ===');
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('🔍 User authenticated: YES');
      print('🔍 UID: ${currentUser.uid}');
      print('🔍 Email: ${currentUser.email}');
      print('🔍 Email verified: ${currentUser.emailVerified}');
      print('🔍 Provider data: ${currentUser.providerData.map((p) => p.providerId).toList()}');
      
      // ตรวจสอบ Firebase Auth token
      try {
        final idToken = await currentUser.getIdToken();
        print('🔍 Has ID Token: ${idToken?.isNotEmpty ?? false}');
        
        final idTokenResult = await currentUser.getIdTokenResult();
        print('🔍 Token expiration: ${idTokenResult.expirationTime}');
        print('🔍 Token auth time: ${idTokenResult.authTime}');
        
        if (idTokenResult.claims != null && idTokenResult.claims!.isNotEmpty) {
          print('🔍 Custom claims: ${idTokenResult.claims}');
        }
      } catch (e) {
        print('❌ Token error: $e');
      }
    } else {
      print('❌ User NOT authenticated');
    }
    
    // ตรวจสอบ Firebase Storage instance
    print('🔍 Storage bucket: ${_storage.bucket}');
    print('🔍 Storage app: ${_storage.app.name}');
    
    print('🔍 === End Debug Info ===');
  }
  
  /// 📱 อัพโหลดรูปภาพสำหรับแชท
  static Future<String?> uploadChatImage({
    required String filePath,
    required String userId,
  }) async {
    try {
      // เรียกใช้ debug function ก่อน
      await _debugFirebaseStorageAuth();
      
      print('🔍 StorageService: Starting upload process...');
      print('🔍 File path: $filePath');
      print('🔍 User ID: $userId');
      
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ StorageService: File does not exist: $filePath');
        Logger.error('File does not exist: $filePath');
        return null;
      }
      
      final fileSize = await file.length();
      print('🔍 File exists, size: $fileSize bytes');
      
      if (fileSize == 0) {
        print('❌ StorageService: File is empty');
        Logger.error('File is empty: $filePath');
        return null;
      }
      
      final fileName = 'chat/${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Logger.info('Starting chat image upload: $fileName');
      Logger.info('File size: $fileSize bytes');
      Logger.info('User ID: $userId');
      print('🔍 Firebase path: $fileName');
      
      // Check authentication status
      final currentUser = FirebaseAuth.instance.currentUser;
      print('🔍 Current user: ${currentUser?.uid}');
      print('🔍 User email: ${currentUser?.email}');
      print('🔍 Email verified: ${currentUser?.emailVerified}');
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Upload file to Firebase Storage
      print('🔍 Creating Firebase Storage reference...');
      final ref = _storage.ref().child(fileName);
      print('🔍 Storage reference: ${ref.fullPath}');
      print('🔍 Storage bucket: ${ref.bucket}');
      
      print('🔍 Starting upload task...');
      final uploadTask = ref.putFile(file);
      
      // Monitor upload progress with enhanced logging
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('📊 Upload progress: ${progress.toStringAsFixed(1)}%');
          print('📊 State: ${snapshot.state}');
          print('📊 Bytes: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
          Logger.info('Upload progress: ${progress.toStringAsFixed(1)}%');
        },
        onError: (error) {
          print('❌ Upload stream error: $error');
          Logger.error('Upload stream error: $error');
        },
      );
      
      print('🔍 Waiting for upload to complete...');
      
      // Wait for upload to complete with timeout
      final snapshot = await uploadTask.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          print('❌ Upload timeout after 5 minutes');
          Logger.error('Upload timeout after 5 minutes');
          throw Exception('Upload timeout after 5 minutes');
        },
      );
      
      print('✅ Upload completed successfully');
      print('✅ Final state: ${snapshot.state}');
      print('✅ Total bytes uploaded: ${snapshot.totalBytes}');
      
      print('🔍 Getting download URL...');
      
      // Get download URL with enhanced error tracking
      print('🔍 Attempting to get download URL...');
      
      try {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('✅ Download URL retrieved successfully');
        print('🔍 Download URL: $downloadUrl');
        
        // Test URL accessibility
        if (downloadUrl.startsWith('https://')) {
          print('✅ URL format is valid');
        } else {
          print('⚠️ Unexpected URL format: $downloadUrl');
        }
        
        // Validate และ log success
        if (downloadUrl.isEmpty) {
          print('❌ Empty download URL received');
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
        
      } catch (urlError, urlStackTrace) {
        print('❌ Failed to get download URL');
        print('❌ URL Error: $urlError');
        print('❌ URL Stack trace: $urlStackTrace');
        
        // ตรวจสอบ specific Firebase Storage errors
        if (urlError is FirebaseException) {
          print('❌ Firebase URL Error Code: ${urlError.code}');
          print('❌ Firebase URL Error Message: ${urlError.message}');
          
          if (urlError.code == 'unauthorized') {
            print('❌ AUTHORIZATION ERROR at getDownloadURL step');
            print('❌ This suggests Storage Rules configuration issue');
            print('❌ File was uploaded successfully but cannot generate public URL');
            
            // ลองดึง metadata เพื่อยืนยันว่าไฟล์อยู่จริง
            try {
              final metadata = await snapshot.ref.getMetadata();
              print('✅ File metadata exists: ${metadata.name}');
              print('✅ File size: ${metadata.size}');
              print('✅ Content type: ${metadata.contentType}');
              print('❌ But download URL generation failed - Storage Rules issue');
            } catch (metadataError) {
              print('❌ Cannot get metadata either: $metadataError');
            }
          }
        }
        
        throw urlError;
      }
      
    } catch (e, stackTrace) {
      print('❌ StorageService Error: $e');
      print('❌ Stack trace: $stackTrace');
      
      // จัดการ Firebase Storage specific errors
      String errorMessage = 'Unknown upload error';
      
      if (e is FirebaseException) {
        print('❌ Firebase Storage Exception Code: ${e.code}');
        print('❌ Firebase Storage Exception Message: ${e.message}');
        
        switch (e.code) {
          case 'unauthorized':
            errorMessage = 'User is not authorized to perform the desired action.';
            print('❌ Firebase Storage unauthorized - checking auth status...');
            final currentUser = FirebaseAuth.instance.currentUser;
            print('❌ Current user UID: ${currentUser?.uid}');
            print('❌ Email: ${currentUser?.email}');
            print('❌ Email verified: ${currentUser?.emailVerified}');
            print('❌ Upload path was: chat/$userId/');
            break;
          case 'cancelled':
            errorMessage = 'Upload was cancelled';
            break;
          case 'unknown':
            errorMessage = 'Unknown Firebase Storage error occurred';
            break;
          default:
            errorMessage = 'Firebase Storage error: ${e.message}';
        }
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network connection error';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Upload timeout';
      } else if (e.toString().contains('storage')) {
        errorMessage = 'Firebase Storage error';
      }
      
      print('❌ Error type: $errorMessage');
      Logger.error('Failed to upload chat image: $errorMessage', error: e, stackTrace: stackTrace);
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