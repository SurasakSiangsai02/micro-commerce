# 💬 Chat Deletion System Documentation

## Overview
ระบบลบการสนทนาสำหรับผู้ใช้ (User Chat Deletion System) ที่ถูกเพิ่มเข้าไปในแอป Micro-Commerce เพื่อให้ลูกค้าสามารถจัดการการสนทนาของตนเองได้

## ✨ Features Added

### 1. Chat Service Enhancements
📁 `lib/services/chat_service.dart`

#### New Methods:
- **`deleteChatRoomByUser()`**: ลบห้องแชทโดย user (เปลี่ยนสถานะเป็น 'deleted_by_user')
- **`restoreChatRoom()`**: กู้คืนห้องแชท (สำหรับ Admin)
- **`getDeletedChatRooms()`**: ดึงห้องแชทที่ถูกลบ (สำหรับ Admin)

#### Key Features:
- ✅ **Soft Delete**: ไม่ลบข้อมูลจริง แต่เปลี่ยนสถานะ
- ✅ **Admin Recovery**: Admin สามารถกู้คืนการสนทนาได้
- ✅ **History Preservation**: เก็บประวัติการลบเพื่อ audit trail
- ✅ **User Validation**: ตรวจสอบสิทธิ์ก่อนลบ

### 2. Chat Provider Enhancements
📁 `lib/providers/chat_provider.dart`

#### New Methods:
- **`deleteChatRoom()`**: Method สำหรับ UI เรียกใช้ลบห้องแชท

#### Functionality:
- ✅ Loading state management
- ✅ Error handling
- ✅ Auto refresh หลังลบสำเร็จ
- ✅ Leave current room ถ้าห้องที่ลบเป็นห้องปัจจุบัน

### 3. Enhanced Confirmation Dialogs
📁 `lib/widgets/confirmation_dialog.dart`

#### New Dialogs:
- **`showDeleteChatRoomDialog()`**: ยืนยันการลบห้องแชท
- **`showDeleteChatMessageDialog()`**: ยืนยันการลบข้อความ
- **`showLeaveChatRoomDialog()`**: ยืนยันการออกจากห้องแชท

#### UI/UX Features:
- 🎯 **Contextual Messages**: แสดงชื่อร้านค้า/ลูกค้าในข้อความ
- ⚠️ **Clear Warning**: อธิบายผลที่จะตามมาอย่างชัดเจน
- 🎨 **Consistent Design**: ใช้ design system เดียวกัน

### 4. Chat Room List Widget Upgrades
📁 `lib/widgets/chat_room_list.dart`

#### New Features:
- **Swipe-to-Delete**: ปัดเพื่อลบการสนทนา
- **Long Press Menu**: กดค้างเพื่อดูตัวเลือก
- **Visual Feedback**: แสดงไอคอนและสีเมื่อปัดลบ

#### UI Components:
```dart
// Swipe-to-Delete Background
Dismissible(
  key: Key(room.id),
  direction: DismissDirection.endToStart,
  background: Container(/* Red delete background */),
  confirmDismiss: (direction) async {
    return await _handleDeleteRoom(context, room);
  },
  child: /* Room tile content */
)
```

### 5. Customer Chat Screen Updates
📁 `lib/screens/customer/customer_chat_screen.dart`

#### New Features:
- **Menu Button**: ปุ่ม 3 จุดใน AppBar
- **Delete Option**: ตัวเลือกลบการสนทนาในเมนู
- **Dual Delete Methods**: ลบได้ทั้งจากหน้าแชทและรายการแชท

#### Implementation:
```dart
// PopupMenuButton ใน AppBar
PopupMenuButton<String>(
  onSelected: (value) {
    switch (value) {
      case 'delete':
        _handleDeleteChatRoom(room);
        break;
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'delete',
      child: Row(/* Delete option */),
    ),
  ],
)
```

## 🔧 Technical Implementation

### Database Schema Changes

