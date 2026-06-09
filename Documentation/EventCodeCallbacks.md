# Event Code Callbacks Documentation

## 1. Overview

The Kore Bot SDK reports lifecycle, connection, network, and navigation events to the host app through a single callback chain. Every event is delivered as a `[String: Any]` dictionary that includes an `event_code` string (and usually `event_message` and `event_reason`).

These callbacks are **not** separate delegate methods per event. They all flow through one closure that you assign on `BotConnect`.

### 1.1 All `event_code` values

| `event_code` | Category | `event_reason` |
|--------------|----------|----------------|
| `BotConnectionStatus` | Connection | `1` connected, `2` token expired, `3` disconnected |
| `BotConnectionLost` | Network / connection | `7` network unreachable, `11` bot disconnected (socket failure) |
| `NetworkReconnected` | Network | `8` |
| `BotClosed` | UI / lifecycle | `4` connection error, `5` user closed |
| `BotMinimized` | UI / lifecycle | `6` |
| **`DeepLinkClicked`** | **In-app navigation** | **`9`** — URL/path in `event_message` |
| **`StartNewSession`** | **Session / UI** | **`10`** — user requested a fresh conversation |

---

## 2. Integration

### 2.1 Assign the callback

After creating `BotConnect` and before or after calling `show()` / `show(in:)`:

```swift
let botConnect = BotConnect()
botConnect.initialize(/* ... */)
botConnect.show()

botConnect.closeOrMinimizeEvent = { eventDic in
    guard let dic = eventDic,
          let eventCode = dic["event_code"] as? String else { return }

    switch eventCode {
    case "BotConnectionStatus":
        let reason = dic["event_reason"] as? Int ?? 0
        // handle connection status (see §4.1)
    case "BotConnectionLost":
        let reason = dic["event_reason"] as? Int ?? 0
        // reason 7: network lost (see §4.2.1)
        // reason 11: bot disconnected / socket failure (see §4.2.2)
    case "NetworkReconnected":
        // network restored (see §4.3)
    case "BotClosed", "BotMinimized":
        // user dismissed UI (see §4.4, §4.5)
    case "DeepLinkClicked":
        // Same-page template link — see §4.6
        let path = dic["event_message"] as? String
        let reason = dic["event_reason"] as? Int  // always 9
        navigateInHostApp(to: path)
    case "StartNewSession":
        // User tapped Start New Session in custom header — see §4.7
        botConnect.socketConnect(isReconnect: true)
    default:
        break
    }
}
```

### 2.2 Internal wiring

| Layer | Property / method |
|-------|-------------------|
| Host app | `BotConnect.closeOrMinimizeEvent` |
| `ChatMessagesViewController` | `closeAndMinimizeEvent` |
| Forwarded in | `BotConnect.show()` / `BotConnect.show(in:)` |

Source references:

- `BotConnect.closeOrMinimizeEvent` — `Sources/KoreBotSDK/AppKit/Common/BotConnect.swift`
- Event emission — `Sources/KoreBotSDK/AppKit/Controllers/ChatMessages/ChatMessagesViewController.swift`

### 2.3 Related callback (no `event_code`)

Push / in-chat local notification text uses a **different** callback:

```swift
botConnect.locaNotificationEvent = { dic in
    let text = dic?["text"] as? String
}
```

Payload: `["text": "<message>"]` only. Posted from `localNotificationMethod` when `localNotification` notification fires.

---

## 3. Payload schema

### 3.1 Common fields

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `event_code` | `String` | Yes | Event identifier (see §4). |
| `event_message` | `String` | Yes* | Human-readable description. *Always present in current SDK; use for logging and UI. |
| `event_reason` | `Int` | No* | Numeric sub-reason (see §3.2). Always `9` for `DeepLinkClicked`. *Omitted only in legacy/commented code paths. |

### 3.2 `event_reason` reference

