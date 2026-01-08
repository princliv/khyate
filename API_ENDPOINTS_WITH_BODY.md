# API Endpoints with Request Body/Payload

This document lists all API endpoints that require a request body or payload, organized by service category.

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

## 4. Sub Service Endpoints (`/api/v1/subservice`)

### 4.1 Create Sub Service
**POST** `/subservice/createSubService`
**Content-Type:** `multipart/form-data`
```
image: <file>
name: "Haircut"
serviceTypeId: "service_id"
groomingDetails: "[{\"weightType\":\"small\",\"price\":100,\"description\":\"Small pet\"}]"
```

### 4.2 Update Sub Service
**PUT** `/subservice/updateSubService/:subServiceId`
**Content-Type:** `multipart/form-data`
```
image: <file>
name: "Haircut Updated"
groomingDetails: "[{\"weightType\":\"small\",\"price\":120}]"
```

### 4.3 Get All Sub Services
**POST** `/subservice/getAllSubService`
```json
{
  "page": 1,
  "limit": 10,
  "search": "haircut"
}
```

---

## 5. Trainer Endpoints (`/api/v1/trainer`)

### 5.1 Create Trainer
**POST** `/trainer/create-trainer`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
email: "trainer@example.com"
first_name: "John"
last_name: "Doe"
phone_number: "1234567890"
gender: "male"
address: "123 Main St"
age: 30
country: "country_id"
city: "city_id"
specialization: "Yoga"
experience: "5 years"
experienceYear: 5
password: "password123"
serviceProvider: "[service_id1, service_id2]"
```

### 5.2 Update Trainer
**PUT** `/trainer/update-trainer/:id`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
first_name: "John"
last_name: "Doe Updated"
specialization: "Advanced Yoga"
```

### 5.3 Update Trainer Status
**PATCH** `/trainer/update-trainer-status/:trainerId`
```json
{
  "status": "active"
}
```

### 5.4 Update Trainer Profile (By Trainer)
**PUT** `/trainer/update-trainer-profiles/:trainerId`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
first_name: "John"
last_name: "Doe"
specialization: "Yoga"
```

### 5.5 Get All Assigned Jobs
**POST** `/trainer/get-all-assigned-jobs`
```json
{
  "page": 1,
  "limit": 10,
  "status": "assigned"
}
```

### 5.6 Trainer Check-in
**POST** `/trainer/checkin/:orderDetailsId`
```json
{
  "checkinTime": "2024-01-01T10:00:00Z",
  "latitude": 25.0772,
  "longitude": 55.1398
}
```

### 5.7 Initiate Checkout
**POST** `/trainer/initiate-checkout/:orderDetailsId`
```json
{
  "notes": "Service completed successfully"
}
```

### 5.8 Complete Checkout
**POST** `/trainer/complete-checkout/:orderDetailsId`
```json
{
  "completionTime": "2024-01-01T11:00:00Z",
  "images": ["url1", "url2"]
}
```

---

## 6. Admin Endpoints (`/api/v1/admin`)

### 6.1 Create Promo Code
**POST** `/admin/create-promo-code`
**Content-Type:** `multipart/form-data`
```
image: <file>
code: "SAVE20"
discountType: "percentage"
discountValue: 20
minOrderAmount: 100
maxDiscountAmount: 50
validFrom: "2024-01-01"
validTo: "2024-12-31"
usageLimit: 100
isActive: true
```

### 6.2 Update Promo Code
**PUT** `/admin/update-promo-code/:id`
**Content-Type:** `multipart/form-data`
```
image: <file>
discountValue: 25
validTo: "2024-12-31"
```

### 6.3 Get All Promo Codes
**POST** `/admin/get-all-promo-codes`
```json
{
  "page": 1,
  "limit": 10,
  "search": "SAVE"
}
```

### 6.4 Get Planner Dashboard
**POST** `/admin/get-planner-dashboard`
```json
{
  "startDate": "2024-01-01",
  "endDate": "2024-01-31",
  "locationId": "location_id"
}
```

### 6.5 Get Available Groomers
**POST** `/admin/get-all-available-groomers`
```json
{
  "date": "2024-01-01",
  "timeslotId": "timeslot_id",
  "subServiceId": "subservice_id"
}
```

### 6.6 Get Available Groomers for Booking
**POST** `/admin/get-all-available-groomers-booking`
```json
{
  "date": "2024-01-01",
  "timeslotId": "timeslot_id",
  "subServiceId": "subservice_id"
}
```

### 6.7 Create Article
**POST** `/admin/create-artical`
**Content-Type:** `multipart/form-data`
```
image: <file>
title: "Article Title"
content: "Article content..."
author: "author_name"
isPublished: true
```

### 6.8 Update Article
**PUT** `/admin/update-artical/:id`
**Content-Type:** `multipart/form-data`
```
image: <file>
title: "Updated Title"
content: "Updated content..."
```

---

## 7. Manager Endpoints (`/api/v1/manager`)

### 7.1 Create Manager
**POST** `/manager/create-manager`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
email: "manager@example.com"
first_name: "John"
last_name: "Doe"
phone_number: "1234567890"
password: "password123"
```

