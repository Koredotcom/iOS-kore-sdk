import Foundation

enum TransportClientMessage {
    case chatMessage(
        text: String,
        messageId: String?,
        sessionId: String?,
        attachmentIds: [String]?,
        metadata: [String: Any]?,
        customData: [String: Any]?
    )
    case endSession(sessionId: String?)
    case actionSubmit(
        actionId: String,
        value: String?,
        formData: [String: String]?,
        renderId: String?
    )
    case feedbackSubmit(
        messageId: String,
        ratingType: String,
        ratingValue: Int,
        feedbackText: String?,
        actionRenderId: String?
    )

    func toJSON() throws -> String {
        let dict = toDictionary()
        let data = try JSONSerialization.data(withJSONObject: dict)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "ArtemisSocketSDK", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to encode transport message",
            ])
        }
        return json
    }

    func toDictionary() -> [String: Any] {
        switch self {
        case let .chatMessage(text, messageId, sessionId, attachmentIds, metadata, customData):
            var dict: [String: Any] = ["type": "chat_message", "text": text]
            if let messageId { dict["messageId"] = messageId }
            if let sessionId { dict["sessionId"] = sessionId }
            if let attachmentIds { dict["attachmentIds"] = attachmentIds }
            if let metadata { dict["metadata"] = metadata }
            if let customData, !customData.isEmpty { dict["customData"] = customData }
            return dict

        case let .endSession(sessionId):
            var dict: [String: Any] = ["type": "end_session"]
            if let sessionId { dict["sessionId"] = sessionId }
            return dict

        case let .actionSubmit(actionId, value, formData, renderId):
            var dict: [String: Any] = ["type": "action_submit", "actionId": actionId]
            if let value { dict["value"] = value }
            if let formData { dict["formData"] = formData }
            if let renderId { dict["renderId"] = renderId }
            return dict

        case let .feedbackSubmit(messageId, ratingType, ratingValue, feedbackText, actionRenderId):
            var dict: [String: Any] = [
                "type": "feedback.submit",
                "messageId": messageId,
                "ratingType": ratingType,
                "ratingValue": ratingValue,
            ]
            if let feedbackText { dict["feedbackText"] = feedbackText }
            if let actionRenderId { dict["actionRenderId"] = actionRenderId }
            return dict
        }
    }
}

struct TransportServerMessage {
    let type: String
    let raw: [String: Any]

    static func fromJSONData(_ data: Data) throws -> TransportServerMessage {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "ArtemisSocketSDK", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid WebSocket message JSON",
            ])
        }
        return TransportServerMessage(
            type: json["type"] as? String ?? "unknown",
            raw: json
        )
    }
}