| Value | Used with `event_code` | Meaning |
|-------|------------------------|---------|
| `1` | `BotConnectionStatus` | Bot connected successfully |
| `2` | `BotConnectionStatus` | Token expired / max connection retries exceeded |
| `3` | `BotConnectionStatus` | Bot disconnected successfully (programmatic) |
| `4` | `BotClosed` | Back button while connection mask is visible (connection error state) |
| `5` | `BotClosed` | User chose **Close** in close/minimize popup |
| `6` | `BotMinimized` | User chose **Minimize** or `minimizeChatBot()` |
| `7` | `BotConnectionLost` | Network became unreachable |
| `8` | `NetworkReconnected` | Network became reachable again |
| `11` | `BotConnectionLost` | Bot disconnected due to socket / RTM connection failure |
| `9` | `DeepLinkClicked` | User tapped an in-app (same-page) deeplink in a button/link template |
| `10` | `StartNewSession` | User requested reset of the conversation and a new session |

---

## 4. Event catalog

### 4.1 `BotConnectionStatus`

Connection lifecycle and authentication failures.

#### 4.1.1 Connected — `event_reason: 1`

| Field | Value |
|-------|-------|
| `event_code` | `BotConnectionStatus` |
| `event_message` | `"Bot connected successfully"` |
| `event_reason` | `1` |

**When fired:** After a successful bot connection in `sucessMethod(client:thread:)`, once the thread is configured, notifications are subscribed, and the loading mask is hidden.

**SDK behavior after callback:**

- Chat UI is fully active (`chatMaskview` hidden).
- `isBotConnectSucessFully = true`.
- For webhook bots, sends `ON_CONNECT` event via webhook API.

**Host app guidance:** Safe point to enable features that depend on an active bot session.

---

#### 4.1.2 Token expired — `event_reason: 2`

| Field | Value |
|-------|-------|
| `event_code` | `BotConnectionStatus` |
| `event_message` | `"Token expired"` |
| `event_reason` | `2` |

**When fired:** `tokenExpiry` runs after `TokenExpiryNotification` is posted. That notification is posted from `KABotClient.tryConnect()` when connection retries exceed the limit (`retryCount > 4` after repeated failures).

**SDK behavior after callback:**

- If `BotConnect.isShowTokenExpiryAlertView == true` (maps to `isShowTokenExpiryAlertV`): shows alert with `sessionExpiryMsg`; on **OK**, calls `botClosed()` (dismisses chat).
- If alert is disabled: callback only; chat stays open unless you dismiss it.

**Host app guidance:** Refresh JWT via `setCustom_JwToken` and call `socketConnect(isReconnect:)` or re-present the bot.

---

#### 4.1.3 Disconnected — `event_reason: 3`

| Field | Value |
|-------|-------|
| `event_code` | `BotConnectionStatus` |
| `event_message` | `"Bot disconnected successfully"` |
| `event_reason` | `3` |

**When fired:** `BotConnect.socketDisconnect()` → `ChatMessagesViewController.socketDisconnect()` → `kaBotClient.socketDisconnect()`.

**SDK behavior after callback:**

- WebSocket disconnect initiated.
- Does **not** auto-dismiss the chat UI (unlike close/minimize).

**Host app guidance:** Use when the host app intentionally tears down the socket while keeping or hiding the UI itself.

---

### 4.2 `BotConnectionLost`

The SDK uses the same `event_code` for two distinct disconnect paths, distinguished by `event_reason`.

#### 4.2.1 Network unreachable — `event_reason: 7`

| Field | Value |
|-------|-------|
| `event_code` | `BotConnectionLost` |
| `event_message` | `"The bot was disconnected due to a network connectivity issue. Please check the internet connection and try reconnecting."` |
| `event_reason` | `7` |

**When fired:** Alamofire `NetworkReachabilityManager` reports `.notReachable` in:

1. `startMonitoringForReachability()` — started when app becomes active (`didBecomeActive`).
2. `networkMonitoringForReachability()` — started in `viewDidLoad` (always while chat is visible).

**SDK behavior after callback:**

- `isInternetAvailable = false` (global).
- `showLoader()` if `isTryConnect` (and, in `networkMonitoringForReachability`, only if `isBotConnectSucessFully`).
- Always calls `KABotClient.shared.setReachabilityStatusChange(status)` → `BotClient.setReachabilityStatusChange` → `rtmConnectionDidFailWithError` (RTM layer marks network unavailable).