### 7.2 Update Manager
**PUT** `/manager/update-manger/:id`
**Content-Type:** `multipart/form-data`
```
profile_image: <file>
first_name: "John"
last_name: "Doe Updated"
```

---

## 8. Time Slot Endpoints (`/api/v1/timeslot`)

### 8.1 Create Time Slot
**POST** `/timeslot/createTimeslot`
```json
{
  "startTime": "09:00",
  "endTime": "10:00",
  "isActive": true
}
```

### 8.2 Update Time Slot
**PUT** `/timeslot/updateTimeslot/:timeslotId`
```json
{
  "startTime": "09:30",
  "endTime": "10:30",
  "isActive": true
}
```

### 8.3 Get All Time Slots
**POST** `/timeslot/getAllTimeslots`
```json
{
  "page": 1,
  "limit": 10
}
```

### 8.4 Get Free Groomers
**POST** `/timeslot/getFreeGroomers`
```json
{
  "date": "2024-01-01",
  "timeslotId": "timeslot_id"
}
```

### 8.5 Get Available Time Slots
**POST** `/timeslot/getAvailableTimeSlots/:subServiceId`
```json
{
  "date": "2024-01-01",
  "groomerId": "groomer_id"
}
```

### 8.6 Mark Office Holiday
**POST** `/timeslot/markOfficeHoliday`
```json
{
  "date": "2024-01-01",
  "reason": "New Year"
}
```

### 8.7 Mark Groomer Holiday
**POST** `/timeslot/markGroomerHoliday`
```json
{
  "groomerId": "groomer_id",
  "date": "2024-01-01",
  "reason": "Personal leave"
}
```

---

## 9. Cart Endpoints (`/api/v1/cart`)

### 9.1 Create Cart Item
**POST** `/cart/create-cart`
```json
{
  "subServiceId": "subservice_id",
  "quantity": 1,
  "timeslotId": "timeslot_id",
  "bookingDate": "2024-01-01",
  "petDetails": {
    "weightType": "small",
    "petName": "Buddy"
  }
}
```

---

## 10. Currency Endpoints (`/api/v1/currency`)

### 10.1 Create Currency
**POST** `/currency/create-currency`
```json
{
  "code": "USD",
  "name": "US Dollar",
  "symbol": "$",
  "isActive": true
}
```

### 10.2 Update Currency
**PUT** `/currency/update-currency/:id`
```json
{
  "name": "US Dollar",
  "symbol": "$",
  "isActive": true
}
```

### 10.3 Create or Update Exchange Rate
**POST** `/currency/createOrUpdateExchange`
```json
{
  "fromCurrency": "USD",
  "toCurrency": "AED",
  "rate": 3.67,
  "isActive": true
}
```

---

## 11. Order Endpoints (`/api/v1/order`)

### 11.1 Create Order
**POST** `/order/create-order`
```json
{
  "cartItems": ["cart_id1", "cart_id2"],
  "addressId": "address_id",
  "paymentMethod": "card",
  "promoCode": "promo_id"
}
```

### 11.2 Update Order
**PUT** `/order/update-order`
```json
{
  "orderId": "order_id",
  "status": "confirmed",
  "notes": "Order notes"
}
```

---

## 12. Payment Endpoints (`/api/v1/payment`)

### 12.1 Create Payment
**POST** `/payment/create-payment`
```json
{
  "orderId": "order_id",
  "amount": 100,
  "paymentMethod": "card",
  "transactionId": "txn_123456"
}
```

---

## 13. Booking Endpoints (`/api/v1/booking`)

### 13.1 Create Manual Booking
**POST** `/booking/create-manual-booking`
```json
{
  "subServiceId": "subservice_id",
  "timeslotId": "timeslot_id",
  "bookingDate": "2024-01-01",
  "groomerId": "groomer_id",
  "addressId": "address_id",
  "petDetails": {
    "weightType": "small",
    "petName": "Buddy"
  }
}
```

### 13.2 Update Manual Booking
**PUT** `/booking/update-booking/:bookingId`
```json
{
  "bookingDate": "2024-01-02",
  "timeslotId": "timeslot_id"
}
```

### 13.3 Create Subscription Booking
**POST** `/booking/subscribe`
```json
{
  "subscriptionId": "subscription_id",
  "paymentMethod": "card",
  "promoCode": "promo_id"
}
```

### 13.4 Cancel Subscription Booking
**POST** `/booking/cancel-subscribe`
```json
{
  "bookingId": "booking_id",
  "reason": "Personal reasons"
}
```

### 13.5 Apply Promo Code to Subscription
**POST** `/booking/subscription-apply-promo`
```json
{
  "subscriptionId": "subscription_id",
  "promoCode": "promo_id"
}
```

