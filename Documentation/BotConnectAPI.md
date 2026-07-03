# BotConnect Configuration API

## 1. Overview

`BotConnect` is the main entry point for integrating the Kore Bot SDK. The public properties listed below configure chat UI, connection behavior, localization, push notifications, and event callbacks.

Properties are applied in `customSettings()`, which runs when you call:

- `initialize(...)`
- `show()`
- `show(in:)`

**Set configuration properties before `show()` / `show(in:)`** so they take effect when the chat opens. Calling `initialize()` also runs `customSettings()` once, but values set after `initialize()` and before `show()` are the ones used for the chat session.

**Source:** `Sources/KoreBotSDK/AppKit/Common/BotConnect.swift`

---

## 2. Quick setup example

```swift
let botConnect = BotConnect()

// Configure before show()
botConnect.history_enable = true
botConnect.reConnectionBySDK = true
botConnect.device_Token = "a1b2c3d4..."           // hex APNS token
botConnect.koreSDkLanguage = "en"
botConnect.isShowBackButton = true
botConnect.sendAllDeepLink = false

botConnect.closeOrMinimizeEvent = { eventDic in
    // Handle SDK events — see EventCodeCallbacks.md
}

botConnect.initialize(
    clientId, clientSecret, botId, chatBotName,
    identity, isAnonymous, isWebhookEnabled,
    JWTServerUrl, BOTServerUrl, BrandingUrl,
    customData, queryParameters, customJWToken
)

botConnect.show()
```

---

## 3. Property reference

### 3.1 Chat UI & templates

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `showQuickRepliesBottom` | `Bool` | `true` | When `false`, quick-reply chips are not pinned to the bottom of the chat. |
| `showVideoOption` | `Bool` | `true` | When `true`, shows **Capture Video** in the attachment action sheet. |
| `buttonsCornerRadious` | `Double` | `5.0` | Corner radius for quick-reply / welcome button templates. |
| `buttonsTextBoraderColor` | `UIColor?` | `nil` | Border and text color for button templates. `nil` uses branding defaults. |
| `setBubbleDateFormat` | `String` | `"EE, MMM dd yyyy 'at' hh:mm:ss a"` | Date format on message bubbles. Must contain `y`, `M`, or `d`; otherwise the default format is used. |
| `setIsShowBotIconTop` | `Bool` | `false` | When `true`, shows the bot/agent avatar at the **top** of the message bubble. |
| `isShowBackButton` | `Bool` | `true` | Shows the back button in the chat header. |
| `isShowMinimiseButton` | `Bool` | `false` | Shows the minimize option in the close/minimize popup. |

**Internal mapping:** `customSettings()` → `isShowQuickRepliesBottom`, `isShowVideoOption`, `buttonTemplteBtnsCornerRadious`, `buttonTemplteBtnsTextBoraderColor`, `bubbleView_DateFormat`, `isShowBotIconTop`, `isShowBackBtn`, `isShowMiniMizeButton`.

---

### 3.2 Chat history

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `history_enable` | `Bool` | `true` | Enables loading and displaying chat history. Maps to `SDKConfiguration.botConfig.isShowChatHistory`. |
| `history_batch_size` | `Int` | `20` | Number of messages fetched per history API call. |

---

### 3.3 Connection & network

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `reConnectionBySDK` | `Bool` | `true` | When `true`, the SDK automatically retries connection on socket failure and reconnects after network restore. When `false`, the host app must handle reconnection (e.g. via `socketConnect(isReconnect:)`). |
| `networkOnResumeCallingHistory` | `Bool` | `true` | When `true`, reloads chat history before reconnecting after network is restored. |
| `isShowTokenExpiryAlertView` | `Bool` | `false` | When `true`, shows an alert on JWT/token expiry before dismissing the chat. When `false`, only fires `closeOrMinimizeEvent` with `event_reason: 2`. |

**Related methods:**

```swift
botConnect.socketConnect(isReconnect: false)
botConnect.socketDisconnect()
botConnect.socketConnectionState()           // BotClientConnectionState
botConnect.socketConnectionStateDescription() // e.g. "Connected", "Disconnected"
```

See `BotConnectionFlow.md` and `EventCodeCallbacks.md` for connection events.

---

### 3.4 Deep links & navigation

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `sendAllDeepLink` | `Bool` | `false` | When `true`, **all** link taps (buttons, WebView URLs, etc.) are routed to the host app via `DeepLinkClicked` (`event_reason: 9`) instead of opening in `SFSafariViewController`. Maps to internal `isSame_PageNavigation`. |