**Host app guidance:** Show offline UI; do not assume messages are delivered until `NetworkReconnected`.

**Note:** This event can fire from **both** reachability listeners in some scenarios (e.g. foreground transition). Deduplicate in the host app if needed.

---

#### 4.2.2 Bot disconnected — `event_reason: 11`

| Field | Value |
|-------|-------|
| `event_code` | `BotConnectionLost` |
| `event_message` | `"Bot disconnected"` |
| `event_reason` | `11` |

**Example payload:**

```json
{
  "event_code": "BotConnectionLost",
  "event_message": "Bot disconnected",
  "event_reason": 11
}
```

**When fired:**

1. RTM WebSocket reports a connection failure via `BotClient.connectionDidFailWithError`.
2. `KABotClient` handles the failure, optionally calls `tryConnect()` when `isReconnectionBySdk` is `true`, and posts `BotConnectionLostNotification`.
3. `ChatMessagesViewController.botConnectionDidFailWithError()` receives the notification and invokes `closeAndMinimizeEvent` with the payload above.

**SDK behavior after callback:**

- `isConnected` / `isConnecting` are cleared on the active `KABotClient`.
- Delegate receives updated `connectionState` (e.g. `.DISCONNECTED`).
- If `BotConnect.reConnectionBySDK` is `true` (default), the SDK may attempt automatic reconnection via `tryConnect()`.

**Host app guidance:** Treat as an active socket/session failure (not only reachability). Inspect `socketConnectionState()` / `socketConnectionStateDescription()`; optionally call `socketConnect(isReconnect:)` after refreshing JWT if auto-reconnect is disabled.

**Demo reference:** `Examples/CocoapodsDemo/KoreBotSDKDemo/ViewController.swift` (`BotEventReason.connectionClose`).

---

### 4.3 `NetworkReconnected`

| Field | Value |
|-------|-------|
| `event_code` | `NetworkReconnected` |
| `event_message` | `"Network connectivity has been restored."` |
| `event_reason` | `8` |

**When fired:** Reachability reports `.reachable(.ethernetOrWiFi)` or `.reachable(.cellular)`.

| Listener | Extra conditions before callback |
|----------|--------------------------------|
| `startMonitoringForReachability` | `isTryConnect == true` |
| `networkMonitoringForReachability` | `isTryConnect`, `isBotConnectSucessFully`, and app not in background |

**SDK behavior after callback:**

- `isInternetAvailable = true`.
- If not webhook: may set `loadReconnectionHistory` and call `establishBotConnection()` → `KABotClient.tryConnect()`.
- Stops loader (with 3s delay if agent chat connected).

**Host app guidance:** Resume sending messages; optionally refresh history if you rely on `networkOnResumeCallingHistory` (default `true` on `BotConnect`).

---

### 4.4 `BotClosed`

User or error path closed the bot UI.

#### 4.4.1 Connection error — `event_reason: 4`

| Field | Value |
|-------|-------|
| `event_code` | `BotClosed` |
| `event_message` | `"Bot connection error"` |
| `event_reason` | `4` |

**When fired:** User taps back (`tapsOnBackBtnAct`) while `chatMaskview` is **not** hidden (still connecting / error mask visible).

**SDK behavior:** `botClosed()` — dismisses or pops chat, `isTryConnect = false`, `prepareForDeinit()`.

---

#### 4.4.2 User closed — `event_reason: 5`

| Field | Value |
|-------|-------|
| `event_code` | `BotClosed` |
| `event_message` | `"Bot closed by the user"` |
| `event_reason` | `5` |

**When fired:** User taps **Close** on the close/minimize popup (`closePopupAction`).

**SDK behavior:**

- `unsubscribeNotifications()`.
- Sends agent or bot close event (`close_AgentChat_EventName` or `close_Button_EventName`).
- After 0.5s timer: `botClosed()`.

**Configurable event names on `BotConnect`:**

- `closeAgentChatEventName` (default `"close_agent_chat"`)
- `closeButtonEventName` (default `"close_button_event"`)

---

### 4.5 `BotMinimized`

