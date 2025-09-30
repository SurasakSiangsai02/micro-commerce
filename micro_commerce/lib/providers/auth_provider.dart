import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user.dart' as user_model;

/// 👤 AuthProvider - จัดการ Authentication State
/// 
/// ฟีเจอร์:
/// • ติดตาม Login/Logout state แบบ Real-time
/// • จัดการ User Profile จาก Firestore
/// • Login, Register, Password Reset
/// • Error Handling + Loading States
/// • Auto-sync กับ Firebase Auth
/// 
/// เชื่อมต่อกับ:
/// - AuthService (Firebase Auth operations)
/// - DatabaseService (User profile CRUD)
/// - UI (ผ่าน ChangeNotifier)
/// - CartProvider (ส่ง userId)
class AuthProvider with ChangeNotifier {
  User? _firebaseUser;
  user_model.User? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get firebaseUser => _firebaseUser;
  user_model.User? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_firebaseUser != null) {
      try {
        _userProfile = await DatabaseService.getUserProfile(_firebaseUser!.uid);
        notifyListeners();
      } catch (e) {
        // หากยังไม่มีโปรไฟล์ผู้ใช้ ให้สร้างใหม่
        if (e.toString().contains('not-found') || e.toString().contains('No user found')) {
          await _createUserProfile();
        } else {
          _errorMessage = 'Failed to load user profile: $e';
          notifyListeners();
        }
      }
    }
  }

  Future<void> _createUserProfile() async {
    if (_firebaseUser != null) {
      try {
        final newUserData = {
          'email': _firebaseUser!.email ?? '',
          'name': _firebaseUser!.displayName ?? 'User',
          'photoUrl': _firebaseUser!.photoURL ?? '',
          'phone': '',
          'address': '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await DatabaseService.updateUserProfile(_firebaseUser!.uid, newUserData);
        _userProfile = await DatabaseService.getUserProfile(_firebaseUser!.uid);
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Failed to create user profile: $e';
        notifyListeners();
      }
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final credential = await AuthService.signInWithEmail(email, password);
      return credential != null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _setLoading(true);
      _clearError();
      
      final credential = await AuthService.registerWithEmail(email, password, name);
      return credential != null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _userProfile = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await AuthService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_firebaseUser == null) return;

    try {
      _setLoading(true);
      _clearError();
      
      await DatabaseService.updateUserProfile(_firebaseUser!.uid, data);
      await _loadUserProfile();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}