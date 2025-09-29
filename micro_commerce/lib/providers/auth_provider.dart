import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user.dart' as user_model;

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
        _errorMessage = 'Failed to load user profile: $e';
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