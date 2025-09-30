import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/user.dart' as user_model;
import '../services/database_service.dart';

/// 🛒 CartProvider - จัดการตะกร้าสินค้า + State Management
/// 
/// ฟีเจอร์:
/// • Add/Remove/Update สินค้าในตะกร้า
/// • Sync กับ Firestore แบบ Real-time
/// • คำนวณราคารวม, ภาษี, จำนวน
/// • สร้าง Order และเคลียร์ตะกร้า
/// • Error Handling + Loading States
/// 
/// เชื่อมต่อกับ:
/// - DatabaseService (CRUD operations)
/// - UI (ผ่าน ChangeNotifier)
/// - Firestore users/{id}/cart subcollection
class CartProvider extends ChangeNotifier {
  List<user_model.CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;

  List<user_model.CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get subtotal => _items.fold(
        0,
        (sum, item) => sum + item.total,
      );

  double get tax => subtotal * 0.07; // 7% tax
  double get total => subtotal + tax;
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void setUserId(String? userId) {
    _userId = userId;
    if (userId != null) {
      loadCart();
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  Future<void> loadCart() async {
    if (_userId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _items = await DatabaseService.getCartItems(_userId!);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load cart: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    if (_userId == null) return;

    try {
      _errorMessage = null;
      
      final cartItem = user_model.CartItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        imageUrl: product.images.isNotEmpty ? product.images.first : '',
        quantity: quantity,
      );

      await DatabaseService.addToCart(_userId!, cartItem);
      await loadCart(); // Reload cart to get updated data
    } catch (e) {
      _errorMessage = 'Failed to add item to cart: $e';
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_userId == null) return;

    try {
      _errorMessage = null;
      
      await DatabaseService.updateCartItem(_userId!, productId, quantity);
      await loadCart(); // Reload cart to get updated data
    } catch (e) {
      _errorMessage = 'Failed to update item quantity: $e';
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    if (_userId == null) return;

    try {
      _errorMessage = null;
      
      await DatabaseService.removeFromCart(_userId!, productId);
      await loadCart(); // Reload cart to get updated data
    } catch (e) {
      _errorMessage = 'Failed to remove item from cart: $e';
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      _errorMessage = null;
      
      await DatabaseService.clearCart(_userId!);
      _items.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear cart: $e';
      notifyListeners();
    }
  }

  Future<String?> createOrder({
    required String paymentMethod,
    required Map<String, dynamic> shippingAddress,
  }) async {
    if (_userId == null || _items.isEmpty) return null;

    try {
      _errorMessage = null;
      
      final order = user_model.Order(
        id: '', // Will be set by Firestore
        userId: _userId!,
        items: _items,
        subtotal: subtotal,
        tax: tax,
        total: total,
        status: 'pending',
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderId = await DatabaseService.createOrder(order);
      await clearCart(); // Clear cart after successful order
      return orderId;
    } catch (e) {
      _errorMessage = 'Failed to create order: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}