When `sendAllDeepLink == false`, only template elements with `isSamePageNavigation: true` fire `DeepLinkClicked`. Other URLs open in the in-app browser.

---

### 3.5 Agent chat & custom events

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `closeAgentChatEventName` | `String` | `"close_agent_chat"` | WebSocket event name sent when closing an **agent** chat session. |
| `closeButtonEventName` | `String` | `"close_button_event"` | WebSocket event name sent when the user closes a **bot** chat. |
| `minimizeButtonEventName` | `String` | `"minimize_button_event"` | WebSocket event name sent when the user minimizes the chat. |
| `isZenDeskEvent` | `Bool` | `false` | When `true`, outbound socket messages use Zendesk-style payload (`resourceid: /bot.clientEvent`, `body` = event name). |

**Agent avatar (live agent messages):**

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `agentImage` | `UIImage?` | `nil` | Local image shown as the agent avatar in message bubbles. |
| `agentImageUrlString` | `String?` | `nil` | Remote URL for the agent avatar. Used when `agentImage` is `nil`. |

---

### 3.6 Push notifications

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `device_Token` | `String?` | `nil` | Hex APNS device token. Set **before** `show()`. Auto-subscribes on successful bot connect. |
| `default_UnSubscribeNotifications` | `Bool` | `true` | When `true`, unsubscribes push notifications when the user **closes** the chat or the app terminates. Does not unsubscribe on minimize. |

See `PushNotificationAPI.md` for full push notification flow.

---

### 3.7 Localization

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `koreSDkLanguage` | `String` | `"en"` | SDK language bundle name (e.g. `"en"`, `"es"`). Loads strings from `Languages/{lang}.lproj`. |

If a custom string property below is **non-empty**, it overrides the bundle value. Leave as `""` to use the bundled localization.

| Property | UI element |
|----------|------------|
| `composeBar_Placeholder` | Compose bar placeholder |
| `tap_To_Speak` | Speech-to-text label |
| `close_Or_MinimizeTitle` | Close/minimize popup title |
| `close_Btn` | Close button label |
| `minimize_Btn` | Minimize button label |
| `cancel_Btn` | Cancel button label |
| `alert_Ok` | Alert OK button |
| `leftMenu_Title` | Left menu title |
| `confirm_Title` | Confirm dialog title |
| `please_Try_Again` | Retry / error message |
| `sessionExpiry_Msg` | Token expiry alert message |
| `videoDownload_AlertTitle` | Video download alert title |
| `fileDownloading_ToastMsg` | File downloading toast |
| `fileSavedSuccessfully_ToastMsg` | File saved toast |
| `videoDownload_AlertCancelTitle` | Video download cancel label |
| `vileDownloadFailed_ToastMsg` | File download failed toast |

---

### 3.8 Event callbacks

| Property | Type | Description |
|----------|------|-------------|
| `closeOrMinimizeEvent` | `(([String: Any]?) -> Void)!` | Main lifecycle callback. Receives dictionaries with `event_code`, `event_message`, and `event_reason`. See `EventCodeCallbacks.md`. |
| `locaNotificationEvent` | `(([String: Any]?) -> Void)!` | Fired for in-chat local notification text. Payload: `["text": "<message>"]`. |

**Example:**

```swift
botConnect.closeOrMinimizeEvent = { eventDic in
    guard let dic = eventDic,
          let eventCode = dic["event_code"] as? String else { return }

    switch eventCode {
    case "BotConnectionStatus":
        let reason = dic["event_reason"] as? Int ?? 0
        print("Connection status, reason: \(reason)")
    case "BotConnectionLost":
        print("Connection lost")
    case "DeepLinkClicked":
        let path = dic["event_message"] as? String
        // Navigate in host app
    default:
        break
    }
}
```

---

### 3.9 Chat view controller reference

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `botViewController` | `ChatMessagesViewController!` | unset until `show()` | Reference to the active chat view controller. Created in `show()` / `show(in:)`. **Do not access before `show()`.** Prefer `BotConnect` methods (`socketConnect`, `closeChatBot`, etc.) over direct VC access. |

---

## 4. Property → internal mapping

`customSettings()` copies `BotConnect` properties to internal SDK globals:

