# Branding API Flow Documentation

## Overview
The branding API system in the KoreAI Bot SDK provides a comprehensive way to customize the visual appearance and styling of the chat interface. This document outlines the complete flow of the branding functionality, from API requests to implementation.

## Architecture Components

### Core Components
1. **KABotClient**
   - Main client interface for bot communication
   - Handles branding API requests
   - Manages branding state

2. **BrandingSingleton**
   - Singleton class for storing branding information
   - Provides global access to branding values
   - Manages branding state persistence

3. **ChatMessagesViewController**
   - Implements branding changes
   - Handles UI updates
   - Manages branding data flow

## Data Models

### BrandingModel
```swift
class BrandingModel: NSObject, Decodable {
    // Widget Properties
    public var widgetBorderColor: String?
    public var widgetTextColor: String?
    public var widgetBgColor: String?
    public var widgetDividerColor: String?
    
    // Button Properties
    public var buttonInactiveBgColor: String?
    public var buttonInactiveTextColor: String?
    public var buttonActiveBgColor: String?
    public var buttonActiveTextColor: String?
    
    // Chat Properties
    public var botchatTextColor: String?
    public var botchatBgColor: String?
    public var userchatBgColor: String?
    public var userchatTextColor: String?
    
    // Theme Properties
    public var theme: String?
    public var botName: String?
    
    // Additional Properties
    public var bankLogo: String?
    public var widgetBgImage: String?
    public var widgetBodyColor: String?
    public var widgetFooterColor: String?
    public var widgetHeaderColor: String?
}
```

### ActiveTheme
```swift
class ActiveTheme: NSObject, Decodable {
    public var botMessage: BotMessagee?
    public var buttons: Buttons?
    public var userMessage: BotMessagee?
    public var widgetBody: WidgetBody?
    public var widgetFooter: WidgetFooter?
    public var widgetHeader: WidgetHeader?
    public var generalAttributes: GeneralAttributes?
}
```

## API Flow

### 1. Branding API Request Flow
```swift
func brandingApiRequest(_ token: String, success: @escaping ([String: Any]) -> Void, failure: @escaping (Error) -> Void) {
    // 1. Construct API URL
    let urlString = "\(serverUrl)/api/branding/\(botId)"
    
    // 2. Set up headers
    let headers: HTTPHeaders = [
        "Authorization": "bearer \(token)",
        "Content-Type": "application/json"
    ]
    
    // 3. Make API request
    sessionManager.request(urlString, 
                         method: .get, 
                         headers: headers)
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                if let brandingData = value as? [String: Any] {
                    success(brandingData)
                }
            case .failure(let error):
                failure(error)
            }
        }
}
```

### 2. Data Processing Flow
1. **API Response Processing**
   ```swift
   // Parse branding response
   if let brandingDic = response as? [String: Any] {
       if let v3Branding = brandingDic["v3"] as? [String: Any] {
           // Process V3 branding
           processBrandingV3(v3Branding)
       } else if let v2Branding = brandingDic["v2"] as? [String: Any] {
           // Process V2 branding
           processBrandingV2(v2Branding)
       }
   }
   ```

2. **Branding Data Storage**
   ```swift
   func storeBrandingData(_ data: BrandingModel) {
       let shared = BrandingSingleton.shared
       shared.widgetBorderColor = data.widgetBorderColor
       shared.widgetTextColor = data.widgetTextColor
       shared.buttonInactiveBgColor = data.buttonInactiveBgColor
       // ... store other properties
   }
   ```
