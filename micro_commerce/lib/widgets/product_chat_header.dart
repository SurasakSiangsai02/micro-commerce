import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_room.dart';

/// 🛍️ ProductChatHeader - แสดงข้อมูลสินค้าในแชท
/// 
/// Features:
/// • Product image, name, price
/// • Compact design for chat header
/// • Clickable to view product details
class ProductChatHeader extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback? onProductTap;

  const ProductChatHeader({
    super.key,
    required this.room,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    // แสดงเฉพาะเมื่อเป็นการแชทเกี่ยวกับสินค้า
    if (room.chatType != 'product_inquiry' || room.productName == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: InkWell(
        onTap: onProductTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: room.productImage != null
                  ? CachedNetworkImage(
                      imageUrl: room.productImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chat about label
                  Text(
                    'Chat about:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // Product name
                  Text(
                    room.productName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Product price
                  if (room.productPrice != null)
                    Text(
                      '\$${room.productPrice!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                ],
              ),
            ),
            
            // View product button
            if (onProductTap != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}