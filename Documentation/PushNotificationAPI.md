# Push Notification API Documentation

## 1. Overview

The Kore Bot SDK registers and unregisters iOS devices for push notifications against the Kore platform. The device token is passed as a **hex string** (`String`), not `Data`.

### 1.1 Integration paths

| Layer | API | Token type |
|-------|-----|------------|
| Host app (recommended) | `BotConnect.device_Token` | `String?` |
| Internal config | `SDKConfiguration.botConfig.deviceToken` | `String?` |
| Low-level RTM client | `BotClient.subscribeToNotifications` / `unsubscribeToNotifications` | `String!` |

After a successful bot connection, the SDK **automatically subscribes** if `device_Token` is set and `default_Notifications` is `true` (default). **Unsubscribe** runs when the user **closes** the chat or the app **terminates**, when `default_Notifications` is `true`. Minimize does **not** trigger unsubscribe.

---

## 2. Host app setup

### 2.1 Set device token on `BotConnect`

Assign `device_Token` **before** calling `show()` or `show(in:)`. It is copied into `SDKConfiguration.botConfig.deviceToken` inside `customSettings()` (called at the start of `show()`).

**Option A — assign a hex string directly:**

```swift
let botConnect = BotConnect()

botConnect.initialize(/* clientId, clientSecret, botId, ... */)
botConnect.device_Token = "a1b2c3d4e5f6789012345678901234567890abcd"  // lowercase hex APNS token
botConnect.show()
```

Then call `show()` when opening the bot. No manual subscribe call is needed after connect.

### 2.2 `BotConnect` properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `device_Token` | `String?` | `nil` | Hex APNS device token |
| `default_Notifications` | `Bool` | `true` | Enables automatic subscribe on connect and unsubscribe on close / app terminate |

### 2.3 Automatic subscribe / unsubscribe

| Action | When | Condition |
|--------|------|-----------|
| **Subscribe** | Bot connects successfully (`sucessMethod`) | `default_Notifications == true` **and** `SDKConfiguration.botConfig.deviceToken != nil` |
| **Unsubscribe** | User taps **Close** on close/minimize popup (`closeChatWindow`) | `default_Notifications == true` |
| **Unsubscribe** | App will terminate (`willTerminate`) | `default_Notifications == true` |
| **Unsubscribe** | `BotConnect.unsubscribeNotifications()` | Chat UI is open (`botViewController != nil`) |

**Does not unsubscribe:**

- User taps **Minimize** (`minimizePopupAction`, `minimizeChatBotWindow`)
- `socketDisconnect()` alone

**Manual unsubscribe:**

```swift
botConnect.unsubscribeNotifications()
```

**Disable automatic push registration:**

```swift
botConnect.default_Notifications = false
```

When `false`, the SDK does not auto-subscribe on connect or auto-unsubscribe on close/terminate. Use `BotConnect.unsubscribeNotifications()` manually if needed.

---

## 3. API reference

### 3.1 `BotConnect`

```swift
public var device_Token: String? = nil
public var default_Notifications = true

public func unsubscribeNotifications()
```

**Source:** `Sources/KoreBotSDK/AppKit/Common/BotConnect.swift`

### 3.2 `BotClient` (RTM layer)

```swift
open func subscribeToNotifications(
    _ deviceToken: String!,
    success: ((Bool) -> Void)?,
    failure: ((_ error: Error?) -> Void)?
)

open func unsubscribeToNotifications(
    _ deviceToken: String!,
    success: ((Bool) -> Void)?,
    failure: ((_ error: Error?) -> Void)?
)
```

Delegates to `HTTPRequestManager` using `userInfoModel` and `authInfoModel` from the active `BotClient` session.

**Source:** `Sources/KoreBotSDK/RTM/Library/BotClient.swift`

### 3.3 `HTTPRequestManager`

```swift
open func subscribeToNotifications(
    _ deviceToken: String!,
    userInfo: UserModel!,
    authInfo: AuthInfoModel!,
    success: ((_ staus: Bool) -> Void)?,
    failure: ((_ error: Error) -> Void)?
)

open func unsubscribeToNotifications(
    _ deviceToken: String!,
    userInfo: UserModel!,
    authInfo: AuthInfoModel!,
    success: ((_ staus: Bool) -> Void)?,
    failure: ((_ error: Error) -> Void)?
)
```

**Source:** `Sources/KoreBotSDK/RTM/Library/REST/HTTPRequestManager.swift`

---

## 4. HTTP request details

Base URL: `Constants.KORE_BOT_SERVER` (set via `BotConnect.initialize` → `BOTServerUrl`).

### 4.1 Subscribe

| Item | Value |
|------|-------|
| Method | `POST` |
| URL | `{KORE_BOT_SERVER}/api/users/{userId}/sdknotifications/subscribe` |
| Headers | `Authorization: {tokenType} {accessToken}` |
| Body | `deviceId` (hex string), `osType: "ios"` |

```swift
// Constants.URL.subscribeUrl(userId)
let parameters: [String: Any] = [
    "deviceId": deviceToken,
    "osType": "ios"
]
```

### 4.2 Unsubscribe

| Item | Value |
|------|-------|
| Method | `DELETE` |
| URL | `{KORE_BOT_SERVER}/api/users/{userId}/sdknotifications/unsubscribe` |
| Headers | `Authorization: {tokenType} {accessToken}` |
| Body | `deviceId` (hex string) |