| `BotConnect` property | Internal target |
|-----------------------|-----------------|
| `showQuickRepliesBottom` | `isShowQuickRepliesBottom` |
| `showVideoOption` | `isShowVideoOption` |
| `closeAgentChatEventName` | `close_AgentChat_EventName` |
| `closeButtonEventName` | `close_Button_EventName` |
| `minimizeButtonEventName` | `minimize_Button_EventName` |
| `isZenDeskEvent` | `isZenDesk_Event` |
| `history_enable` | `SDKConfiguration.botConfig.isShowChatHistory` |
| `history_batch_size` | `SDKConfiguration.botConfig.history_batch_size` |
| `device_Token` | `SDKConfiguration.botConfig.deviceToken` |
| `networkOnResumeCallingHistory` | `isNetworkOnResumeCallingHistory` |
| `setIsShowBotIconTop` | `isShowBotIconTop` |
| `buttonsCornerRadious` | `buttonTemplteBtnsCornerRadious` |
| `buttonsTextBoraderColor` | `buttonTemplteBtnsTextBoraderColor` |
| `isShowMinimiseButton` | `isShowMiniMizeButton` |
| `isShowBackButton` | `isShowBackBtn` |
| `isShowTokenExpiryAlertView` | `isShowTokenExpiryAlertV` |
| `setBubbleDateFormat` | `bubbleView_DateFormat` |
| `reConnectionBySDK` | `isReconnectionBySdk` |
| `sendAllDeepLink` | `isSame_PageNavigation` |
| `agentImage` | `agent_Image` |
| `agentImageUrlString` | `agent_Image_UrlString` |
| `default_UnSubscribeNotifications` | `default_UnSubscribe_Notifications` |
| `koreSDkLanguage` + string overrides | `laguageSettings()` → global UI strings |

---

## 5. Related `BotConnect` methods

These are configured separately from the properties above but are commonly used together:

| Method | Purpose |
|--------|---------|
| `initialize(...)` | Bot credentials, server URLs, JWT, custom data |
| `show()` | Present chat modally from root view controller |
| `show(in:)` | Push chat onto an existing navigation stack |
| `setBrandingConfig(configTheme:)` | Apply local branding theme |
| `setCustom_JwToken(customJWToken:customData:queryParameters:)` | Refresh JWT and session context |
| `setConnectionMode(connectMode:)` | Append `ConnectionMode` query parameter |
| `showOrHideFooterViewIcons(isShowSpeachToTextIcon:isShowAttachmentIcon:isShowMenuBtnIcon:)` | Footer compose bar icons |
| `addCustomTemplates(numbersOfViews:customerTemplaateTypes:)` | Register custom bubble templates |
| `addCustomHeaderView(headerView:headerViewHeight:)` | Custom header (e.g. Start New Session) |
| `minimizeChatBot()` | Programmatic minimize |
| `closeChatBot()` | Programmatic close |
| `unsubscribeNotifications()` | Manual push unsubscribe |

---

## 6. Quick reference (defaults)

| Property | Default |
|----------|---------|
| `showQuickRepliesBottom` | `true` |
| `showVideoOption` | `true` |
| `closeAgentChatEventName` | `"close_agent_chat"` |
| `closeButtonEventName` | `"close_button_event"` |
| `minimizeButtonEventName` | `"minimize_button_event"` |
| `isZenDeskEvent` | `false` |
| `history_enable` | `true` |
| `history_batch_size` | `20` |
| `koreSDkLanguage` | `"en"` |
| `networkOnResumeCallingHistory` | `true` |
| `setIsShowBotIconTop` | `false` |
| `device_Token` | `nil` |
| `buttonsCornerRadious` | `5.0` |
| `buttonsTextBoraderColor` | `nil` |
| `isShowMinimiseButton` | `false` |
| `isShowBackButton` | `true` |
| `isShowTokenExpiryAlertView` | `false` |
| `setBubbleDateFormat` | `"EE, MMM dd yyyy 'at' hh:mm:ss a"` |
| `reConnectionBySDK` | `true` |
| `sendAllDeepLink` | `false` |
| `agentImage` | `nil` |
| `agentImageUrlString` | `nil` |
| `default_UnSubscribeNotifications` | `true` |

---

## 7. Source file index

| Concern | File |
|---------|------|
| All `BotConnect` properties | `BotConnect.swift` |
| `customSettings()` mapping | `BotConnect.swift` |
| Localization overrides | `BotConnect.swift` (`laguageSettings`, `getLaguageValues`) |
| Event callbacks wiring | `BotConnect.swift` (`show`, `show(in:)`) |
| Connection / socket state | `BotConnect.swift`, `ChatMessagesViewController.swift` |
| Push notifications | `PushNotificationAPI.md` |
| Event codes | `EventCodeCallbacks.md` |
| Demo integration | `Examples/CocoapodsDemo/KoreBotSDKDemo/ViewController.swift` |