### 13.6 Mark Subscription Attendance
**POST** `/booking/mark-Subscription-Attendance`
```json
{
  "subscriptionId": "subscription_id",
  "bookingId": "booking_id",
  "attendanceStatus": "present"
}
```

---

## 14. Subscription Endpoints (`/api/v1/subscription`)

### 14.1 Create Subscription
**POST** `/subscription/create-subscription`
**Content-Type:** `multipart/form-data`
```
media: <file>
name: "Yoga Class"
categoryId: "category_id"
price: 100
trainer: "trainer_id"
sessionType: "session_id"
description: "Yoga class description"
isActive: true
date: "[\"2024-01-01\", \"2024-01-08\"]"
startTime: "09:00"
endTime: "10:00"
Address: {...}
isSingleClass: false
```

### 14.2 Update Subscription
**PUT** `/subscription/update-subscription/:id`
**Content-Type:** `multipart/form-data`
```
media: <file>
name: "Yoga Class Updated"
price: 120
description: "Updated description"
```

### 14.3 Get All Subscriptions
**POST** `/subscription/get-all-subscription`
```json
{
  "page": 1,
  "limit": 10,
  "categoryId": "category_id",
  "sessionTypeId": "session_id",
  "trainerId": "trainer_id"
}
```

### 14.4 Get Subscriptions by Date
**POST** `/subscription/get-subscriptions-by-date`
```json
{
  "date": "2024-01-01"
}
```

### 14.5 Get Subscriptions by Coordinates
**POST** `/subscription/get-subscriptions-by-coordinates`
```json
{
  "latitude": 25.0772,
  "longitude": 55.1398,
  "radius": 10
}
```

### 14.6 Get Subscriptions by User Miles
**POST** `/subscription/get-subscriptions-by-coordinates`
```json
{
  "latitude": 25.0772,
  "longitude": 55.1398,
  "miles": 5
}
```

### 14.7 Get Subscriptions by Location ID
**GET** `/subscription/get-subscriptions-by-loc-id/:locationId`

### 14.8 Filter and Sort Subscriptions
**POST** `/subscription/get-subscriptions-filter`
```json
{
  "categoryId": "category_id",
  "sessionTypeId": "session_id",
  "trainerId": "trainer_id",
  "minPrice": 50,
  "maxPrice": 200,
  "sortBy": "price",
  "sortOrder": "asc"
}
```

### 14.9 Get Trainer Assigned Subscriptions (Filters)
**POST** `/subscription/get-trainer-Assigned-Subscriptions-filters`
```json
{
  "status": "active",
  "date": "2024-01-01"
}
```

### 14.10 Search Subscriptions
**GET** `/subscription/search-subscriptions?query=yoga`

### 14.11 Get Subscriptions Nearby
**GET** `/subscription/subscriptions/nearby?latitude=25.0772&longitude=55.1398&radius=10`

### 14.12 Subscription Check-in
**POST** `/subscription/subscription-check-in/:subscriptionId`
```json
{
  "checkinTime": "2024-01-01T09:00:00Z",
  "latitude": 25.0772,
  "longitude": 55.1398
}
```

### 14.13 Subscription Check-out
**POST** `/subscription/subscription-check-out/:subscriptionId`
```json
{
  "checkoutTime": "2024-01-01T10:00:00Z",
  "notes": "Class completed"
}
```

---

## 15. Package Endpoints (`/api/v1/package`)

### 15.1 Create Package
**POST** `/package/create-package`
**Content-Type:** `multipart/form-data`
```
image: <file>
name: "Premium Package"
description: "Package description"
price: 500
duration: 30
classesIncluded: 10
isActive: true
```

### 15.2 Update Package
**PUT** `/package/update-package/:id`
**Content-Type:** `multipart/form-data`
```
image: <file>
name: "Premium Package Updated"
price: 600
```

### 15.3 Get All Packages
**POST** `/package/get-all-packages`
```json
{
  "page": 1,
  "limit": 10,
  "search": "premium"
}
```

---

## 16. Package Booking Endpoints (`/api/v1/package-booking`)

### 16.1 Create Package Booking
**POST** `/package-booking/create-package-booking`
```json
{
  "packageId": "package_id",
  "paymentMethod": "card",
  "promoCode": "promo_id"
}
```

### 16.2 Join Class with Package
**POST** `/package-booking/package-booking-join-class`
```json
{
  "packageBookingId": "package_booking_id",
  "subscriptionId": "subscription_id",
  "classDate": "2024-01-01"
}
```

### 16.3 Mark Class Attendance
**POST** `/package-booking/mark-attendance`
```json
{
  "packageBookingId": "package_booking_id",
  "subscriptionId": "subscription_id",
  "attendanceStatus": "present"
}
```

---

## Summary

This document includes all API endpoints that require a request body or payload. Endpoints are organized by service category for easy reference.

**Total Endpoints with Body/Payload:** ~150+

**Note:** Some endpoints may accept optional query parameters in addition to the request body. Refer to the main README.md for complete endpoint documentation including responses and authentication requirements.

