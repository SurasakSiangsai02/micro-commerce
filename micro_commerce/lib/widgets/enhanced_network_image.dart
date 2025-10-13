import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/logger.dart';

/// 🖼️ Enhanced Network Image Widget
/// พัฒนาจาก Image.network ธรรมดา เพิ่ม error handling และ loading states
class EnhancedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? fallbackText;
  final IconData? fallbackIcon;

  const EnhancedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackText,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          return Container(
            width: width,
            height: height,
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: AppTheme.darkGreen,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                  if (height != null && height! > 60) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Log the error for debugging
          Logger.error('Failed to load image: $imageUrl', error: error);
          
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    fallbackIcon ?? Icons.image_not_supported_outlined,
                    size: _getIconSize(),
                    color: Colors.grey[500],
                  ),
                  if (_shouldShowText()) ...[
                    const SizedBox(height: 4),
                    Text(
                      fallbackText ?? 'Image not available',
                      style: TextStyle(
                        fontSize: _getTextSize(),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getIconSize() {
    if (width != null && width! < 60) return 20;
    if (height != null && height! < 60) return 20;
    if (width != null && width! < 120) return 32;
    if (height != null && height! < 120) return 32;
    return 48;
  }

  double _getTextSize() {
    if (width != null && width! < 80) return 10;
    if (height != null && height! < 80) return 10;
    return 12;
  }

  bool _shouldShowText() {
    return (width == null || width! >= 60) && 
           (height == null || height! >= 60);
  }
}

/// 🖼️ Product Image Widget
/// เฉพาะสำหรับแสดงรูปภาพสินค้า
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      fallbackIcon: Icons.shopping_bag_outlined,
      fallbackText: 'Product image not available',
    );
  }
}

/// 🖼️ Avatar Image Widget
/// สำหรับแสดงรูปโปรไฟล์ผู้ใช้
class AvatarImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool isCircular;

  const AvatarImage({
    super.key,
    required this.imageUrl,
    this.size = 40.0,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(8),
      ),
      child: EnhancedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: isCircular 
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(8),
        fallbackIcon: Icons.person_outline,
        fallbackText: null, // No text for avatars
      ),
    );
  }
}

/// 🖼️ Chat Image Widget  
/// สำหรับแสดงรูปภาพในแชท
class ChatImage extends StatelessWidget {
  final String imageUrl;
  final double maxWidth;
  final double maxHeight;
  final VoidCallback? onTap;

  const ChatImage({
    super.key,
    required this.imageUrl,
    this.maxWidth = 250,
    this.maxHeight = 300,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: EnhancedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(12),
          fallbackIcon: Icons.image_outlined,
          fallbackText: 'Image not available',
        ),
      ),
    );
  }
}