# 🎨 Frontend Customization Complete Guide
## คู่มือการปรับแต่ง Frontend ครบถ้วนทุกส่วน

> 📅 สร้างเมื่อ: ${DateTime.now().toString().split(' ')[0]}
> 
> 🎯 **จุดประสงค์:** คู่มือสำหรับการปรับแต่ง UI/UX ทุกส่วนของแอปพลิเคชัน E-commerce Flutter

---

## 📋 สารบัญ

1. [🎨 การปรับแต่งสี (Colors & Themes)](#การปรับแต่งสี)
2. [🔤 การปรับแต่งตัวอักษร (Typography)](#การปรับแต่งตัวอักษร)
3. [🎪 การปรับแต่ง Components (UI Elements)](#การปรับแต่ง-components)
4. [📱 การปรับแต่ง Layout & Spacing](#การปรับแต่ง-layout--spacing)
5. [✨ การเพิ่ม Animations & Effects](#การเพิ่ม-animations--effects)
6. [🖼️ การปรับแต่งรูปภาพและไอคอน](#การปรับแต่งรูปภาพและไอคอน)
7. [📲 การทำ Responsive Design](#การทำ-responsive-design)
8. [🌙 การเพิ่ม Dark Mode](#การเพิ่ม-dark-mode)
9. [🎯 การปรับแต่งหน้าจอเฉพาะ](#การปรับแต่งหน้าจอเฉพาะ)

---

## 🎨 การปรับแต่งสี

### 1. การเปลี่ยนสีหลักของแอป

**ไฟล์:** `lib/utils/theme.dart`  
**บรรทัด:** 4-7

```dart
// เปลี่ยนจาก
static const darkGreen = Color(0xFF064E3B);
static const lightGreen = Color(0xFF10B981);

// เป็น (ตัวอย่าง: สีฟ้า)
static const darkBlue = Color(0xFF1E3A8A);
static const lightBlue = Color(0xFF3B82F6);

// หรือ (ตัวอย่าง: สีม่วง)
static const darkPurple = Color(0xFF7C3AED);
static const lightPurple = Color(0xFF A855F7);

// หรือ (ตัวอย่าง: สีแดง)
static const darkRed = Color(0xFFDC2626);
static const lightRed = Color(0xFFEF4444);
```

**การใช้งาน:** อัพเดทในบรรทัด 46-49 ด้วย

```dart
colorScheme: ColorScheme.light(
  primary: darkBlue,        // เปลี่ยนจาก darkGreen
  secondary: lightBlue,     // เปลี่ยนจาก lightGreen
  error: errorRed,
```

### 2. การเพิ่มสีใหม่สำหรับ Categories

**ไฟล์:** `lib/utils/theme.dart`  
**บรรทัด:** หลัง 15 (เพิ่มใหม่)

```dart
// Category Colors
static const categoryElectronics = Color(0xFF3B82F6);  // ฟ้า
static const categoryFashion = Color(0xFFEC4899);       // ชมพู
static const categoryHome = Color(0xFFF59E0B);          // ส้ม
static const categorySports = Color(0xFF10B981);        // เขียว
static const categoryBooks = Color(0xFF8B5CF6);         // ม่วง

// Gradient Colors
static const gradientStart = Color(0xFF667EEA);
static const gradientEnd = Color(0xFF764BA2);
```

### 3. การใช้สีในปุ่ม

**ไฟล์:** `lib/widgets/custom_button.dart`  
**บรรทัด:** 26-27

```dart
// เปลี่ยนสีปุ่มเป็นไล่สี
style: ElevatedButton.styleFrom(
  backgroundColor: backgroundColor ?? Colors.transparent,
  foregroundColor: textColor ?? AppTheme.white,
  padding: const EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),  // เปลี่ยนจาก 8
  ),
).copyWith(
  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return AppTheme.darkBlue.withOpacity(0.8);
      }
      return null; // Use gradient instead
    },
  ),
),
```

**และเพิ่ม Container wrapper ใน build method บรรทัด 22:**

```dart
child: Container(
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: ElevatedButton(
    // ... existing button code
  ),
),
```

---

## 🔤 การปรับแต่งตัวอักษร

### 1. การเปลี่ยนฟอนต์

**ไฟล์:** `pubspec.yaml`  
**บรรทัด:** หลัง dependencies (เพิ่มใหม่)

```yaml
fonts:
  - family: Kanit
    fonts:
      - asset: assets/fonts/Kanit-Regular.ttf
      - asset: assets/fonts/Kanit-Bold.ttf
        weight: 700
  - family: Sarabun
    fonts:
      - asset: assets/fonts/Sarabun-Regular.ttf
      - asset: assets/fonts/Sarabun-Bold.ttf
        weight: 700
```

**แล้วใน theme.dart บรรทัด 18-38:**

```dart
static const TextStyle headlineLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: black,
  fontFamily: 'Kanit',  // เพิ่มบรรทัดนี้
);

static const TextStyle headlineMedium = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: black,
  fontFamily: 'Kanit',
);

static const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  color: black,
  fontFamily: 'Sarabun',
);
```

### 2. การเพิ่ม Text Styles ใหม่

**ไฟล์:** `lib/utils/theme.dart`  
**บรรทัด:** หลัง 38 (เพิ่มใหม่)

```dart
// เพิ่ม Text Styles ใหม่
static const TextStyle caption = TextStyle(
  fontSize: 12,
  color: Colors.grey,
  fontFamily: 'Sarabun',
);

static const TextStyle buttonText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
  fontFamily: 'Kanit',
);

static const TextStyle priceText = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: darkGreen,
  fontFamily: 'Kanit',
);

static const TextStyle discountText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Colors.red,
  decoration: TextDecoration.lineThrough,
  fontFamily: 'Sarabun',
);
```

---

## 🎪 การปรับแต่ง Components

### 1. การปรับแต่ง Product Card

**ไฟล์:** `lib/widgets/product_card.dart`  
**บรรทัด:** 26-32

```dart
// เปลี่ยนจาก Card เรียบ เป็น Card ที่มี Shadow และ Border สวย
child: Card(
  elevation: 8,           // เพิ่มจาก 3
  shadowColor: Colors.black26,  // เพิ่มสีเงา
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),  // เพิ่มจาก 16
    side: BorderSide(                         // เพิ่มขอบ
      color: Colors.grey.shade200,
      width: 1,
    ),
  ),
```

**บรรทัด 34-40 เพิ่ม Gradient Background:**

```dart
child: Container(
  width: cardWidth,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Colors.grey.shade50],
    ),
  ),
```

### 2. การเพิ่มปุ่มแบบใหม่

**ไฟล์:** `lib/widgets/custom_button.dart` (สร้างใหม่หรือเพิ่ม)

```dart
// เพิ่ม enum สำหรับประเภทปุ่ม
enum ButtonType { primary, secondary, outline, gradient, icon }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final ButtonType type;           // เพิ่มใหม่
  final IconData? icon;            // เพิ่มใหม่
  final double? width;             // เพิ่มใหม่

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.type = ButtonType.primary,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: _buildButtonByType(),
    );
  }

  Widget _buildButtonByType() {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton();
      case ButtonType.secondary:
        return _buildSecondaryButton();
      case ButtonType.outline:
        return _buildOutlineButton();
      case ButtonType.gradient:
        return _buildGradientButton();
      case ButtonType.icon:
        return _buildIconButton();
    }
  }

  Widget _buildGradientButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: icon != null ? Icon(icon) : SizedBox.shrink(),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }
}
```

### 3. การเพิ่ม Loading Skeleton

**ไฟล์ใหม่:** `lib/widgets/skeleton_loader.dart`

```dart
import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  _SkeletonLoaderState createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.0, 0.0),
              end: Alignment(1.0, 0.0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**การใช้งาน Skeleton ใน ProductCard:**

**ไฟล์:** `lib/widgets/product_card.dart`  
**บรรทัด:** 47-50

```dart
// เปลี่ยนจาก
child: Image.network(
  product.images.first,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(child: CircularProgressIndicator());
  },
),

// เป็น
child: Image.network(
  product.images.first,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return SkeletonLoader(
      width: double.infinity,
      height: cardWidth * 0.75,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    );
  },
),
```

---

## 📱 การปรับแต่ง Layout & Spacing

### 1. การปรับ Spacing ใน Product Grid

**ไฟล์:** `lib/screens/customer/product_list_screen.dart`  
**บรรทัดประมาณ:** 200-220 (ในส่วน GridView)

```dart
// เพิ่ม spacing ระหว่าง cards
GridView.builder(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // เพิ่มจาก 16, 8
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,    // เพิ่มจาก 8
    mainAxisSpacing: 20,     // เพิ่มจาก 8
    childAspectRatio: 0.8,   // ปรับสัดส่วน
  ),
  itemBuilder: (context, index) {
    return ProductCard(product: products[index]);
  },
)
```

### 2. การทำ Staggered Grid Layout

**ไฟล์:** `pubspec.yaml` เพิ่ม dependency:

```yaml
dependencies:
  flutter_staggered_grid_view: ^0.7.0
```

**แล้วใน product_list_screen.dart:**

```dart
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// เปลี่ยนจาก GridView.builder เป็น
MasonryGridView.builder(
  padding: EdgeInsets.all(16),
  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  itemBuilder: (context, index) {
    return ProductCard(product: products[index]);
  },
)
```

### 3. การเพิ่ม Custom AppBar

**ไฟล์:** `lib/widgets/custom_app_bar.dart` (สร้างใหม่)

```dart
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkGreen, AppTheme.lightGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
            : null,
        actions: actions,
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
```

---

## ✨ การเพิ่ม Animations & Effects

### 1. การเพิ่ม Page Transition Animation

**ไฟล์ใหม่:** `lib/utils/page_transitions.dart`

```dart
import 'package:flutter/material.dart';

class PageTransitions {
  // Slide Transition
  static Route slideTransition({
    required Widget page,
    required SlideDirection direction,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        switch (direction) {
          case SlideDirection.fromRight:
            begin = Offset(1.0, 0.0);
            break;
          case SlideDirection.fromLeft:
            begin = Offset(-1.0, 0.0);
            break;
          case SlideDirection.fromTop:
            begin = Offset(0.0, -1.0);
            break;
          case SlideDirection.fromBottom:
            begin = Offset(0.0, 1.0);
            break;
        }

        var tween = Tween(begin: begin, end: Offset.zero);
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  // Fade Transition
  static Route fadeTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  // Scale Transition
  static Route scaleTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(scale: animation, child: child);
      },
    );
  }
}

enum SlideDirection { fromRight, fromLeft, fromTop, fromBottom }
```

**การใช้งาน ใน product_card.dart บรรทัด onTap:**

```dart
onTap: () {
  Navigator.push(
    context,
    PageTransitions.slideTransition(
      page: ProductDetailScreen(product: product),
      direction: SlideDirection.fromRight,
    ),
  );
},
```

### 2. การเพิ่ม Hover Effects ใน Product Card

**ไฟล์:** `lib/widgets/product_card.dart`  
**เปลี่ยน StatelessWidget เป็น StatefulWidget และเพิ่ม:**

```dart
class ProductCard extends StatefulWidget {
  // ... existing code

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Card(
                elevation: _isHovered ? 12 : 3,  // เพิ่ม elevation เมื่อ hover
                // ... rest of card content
              ),
            ),
          );
        },
      ),
    );
  }

  void _onHover(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
```

### 3. การเพิ่ม Staggered Animation ใน List

**ไฟล์:** `lib/widgets/animated_list_item.dart` (สร้างใหม่)

```dart
import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start animation with delay based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**การใช้งานใน GridView:**

```dart
GridView.builder(
  itemBuilder: (context, index) {
    return AnimatedListItem(
      index: index,
      child: ProductCard(product: products[index]),
    );
  },
)
```

---

## 🖼️ การปรับแต่งรูปภาพและไอคอน

### 1. การเพิ่ม Image Shimmer Effect

**ไฟล์:** `lib/widgets/enhanced_network_image.dart`  
**ปรับแต่งเพิ่ม shimmer effect:**

```dart
// เพิ่ม dependencies ใน pubspec.yaml:
// shimmer: ^3.0.0

import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EnhancedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const EnhancedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: borderRadius,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: borderRadius,
          ),
          child: Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
```

### 2. การเพิ่ม Custom Icons

**ไฟล์:** `lib/utils/custom_icons.dart` (สร้างใหม่)

```dart
import 'package:flutter/material.dart';

class CustomIcons {
  // Category Icons
  static const IconData electronics = Icons.devices;
  static const IconData fashion = Icons.checkroom;
  static const IconData home = Icons.home_filled;
  static const IconData sports = Icons.sports_basketball;
  static const IconData books = Icons.menu_book;

  // Action Icons
  static const IconData cart = Icons.shopping_cart_outlined;
  static const IconData cartFilled = Icons.shopping_cart;
  static const IconData favorite = Icons.favorite_border;
  static const IconData favoriteFilled = Icons.favorite;
  static const IconData share = Icons.share_outlined;

  // Status Icons
  static const IconData verified = Icons.verified;
  static const IconData trending = Icons.trending_up;
  static const IconData newProduct = Icons.fiber_new;
  static const IconData discount = Icons.local_offer;

  // สร้าง Icon Widget พร้อมสี
  static Widget categoryIcon(String category, {double size = 24, Color? color}) {
    IconData iconData;
    Color iconColor = color ?? Colors.grey[600]!;

    switch (category.toLowerCase()) {
      case 'electronics':
        iconData = electronics;
        iconColor = color ?? Colors.blue;
        break;
      case 'fashion':
        iconData = fashion;
        iconColor = color ?? Colors.pink;
        break;
      case 'home':
        iconData = home;
        iconColor = color ?? Colors.orange;
        break;
      case 'sports':
        iconData = sports;
        iconColor = color ?? Colors.green;
        break;
      case 'books':
        iconData = books;
        iconColor = color ?? Colors.purple;
        break;
      default:
        iconData = Icons.category;
    }

    return Icon(iconData, size: size, color: iconColor);
  }
}
```

---

## 📲 การทำ Responsive Design

### 1. การสร้าง Responsive Breakpoints

**ไฟล์:** `lib/utils/responsive.dart` (สร้างใหม่)

```dart
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = getGridColumns(context);
    final spacing = 16.0;
    final totalSpacing = spacing * (columns + 1);
    return (screenWidth - totalSpacing) / columns;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) return EdgeInsets.all(16);
    if (isTablet(context)) return EdgeInsets.all(24);
    return EdgeInsets.all(32);
  }
}
```

### 2. การใช้ ResponsiveHelper ใน ProductListScreen

**ไฟล์:** `lib/screens/customer/product_list_screen.dart`  
**แทนที่ GridView ด้วย:**

```dart
GridView.builder(
  padding: ResponsiveHelper.getScreenPadding(context),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveHelper.getGridColumns(context),
    crossAxisSpacing: ResponsiveHelper.isMobile(context) ? 12 : 16,
    mainAxisSpacing: ResponsiveHelper.isMobile(context) ? 12 : 16,
    childAspectRatio: ResponsiveHelper.isMobile(context) ? 0.75 : 0.8,
  ),
  itemBuilder: (context, index) {
    return ProductCard(product: filteredProducts[index]);
  },
)
```

### 3. การสร้าง Responsive Text

**ไฟล์:** `lib/utils/responsive_text.dart` (สร้างใหม่)

```dart
import 'package:flutter/material.dart';
import 'responsive.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.baseStyle,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;

    if (ResponsiveHelper.isMobile(context)) {
      fontSize = mobileFontSize ?? 14;
    } else if (ResponsiveHelper.isTablet(context)) {
      fontSize = tabletFontSize ?? 16;
    } else {
      fontSize = desktopFontSize ?? 18;
    }

    return Text(
      text,
      style: (baseStyle ?? TextStyle()).copyWith(fontSize: fontSize),
    );
  }
}
```

---

## 🌙 การเพิ่ม Dark Mode

### 1. การสร้าง Dark Theme

**ไฟล์:** `lib/utils/theme.dart`  
**เพิ่มหลังบรรทัด 94:**

```dart
// Dark Theme
static ThemeData darkTheme = ThemeData(
  primaryColor: lightGreen,
  scaffoldBackgroundColor: Color(0xFF121212),
  colorScheme: ColorScheme.dark(
    primary: lightGreen,
    secondary: darkGreen,
    error: errorRed,
    surface: Color(0xFF1E1E1E),
    onSurface: white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: white,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: Color(0xFF2C2C2C),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightGreen,
      foregroundColor: white,
    ),
  ),
);

// Dark Text Styles
static const TextStyle darkHeadlineLarge = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  color: white,
);

static const TextStyle darkBodyLarge = TextStyle(
  fontSize: 16,
  color: white,
);
```

### 2. การสร้าง Theme Provider

**ไฟล์:** `lib/providers/theme_provider.dart` (สร้างใหม่)

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
  }
}
```

### 3. การใช้ Theme Provider ใน main.dart

**ไฟล์:** `lib/main.dart`  
**แก้ไขส่วน MaterialApp:**

```dart
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'utils/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ... existing providers
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Micro Commerce',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: LoginScreen(),
        );
      },
    );
  }
}
```

### 4. การสร้าง Theme Switch Widget

**ไฟล์:** `lib/widgets/theme_switch.dart` (สร้างใหม่)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.light_mode,
              color: !themeProvider.isDarkMode ? Colors.orange : Colors.grey,
            ),
            SizedBox(width: 8),
            Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: Colors.purple,
            ),
            SizedBox(width: 8),
            Icon(
              Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.purple : Colors.grey,
            ),
          ],
        );
      },
    );
  }
}
```

