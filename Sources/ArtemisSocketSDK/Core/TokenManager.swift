import Foundation

private let refreshLeewayMs: Int64 = 60 * 1000

/// Bootstrap and refresh short-lived SDK session tokens.
final class TokenManager {
    private let config: SDKConfiguration
    private let httpEndpoint: String
    private let urlSession: URLSession

    private var token: String?
    private var expiresAtMs: Int64?
    private var scope: SDKSessionScope?
    private var widgetConfig: WidgetConfig?
    private var inflight: Task<String, Error>?

    init(config: SDKConfiguration, urlSession: URLSession = .shared) {
        self.config = config
        self.httpEndpoint = EndpointNormalizer.normalizeHttpEndpoint(config.connection.endpoint)
        self.urlSession = urlSession
    }

    func getToken() async throws -> String {
        if let inflight {
            return try await inflight.value
        }

        if let token, !shouldRefresh() {
            return token
        }

        let task = Task<String, Error> {
            defer { self.inflight = nil }
            return try await refreshOrInit()
        }
        inflight = task
        return try await task.value
    }

    func getScope() -> SDKSessionScope? { scope }
    func getWidgetConfig() -> WidgetConfig? { widgetConfig }

    func invalidateToken() {
        token = nil
        expiresAtMs = nil
        scope = nil
        widgetConfig = nil
    }

    // MARK: - Private

    private func refreshOrInit() async throws -> String {
        if token == nil {
            return try await initToken()
        }

        let currentToken = token!

        do {
            return try await refreshToken(currentToken)
        } catch let validation as TokenResponseValidationError {
            clearToken()
            throw SdkStageError(code: .tokenRefresh, cause: validation)
        } catch {
            if !isExpired(), !isUnauthorizedError(error) {
                return currentToken
            }
            clearToken()
            return try await initToken()
        }
    }

    private func initToken() async throws -> String {
        do {
            return try await initTokenImpl()
        } catch let staged as SdkStageError {
            throw staged
        } catch {
            throw SdkStageError(code: .tokenInit, cause: error)
        }
    }

