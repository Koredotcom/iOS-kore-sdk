# Chat History API Flow Documentation

## Overview
The Chat History functionality in the KoreAI Bot SDK provides a mechanism to retrieve historical chat messages between the user and the bot. This document outlines the complete flow of the history retrieval process, including API requests, data models, and implementation details.

## Data Flow

### 1. History Request Flow
```swift
func getHistory(offset: String?, success: @escaping ([Message]) -> Void, failure: @escaping (Error) -> Void) {
    // 1. Construct API URL
    let urlString = "\(serverUrl)/api/1.1/ka/users/\(userId)/history"
    
    // 2. Set up parameters
    var parameters: [String: Any] = [
        "botId": botId,
        "limit": 20  // Default limit
    ]
    if let offset = offset {
        parameters["offset"] = offset
    }
    
    // 3. Set up headers
    let headers: HTTPHeaders = [
        "Authorization": "bearer \(token)",
        "Content-Type": "application/json"
    ]
    
    // 4. Make API request
    sessionManager.request(urlString,
                         method: .get,
                         parameters: parameters,
                         headers: headers)
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                if let messages = self.parseHistoryResponse(value) {
                    success(messages)
                }
            case .failure(let error):
                failure(error)
            }
        }
}
```

### 2. Data Processing Flow

#### Message Parsing
```swift
func parseHistoryResponse(_ response: Any) -> [Message]? {
    guard let historyData = response as? [String: Any],
          let messages = historyData["messages"] as? [[String: Any]] else {
        return nil
    }
    
    return messages.compactMap { messageData in
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: messageData)
            return try JSONDecoder().decode(Message.self, from: jsonData)
        } catch {
            print("Error parsing message: \(error)")
            return nil
        }
    }
}
```

### 3. Message Model
```swift
struct Message: Codable {
    // Message Properties
    let messageId: String
    let type: String
    let message: MessageContent
    let timestamp: Date
    let sender: Sender
    
    // Optional Properties
    var attachments: [Attachment]?
    var metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case messageId = "id"
        case type
        case message
        case timestamp
        case sender
        case attachments
        case metadata
    }
}

struct MessageContent: Codable {
    let text: String?
    let components: [MessageComponent]?
}

struct Sender: Codable {
    let id: String
    let type: String  // "bot" or "user"
}
```

## Implementation Details

### 1. Pagination Handling
```swift
class HistoryManager {
    private var currentOffset: String?
    private var hasMoreMessages: Bool = true
    
    func loadNextPage(completion: @escaping ([Message]) -> Void) {
        guard hasMoreMessages else {
            completion([])
            return
        }
        
        botClient.getHistory(offset: currentOffset) { [weak self] messages in
            guard let self = self else { return }
            
            // Update pagination state
            self.hasMoreMessages = !messages.isEmpty
            if let lastMessage = messages.last {
                self.currentOffset = lastMessage.messageId
            }
            
            completion(messages)
        } failure: { error in
            print("Failed to load history: \(error)")
            completion([])
        }
    }
}
```



## Error Handling

### 1. Network Error Handling
```swift
enum HistoryError: Error {
    case invalidResponse
    case parsingError
    case networkError(Error)
    case unauthorized
}

func handleHistoryError(_ error: Error) {
    switch error {
    case let historyError as HistoryError:
        switch historyError {
        case .invalidResponse:
            // Handle invalid response
            break
        case .parsingError:
            // Handle parsing error
            break
        case .networkError(let error):
            // Handle network error
            break
        case .unauthorized:
            // Handle unauthorized error
            break
        }
    default:
        // Handle unknown error
        break
    }
}
```

### 2. Data Validation
```swift
func validateHistoryResponse(_ response: Any) -> Bool {
    guard let historyData = response as? [String: Any],
          let messages = historyData["messages"] as? [[String: Any]],
          let offset = historyData["offset"] as? String else {
        return false
    }
    return true
}
```

## Best Practices

1. **Performance**
   - Implement efficient pagination
   - Cache history data locally
   - Optimize network requests

2. **Data Management**
   - Handle message ordering
   - Implement proper data persistence
   - Manage memory efficiently

3. **Error Recovery**
   - Implement retry mechanisms
   - Handle network timeouts
   - Provide fallback options

## Security Considerations

1. **Data Protection**
   - Secure message storage
   - Encrypt sensitive data
   - Handle user privacy

2. **Authentication**
   - Validate tokens
   - Handle session expiry
   - Secure API endpoints

## Usage Examples

### 1. Basic History Retrieval
```swift
let botClient = BotClient()
botClient.getHistory(offset: nil) { messages in
    // Handle retrieved messages
    messages.forEach { message in
        print("Message: \(message.processMessageContent())")
    }
} failure: { error in
    print("Failed to retrieve history: \(error)")
}
```

### 2. Paginated History Loading
```swift
let historyManager = HistoryManager()
func loadMoreHistory() {
    historyManager.loadNextPage { messages in
        if messages.isEmpty {
            print("No more messages")
            return
        }
        // Process new messages
        updateUI(with: messages)
    }
}
```
