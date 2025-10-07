# Coupon System Testing Guide

## Overview
คู่มือการทดสอบระบบคูปองส่วนลดแบบครบถ้วนสำหรับ Micro Commerce App

## 🔧 Components Implemented

### 1. Backend Services
- **CouponService**: CRUD operations with Firestore
- **CouponProvider**: State management for coupon operations
- **Coupon Model**: Data model with validation logic

### 2. Admin Features
- **CouponManagementScreen**: Dashboard with statistics and coupon list
- **CouponFormScreen**: Create/edit coupon form with validation
- **Real-time coupon statistics**: Usage tracking and analytics

### 3. Customer Features
- **Checkout Integration**: Coupon input and discount application
- **Order History**: Enhanced display with coupon information
- **Real-time validation**: Instant feedback on coupon validity

## 🧪 Testing Scenarios

### Phase 1: Admin Coupon Creation
**Test Case 1.1: Create Percentage Coupon**
1. Login as admin
2. Navigate to Coupon Management
3. Click "Add New Coupon"
4. Fill form:
   - Code: SAVE20
   - Type: Percentage
   - Value: 20
   - Usage Limit: 100
   - Expiry: Future date
5. Save and verify creation

**Test Case 1.2: Create Fixed Amount Coupon**
1. Create new coupon
2. Fill form:
   - Code: FLAT10
   - Type: Fixed Amount
   - Value: 10.00
   - Usage Limit: 50
   - Expiry: Future date
3. Save and verify creation

**Test Case 1.3: Auto-Generate Coupon Code**
1. Create new coupon
2. Click "Generate Random Code"
3. Verify 8-character alphanumeric code generation
4. Save coupon

### Phase 2: Coupon Validation Logic
**Test Case 2.1: Valid Coupon Application**
1. Switch to customer view
2. Add items to cart
3. Go to checkout
4. Enter valid coupon code (SAVE20)
5. Verify discount calculation
6. Verify order total update

**Test Case 2.2: Expired Coupon**
1. Create coupon with past expiry date
2. Try to apply in checkout
3. Verify error message display
4. Verify no discount applied

**Test Case 2.3: Usage Limit Exceeded**
1. Create coupon with usage limit 1
2. Complete one order with coupon
3. Try to use same coupon again
4. Verify usage limit error

**Test Case 2.4: Invalid Coupon Code**
1. Enter non-existent coupon code
2. Verify "Coupon not found" error
3. Verify no discount applied

### Phase 3: Customer Experience
**Test Case 3.1: Percentage Discount Calculation**
```
Cart Total: $100.00
Coupon: SAVE20 (20% off)
Expected Result:
- Subtotal: $100.00
- Discount: -$20.00
- Tax: $6.40 (8% on discounted amount)
- Total: $86.40
```

**Test Case 3.2: Fixed Amount Discount**
```
Cart Total: $50.00
Coupon: FLAT10 ($10 off)
Expected Result:
- Subtotal: $50.00
- Discount: -$10.00
- Tax: $3.20 (8% on discounted amount)
- Total: $43.20
```

**Test Case 3.3: Minimum Order Validation**
1. Add $30 worth of items
2. Try applying FLAT10 (min order $50)
3. Verify minimum order error
4. Add more items to meet minimum
5. Apply coupon successfully

### Phase 4: Order Integration
**Test Case 4.1: Order Completion with Coupon**
1. Apply valid coupon
2. Complete checkout process
3. Verify order saved with coupon details:
   - couponCode
   - couponValue
   - couponType
   - discountAmount
4. Verify coupon usage count incremented

**Test Case 4.2: Order History Display**
1. Complete order with coupon
2. Go to Order History
3. View order details
4. Verify coupon information displayed:
   - Coupon code and type
   - Discount amount
   - Adjusted total

### Phase 5: Error Handling
**Test Case 5.1: Network Error Simulation**
1. Disconnect internet
2. Try to apply coupon
3. Verify appropriate error handling
4. Reconnect and retry

**Test Case 5.2: Concurrent Usage**
1. Two users try same limited coupon
2. Verify proper usage tracking
3. Verify one user gets error when limit reached

**Test Case 5.3: Form Validation**
1. Try creating coupon with:
   - Empty code
   - Negative value
   - Past expiry date
   - Zero usage limit
2. Verify validation errors

## 📊 Admin Dashboard Testing

### Statistics Verification
1. Create multiple coupons
2. Use some coupons in orders
3. Verify statistics accuracy:
   - Total coupons count
   - Active coupons count
   - Total usage count
   - Most used coupon

### Coupon Management
1. Edit existing coupon
2. Deactivate coupon
3. Delete unused coupon
4. Search/filter coupons
5. Sort by different criteria

## 🚀 Performance Testing

### Load Testing
1. Create 100+ coupons
2. Test admin dashboard performance
3. Test coupon search/filter speed
4. Test concurrent coupon applications

### Memory Testing
1. Navigate between screens multiple times
2. Create/delete many coupons
3. Monitor for memory leaks
4. Test app stability

## ✅ Acceptance Criteria

### Admin Requirements
- [ ] Admin can create percentage and fixed amount coupons
- [ ] Admin can set usage limits and expiry dates
- [ ] Admin can view real-time coupon statistics
- [ ] Admin can edit/deactivate/delete coupons
- [ ] Auto-generate random coupon codes works

### Customer Requirements
- [ ] Customers can apply coupons during checkout
- [ ] Real-time discount calculation works correctly
- [ ] Appropriate error messages for invalid coupons
- [ ] Order history shows coupon information
- [ ] Coupon validation handles all edge cases

### Technical Requirements
- [ ] All data persists correctly in Firestore
- [ ] Real-time updates work across devices
- [ ] Error handling is comprehensive
- [ ] Performance is acceptable with large datasets
- [ ] UI is responsive and user-friendly

## 🐛 Known Issues & Solutions

### Issue 1: Null Safety
**Problem**: Some null safety warnings in order integration
**Solution**: Added proper null checks and default values

### Issue 2: Color Constants
**Problem**: AppTheme.primaryColor not defined
**Solution**: Updated to use AppTheme.lightGreen constant

### Issue 3: Order Model Updates
**Problem**: Order class needed coupon fields
**Solution**: Extended Order model with coupon-related properties

## 📝 Next Steps

1. **Complete Testing**: Run all test cases systematically
2. **Bug Fixes**: Address any issues found during testing
3. **Performance Optimization**: Optimize if needed based on test results
4. **Documentation**: Update user documentation with coupon features
5. **Deployment**: Prepare for production deployment

## 🎯 Success Metrics

- **Functionality**: All test cases pass without errors
- **Performance**: App loads and responds within 2-3 seconds
- **User Experience**: Intuitive UI with clear feedback
- **Data Integrity**: All coupon and order data saves correctly
- **Error Handling**: Graceful handling of all error scenarios

---

**Prepared by**: AI Assistant  
**Date**: Testing Phase  
**Version**: 1.0  
**Status**: Ready for comprehensive testing