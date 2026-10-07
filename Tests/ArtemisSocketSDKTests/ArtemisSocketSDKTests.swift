import XCTest
@testable import ArtemisSocketSDK

final class EndpointNormalizerTests: XCTestCase {
    func testNormalizeHttpEndpointStripsTrailingSlash() {
        XCTAssertEqual(
            EndpointNormalizer.normalizeHttpEndpoint("https://example.com/"),
            "https://example.com"
        )
    }

    func testNormalizeWebSocketEndpointConvertsHttpsToWss() {
        XCTAssertEqual(
            EndpointNormalizer.normalizeWebSocketEndpoint("https://example.com"),
            "wss://example.com"
        )
    }

    func testWebSocketAuthProtocols() {
        XCTAssertEqual(
            WebSocketAuth.buildTicketProtocols("ticket123"),
            ["sdk-ticket", "ticket123"]
        )
        XCTAssertEqual(
            WebSocketAuth.buildTokenProtocols("token456"),
            ["sdk-auth", "token456"]
        )
    }
}

final class SDKConfigurationLoaderTests: XCTestCase {
    func testLoadFromYAMLString() throws {
        let yaml = """
        artemis_sdk:
          environment: dev
          connection:
            project_id: test-project
            endpoint: https://example.com
            api_key: test-key
        """

        let config = try SDKConfigurationLoader.load(yaml: yaml)
        XCTAssertEqual(config.environment, "dev")
        XCTAssertEqual(config.connection.projectId, "test-project")
        XCTAssertEqual(config.connection.endpoint, "https://example.com")
        XCTAssertEqual(config.connection.apiKey, "test-key")
    }

    func testValidationRejectsMissingApiKey() {
        let yaml = """
        artemis_sdk:
          environment: dev
          connection:
            project_id: test-project
            endpoint: https://example.com
        """

        XCTAssertThrowsError(try SDKConfigurationLoader.load(yaml: yaml)) { error in
            XCTAssertTrue(error is SDKConfigurationError)
        }
    }

    func testCreateDefaultConfiguration() {
        let config = SDKConfigurationLoader.createDefault(
            projectId: "proj",
            endpoint: "https://example.com",
            apiKey: "key"
        )
        XCTAssertEqual(config.connection.projectId, "proj")
        XCTAssertTrue(config.debug.enabled)
    }
}

final class TransportTypesTests: XCTestCase {
    func testChatMessageTransportJSON() throws {
        let message = TransportClientMessage.chatMessage(
            text: "Hello",
            messageId: "msg_1",
            sessionId: "sess_1",
            attachmentIds: nil,
            metadata: ["key": "value"],
            customData: ["platform": "ios"]
        )

        let dict = message.toDictionary()
        XCTAssertEqual(dict["type"] as? String, "chat_message")
        XCTAssertEqual(dict["text"] as? String, "Hello")
        XCTAssertEqual(dict["messageId"] as? String, "msg_1")
        XCTAssertEqual((dict["customData"] as? [String: Any])?["platform"] as? String, "ios")
    }

    func testServerMessageParsing() throws {
        let json = #"{"type":"session_start","sessionId":"abc"}"#.data(using: .utf8)!
        let message = try TransportServerMessage.fromJSONData(json)
        XCTAssertEqual(message.type, "session_start")
        XCTAssertEqual(message.raw["sessionId"] as? String, "abc")
    }
}
