# Push Notifications Integration - Quick Reference

**Status: Ready for Backend Integration ✓**

---

## WHAT YOU (MOBILE) HAVE ALREADY DONE ✓

### App Configuration
- [x] Firebase Core (`firebase_core: ^4.7.0`)
- [x] Firebase Messaging (`firebase_messaging: ^16.2.0`)
- [x] Local Notifications Plugin (`flutter_local_notifications: ^18.0.1`)
- [x] Google Services Plugin in Android build
- [x] `google-services.json` in `android/app/`
- [x] POST_NOTIFICATIONS permission in AndroidManifest

### Dart Code
- [x] `PushNotificationService` handles Firebase initialization
- [x] Token retrieval and refresh listening
- [x] Background message handler for app-terminated notifications
- [x] Foreground notification display
- [x] Notification tap handling
- [x] Token sync on login/logout/account switch
- [x] Automatic token refresh listener

### Bootstrap & Integration
- [x] `PushNotificationService.init()` called at app startup
- [x] `PushNotificationTokenSync` widget wraps app
- [x] Token synced after user login
- [x] Token unregistered on logout
- [x] Auth interceptor includes Bearer token on all requests

---

## WHAT YOUR BACKEND NEEDS TO DO

### 1. Implement Two REST Endpoints

#### POST `/api/notifications/device-tokens`
**Purpose:** Register/update device token
```
Request:  Bearer token + JSON body
Response: 200 OK or 400 error

Body:
{
  "token": "FCM_TOKEN_STRING",
  "fcmToken": "FCM_TOKEN_STRING",
  "platform": "android" | "ios"
}
```

#### DELETE `/api/notifications/device-tokens`
**Purpose:** Unregister token on logout
```
Request:  Bearer token + JSON body
Response: 200 OK

Body:
{
  "token": "FCM_TOKEN_STRING",
  "fcmToken": "FCM_TOKEN_STRING",
  "platform": "android" | "ios"
}
```

### 2. Store Tokens in Database
```sql
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  fcm_token TEXT NOT NULL,
  platform VARCHAR(10),
  is_active BOOLEAN DEFAULT true,
  registered_at TIMESTAMP,
  UNIQUE(user_id, fcm_token)
);
```

### 3. Send Notifications Using Firebase Admin SDK

Example Node.js:
```javascript
const admin = require('firebase-admin');
const serviceAccountKey = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccountKey),
  projectId: 'tunify-3d931'
});

async function sendToUser(userId, title, body) {
  const tokens = await db.collection('deviceTokens')
    .where('userId', '==', userId)
    .where('isActive', '==', true)
    .get();

  for (const doc of tokens.docs) {
    await admin.messaging().send({
      notification: { title, body },
      data: { type: 'like', trackId: '...' },
      token: doc.data().fcmToken
    });
  }
}
```

### 4. Firebase Project Setup
- Download service account key from Firebase Console
- Use project ID: `tunify-3d931`
- Use same project as mobile app

---

## TESTING CHECKLIST

### Phase 1: Token Registration
- [ ] Run app: `flutter run`
- [ ] Check logs for: `[PushNotifications] FCM token: <TOKEN>`
- [ ] Confirm logs show: `[PushNotifications] FCM token synced`
- [ ] Verify backend received POST request to `/api/notifications/device-tokens`
- [ ] Verify backend stored token with correct user_id

### Phase 2: Send Test Notification
- [ ] Backend sends test message via Firebase Admin SDK
- [ ] Notification appears in Android notification tray
- [ ] Tap notification and verify it navigates correctly

### Phase 3: Token Refresh
- [ ] Restart app
- [ ] Verify new token is generated
- [ ] Verify new token is synced to backend

### Phase 4: Logout
- [ ] Sign out user
- [ ] Verify DELETE request sent to backend
- [ ] Verify token is marked inactive/deleted in database

---

## IMPORTANT NOTES

### What the App Sends
The Dio HTTP client automatically adds:
- `Authorization: Bearer <JWT_TOKEN>` (via AuthInterceptor)
- `Content-Type: application/json`

So your backend just needs to validate the JWT as usual.

### Token Payload
App always sends TWO fields with same token value:
```json
{
  "token": "eR5Jvui6RfCxjKvUg...",
  "fcmToken": "eR5Jvui6RfCxjKvUg..."
}
```
(Both refer to same FCM token - for flexibility)

### Platform Detection
- Android: `"platform": "android"`
- iOS: `"platform": "ios"`

### Error Handling
- Check backend logs if `[PushNotifications] token sync failed` appears
- Common issues:
  - Invalid JWT (check auth)
  - Wrong endpoint path
  - Backend returning non-200 status
  - Missing `Content-Type: application/json` header

---

## FULL DOCUMENTATION

See `BACKEND_FCM_REQUIREMENTS.md` for complete implementation guide including:
- Database schema examples (SQL & MongoDB)
- Detailed code examples (Node.js, Python)
- Troubleshooting guide
- Firebase setup instructions
- Payload structure examples

---

## QUICK SETUP SUMMARY

**Backend TODO:**
1. Create `POST /api/notifications/device-tokens` endpoint
2. Create `DELETE /api/notifications/device-tokens` endpoint
3. Add `device_tokens` table to database
4. Initialize Firebase Admin SDK with service account key
5. Implement `sendNotificationToUser(userId, title, body, data)` function
6. Test with curl or postman

**Time estimate:** 2-4 hours for experienced backend developer

---

## Questions?

- **Endpoint path not working?** → Check API base URL matches `https://tunify.duckdns.org/api`
- **Token not syncing?** → Check backend returns 200 OK status
- **Notification not arriving?** → Verify Firebase project ID and service account key
- **Token invalid error?** → Mark as inactive and remove old tokens

