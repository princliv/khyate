# API Endpoints with Request Body/Payload - Part 3

**Manager, Time Slots, Cart, Currency, Orders & Payments**

This document lists API endpoints that require a request body or payload for Manager Management, Time Slots, Cart, Currency, Orders, and Payment services.

**Base URL:** `/api/v1`

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

**Note:** Refer to the main README.md for complete endpoint documentation including responses and authentication requirements.

