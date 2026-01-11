# CORS Error Solution Guide

## Understanding the Error

**CORS (Cross-Origin Resource Sharing)** is a browser security feature that blocks requests from one origin (domain/port) to another unless the server explicitly allows it.

### Your Current Situation:
- **Frontend Origin**: `http://localhost:55772` (Flutter web dev server)
- **Backend API**: `https://outbox.nablean.com/api/v1`
- **Problem**: Backend CORS config doesn't allow requests from `localhost:55772`

### Why It's Happening:
The backend has `credentials: true` in CORS config, which means:
- It cannot use `"*"` (wildcard) for origins
- It must specify exact origins
- Your dynamic Flutter web port isn't in the whitelist

## Solutions

### ✅ Solution 1: Backend Fix (Recommended - Requires Backend Team)

**Ask the backend team to update `mobile-gym-backend/mobile-gym-backend/config/cors.config.js`:**

```javascript
export const whiteListCors = [
  "http://192.168.1.8:3002/",
  "http://localhost:3001/",
  "http://localhost:3002/",
  "http://192.168.1.19:3000",
  "http://192.168.1.19:5174/",
  "http://192.168.1.30:3000/",
  "http://192.168.1.36:3000/",
  "https://obadmin.nablean.com",
  "http://localhost:*",  // Allow any localhost port
  // OR add specific ports:
  // "http://localhost:55772",
  // "http://localhost:8080",
];
```

**OR** if they want to allow all localhost ports during development:

```javascript
// In app.js, modify CORS to handle localhost dynamically
app.use(
  cors({
    origin: function (origin, callback) {
      // Allow requests with no origin (mobile apps, Postman, etc.)
      if (!origin) return callback(null, true);
      
      // Allow localhost with any port
      if (origin.startsWith('http://localhost:') || 
          origin.startsWith('http://127.0.0.1:')) {
        return callback(null, true);
      }
      
      // Check whitelist
      if (whiteListCors.includes(origin) || whiteListCors.includes('*')) {
        return callback(null, true);
      }
      
      callback(new Error('Not allowed by CORS'));
    },
    credentials: true,
  })
);
```

### ✅ Solution 2: Use a Whitelisted Port (Quick Fix)

Run Flutter web on a port that's already whitelisted:

```bash
# Use port 3001 or 3002 (already in whitelist)
flutter run -d chrome --web-port=3001
```

### ✅ Solution 3: Browser Extension (Development Only)

**⚠️ WARNING: Only for development! Never use in production!**

Install a CORS browser extension:
- Chrome: "CORS Unblock" or "Allow CORS: Access-Control-Allow-Origin"
- Firefox: "CORS Everywhere"

**Steps:**
1. Install the extension
2. Enable it
3. Refresh your Flutter web app

### ✅ Solution 4: Proxy Server (Development)

Create a simple proxy server to forward requests:

**Create `proxy-server.js` in project root:**

```javascript
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();

// Enable CORS for all routes
app.use(cors());

// Proxy API requests
app.use('/api', createProxyMiddleware({
  target: 'https://outbox.nablean.com',
  changeOrigin: true,
  secure: true,
  logLevel: 'debug',
}));

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Proxy server running on http://localhost:${PORT}`);
  console.log(`Proxying /api/* to https://outbox.nablean.com/api/*`);
});
```

**Install dependencies:**
```bash
npm init -y
npm install express http-proxy-middleware cors
```

**Run proxy:**
```bash
node proxy-server.js
```

**Update API base URL in Flutter:**
```dart
// In lib/services/api_service.dart
static const String baseUrl = 'http://localhost:3001/api/v1';
```

### ✅ Solution 5: Flutter Web with Specific Port

Modify your Flutter run command to use a fixed port:

```bash
# Windows PowerShell
flutter run -d chrome --web-port=3001

# Or in launch.json for VS Code
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Web",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--web-port=3001"]
    }
  ]
}
```

## Recommended Approach

1. **For immediate development**: Use Solution 2 (whitelisted port) or Solution 3 (browser extension)
2. **For long-term**: Request backend team to implement Solution 1
3. **For production**: Backend must properly configure CORS for your production domain

## Testing CORS Fix

After implementing a solution, test with:

```dart
// In your Flutter app, make a test API call
try {
  final response = await http.get(
    Uri.parse('https://outbox.nablean.com/api/v1/auth/login/3'),
  );
  print('CORS working! Status: ${response.statusCode}');
} catch (e) {
  print('CORS error: $e');
}
```

## Important Notes

- **Never disable CORS in production** - it's a security feature
- **Always use HTTPS in production** - required for secure cookies/credentials
- **Backend should whitelist specific origins** - not use wildcards with credentials
- **Mobile apps don't have CORS** - this only affects web browsers

