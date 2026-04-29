# Push Notifications - Verification & Troubleshooting Guide

**Last Updated:** April 29, 2026

---

## STEP 1: Verify App Compiles

Run this command to ensure no build errors:

```bash
flutter clean
flutter pub get
flutter run
```

**Expected Output:**
```
✓ Build successful
✓ No compilation errors
✓ App launches on device
```

---

## STEP 2: Check for FCM Token in Logs

When the app starts, look for this log message:

```
I/flutter: [PushNotifications] FCM token: eR5Jvui6RfCxjKvUg2_7P4x8w9z...
```

**Location to find logs:**
- Android Studio → Logcat → filter for `PushNotifications`
- Terminal with `flutter run` active → watch console

**If you don't see the token:**
- Check Android version is 5.0+
- Verify Google Services JSON is present
- Check device has internet connection
- Check Firebase project is active

---

## STEP 3: Verify Token Sync After Login

After logging in, you should see:

```
I/flutter: [PushNotifications] FCM token synced
```

**If you see this instead:**
```
[PushNotifications] token sync failed (401): Unauthorized
[PushNotifications] token sync failed (404): Not Found
```

→ Backend endpoint doesn't exist yet, that's expected. Implement the endpoint first.

---

## STEP 4: Monitor Network Requests

Use a tool to see the exact HTTP request the app sends:

### Option A: Charles Proxy
1. Install Charles (https://www.charlesproxy.com/)
2. Configure Flutter to use Charles as proxy
3. Watch POST to `/api/notifications/device-tokens`
4. Should see:
   - Method: POST
   - URL: `https://tunify.duckdns.org/api/notifications/device-tokens`
   - Headers: `Authorization: Bearer <JWT_TOKEN>`
   - Body: `{"token": "...", "fcmToken": "...", "platform": "android"}`

### Option B: Backend Logging
Add logging to your endpoint:

```javascript
app.post('/api/notifications/device-tokens', (req, res) => {
  console.log('Headers:', req.headers);
  console.log('Body:', req.body);
  console.log('Auth:', req.headers.authorization);
  res.status(200).json({ success: true });
});
```

Then check if requests arrive.

---

## STEP 5: Verify on Different States

### 1. After Login
```bash
dart logs should show:
[PushNotifications] FCM token: <TOKEN>
[PushNotifications] FCM token synced
```

### 2. After Logout
```bash
Logs should show:
[PushNotifications] token unregister (or similar)
```

### 3. After App Restart
```bash
Same token should appear (unless device reset)
Logs should show: [PushNotifications] FCM token synced
```

### 4. Token Refresh
```bash
If token changes, logs should show:
[PushNotifications] FCM token: <NEW_TOKEN>
[PushNotifications] FCM token synced
```

---

## COMMON ISSUES & FIXES

### Issue: "FCM token: null"

**Cause:** Firebase not initialized or permission denied

**Fix:**
1. Verify `google-services.json` exists and is valid
2. Check AndroidManifest has `POST_NOTIFICATIONS` permission
3. Run on device with Play Services installed
4. Check device isn't in airplane mode

---

### Issue: "token sync failed (401): Unauthorized"

**Cause:** JWT token invalid or expired

**Fix:**
1. Verify user is logged in
2. Check JWT is being read correctly
3. Verify backend validates JWT correctly
4. Check token hasn't expired

---

### Issue: "token sync failed (404): Not Found"

**Cause:** Backend endpoint doesn't exist

**Fix:**
1. Create `POST /api/notifications/device-tokens` endpoint
2. Make sure it returns 200 OK
3. Verify base URL is `https://tunify.duckdns.org/api`

---

### Issue: App crashes on startup

**Cause:** Firebase initialization error

**Fix:**
1. Check `google-services.json` syntax (valid JSON?)
2. Verify Firebase project exists and is active
3. Check Android SDK version (minSdk should be ≥ 16)
4. Run `flutter clean` and rebuild

---

### Issue: Notification arrives but doesn't display

**Cause:** Notification channel not configured

**Fix:**
Verify Android manifest has:
```xml
<meta-data
  android:name="com.google.firebase.messaging.default_notification_channel_id"
  android:value="tunify_notifications" />
```

And backend sends with correct channel:
```json
{
  "android": {
    "notification": {
      "channelId": "tunify_notifications"
    }
  }
}
```

---

### Issue: "Invalid or missing token" error from backend

**Cause:** Token payload format wrong

**Fix:**
App sends:
```json
{
  "token": "FCM_TOKEN_STRING",
  "fcmToken": "FCM_TOKEN_STRING",
  "platform": "android"
}
```

Make sure backend accepts both `token` and `fcmToken` fields (they're identical).

---

## DEBUGGING CHECKLIST

- [ ] App runs without errors: `flutter run`
- [ ] FCM token visible in logs
- [ ] Token syncs after login (no error in logs)
- [ ] Network request reaches backend endpoint
- [ ] Backend returns 200 OK status
- [ ] Token stored in database
- [ ] Can see token in database query
- [ ] Backend can send test notification
- [ ] Notification appears on device
- [ ] Notification tap works (if handler implemented)

---

## MINIMAL BACKEND IMPLEMENTATION (To Test)

If backend isn't ready yet, create minimal stub to verify app works:

### Express.js Stub
```javascript
app.post('/api/notifications/device-tokens', (req, res) => {
  console.log('Token received:', req.body.fcmToken);
  res.status(200).json({ success: true, message: 'Token registered' });
});

app.delete('/api/notifications/device-tokens', (req, res) => {
  console.log('Token unregistered:', req.body.fcmToken);
  res.status(200).json({ success: true, message: 'Token unregistered' });
});
```

This will:
- Stop "token sync failed" errors
- Prove the app is sending requests correctly
- Show exact token format in logs

---

## FIREBASE ADMIN SDK TEST

Once you have service account key, test manually:

```javascript
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
  projectId: 'tunify-3d931'
});

// Send test message
async function test() {
  const message = {
    notification: {
      title: 'Test Notification',
      body: 'This is a test'
    },
    token: 'YOUR_FCM_TOKEN_FROM_APP_LOGS'
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Success:', response);
  } catch (error) {
    console.error('Failed:', error);
  }
}

test();
```

**Expected Result:**
- If token valid: notification appears immediately on device
- If token invalid: error message in console

---

## NEXT STEPS

1. **Immediate:** Share these two docs with backend team
   - `BACKEND_FCM_REQUIREMENTS.md` (full guide)
   - `APP_SETUP_COMPLETE.md` (quick reference)

2. **Backend Implementation:** 2-4 hours
   - Create token endpoints
   - Set up database storage
   - Test with stub endpoint first

3. **Integration Test:**
   - Run app
   - Login
   - Verify token syncs
   - Send test notification
   - Verify it arrives

4. **Production Ready:**
   - Implement full notification logic
   - Add error handling
   - Add token cleanup jobs
   - Add rate limiting (optional)

---

## SUPPORT RESOURCES

- **Google FCM Docs:** https://firebase.google.com/docs/cloud-messaging
- **Firebase Console:** https://console.firebase.google.com/project/tunify-3d931
- **Flutter Firebase Plugin:** https://firebase.flutter.dev/
- **Android FCM Guide:** https://developer.android.com/google/play-services/fcm

---

**Ready to integrate! 🚀**

