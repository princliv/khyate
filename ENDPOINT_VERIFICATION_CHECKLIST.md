# Endpoint Verification Checklist

Use this checklist to verify all endpoints are working correctly.

## ✅ Authentication Endpoints

### 1.1 Check Email
- [ ] Test with valid email - should return role_id
- [ ] Test with invalid email - should return error
- [ ] Verify auto-role detection works in login screen

### 1.2 Register User
- [ ] Test registration with all required fields
- [ ] Verify gender values: "Male", "Female", "Others" (capitalized)
- [ ] Verify user_role is sent as number (3 for customer)
- [ ] Verify city is sent as city_id (not city name)
- [ ] Verify country is sent as country_id
- [ ] Test registration success flow

### 1.3 Login User
- [ ] Test login as customer (role_id: 3)
- [ ] Test login as admin (role_id: 1)
- [ ] Verify token is saved after login
- [ ] Verify role is saved after login

### 1.4 Generate OTP
- [ ] Test with email
- [ ] Test with phone number
- [ ] Verify OTP is sent successfully

### 1.5 Verify OTP
- [ ] Test with correct OTP
- [ ] Test with incorrect OTP
- [ ] Verify token is saved after successful verification

### 1.6 Reset Password
- [ ] Complete OTP flow: Generate → Verify → Reset
- [ ] Test with email
- [ ] Test with phone
- [ ] Verify new password works for login

### 1.7 Change Password
- [ ] Test with correct old password
- [ ] Test with incorrect old password
- [ ] Verify new password works after change

### 1.8 Update Account Details
- [ ] Test updating first_name
- [ ] Test updating last_name
- [ ] Test updating phone_number
- [ ] Test updating profile_image (URL)

### 1.9 Update Cover Image
- [ ] Test updating cover image URL

### 1.10 Create FCM Token
- [ ] Test after login
- [ ] Verify token is saved

---

## ✅ User Management Endpoints

### 2.4 Create Address
- [ ] Test creating address with all fields
- [ ] Test setting default address
- [ ] Verify address appears in list

### 2.5 Update Address
- [ ] Test updating address name
- [ ] Test updating street
- [ ] Test toggling default status

### 2.6 Create Subscription Review
- [ ] Test creating review with rating
- [ ] Test creating review with images
- [ ] Verify review is saved

### 2.7 Update Subscription Review
- [ ] Test updating rating
- [ ] Test updating review text
- [ ] Test updating images

### 2.8 Create Trainer Review
- [ ] Test creating trainer review
- [ ] Verify review is saved

### 2.9 Update Trainer Review
- [ ] Test updating trainer review

### 2.14 Calculate Cart Total
- [ ] Test with cart items
- [ ] Test with promo code
- [ ] Verify total calculation is correct

### 2.15 Update Notification
- [ ] Test marking notification as read
- [ ] Verify notification status updates

---

## ✅ Master Data Endpoints

### Get All Countries
- [ ] Verify countries load in signup screen
- [ ] Verify countries are displayed correctly

### Get Cities by Country
- [ ] Verify cities load when country is selected
- [ ] Verify cities are displayed correctly

### Get All Sessions
- [ ] Test fetching all sessions
- [ ] Verify sessions are displayed

### Get All Categories
- [ ] Test fetching all categories
- [ ] Verify categories are displayed

### Get All Roles
- [ ] Test fetching all roles
- [ ] Verify roles are displayed

### Get All Location Masters
- [ ] Test fetching locations
- [ ] Test with search parameter
- [ ] Verify pagination works

### Get Locations by Country and City
- [ ] Test with country and city IDs
- [ ] Verify filtered locations are returned

---

## 🐛 Common Issues to Check

1. **CORS Errors**: Ensure backend CORS allows localhost
2. **Network Errors**: Verify backend is running on port 5000
3. **Response Parsing**: Check console for response structure issues
4. **Field Name Mismatches**: Verify all field names match backend exactly
5. **Gender Values**: Must be "Male", "Female", "Others" (capitalized)
6. **Role IDs**: Must be numbers (1 for admin, 3 for customer)
7. **City/Country**: Must be IDs (ObjectId), not names

---

## 📱 UI Flow Tests

1. **Registration Flow**
   - [ ] Fill all fields
   - [ ] Select country → cities load
   - [ ] Submit → success → navigate to home

2. **Login Flow**
   - [ ] Enter email → optionally auto-detect role
   - [ ] Select role → login → navigate to home

3. **Forgot Password Flow**
   - [ ] Enter email → send OTP
   - [ ] Enter OTP → verify
   - [ ] Enter new password → reset → login with new password

4. **Profile Update Flow**
   - [ ] Load profile → verify data displays
   - [ ] Edit personal info → save → verify update
   - [ ] Edit contact info → save → verify update

5. **Address Management Flow**
   - [ ] View addresses list
   - [ ] Add new address → verify appears
   - [ ] Update address → verify changes

6. **Change Password Flow**
   - [ ] Enter old password
   - [ ] Enter new password
   - [ ] Confirm → verify change

---

## 🔍 Debug Tips

1. Check browser console for API request/response logs
2. Verify backend server is running: `http://localhost:5000`
3. Check network tab for failed requests
4. Verify CORS headers in response
5. Check API response structure matches expected format

---

**Status**: All endpoints connected and ready for testing
**Last Verified**: $(date)