    private func initTokenImpl() async throws -> String {
        var body: [String: Any] = [:]
        var headers = ["Content-Type": "application/json"]

        if let bootstrapToken = config.connection.bootstrapToken, !bootstrapToken.isEmpty {
            body["bootstrapToken"] = bootstrapToken
        } else {
            if let channel = config.channel {
                if let channelId = channel.channelId, !channelId.isEmpty {
                    body["channelId"] = channelId
                } else if let channelName = channel.channelName, !channelName.isEmpty {
                    body["channelName"] = channelName
                }
                if let deploymentSlug = channel.deploymentSlug, !deploymentSlug.isEmpty {
                    body["deploymentSlug"] = deploymentSlug
                }
            }

            if let userContext = config.userContext {
                var contextBody: [String: Any] = [:]
                if let userId = userContext.userId, !userId.isEmpty {
                    contextBody["userId"] = userId
                }
                if let attrs = JSONValue.dictionary(from: userContext.customAttributes), !attrs.isEmpty {
                    contextBody["customAttributes"] = attrs
                }
                if !contextBody.isEmpty {
                    body["userContext"] = contextBody
                }
            }

            guard let apiKey = config.connection.apiKey, !apiKey.isEmpty else {
                throw TokenRequestError(status: 0, message: "connection.api_key is required")
            }
            headers["X-Public-Key"] = apiKey
        }

        let url = URL(string: "\(httpEndpoint)/api/v1/sdk/init")!
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        if config.debug.logNetworkRequests {
            ArtemisLogger.debug("SDK init request", metadata: [
                "url": url.absoluteString,
                "headers": headers,
            ])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        for (key, value) in headers { request.setValue(value, forHTTPHeaderField: key) }
        request.httpBody = bodyData

        let (data, response) = try await urlSession.data(for: request)
        return try storeResponse(data: data, response: response, fallbackMessage: "SDK init failed")
    }

    private func refreshToken(_ currentToken: String) async throws -> String {
        let url = URL(string: "\(httpEndpoint)/api/v1/sdk/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(currentToken, forHTTPHeaderField: "X-SDK-Token")
        request.httpBody = "{}".data(using: .utf8)

        let (data, response) = try await urlSession.data(for: request)
        return try storeResponse(data: data, response: response, fallbackMessage: "SDK token refresh failed")
    }

    private func storeResponse(data: Data, response: URLResponse, fallbackMessage: String) throws -> String {
        guard let http = response as? HTTPURLResponse else {
            throw TokenRequestError(status: 0, message: fallbackMessage)
        }

        if http.statusCode < 200 || http.statusCode >= 300 {
            let message = String(data: data, encoding: .utf8).flatMap { $0.isEmpty ? nil : $0 } ?? fallbackMessage
            throw TokenRequestError(status: http.statusCode, message: message)
        }

        let payload = try JSONSerialization.jsonObject(with: data)
        let parsed = try parseTokenResponse(payload, fallbackMessage: fallbackMessage)
        token = parsed.token
        expiresAtMs = Int64(Date().timeIntervalSince1970 * 1000) + Int64(parsed.expiresIn) * 1000
        scope = try resolveScope(parsed)
        widgetConfig = parsed.widgetConfig
        return parsed.token
    }

    private struct TokenResponse {
        let token: String
        let expiresIn: Int
        let tenantId: String
        let projectId: String
        let channelId: String
        let deploymentId: String?
        let permissions: [String]
        let showActivityUpdates: Bool
        let widgetConfig: WidgetConfig?
    }

    private func parseTokenResponse(_ payload: Any, fallbackMessage: String) throws -> TokenResponse {
        guard let map = payload as? [String: Any] else {
            throw TokenResponseValidationError(message: "\(fallbackMessage): invalid JSON payload.")
        }

        let token = (map["token"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if token.isEmpty {
            throw TokenResponseValidationError(message: "\(fallbackMessage): missing token in SDK session response.")
        }

        let expiresInValue = map["expiresIn"]
        let expiresIn: Int
        if let int = expiresInValue as? Int { expiresIn = int }
        else if let double = expiresInValue as? Double { expiresIn = Int(double) }
        else { throw TokenResponseValidationError(message: "\(fallbackMessage): invalid expiresIn in SDK session response.") }
        if expiresIn <= 0 {
            throw TokenResponseValidationError(message: "\(fallbackMessage): invalid expiresIn in SDK session response.")
        }

        let tenantId = (map["tenantId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let projectId = (map["projectId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let channelId = (map["channelId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if tenantId.isEmpty || projectId.isEmpty || channelId.isEmpty {
            throw TokenResponseValidationError(
                message: "\(fallbackMessage): Runtime must return tenantId, projectId, and channelId."
            )
        }

        let permissions = (map["permissions"] as? [Any])?
            .compactMap { $0 as? String }
            .filter { !$0.isEmpty } ?? []
        if permissions.isEmpty {
            throw TokenResponseValidationError(
                message: "\(fallbackMessage): Runtime must return a non-empty permissions array."
            )
        }

        guard let showActivityUpdates = map["showActivityUpdates"] as? Bool else {
            throw TokenResponseValidationError(
                message: "\(fallbackMessage): Runtime must return showActivityUpdates."
            )
        }

        let deploymentId = (map["deploymentId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let widgetConfigRaw = map["widgetConfig"] as? [String: Any]
        let widgetConfig = widgetConfigRaw.map { WidgetConfig(raw: $0) }

        return TokenResponse(
            token: token,
            expiresIn: expiresIn,
            tenantId: tenantId,
            projectId: projectId,
            channelId: channelId,
            deploymentId: deploymentId?.isEmpty == false ? deploymentId : nil,
            permissions: permissions,
            showActivityUpdates: showActivityUpdates,
            widgetConfig: widgetConfig
        )
    }

    private func resolveScope(_ payload: TokenResponse) throws -> SDKSessionScope {
        let nextScope = SDKSessionScope(
            tenantId: payload.tenantId,
            projectId: payload.projectId,
            channelId: payload.channelId,
            deploymentId: payload.deploymentId,
            permissions: payload.permissions,
            showActivityUpdates: payload.showActivityUpdates
        )

        if nextScope.projectId != config.connection.projectId {
            throw TokenResponseValidationError(
                message: "Runtime returned an SDK session for a different project than the SDK config."
            )
        }

        if let previous = scope {
            if previous.tenantId != nextScope.tenantId ||
                previous.projectId != nextScope.projectId ||
                previous.channelId != nextScope.channelId ||
                previous.deploymentId != nextScope.deploymentId ||
                previous.showActivityUpdates != nextScope.showActivityUpdates ||
                previous.permissions != nextScope.permissions {
                throw TokenResponseValidationError(
                    message: "Runtime changed SDK session scope during refresh. Re-initialize the SDK session."
                )
            }
        }

        return nextScope
    }

    private func shouldRefresh() -> Bool {
        guard let expiresAtMs else { return true }
        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
        return expiresAtMs - nowMs <= refreshLeewayMs
    }

    private func isExpired() -> Bool {
        guard let expiresAtMs else { return true }
        return expiresAtMs <= Int64(Date().timeIntervalSince1970 * 1000)
    }

    private func isUnauthorizedError(_ error: Error) -> Bool {
        guard let tokenError = error as? TokenRequestError else { return false }
        return tokenError.status == 401 || tokenError.status == 403
    }

    private func clearToken() {
        token = nil
        expiresAtMs = nil
        scope = nil
        widgetConfig = nil
    }
}
