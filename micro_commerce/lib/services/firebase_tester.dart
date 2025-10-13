import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/logger.dart';

/// 🔬 Firebase Connection Tester
/// 
/// ทดสอบการเชื่อมต่อและสิทธิ์ Firebase
class FirebaseConnectionTester {
  
  /// ทดสอบการเชื่อมต่อ Firebase Auth
  static Future<bool> testFirebaseAuth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      Logger.info('Firebase Auth Test:');
      Logger.info('- Current user: ${user?.uid}');
      Logger.info('- Email: ${user?.email}');
      Logger.info('- Email verified: ${user?.emailVerified}');
      Logger.info('- Anonymous: ${user?.isAnonymous}');
      
      if (user != null) {
        // Try to get ID token
        final idToken = await user.getIdToken();
        Logger.info('- ID Token available: ${idToken?.isNotEmpty == true}');
        return true;
      }
      
      Logger.warning('No authenticated user found');
      return false;
      
    } catch (e, stackTrace) {
      Logger.error('Firebase Auth test failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// ทดสอบการเชื่อมต่อ Firebase Storage
  static Future<bool> testFirebaseStorage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Logger.warning('Cannot test storage: user not authenticated');
        return false;
      }
      
      Logger.info('Firebase Storage Test:');
      
      // Test creating a reference
      final ref = FirebaseStorage.instance.ref().child('test/${user.uid}/test.txt');
      Logger.info('- Reference created: ${ref.fullPath}');
      
      // Test basic metadata access (doesn't require upload)
      Logger.info('- Storage bucket: ${FirebaseStorage.instance.bucket}');
      
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('Firebase Storage test failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// ทดสอบการอัพโหลดไฟล์ขนาดเล็ก
  static Future<bool> testUploadSmallFile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Logger.warning('Cannot test upload: user not authenticated');
        return false;
      }
      
      Logger.info('Testing small file upload...');
      
      // Create a small test data
      final testData = 'Test file content - ${DateTime.now().millisecondsSinceEpoch}';
      final bytes = testData.codeUnits;
      
      // Create reference
      final ref = FirebaseStorage.instance
          .ref()
          .child('test_uploads/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.txt');
      
      Logger.info('Uploading to: ${ref.fullPath}');
      
      // Upload
      final uploadTask = ref.putData(Uint8List.fromList(bytes));
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      Logger.info('Upload successful!');
      Logger.info('- Bytes transferred: ${snapshot.bytesTransferred}');
      Logger.info('- Download URL: $downloadUrl');
      
      // Clean up - delete test file
      try {
        await ref.delete();
        Logger.info('- Test file cleaned up');
      } catch (e) {
        Logger.warning('Could not clean up test file: $e');
      }
      
      return true;
      
    } catch (e, stackTrace) {
      Logger.error('Upload test failed', error: e, stackTrace: stackTrace);
      
      // Check specific error types
      if (e.toString().contains('unauthorized')) {
        Logger.error('AUTHORIZATION ERROR: Check Firebase Storage Security Rules');
        Logger.info('Rules should allow: allow read, write: if request.auth != null;');
      }
      
      return false;
    }
  }
  
  /// รัน test ทั้งหมด
  static Future<void> runAllTests() async {
    Logger.info('🔬 Starting Firebase Connection Tests...');
    
    final authTest = await testFirebaseAuth();
    Logger.info('Auth Test: ${authTest ? "✅ PASS" : "❌ FAIL"}');
    
    if (authTest) {
      final storageTest = await testFirebaseStorage();
      Logger.info('Storage Test: ${storageTest ? "✅ PASS" : "❌ FAIL"}');
      
      if (storageTest) {
        final uploadTest = await testUploadSmallFile();
        Logger.info('Upload Test: ${uploadTest ? "✅ PASS" : "❌ FAIL"}');
      }
    }
    
    Logger.info('🔬 Firebase Tests Complete');
  }
}