```swift
// Constants.URL.unSubscribeUrl(userId)
let parameters: [String: Any] = ["deviceId": deviceToken]
```

### 4.3 Response handling (HTTP 200)

Success requires **HTTP status code `200` exactly** (not any 2xx):

```swift
dataRequest.responseJSON { response in
    if let statusCode = response.response?.statusCode, statusCode == 200 {
        success?(true)
        return
    }

    let code = response.response?.statusCode ?? response.error?.responseCode ?? 0
    failure?(NSError(domain: "KoreBotSDK", code: code, userInfo: [:]))
}
```

| Outcome | Behavior |
|---------|----------|
| `statusCode == 200` | `success?(true)` |
| Any other status or network error | `failure?(error)` — HTTP code in `NSError.code` |

---

## 5. Implementation flow

### 5.1 Subscribe

```
Host sets BotConnect.device_Token (hex string)
        │
        ▼
show() → customSettings() → SDKConfiguration.botConfig.deviceToken
        │
        ▼
Bot connects (sucessMethod)
        │
        ▼
default_notifications == true?
        │
        ├─ yes → ChatMessagesViewController.subscribeNotifications()
        └─ no  → skip subscribe
        │
        ▼
BotClient.subscribeToNotifications(deviceToken)
        │
        ▼
HTTPRequestManager → POST .../sdknotifications/subscribe
        │
        ▼
HTTP 200 → success
```

### 5.2 Unsubscribe

```
User closes chat OR app will terminate OR botConnect.unsubscribeNotifications()
        │
        ▼
ChatMessagesViewController.unsubscribeNotifications()
        │
        ▼
BotClient.unsubscribeToNotifications(deviceToken)
        │
        ▼
HTTPRequestManager → DELETE .../sdknotifications/unsubscribe
        │
        ▼
HTTP 200 → success
```

---

## 6. Usage examples

### 6.1 Recommended — via `BotConnect`

```swift
class ViewController: UIViewController {
    let botConnect = BotConnect()

    @IBAction func openBot(_ sender: Any) {
        botConnect.initialize(/* ... */)

        // Set before show()
        botConnect.device_Token = "21123121212123d233"

        botConnect.show()
    }
}
```

With APNS registration in `AppDelegate`:

```swift
func application(_ application: UIApplication,
                 didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    botConnect.device_Token = token
}
```

### 6.2 Direct — via `BotClient` (advanced)

Use only when you have an active `BotClient` with valid `userInfoModel` and `authInfoModel`:

```swift
let deviceToken = "a1b2c3d4e5f6..." // hex string

botClient.subscribeToNotifications(deviceToken,
    success: { _ in
        print("Successfully subscribed to notifications")
    },
    failure: { error in
        print("Failed to subscribe: \(error?.localizedDescription ?? "")")
    })

botClient.unsubscribeToNotifications(deviceToken,
    success: { _ in
        print("Successfully unsubscribed from notifications")
    },
    failure: { error in
        print("Failed to unsubscribe: \(error?.localizedDescription ?? "")")
    })
```

---

## 7. Required models

### UserModel

```swift
class UserModel {
    var userId: String
    // Other user properties
}
```

### AuthInfoModel

```swift
class AuthInfoModel {
    var accessToken: String?
    var tokenType: String?
    // Other authentication properties
}
```

---

## 8. Error handling

### Common error cases

| Case | Cause | SDK behavior |
|------|-------|--------------|
| Invalid device token | `nil` or empty string | Failure before request; `"deviceId is nil"` |
| Non-200 HTTP response | 401, 404, 500, etc. | `failure` with status code in `NSError.code` |
| Network error | Timeout, no connection | `failure` with `response.error?.responseCode` or `0` |
| Missing auth | No `userInfoModel` / `authInfoModel` on `BotClient` | Request fails at API level |

### Token format

Lowercase hex string, no spaces or angle brackets:

```
a1b2c3d4e5f6789012345678901234567890abcd
```

Convert from APNS `Data`:

```swift
deviceToken.map { String(format: "%02x", $0) }.joined()
```

---

## 9. Best practices

1. **Set `device_Token` before `show()`** — `customSettings()` copies it once when the chat opens.
2. **Update on token refresh** — If APNS issues a new token, update `device_Token` and reconnect or call subscribe again.
3. **Handle non-200 responses** — Inspect `error` code in the failure closure (e.g. `401` → refresh JWT).
4. **Keep registration on minimize** — Default behavior already keeps the device subscribed when the user minimizes; only close/terminate unsubscribes.
5. **Disable automatic push handling** — Set `default_Notifications = false` to skip auto-subscribe and auto-unsubscribe; manage push registration manually in the host app.

---

## 10. Source file index

| Concern | File |
|---------|------|
| Public `device_Token`, `unsubscribeNotifications()` | `BotConnect.swift` |
| Internal token storage | `SDKConfiguration.swift` |
| Auto subscribe / unsubscribe | `ChatMessagesViewController.swift` |
| Subscribe URL constants | `Constants.swift` |
| `BotClient` API | `BotClient.swift` |
| HTTP requests & status `200` check | `HTTPRequestManager.swift` |