| Field | Value |
|-------|-------|
| `event_code` | `BotMinimized` |
| `event_message` | `"Bot Minimized by the user"` |
| `event_reason` | `6` |

**When fired:**

1. **Minimize** on close/minimize popup (`minimizePopupAction`).
2. **`BotConnect.minimizeChatBot()`** → `minimizeChatBotWindow()`.

**SDK behavior:**

- Sends `minimize_Button_EventName` (default `"minimize_button_event"`) to bot/agent.
- `botClosed()` — UI is dismissed (minimize is implemented as closing the presented chat from the SDK’s perspective).

**Host app guidance:** Treat as “user wants chat hidden”; restore with `show()` again when needed.

---

### 4.6 `DeepLinkClicked`

In-app navigation when the user taps a **same-page** link in a button/link quick-reply or welcome template. The host app receives the target path/URL and is expected to route inside the app (native or React Native).

#### Payload

| Field | Value |
|-------|-------|
| `event_code` | `DeepLinkClicked` |
| `event_message` | Deeplink URL or path from the template (`elements.elementUrl`) |
| `event_reason` | `9` |

**Example payload:**

```json
{
  "event_code": "DeepLinkClicked",
  "event_message": "/account/settings",
  "event_reason": 9
}
```

#### When fired

1. Bot renders a button/link template (`ButtonLinkNBubbleView`).
2. Template element has **`isSamePageNavigation: true`**.
3. User taps that row in `tableView(_:didSelectRowAt:)`.
4. SDK posts `Notification.Name(deepLinkNotification)` with `object` = `elementUrl`.
5. `ChatMessagesViewController.deepLinkNotificationAction` builds the dictionary and invokes `closeAndMinimizeEvent`.

**Notification constant:** `deepLinkNotification` = `"DeepLinkNotification"` (`Common.swift`).

#### What does **not** fire `DeepLinkClicked`

| Template behavior | SDK action | Callback |
|-------------------|------------|----------|
| `isSamePageNavigation == false` and `elementType` is `web_url` or `url` | Opens via `linkAction` (browser / external) | None |
| Other element types | Sends option text via `optionsAction` | None |

#### SDK behavior after callback

- `isAgentConnect = false`
- `botClosed()` — chat UI is dismissed so the host app can navigate without the bot overlay

#### Host app guidance

1. Handle **`DeepLinkClicked`** in `closeOrMinimizeEvent` (same callback as close/minimize/network events).
2. Parse route from **`event_message`** (not a separate `path` key).
3. Navigate in your app, then re-open the bot with `show()` if needed.
4. Optionally check `event_reason == 9` for logging consistency.

**Example handler:**

```swift
botConnect.closeOrMinimizeEvent = { eventDic in
    guard let dic = eventDic,
          dic["event_code"] as? String == "DeepLinkClicked",
          let path = dic["event_message"] as? String else { return }

    // Route in host app (UIKit, SwiftUI, React Native bridge, etc.)
    AppRouter.shared.open(path: path)
}
```

#### Bot / template configuration

Ensure the bot designer or JSON template sets:

- `isSamePageNavigation: true` for in-app routes
- `elementUrl` to the path or deep link the host app understands

---

### 4.7 `StartNewSession`

User-initiated reset of the current conversation so the bot can start a fresh session (typically with the welcome flow).

#### Payload

| Field | Value |
|-------|-------|
| `event_code` | `StartNewSession` |
| `event_message` | `"Reset the conversation and begin a new session."` |
| `event_reason` | `10` |

**Example payload:**

```json
{
  "event_code": "StartNewSession",
  "event_message": "Reset the conversation and begin a new session.",
  "event_reason": 10
}
```

#### When fired

1. Host app provides a **custom header** via `BotConnect.addCustomHeaderView(headerView:)`.
2. The header view conforms to `KoreCustomHeaderView` and invokes the `startNewSession` closure (e.g. a **Start New Session** button in `SampleHeaderView`).
3. `ChatMessagesViewController.customHeaderViewConfigure()` wires `customHeaderView?.startNewSession`:
   - Calls `socketDisconnect()` immediately (sets `isShowWelcomeMsg = true`, tears down the WebSocket).
   - After a **1 second** delay, invokes `closeAndMinimizeEvent` with the `StartNewSession` payload.

