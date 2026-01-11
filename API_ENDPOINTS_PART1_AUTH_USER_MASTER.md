# API Endpoints with Request Body/Payload - Part 1

**Authentication, User Management & Master Data**

This document lists API endpoints that require a request body or payload for Authentication, User Management, and Master Data services.

**Base URL:** `/api/v1`

---

## 1. Authentication Endpoints (`/api/v1/auth`)

### 1.1 Check Email
**POST** `/auth/check-email`
```json
{
  "email": "user@example.com"
}
```

### 1.2 Register User
**POST** `/auth/register`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
email: "user@example.com"
user_role: 1
first_name: "John"
last_name: "Doe"
country: "country_id"
city: "city_id"
gender: "male"
address: "123 Main St"
profile_image: "url"
age: 25
password: "password123"
emirates_id: "1234567890123"
```

### 1.3 Login User
**POST** `/auth/login/:role_id`
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### 1.4 Generate OTP
**POST** `/auth/generate-otp`
```json
{
  "emailOrPhone": "user@example.com"
}
```

### 1.5 Verify OTP
**POST** `/auth/verify-otp`
```json
{
  "emailOrPhone": "user@example.com",
  "otp": "123456"
}
```

### 1.6 Reset Password
**POST** `/auth/reset-password`
```json
{
  "emailOrPhone": "user@example.com",
  "newPassword": "new_password123"
}
```

### 1.7 Change Password
**POST** `/auth/change-password`
**Headers:** `Authorization: Bearer <access_token>`
```json
{
  "oldPassword": "old_password123",
  "newPassword": "new_password123"
}
```

### 1.8 Update Account Details
**PATCH** `/auth/update-account`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
first_name: "John"
last_name: "Doe"
phone_number: "1234567890"
```

### 1.9 Update Cover Image
**PATCH** `/auth/update-cover-image`
**Content-Type:** `multipart/form-data`
```
cover_image: <file>
```

### 1.10 Create FCM Token
**POST** `/auth/create-fcm-token`
```json
{
  "user_id": "user_id",
  "fcm_token": "fcm_token_string",
  "device_type": "android",
  "device_id": "device_unique_id"
}
```

---

## 2. User Management Endpoints (`/api/v1/user`)

### 2.1 Update User Status
**PATCH** `/user/update-user-status/:userId`
```json
{
  "status": "Approved"
}
```

### 2.2 Create User
**POST** `/user/create-user`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
email: "user@example.com"
user_role: "role_id"
first_name: "John"
last_name: "Doe"
phone_number: "1234567890"
emirates_id: "1234567890123"
gender: "male"
address: "123 Main St"
age: 25
country: "country_id"
city: "city_id"
specialization: "specialization"
experience: "experience"
experienceYear: 5
password: "password123"
```

### 2.3 Update User
**PUT** `/user/update-user`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
email: "user@example.com"
first_name: "John"
last_name: "Doe"
phone_number: "1234567890"
```

### 2.4 Create Address
**POST** `/user/create-address`
```json
{
  "name": "Home",
  "phone_number": "1234567890",
  "pincode": "12345",
  "street": "123 Main St",
  "flat_no": "Apt 4B",
  "city": "city_id",
  "country": "country_id",
  "isDefault": true
}
```

### 2.5 Update Address
**PUT** `/user/update-address/:id`
```json
{
  "name": "Work",
  "street": "456 Business St",
  "isDefault": false
}
```

### 2.6 Create Subscription Rating Review
**POST** `/user/create-subscription-rating-review`
```json
{
  "subscriptionId": "subscription_id",
  "rating": 5,
  "review": "Great class!",
  "images": ["url1", "url2"]
}
```

### 2.7 Update Subscription Review
**PUT** `/user/update-subscription-review/:subscriptionId`
```json
{
  "rating": 4,
  "review": "Updated review",
  "images": ["url1"]
}
```

### 2.8 Create Trainer Rating Review
**POST** `/user/create-trainer-rating-review`
```json
{
  "trainerId": "trainer_id",
  "rating": 5,
  "review": "Excellent trainer!",
  "images": ["url1", "url2"]
}
```

### 2.9 Update Trainer Review
**PUT** `/user/update-trainer-review/:trainerId`
```json
{
  "rating": 4,
  "review": "Updated review",
  "images": ["url1"]
}
```

### 2.10 Reply to Trainer Review (Admin)
**POST** `/user/admin-reply-trainer-review/:reviewId`
```json
{
  "reply": "Thank you for your feedback!"
}
```

### 2.11 Reply to Subscription Review (Admin)
**POST** `/user/reply-subscription-review/:reviewId`
```json
{
  "reply": "Thank you for your feedback!"
}
```

### 2.12 Toggle Trainer Review Visibility (Admin)
**PUT** `/user/admin-hide-trainer-review/:reviewId`
```json
{
  "isHidden": true
}
```

