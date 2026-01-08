# API Endpoints with Request Body/Payload - Part 2

**Services, Trainers & Admin**

This document lists API endpoints that require a request body or payload for Sub Services, Trainer Management, and Admin services.

**Base URL:** `/api/v1`

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

**Note:** Refer to the main README.md for complete endpoint documentation including responses and authentication requirements.