**Source:** `ChatMessagesViewController.swift` (`customHeaderViewConfigure`, `startNewSession` closure).

#### SDK behavior before callback

- `socketDisconnect()` → `kaBotClient.socketDisconnect()`.
- Chat UI **stays open**; the event is delivered to the host app only (not auto-reconnect).

#### Host app guidance

1. Handle **`StartNewSession`** in `closeOrMinimizeEvent` (check `event_code` or `event_reason == 10`).
2. Optionally refresh JWT / `customData` / `queryParameters` via `setCustom_JwToken` if your bot requires a new identity or session context.
3. Call **`BotConnect.socketConnect(isReconnect: true)`** to reconnect.

**What `socketConnect(isReconnect: true)` does in the SDK:**

- Sets `isShowWelcomeMsg = true`.
- Clears **local chat messages** for the current bot (`clearChatHistory()` → `DataStoreManager.deleteMessages(for:)`); the Core Data **thread** is retained.
- Calls `kaBotClient.tryConnect()` to re-establish the socket and load the welcome flow.

**Example handler:**

```swift
botConnect.closeOrMinimizeEvent = { eventDic in
    guard let dic = eventDic,
          dic["event_code"] as? String == "StartNewSession" else { return }

    // Optional: refresh token or session context
    botConnect.setCustom_JwToken(customJWToken: newToken, customData: [:], queryParameters: [])
    botConnect.socketConnect(isReconnect: true)
}
```

**Demo reference:** `Examples/CocoapodsDemo/KoreBotSDKDemo/ViewController.swift` (`BotEventReason.startNewSession`).

#### Custom header requirement

This event is **only** emitted when a custom header is supplied and the header calls `startNewSession?()`. The default SDK header does not expose this action.

---

## 5. Event flow diagrams

### 5.1 Callback pipeline

```
SDK internal action
        │
        ▼
ChatMessagesViewController.closeAndMinimizeEvent(dic)
        │
        ▼
BotConnect.closeOrMinimizeEvent(dic)   ← host app
```

### 5.2 Network loss and recovery

```
NetworkReachabilityManager (.notReachable)
        │
        ├─► closeAndMinimizeEvent → BotConnectionLost (reason 7)
        ├─► isInternetAvailable = false
        ├─► showLoader() (conditions apply)
        └─► KABotClient.setReachabilityStatusChange → RTM fail

NetworkReachabilityManager (.reachable)
        │
        ├─► closeAndMinimizeEvent → NetworkReconnected (reason 8)
        ├─► isInternetAvailable = true
        ├─► establishBotConnection() / tryConnect() (if RTM, not webhook)
        └─► stopLoader()
```

### 5.3 Connection success vs token failure

```
sucessMethod()
        └─► BotConnectionStatus, reason 1

KABotClient.tryConnect() failures (retryCount > 4)
        └─► TokenExpiryNotification
                └─► tokenExpiry()
                        └─► BotConnectionStatus, reason 2
```

### 5.4 Deep link (same-page navigation)

```
User taps template row (isSamePageNavigation == true)
        │
        ▼
ButtonLinkNBubbleView.didSelectRow
        │
        ▼
NotificationCenter.post(DeepLinkNotification, object: elementUrl)
        │
        ▼
deepLinkNotificationAction
        │
        ├─► closeAndMinimizeEvent → DeepLinkClicked (reason 9, message = elementUrl)
        ├─► isAgentConnect = false
        └─► botClosed()  → dismiss chat UI
                │
                ▼
        Host app routes using event_message
```

### 5.5 Start new session (custom header)

```
User taps Start New Session in custom header
        │
        ▼
customHeaderView.startNewSession closure
        │
        ├─► socketDisconnect()  → isShowWelcomeMsg = true
        │
        ▼ (after 1s delay)
closeAndMinimizeEvent → StartNewSession (reason 10)
        │
        ▼
Host app: socketConnect(isReconnect: true)
        │
        ├─► clearChatHistory()  → delete local messages only
        └─► kaBotClient.tryConnect()  → welcome / new session
```