### 2.13 Toggle Subscription Review Visibility (Admin)
**PUT** `/user/review-subscription-visibility/:reviewId`
```json
{
  "isHidden": true
}
```

### 2.14 Calculate Cart Total
**POST** `/user/cart-total-price-calculate`
```json
{
  "cartItems": ["cart_id1", "cart_id2"],
  "promoCode": "promo_id"
}
```

### 2.15 Update Notification
**PUT** `/user/update-notification/:id`
```json
{
  "isRead": true
}
```

### 2.16 Cancel Order by Customer
**PUT** `/user/cancel-by-customer/::orderDetailsId`
```json
{
  "bookingStatus": "CANCEL"
}
```

---

## 3. Master Data Endpoints (`/api/v1/master`)

### 3.1 Create Terms & Policy
**POST** `/master/create-terms-n-policy`
```json
{
  "type": "terms",
  "content": "Terms and conditions content...",
  "version": "1.0"
}
```

### 3.2 Update Terms & Policy
**PATCH** `/master/update-terms-n-policy/:policyId`
```json
{
  "content": "Updated terms and conditions content...",
  "version": "1.1"
}
```

### 3.3 Create Tenure
**POST** `/master/create-tenure`
```json
{
  "name": "Monthly",
  "duration": 30,
  "isActive": true
}
```

### 3.4 Update Tenure
**PUT** `/master/update-tenure/:id`
```json
{
  "name": "Quarterly",
  "duration": 90
}
```

### 3.5 Create Tax Master
**POST** `/master/create-tax-master`
```json
{
  "name": "VAT",
  "percentage": 5,
  "isActive": true
}
```

### 3.6 Update Tax Master
**PUT** `/master/update-tax-master/:id`
```json
{
  "name": "VAT",
  "percentage": 10,
  "isActive": true
}
```

### 3.7 Get All Tax Masters
**POST** `/master/get-all-tax-master`
```json
{
  "page": 1,
  "limit": 10
}
```

### 3.8 Create Location Master
**POST** `/master/create-location-master`
```json
{
  "name": "Dubai Marina",
  "country": "country_id",
  "city": "city_id",
  "latitude": 25.0772,
  "longitude": 55.1398,
  "address": "Dubai Marina, Dubai"
}
```

### 3.9 Update Location Master
**PUT** `/master/update-location-master/:id`
```json
{
  "name": "Dubai Marina Updated",
  "latitude": 25.0772,
  "longitude": 55.1398
}
```

### 3.10 Get All Location Masters
**POST** `/master/get-all-location-master`
```json
{
  "page": 1,
  "limit": 10,
  "search": "dubai"
}
```

### 3.11 Get Locations by Country and City
**GET** `/master/get-location-by-country-city`
**Query Parameters:**
- `country`: country_id
- `city`: city_id

### 3.12 Create Session
**POST** `/master/create-session`
**Content-Type:** `multipart/form-data`
```
image: <file>
name: "Yoga"
categoryId: "category_id"
description: "Yoga session description"
isActive: true
```

### 3.13 Update Session
**PUT** `/master/update-session/:id`
**Content-Type:** `multipart/form-data`
```
image: <file>
name: "Yoga Updated"
description: "Updated description"
```

### 3.14 Create Category
**POST** `/master/create-category`
**Content-Type:** `multipart/form-data`
```
image: <file>
name: "Fitness"
description: "Fitness category"
isActive: true
```

### 3.15 Update Category
**PUT** `/master/update-category/:id`
**Content-Type:** `multipart/form-data`
```
image: <file>
name: "Fitness Updated"
description: "Updated description"
```

### 3.16 Create Role
**POST** `/master/create-role`
```json
{
  "name": "customer",
  "isActive": true
}
```

### 3.17 Update Role
**PUT** `/master/update-role/:id`
```json
{
  "name": "customer",
  "isActive": true
}
```

### 3.18 Get All Roles
**POST** `/master/get-all-role`
```json
{
  "page": 1,
  "limit": 10
}
```

### 3.19 Create Country
**POST** `/master/create-country`
```json
{
  "name": "United Arab Emirates",
  "code": "UAE",
  "isActive": true
}
```

### 3.20 Update Country
**PUT** `/master/update-country/:countryId`
```json
{
  "name": "United Arab Emirates",
  "code": "UAE",
  "isActive": true
}
```

### 3.21 Create City
**POST** `/master/create-city`
```json
{
  "name": "Dubai",
  "country": "country_id",
  "isActive": true
}
```

### 3.22 Update City
**PUT** `/master/update-city/:cityId`
```json
{
  "name": "Dubai",
  "country": "country_id",
  "isActive": true
}
```

---

**Note:** Refer to the main README.md for complete endpoint documentation including responses and authentication requirements.

