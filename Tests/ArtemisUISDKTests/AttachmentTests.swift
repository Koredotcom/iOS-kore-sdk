import XCTest
@testable import ArtemisUISDK
@testable import ArtemisSocketSDK

final class AttachmentTests: XCTestCase {
    func testMultipartPreservesBinaryAndEscapesFilename() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("report\"\r\n.pdf")
        let bytes = Data([0, 255, 13, 10, 128])
        try bytes.write(to: file)
        let bodyURL = try AttachmentHTTP.multipartFile(source: file, contentType: "application/pdf", boundary: "test-boundary")
        defer { try? FileManager.default.removeItem(at: bodyURL) }
        let body = try Data(contentsOf: bodyURL)
        var expected = Data("--test-boundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"report___.pdf\"\r\nContent-Type: application/pdf\r\n\r\n".utf8)
        expected.append(bytes)
        expected.append(Data("\r\n--test-boundary--\r\n".utf8))
        XCTAssertEqual(body, expected)
    }

    func testMultipartRejectsRemoteSource() {
        XCTAssertThrowsError(try AttachmentHTTP.multipartFile(source: URL(string: "https://example.com/file")!, contentType: "image/png", boundary: "test"))
    }

    func testScopedAttachmentRoutesEncodePathSegments() throws {
        let url = try AttachmentHTTP.url(endpoint: "https://example.com/", projectId: "p/one", sessionId: "s?two", attachmentId: "a#three")
        XCTAssertEqual(url.absoluteString, "https://example.com/api/projects/p%2Fone/sessions/s%3Ftwo/attachments/a%23three/url?disposition=attachment")
    }

    func testUploadUsesSDKTokenAndReturnsAttachmentID() async throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("hello".utf8).write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [AttachmentProtocol.self]
        let session = URLSession(configuration: config)
        defer { session.invalidateAndCancel() }
        let id = try await AttachmentHTTP.upload(fileURL: file, contentType: "text/plain", endpoint: "https://example.com", projectId: "project", sessionId: "session", token: "session-token", urlSession: session)
        XCTAssertEqual(id, "att-1")
    }

    func testUploadRejectsMalformedResponseAndHTTPFailure() async throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("hello".utf8).write(to: file)
        defer { try? FileManager.default.removeItem(at: file) }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [AttachmentProtocol.self]
        let session = URLSession(configuration: config)
        defer { session.invalidateAndCancel() }
        for project in ["missing-id", "denied"] {
            do {
                _ = try await AttachmentHTTP.upload(fileURL: file, contentType: "text/plain", endpoint: "https://example.com", projectId: project, sessionId: "session", token: "session-token", urlSession: session)
                XCTFail("Expected upload failure for \(project)")
            } catch {
                XCTAssertTrue(error is AttachmentError)
            }
        }
    }

    func testHistoryUsesWebSDKCustomerAttachmentMetadata() {
        let message = Message(id: "m", role: .user, content: "", metadata: ["custom": AnySendable([
            "customerAttachments": [
                ["attachmentId": "a1", "fileName": "image.png", "fileType": "image/png", "size": 42],
                ["id": "a1", "filename": "duplicate"]
            ]
        ])])
        XCTAssertEqual(ChatAttachment.from(message), [ChatAttachment(id: "a1", filename: "image.png", mimeType: "image/png", sizeBytes: 42)])
    }

    func testHistoryParsesParallelMetadataAndBareIDs() {
        let message = Message(id: "m", role: .user, content: "", metadata: [
            "attachmentIds": AnySendable(["a1", "a2"]),
            "attachmentFilenames": AnySendable(["document.pdf"]),
            "attachmentMimeTypes": AnySendable(["application/pdf"]),
            "attachmentSizes": AnySendable([2048])
        ])
        let refs = ChatAttachment.from(message)
        XCTAssertEqual(refs.count, 2)
        XCTAssertEqual(refs[0].sizeBytes, 2048)
        XCTAssertEqual(refs[1].filename, "Attachment")
        XCTAssertEqual(ChatAttachment.from(Message(id: "m2", role: .user, content: "", attachmentIds: ["a3"])).first?.id, "a3")
    }

    @MainActor func testDisconnectedUploadsNeverSend() async {
        let sdk = AgentSDK.create(with: SDKConfiguration(environment: "dev", connection: ConnectionConfig(projectId: "p", endpoint: "https://example.com", apiKey: "key")))
        do {
            _ = try await sdk.uploadAttachment(fileURL: URL(fileURLWithPath: "/missing"))
            XCTFail("Disconnected uploads should fail")
        } catch { XCTAssertTrue(error is AgentSDKError) }
    }
}

private final class AttachmentProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-SDK-Token"), "session-token")
        XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("multipart/form-data; boundary=Artemis-") == true)
        XCTAssertTrue(request.url!.path.hasSuffix("/sessions/session/attachments"))
        let denied = request.url!.path.contains("/denied/")
        let missing = request.url!.path.contains("/missing-id/")
        let response = HTTPURLResponse(url: request.url!, statusCode: denied ? 403 : 200, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data((denied ? "Forbidden" : missing ? "{}" : "{\"attachmentId\":\"att-1\"}").utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
