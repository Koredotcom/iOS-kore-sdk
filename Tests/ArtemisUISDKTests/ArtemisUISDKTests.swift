import XCTest
@testable import ArtemisUISDK
import ArtemisSocketSDK

final class ArtemisUISDKTests: XCTestCase {
    func testCreateDefaultRequiresExactlyOneCredential() throws {
        let config = try ArtemisUISDK.SDKConfigurationLoader.createDefault(projectId: "p", endpoint: "https://example.com", apiKey: "key")
        XCTAssertEqual(config.connection.projectId, "p")
        XCTAssertThrowsError(try ArtemisUISDK.SDKConfigurationLoader.createDefault(projectId: "p", endpoint: "https://example.com"))
    }

    func testMessageParsesRichContentAndActions() throws {
        let message = Message(
            id: "m1",
            role: .assistant,
            content: "Here you go",
            metadata: [
                "richContent": AnySendable([
                    "kpi": ["label": "Revenue", "value": 42, "unit": "USD"],
                    "quick_replies": [["id": "yes", "label": "Yes"]],
                    "form": [
                        "title": "Profile",
                        "fields": [["id": "email", "type": "input", "label": "Email", "required": true]]
                    ]
                ]),
                "actions": AnySendable([
                    "renderId": "r1",
                    "elements": [["id": "confirm", "type": "button", "label": "Confirm", "value": "ok"]]
                ])
            ]
        )

        XCTAssertEqual(message.richContent?.kpi?.displayValue, "42 USD")
        XCTAssertEqual(message.richContent?.quickReplies?.first?.label, "Yes")
        XCTAssertEqual(message.richContent?.form?.fields.first?.id, "email")
        XCTAssertEqual(message.actions?.elements.first?.id, "confirm")
        XCTAssertEqual(message.actions?.renderId, "r1")
    }
}