---

## 🎯 การปรับแต่งหน้าจอเฉพาะ

### 1. การปรับแต่งหน้า Product Detail

**ไฟล์:** `lib/screens/customer/product_detail_screen.dart`  
**เพิ่มส่วนสำหรับการแสดงภาพแบบ Gallery:**

```dart
// เพิ่มใน build method หลังจาก existing image display
Widget _buildImageGallery() {
  return Container(
    height: 300,
    child: PageView.builder(
      itemCount: widget.product.images.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              widget.product.images[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ),
  );
}

// เพิ่ม Image Indicators
Widget _buildImageIndicators() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      widget.product.images.length,
      (index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index == _currentImageIndex
              ? AppTheme.darkGreen
              : Colors.grey[300],
        ),
      ),
    ),
  );
}
```

### 2. การปรับแต่งหน้า Cart

**ไฟล์:** `lib/screens/customer/cart_screen.dart`  
**เพิ่ม Swipe to Delete:**

```dart
// ใน ListView.builder ของ Cart Items
ListView.builder(
  itemBuilder: (context, index) {
    return Dismissible(
      key: Key(cartItems[index].id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('ยืนยันการลบ'),
            content: Text('คุณต้องการลบสินค้านี้ออกจากตะกร้า?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('ลบ'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _removeFromCart(cartItems[index]);
      },
      child: CartItemCard(item: cartItems[index]),
    );
  },
)
```