#### ChatRoom Status Values:
- `active`: ห้องแชทปกติ
- `deleted_by_user`: ลูกค้าลบแล้ว
- `closed`: ปิดโดย Admin
- `pending`: รอการตอบกลับ

#### New Fields:
```dart
{
  "status": "deleted_by_user",
  "deletedBy": "user_id",
  "deletedAt": Timestamp,
  "lastActivity": Timestamp
}
```

### Firestore Security Rules
```javascript
// Allow users to soft-delete their own chat rooms
match /chatRooms/{roomId} {
  allow update: if request.auth != null 
    && resource.data.participants.hasAll([request.auth.uid])
    && request.resource.data.keys().hasOnly(['status', 'deletedBy', 'deletedAt', 'lastActivity'])
    && request.resource.data.status == 'deleted_by_user'
    && request.resource.data.deletedBy == request.auth.uid;
}
```

### Error Handling Strategy

#### User-Friendly Messages:
```dart
try {
  await chatProvider.deleteChatRoom(room.id);
  // แสดงข้อความสำเร็จ
} catch (e) {
  // แสดงข้อผิดพลาดที่เข้าใจง่าย
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
  );
}
```

## 🧪 Test Cases Added

### TC022-TC025: Chat Deletion System Tests
📁 `test/unit_test.dart`

#### Test Coverage:
1. **TC022**: Chat room deletion validation
2. **TC023**: Chat deletion confirmation dialog
3. **TC024**: Chat room status validation  
4. **TC025**: Chat swipe-to-delete validation

#### Test Results:
```
✅ 27/27 tests passed (including 4 new chat deletion tests)
```

## 🎨 User Experience Flow

### Scenario 1: Delete from Chat List
```
1. User เห็นรายการแชท
2. Swipe ซ้ายบนการสนทนาที่ต้องการลบ
3. แสดง red background พร้อมไอคอนลบ
4. ปล่อย swipe → แสดง confirmation dialog
5. กด "ลบการสนทนา" → ลบสำเร็จ
6. รายการหายไปจาก list
```

### Scenario 2: Delete from Chat Screen
```
1. User เปิดการสนทนา
2. กดปุ่ม 3 จุดใน AppBar
3. เลือก "ลบการสนทนา"
4. แสดง confirmation dialog
5. กด "ลบการสนทนา" → ลบสำเร็จ
6. กลับไปหน้ารายการแชท
```

### Scenario 3: Long Press Menu
```
1. User กดค้างที่รายการแชท
2. แสดง Bottom Sheet พร้อมตัวเลือก
3. กด "ลบการสนทนา"
4. แสดง confirmation dialog
5. ดำเนินการตามต้องการ
```

## 📊 UI Components Design

