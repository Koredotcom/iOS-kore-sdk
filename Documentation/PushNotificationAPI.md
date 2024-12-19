# Push Notification API Documentation

## Overview
The Push Notification API in the Kore Bot SDK provides functionality to register and unregister devices for push notifications. This document details the implementation and usage of the push notification services.

## Notification Flow

### 1. Subscribe to Notifications
```swift
func subscribeToNotifications(_ deviceToken: Data!, success:((Bool) -> Void)?, failure:((_ error: Error?) -> Void)?) {
    let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
    requestManager.subscribeToNotifications(deviceToken as Data?, 
                                         userInfo: userInfoModel, 
                                         authInfo: authInfoModel, 
                                         success: success, 
                                         failure: failure)
}
```

### 2. HTTP Request Implementation
```swift
func subscribeToNotifications(_ deviceToken: Data!, 
                            userInfo: UserModel!, 
                            authInfo: AuthInfoModel!, 
                            success:((_ staus: Bool) -> Void)?, 
                            failure:((_ error: Error) -> Void)?) {
    // 1. Construct URL
    let urlString: String = Constants.URL.subscribeUrl(userInfo.userId)
    
    // 2. Set up authorization header
    let accessToken = String(format: "%@ %@", authInfo.tokenType ?? "", authInfo.accessToken ?? "")
    let headers: HTTPHeaders = [
        "Authorization": accessToken,
    ]
    
    // 3. Convert device token to hex string
    let deviceId = deviceToken.hexadecimal()
    guard deviceId != nil else {
        failure?(NSError(domain: "KoreBotSDK", 
                        code: 0, 
                        userInfo: ["message": "deviceId is nil"]))
        return
    }
    
    // 4. Set up request parameters
    let parameters: [String: Any] = [
        "deviceId": deviceId, 
        "osType": "ios"
    ]
    
    // 5. Make API request
    let dataRequest = sessionManager.request(urlString, 
                                          method: .post, 
                                          parameters: parameters, 
                                          headers: headers)
    
    // 6. Handle response
    dataRequest.validate().responseJSON { (response) in
        if let _ = response.error {
            let error = NSError(domain: "KoreBotSDK", code: 0, userInfo: [:])
            failure?(error)
            return
        }
        
        if let _ = response.value {
            success?(true)
        } else {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: [:]))
        }
    }
}
```

### 3. Unsubscribe from Notifications
```swift
func unsubscribeToNotifications(_ deviceToken: Data!, success:((Bool) -> Void)?, failure:((_ error: Error?) -> Void)?) {
    let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
    requestManager.unsubscribeToNotifications(deviceToken as Data?, 
                                           userInfo: userInfoModel, 
                                           authInfo: authInfoModel, 
                                           success: success, 
                                           failure: failure)
}
```

### 4. Unsubscribe Implementation
```swift
func unsubscribeToNotifications(_ deviceToken: Data!, 
                              userInfo: UserModel!, 
                              authInfo: AuthInfoModel!, 
                              success:((_ staus: Bool) -> Void)?, 
                              failure:((_ error: Error) -> Void)?) {
    // 1. Construct URL
    let urlString: String = Constants.URL.unSubscribeUrl(userInfo.userId)
    
    // 2. Set up authorization header
    let accessToken = String(format: "%@ %@", authInfo.tokenType ?? "", authInfo.accessToken ?? "")
    let headers: HTTPHeaders = [
        "Authorization": accessToken,
    ]
    
    // 3. Convert device token to hex string
    let deviceId = deviceToken.hexadecimal()
    guard deviceId != nil else {
        failure?(NSError(domain: "KoreBotSDK", 
                        code: 0, 
                        userInfo: ["message": "deviceId is nil"]))
        return
    }
    
    // 4. Set up request parameters
    let parameters: [String: Any] = ["deviceId": deviceId]
    
    // 5. Make API request
    let dataRequest = sessionManager.request(urlString, 
                                          method: .delete, 
                                          parameters: parameters, 
                                          headers: headers)
    
    // 6. Handle response
    dataRequest.validate().responseJSON { (response) in
        if let _ = response.error {
            let error = NSError(domain: "KoreBotSDK", code: 0, userInfo: [:])
            failure?(error)
            return
        }
        
        if let _ = response.value {
            success?(true)
        } else {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: [:]))
        }
    }
}
```

## Required Models

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

## Usage Example

### Subscribe to Notifications
```swift
// Get device token from APNS
func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    botClient.subscribeToNotifications(deviceToken,
        success: { status in
            print("Successfully subscribed to notifications")
        },
        failure: { error in
            print("Failed to subscribe: \(error?.localizedDescription ?? "")")
        })
}
```

### Unsubscribe from Notifications
```swift
func unsubscribeUser(deviceToken: Data) {
    botClient.unsubscribeToNotifications(deviceToken,
        success: { status in
            print("Successfully unsubscribed from notifications")
        },
        failure: { error in
            print("Failed to unsubscribe: \(error?.localizedDescription ?? "")")
        })
}
```

## Error Handling

### Common Error Cases
1. **Invalid Device Token**
   - Error when device token is nil or invalid
   - Proper hex conversion failure

2. **Authentication Errors**
   - Invalid or expired access token
   - Missing authorization headers

3. **Network Errors**
   - Connection timeout
   - Server unavailable
   - Invalid response format

## Best Practices

1. **Device Token Management**
   - Store device token securely
   - Update token when it changes
   - Handle token refresh scenarios

2. **Error Recovery**
   - Implement retry mechanism
   - Handle token expiry
   - Log failures for debugging

3. **Security**
   - Secure token storage
   - Proper authorization
   - Data encryption

## API Endpoints

### Subscribe URL
```swift
/api/users/{userId}/subscribe
```

### Unsubscribe URL
```swift
/api/users/{userId}/unsubscribe
```

## Headers
```swift
Authorization: Bearer {access_token}
Content-Type: application/json
```

## Request Parameters
```swift
{
    "deviceId": "device_token_hex_string",
    "osType": "ios"
}
```

## Response Format
```swift
// Success
{
    "status": true
}

// Error
{
    "error": {
        "code": "error_code",
        "message": "error_message"
    }
}
```