---

## 6. Reachability listeners (important)

Two listeners can be active:

| Method | Started | Stops |
|--------|---------|-------|
| `networkMonitoringForReachability()` | `viewDidLoad` | Not stopped until deinit |
| `startMonitoringForReachability()` | `UIApplication.didBecomeActive` | `stopMonitoringForReachability()` on `didEnterBackground` |

Implications:

- **`BotConnectionLost` / `NetworkReconnected`** may be emitted from either listener depending on app state.
- `networkMonitoringForReachability` only fires `NetworkReconnected` when `isBotConnectSucessFully` is true; `startMonitoringForReachability` fires it whenever `isTryConnect` is true.

---

## 7. Configuration flags affecting events

| `BotConnect` property | Default | Effect |
|----------------------|---------|--------|
| `isShowTokenExpiryAlertView` | `false` | When `true`, token expiry shows alert before `botClosed()`. |
| `networkOnResumeCallingHistory` | `true` | On reconnect, loads history before `establishBotConnection()`. |
| `history_enable` | `true` | Chat history feature (indirect; used on reconnect path). |

Global flags (not on `BotConnect`):

| Flag | Role |
|------|------|
| `isTryConnect` | If `false`, network reconnect callbacks skip reconnection logic. Set `false` in `botClosed()`. |
| `isBotConnectSucessFully` | Gates some `networkMonitoringForReachability` behavior. |
| `isInternetAvailable` | Updated on reachability; gates `tryConnect` retry increment. |

---

## 8. Quick reference table

| `event_code` | `event_reason` | Trigger summary |
|--------------|----------------|-----------------|
| `BotConnectionStatus` | `1` | Bot connected (`sucessMethod`) |
| `BotConnectionStatus` | `2` | Max connect retries / token expiry notification |
| `BotConnectionStatus` | `3` | `socketDisconnect()` |
| `BotClosed` | `4` | Back while connection mask visible |
| `BotClosed` | `5` | Close on popup |
| `BotMinimized` | `6` | Minimize on popup or `minimizeChatBot()` |
| `BotConnectionLost` | `7` | Network `.notReachable` |
| `BotConnectionLost` | `11` | RTM socket failure → `BotConnectionLostNotification` |
| `NetworkReconnected` | `8` | Network reachable |
| `DeepLinkClicked` | `9` | Same-page navigation template link |
| `StartNewSession` | `10` | Custom header **Start New Session** → `socketDisconnect`, then host calls `socketConnect(isReconnect: true)` |

---

## 9. Source file index

| Concern | File |
|---------|------|
| All `event_code` payloads | `ChatMessagesViewController.swift` |
| **`BotConnectionLost` reason `11`** | `ChatMessagesViewController.swift` (`botConnectionDidFailWithError`) |
| Socket failure → notification | `KABotClient.swift` (`connectionDidFailWithError` → `botConnectionLostNotification`) |
| Public callback wiring | `BotConnect.swift` |
| Token expiry notification | `KABotClient.swift` (`tryConnect` failure) |
| **`DeepLinkClicked` emission** | `ChatMessagesViewController.swift` (`deepLinkNotificationAction`) |
| **`StartNewSession` emission** | `ChatMessagesViewController.swift` (`customHeaderViewConfigure`, `startNewSession` closure) |
| Custom header `startNewSession` API | `KoreCustomHeaderView.swift` |
| Deeplink notification post | `ButtonLinkNBubbleView.swift` (`didSelectRowAt`) |
| Notification name constants | `Common.swift` (`tokenExipryNotification`, `deepLinkNotification`) |
| Demo integration | `Examples/CocoapodsDemo/KoreBotSDKDemo/ViewController.swift` |

---

## 10. Version notes

- Commented legacy UIAlert close/minimize paths in `tapsOnBackBtnAct` still show older payloads **without** `event_reason`; the active UI uses `closePopupAction` / `minimizePopupAction` with reasons `5` and `6`.
- A commented React Native-style payload `DEEPLINK_ROUTER` exists in `ButtonLinkNBubbleView`; the shipped event is **`DeepLinkClicked`** with `event_reason: 9` and the path in `event_message`.