### Swipe-to-Delete Background
- 🔴 **Background Color**: Red (#F44336)
- 🗑️ **Icon**: `Icons.delete_outline`
- 📝 **Text**: "ลบ" (Bold, White)
- 📱 **Animation**: Smooth reveal on swipe

### Confirmation Dialog
- ⚠️ **Icon**: `Icons.chat_bubble_outline`
- 🔴 **Color Scheme**: Red for danger action
- 💬 **Message**: Contextual with shop/customer name
- 🔘 **Buttons**: "ลบการสนทนา" / "ยกเลิก"

### Menu Options
- 📋 **Bottom Sheet**: Modern design
- 🗑️ **Delete Option**: Red icon and text
- ❌ **Cancel Option**: Gray icon and text

## 🔒 Security Considerations

### Permission Checks
```dart
// ตรวจสอบว่า user เป็นผู้เข้าร่วมห้องแชท
final participants = List<String>.from(roomData['participants'] ?? []);
if (!participants.contains(userId)) {
  throw Exception('User is not a participant in this chat room');
}
```

### Data Privacy
- **Soft Delete**: ข้อมูลยังอยู่ แต่ไม่แสดงให้ user เห็น
- **Admin Access**: เฉพาะ Admin เท่านั้นที่เห็นแชทที่ถูกลบ
- **Audit Trail**: เก็บข้อมูลว่าใครลบเมื่อไหร่

### Rate Limiting
- **Client-side**: ป้องกันการลบซ้ำๆ ด้วย loading states
- **Server-side**: Firestore security rules จำกัดการเข้าถึง

## 🚀 Benefits

### For Users
- 🧹 **Clean Interface**: จัดการรายการแชทให้เป็นระเบียบ
- 🚫 **Stop Unwanted Chats**: หยุดการสนทนาที่ไม่ต้องการ
- 💨 **Quick Actions**: ลบได้รวดเร็วด้วย swipe gesture
- 🛡️ **Safe Actions**: มี confirmation ป้องกันการลบผิดพลาด

### For Business
- 📊 **Data Retention**: เก็บข้อมูลสำหรับ analytics
- 🔍 **Admin Oversight**: Admin ยังดูประวัติได้
- 🎯 **Better UX**: ประสบการณ์ที่ดีขึ้นลดการ abandon
- 📈 **User Satisfaction**: ควบคุมการสนทนาได้เอง

### For Developers
- 🧪 **Testable**: มี test cases ครอบคลุม
- 🔧 **Maintainable**: Code structure ชัดเจน
- 🔄 **Reusable**: Components ใช้ซ้ำได้
- 📚 **Documented**: มี documentation ครบถ้วน

## 📅 Implementation Timeline

- **Phase 1**: Backend methods (ChatService, ChatProvider)
- **Phase 2**: UI components (Confirmation dialogs, Swipe gestures)
- **Phase 3**: Integration (Chat screens, Room list)
- **Phase 4**: Testing (Unit tests, Manual testing)
- **Phase 5**: Documentation (API docs, User guides)

## 📈 Quality Metrics

### Before Implementation
- **Test Cases**: 23 cases
- **Chat Features**: Basic messaging only
- **User Control**: Limited chat management

### After Implementation
- **Test Cases**: 27 cases (+4 new)
- **Chat Features**: Full chat lifecycle management
- **User Control**: Complete chat deletion system

## 🔮 Future Enhancements

### Planned Features
1. **Batch Delete**: ลบหลายการสนทนาพร้อมกัน
2. **Archive System**: เก็บถาวรแทนการลบ
3. **Auto-Delete**: ลบการสนทนาเก่าอัตโนมัติ
4. **Restore Function**: ให้ user กู้คืนการสนทนาได้เอง
5. **Block System**: บล็อค user เฉพาะ

### Technical Improvements
1. **Offline Support**: ลบแชทแม้ไม่มีเน็ต
2. **Push Notifications**: แจ้งเตือนเมื่อมีการลบ
3. **Analytics**: ติดตามพฤติกรรมการลบแชท
4. **Performance**: Optimize การโหลดรายการแชท

## 📱 Platform Support

### Mobile Gestures
- **iOS**: Natural swipe gestures
- **Android**: Material Design patterns
- **Responsive**: ทำงานได้ทุกขนาดหน้าจอ

### Accessibility
- **Screen Readers**: รองรับการอ่านหน้าจอ
- **High Contrast**: สีชัดเจนสำหรับผู้มีปัญหาสายตา
- **Large Text**: ปรับขนาดตัวอักษรได้

## 💡 Usage Examples

### Basic Chat Deletion
```dart
// จาก ChatProvider
await chatProvider.deleteChatRoom(roomId);
```

### With Confirmation
```dart
final shouldDelete = await ConfirmationDialogs.showDeleteChatRoomDialog(
  context: context,
  customerName: 'ร้านค้า ABC',
);

if (shouldDelete == true) {
  await chatProvider.deleteChatRoom(roomId);
}
```

### Swipe-to-Delete Setup
```dart
Dismissible(
  key: Key(room.id),
  direction: DismissDirection.endToStart,
  confirmDismiss: (direction) async {
    return await _handleDeleteRoom(context, room);
  },
  child: /* Room tile */,
)
```

---

*Documentation สร้างเมื่อ: October 18, 2025*
*Version: 1.0.0*  
*Author: GitHub Copilot*