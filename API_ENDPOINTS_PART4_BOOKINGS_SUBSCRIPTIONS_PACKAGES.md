# API Endpoints with Request Body/Payload - Part 4

**Bookings, Subscriptions & Packages**

This document lists API endpoints that require a request body or payload for Booking, Subscription, and Package services.

**Base URL:** `/api/v1`

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

**Note:** Refer to the main README.md for complete endpoint documentation including responses and authentication requirements.