### 3. การเพิ่ม Search Bar แบบ Animated

**ไฟล์:** `lib/widgets/animated_search_bar.dart` (สร้างใหม่)

```dart
import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;

  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    this.hintText = 'ค้นหาสินค้า...',
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  
  bool _isExpanded = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 50, end: 250).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.search : Icons.search,
                  color: Colors.grey[600],
                ),
                onPressed: _toggleSearch,
              ),
              if (_isExpanded)
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: widget.onSearch,
                    onSubmitted: (_) => _toggleSearch(),
                  ),
                ),
              if (_isExpanded)
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: _clearAndClose,
                ),
            ],
          ),
        );
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
      _textController.clear();
      widget.onSearch('');
    }
  }

  void _clearAndClose() {
    _textController.clear();
    widget.onSearch('');
    _toggleSearch();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }
}
```

**การใช้งานใน ProductListScreen AppBar:**

```dart
appBar: AppBar(
  title: Text('สินค้า'),
  actions: [
    AnimatedSearchBar(
      onSearch: (query) {
        setState(() {
          searchQuery = query;
        });
      },
    ),
    SizedBox(width: 16),
  ],
),
```

---

## 📋 สรุปไฟล์ที่ต้องแก้ไข/เพิ่ม

### ไฟล์ที่ต้องแก้ไข:
1. `lib/utils/theme.dart` - เพิ่มสี, ฟอนต์, dark theme
2. `lib/widgets/custom_button.dart` - เพิ่มประเภทปุ่ม, gradient
3. `lib/widgets/product_card.dart` - เพิ่ม animations, hover effects
4. `lib/screens/customer/product_list_screen.dart` - responsive grid, search
5. `lib/main.dart` - เพิ่ม theme provider
6. `pubspec.yaml` - เพิ่ม dependencies ใหม่

### ไฟล์ที่ต้องสร้างใหม่:
1. `lib/widgets/skeleton_loader.dart` - Loading animation
2. `lib/widgets/custom_app_bar.dart` - Custom AppBar
3. `lib/widgets/animated_list_item.dart` - List animations
4. `lib/widgets/animated_search_bar.dart` - Search bar
5. `lib/widgets/theme_switch.dart` - Dark mode toggle
6. `lib/utils/page_transitions.dart` - Page transitions
7. `lib/utils/responsive.dart` - Responsive helpers
8. `lib/utils/custom_icons.dart` - Custom icons
9. `lib/providers/theme_provider.dart` - Theme management

### Dependencies ที่ต้องเพิ่ม:
```yaml
dependencies:
  flutter_staggered_grid_view: ^0.7.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

---

🎉 **ตอนนี้คุณมีคู่มือครบถ้วนสำหรับการปรับแต่ง Frontend ได้ทุกส่วนแล้ว!** 

แต่ละตัวอย่างสามารถนำไปใช้ได้เลย และปรับแต่งเพิ่มเติมตามความต้องการ สามารถเริ่มจากส่วนที่ง่ายๆ เช่น การเปลี่ยนสี หรือการเพิ่ม animations ก่อนได้เลยครับ