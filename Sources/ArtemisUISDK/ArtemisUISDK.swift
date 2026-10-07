import Foundation
import SwiftUI
import Combine
// Host apps need the socket module's initializers even with MemberImportVisibility enabled.
// Public aliases alone expose the type names but not their members.
@_exported import ArtemisSocketSDK

public typealias SDKConfiguration = ArtemisSocketSDK.SDKConfiguration
public typealias ConnectionConfig = ArtemisSocketSDK.ConnectionConfig
public typealias ChannelConfig = ArtemisSocketSDK.ChannelConfig
public typealias Message = ArtemisSocketSDK.Message
#if canImport(UIKit)
import UIKit
#endif

public struct ChatHeaderContext {
    public let title: String
    public let theme: ChatTheme?
    public let onMinimize: () -> Void
    public let onClose: () -> Void
    public init(title: String, theme: ChatTheme?, onMinimize: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.title = title; self.theme = theme; self.onMinimize = onMinimize; self.onClose = onClose
    }
}
public typealias ChatHeaderBuilder = @MainActor (ChatHeaderContext) -> AnyView

public struct ChatFooterContext {
    public let text: Binding<String>
    public let enabled: Bool
    public let placeholder: String
    public let theme: ChatTheme?
    public let onSend: () -> Void
    public let onAttach: (() -> Void)?
    public let canSend: Bool
    public let isUploading: Bool
    public let pendingAttachments: [ChatAttachment]
    public init(text: Binding<String>, enabled: Bool, placeholder: String, theme: ChatTheme?, onSend: @escaping () -> Void, onAttach: (() -> Void)? = nil, canSend: Bool? = nil, isUploading: Bool = false, pendingAttachments: [ChatAttachment] = []) {
        self.text = text; self.enabled = enabled; self.placeholder = placeholder; self.theme = theme; self.onSend = onSend; self.onAttach = onAttach
        self.canSend = canSend ?? (enabled && !text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        self.isUploading = isUploading; self.pendingAttachments = pendingAttachments
    }
}
public typealias ChatFooterBuilder = @MainActor (ChatFooterContext) -> AnyView

public enum RichTemplateTypes {
    public static let image = "image"
    public static let html = "html"
    public static let video = "video"
    public static let audio = "audio"
    public static let file = "file"
    public static let list = "list"
    public static let kpi = "kpi"
    public static let table = "table"
    public static let chart = "chart"
    public static let form = "form"
    public static let progress = "progress"
    public static let feedback = "feedback"
    public static let actions = "actions"
    public static let quickReplies = "quick_replies"
    public static let channelFallback = "channel_fallback"
}

public struct RichTemplateContext {
    public let message: Message
    public let theme: ChatTheme?
    public let accentColor: Color
    public let submitAction: (_ actionId: String, _ value: String?, _ formData: [String: String]?, _ renderId: String?) -> Void
    public let submitFeedback: (_ messageId: String, _ ratingType: String, _ ratingValue: Int, _ actionRenderId: String?) -> Void
    public init(message: Message, theme: ChatTheme?, accentColor: Color,
                submitAction: @escaping (String, String?, [String: String]?, String?) -> Void,
                submitFeedback: @escaping (String, String, Int, String?) -> Void = { _, _, _, _ in }) {
        self.message = message; self.theme = theme; self.accentColor = accentColor; self.submitAction = submitAction; self.submitFeedback = submitFeedback
    }
}

public struct RichTemplateRenderer {
    public let type: String
    public let matches: (_ message: Message) -> Bool
    public let build: @MainActor (_ message: Message, _ context: RichTemplateContext) -> AnyView
    public init(type: String, matches: @escaping (Message) -> Bool, build: @escaping @MainActor (Message, RichTemplateContext) -> AnyView) {
        self.type = type; self.matches = matches; self.build = build
    }
}

public struct RichTemplateRegistry {
    private var renderers: [String: RichTemplateRenderer] = [:]
    private var order: [String] = []
    public init() {}
    public mutating func register(_ renderer: RichTemplateRenderer, override: Bool = false) {
        if renderers[renderer.type] != nil && !override { return }
        if renderers[renderer.type] == nil { order.append(renderer.type) }
        renderers[renderer.type] = renderer
    }
    var registeredTypes: Set<String> { Set(order) }
    func renderer(for message: Message) -> RichTemplateRenderer? {
        order.lazy.compactMap { renderers[$0] }.first { $0.matches(message) }
    }
    func renderers(for message: Message) -> [RichTemplateRenderer] {
        order.compactMap { renderers[$0] }.filter { $0.matches(message) }
    }
}

public struct ChatFonts: Sendable {
    public var family: String?
    public var monospaceFamily: String?
    public init(family: String? = nil, monospaceFamily: String? = nil) {
        self.family = family; self.monospaceFamily = monospaceFamily
    }
}

public struct ChatTheme: Sendable {
    public let primaryColor: String
    public let backgroundColor: String
    public let surfaceColor: String
    public let textColor: String
    public let mutedTextColor: String
    public let headerBackgroundColor: String
    public let headerTextColor: String
    public let userBubbleColor: String
    public let userBubbleTextColor: String
    public let assistantBubbleColor: String
    public let assistantBubbleTextColor: String
    public let composeBarBackgroundColor: String
    public let borderColor: String
    public let borderRadius: Double

    public init(configuration: SDKConfiguration, widgetConfig: WidgetConfig? = nil) {
        let base = configuration.theme
        let server = widgetConfig?.theme
        func pick(_ serverValue: String?, _ fallback: String) -> String { serverValue?.isEmpty == false ? serverValue! : fallback }
        primaryColor = pick(server?.primaryColor, base.primaryColor)
        backgroundColor = pick(server?.backgroundColor, base.backgroundColor)
        surfaceColor = pick(server?.surfaceColor, base.surfaceColor)
        textColor = pick(server?.textColor, base.textColor)
        mutedTextColor = pick(server?.textMutedColor, "#667085")
        headerBackgroundColor = pick(server?.headerBackgroundColor, primaryColor)
        headerTextColor = pick(server?.headerTextColor, "#FFFFFF")
        userBubbleColor = pick(server?.userBubbleColor, primaryColor)
        userBubbleTextColor = pick(server?.userBubbleTextColor, "#FFFFFF")
        assistantBubbleColor = pick(server?.assistantBubbleColor, surfaceColor)
        assistantBubbleTextColor = pick(server?.assistantBubbleTextColor, textColor)
        composeBarBackgroundColor = pick(server?.composeBarBackgroundColor, "#FFFFFF")
        borderColor = pick(server?.borderColor, "#E4E7EC")
        borderRadius = Double(server?.borderRadius ?? Int(base.borderRadius))
    }
}

public enum ConnectionStatus: String, Sendable { case notConnected, connecting, connected }
public struct UIConfigurationError: Error, LocalizedError, Sendable {
    public let message: String
    public var errorDescription: String? { message }
    public init(_ message: String) { self.message = message }
}

public enum SDKConfigurationLoader {
    public static func createDefault(projectId: String, endpoint: String, apiKey: String? = nil,
                                     bootstrapToken: String? = nil, channelId: String? = nil,
                                     channelName: String? = nil) throws -> SDKConfiguration {
        guard !projectId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw UIConfigurationError("projectId is required") }
        guard let url = URL(string: endpoint), ["http", "https"].contains(url.scheme?.lowercased()) else { throw UIConfigurationError("endpoint must be an HTTP(S) URL") }
        guard (apiKey != nil) != (bootstrapToken != nil) else { throw UIConfigurationError("Provide exactly one of apiKey or bootstrapToken") }
        return SDKConfiguration(environment: "dev", connection: ConnectionConfig(projectId: projectId, endpoint: endpoint, apiKey: apiKey, bootstrapToken: bootstrapToken), channel: ChannelConfig(channelId: channelId, channelName: channelName))
    }
    @MainActor public static func load(fromBundle bundle: Bundle = .main, resourceName: String = "sdk_configurations", environment: String? = nil, runtimeUserContext: SDKUserContext? = nil) throws -> SDKConfiguration {
        try AgentSDK.initialize(fromBundle: bundle, resourceName: resourceName, environment: environment, runtimeUserContext: runtimeUserContext).configuration
    }
}

public enum AgentChatUI {
    public static func view(configuration: SDKConfiguration? = nil, title: String = "Chat", fonts: ChatFonts? = nil,
                            environment: String? = nil, configResource: String = "sdk_configurations",
                            runtimeUserContext: SDKUserContext? = nil, headerBuilder: ChatHeaderBuilder? = nil,
                            footerBuilder: ChatFooterBuilder? = nil, templateRegistry: RichTemplateRegistry? = nil,
                            onClose: (() -> Void)? = nil) -> AgentChatView {
        AgentChatView(configuration: configuration, title: title, fonts: fonts, environment: environment, configResource: configResource, runtimeUserContext: runtimeUserContext, headerBuilder: headerBuilder, footerBuilder: footerBuilder, templateRegistry: templateRegistry, onClose: onClose)
    }

#if canImport(UIKit)
    /// Pushes chat onto an existing navigation stack. Returns false if no stack
    /// is available or chat is already its top screen.
    @MainActor @discardableResult
    public static func show(in controller: UIViewController, configuration: SDKConfiguration? = nil,
                            title: String = "Chat", fonts: ChatFonts? = nil, environment: String? = nil,
                            configResource: String = "sdk_configurations", runtimeUserContext: SDKUserContext? = nil,
                            headerBuilder: ChatHeaderBuilder? = nil, footerBuilder: ChatFooterBuilder? = nil,
                            templateRegistry: RichTemplateRegistry? = nil,
                            hidesBottomBarWhenPushed: Bool = true, animated: Bool = true) -> Bool {
        guard let navigationController = (controller as? UINavigationController) ?? controller.navigationController,
              let source = navigationController.topViewController,
              !(source is ChatNavigationHostingController<AgentChatView>) else { return false }

        let chat = view(configuration: configuration, title: title, fonts: fonts, environment: environment,
                        configResource: configResource, runtimeUserContext: runtimeUserContext,
                        headerBuilder: headerBuilder, footerBuilder: footerBuilder, templateRegistry: templateRegistry) { [weak navigationController, weak source] in
            guard let navigationController, let source,
                  navigationController.topViewController is ChatNavigationHostingController<AgentChatView>,
                  navigationController.viewControllers.contains(where: { $0 === source }) else { return }
            navigationController.popToViewController(source, animated: animated)
        }
        let host = ChatNavigationHostingController(rootView: chat)
        host.title = title
        host.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        navigationController.pushViewController(host, animated: animated)
        return true
    }

    @MainActor public static func present(from controller: UIViewController, configuration: SDKConfiguration? = nil,
                                          title: String = "Chat", fonts: ChatFonts? = nil, environment: String? = nil,
                                          configResource: String = "sdk_configurations", runtimeUserContext: SDKUserContext? = nil,
                                          headerBuilder: ChatHeaderBuilder? = nil, footerBuilder: ChatFooterBuilder? = nil,
                                          templateRegistry: RichTemplateRegistry? = nil) {
        let chat = view(configuration: configuration, title: title, fonts: fonts, environment: environment, configResource: configResource, runtimeUserContext: runtimeUserContext, headerBuilder: headerBuilder, footerBuilder: footerBuilder, templateRegistry: templateRegistry) { [weak controller] in
            controller?.dismiss(animated: true)
        }
        let host = UIHostingController(rootView: chat)
        let navigationController = UINavigationController(rootViewController: host)
        // AgentChatView provides its own header and close action.
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .fullScreen
        controller.present(navigationController, animated: true)
    }
#endif
}

@MainActor public final class AgentChatViewModel: ObservableObject {
    @Published public private(set) var messages: [Message] = []
    @Published public private(set) var status: ConnectionStatus = .notConnected
    @Published public private(set) var isTyping = false
    @Published private(set) var scrollToBottomRequest = 0
    @Published public private(set) var theme: ChatTheme?
    @Published public var errorMessage: String?
    public private(set) var sdk: AgentSDK?
    private var sdkCancellable: AnyCancellable?
    private var chatCancellable: AnyCancellable?
    private let configuration: SDKConfiguration?
    private let environment: String?
    private let configResource: String
    private let runtimeUserContext: SDKUserContext?
    private let headerBuilder: ChatHeaderBuilder?
    private let footerBuilder: ChatFooterBuilder?
    private let templateRegistry: RichTemplateRegistry?
    @Published public var composeText = ""
    @Published public internal(set) var pendingAttachments: [ChatAttachment] = []
    @Published public internal(set) var isUploadingAttachment = false
    @Published public internal(set) var uploadingFilename: String?
    @Published public internal(set) var isSending = false
    @Published var sentAttachments: [String: [ChatAttachment]] = [:]
    var attachmentSessionId: String?
    var uploadTask: Task<Void, Never>?


    public init(configuration: SDKConfiguration?, environment: String?, configResource: String, runtimeUserContext: SDKUserContext?, headerBuilder: ChatHeaderBuilder? = nil, footerBuilder: ChatFooterBuilder? = nil, templateRegistry: RichTemplateRegistry? = nil) {
        self.configuration = configuration; self.environment = environment; self.configResource = configResource; self.runtimeUserContext = runtimeUserContext
        self.headerBuilder = headerBuilder; self.footerBuilder = footerBuilder; self.templateRegistry = templateRegistry
    }
    public func start() {
        guard sdk == nil else { return }
        status = .connecting
        do {
            let created: AgentSDK
            if let configuration { created = AgentSDK.create(with: runtimeUserContext.map { configuration.copyForUI(context: $0) } ?? configuration) }
            else { created = try AgentSDK.initialize(fromBundle: .main, resourceName: configResource, environment: environment, runtimeUserContext: runtimeUserContext) }
            sdk = created
            theme = ChatTheme(configuration: created.configuration, widgetConfig: created.getWidgetConfig())
            sdkCancellable = created.sdkEvents.receive(on: DispatchQueue.main).sink { [weak self] event in self?.handle(event) }
            chatCancellable = created.chatEvents.receive(on: DispatchQueue.main).sink { [weak self] event in self?.handle(event) }
            Task { [weak self, weak created] in
                guard let self, let created else { return }
                do { _ = try await created.connect(); self.messages = created.getMessages(); self.theme = ChatTheme(configuration: created.configuration, widgetConfig: created.getWidgetConfig()); self.status = .connected }
                catch { self.status = .notConnected; self.errorMessage = error.localizedDescription }
            }
        } catch { status = .notConnected; errorMessage = error.localizedDescription }
    }
    public func send(_ text: String) {
        guard let sdk, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isTyping = true
        scrollToBottomRequest &+= 1
        Task { [weak self, weak sdk] in
            guard let self, let sdk else { return }
            do {
                _ = try await sdk.sendMessage(text)
                self.messages = sdk.getMessages()
                self.isTyping = !Self.hasAssistantReply(self.messages)
            } catch {
                self.isTyping = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    public func sendComposedText() {
        guard canSend, let sdk else { return }
        let text = composeText.trimmingCharacters(in: .whitespacesAndNewlines)
        let attachments = pendingAttachments
        if !attachments.isEmpty && attachmentSessionId != sdk.getSessionId() {
            pendingAttachments.removeAll()
            errorMessage = "The chat session changed. Please attach your files again."
            return
        }
        isSending = true
        isTyping = true
        scrollToBottomRequest &+= 1
        Task { [weak self] in
            guard let self else { return }
            defer { self.isSending = false }
            do {
                let id = try await sdk.sendMessage(text, attachmentIds: attachments.isEmpty ? nil : attachments.map(\.id))
                guard self.sdk === sdk else { return }
                self.sentAttachments[id] = attachments
                self.composeText = ""
                self.pendingAttachments.removeAll()
                self.messages = sdk.getMessages()
                self.isTyping = !Self.hasAssistantReply(self.messages)
            } catch {
                self.isTyping = false
                self.errorMessage = error.localizedDescription
            }
        }
    }
    public func submitAction(_ actionId: String, value: String? = nil, formData: [String: String]? = nil, renderId: String? = nil) {
        guard let sdk else { return }
        do {
            try sdk.submitAction(actionId, value: value, formData: formData, renderId: renderId)
            messages = sdk.getMessages()
            isTyping = !Self.hasAssistantReply(messages)
        } catch {
            isTyping = false
            errorMessage = error.localizedDescription
        }
    }
    public func submitFeedback(_ messageId: String, ratingType: String, ratingValue: Int, actionRenderId: String? = nil) {
        guard let sdk else { return }
        Task { [weak self, weak sdk] in
            guard let self, let sdk else { return }
            do { _ = try await sdk.submitFeedback(messageId: messageId, ratingType: ratingType, ratingValue: ratingValue, actionRenderId: actionRenderId) }
            catch { self.errorMessage = error.localizedDescription }
        }
    }
    public func reconnect() { resetAttachments(); sdk?.dispose(); sdk = nil; start() }
    public func stop() { resetAttachments(); sdk?.dispose(); sdk = nil; sdkCancellable = nil; chatCancellable = nil; status = .notConnected; isTyping = false }
    private func handle(_ event: SDKEvent) {
        switch event { case .connected: status = .connected; case .reconnecting: status = .connecting; case .disconnected: status = .notConnected; case .error(let error, _): errorMessage = error.localizedDescription; if sdk?.isConnected() != true { status = .notConnected }; default: break }
    }
    private func handle(_ event: ChatEvent) {
#if DEBUG
        switch event {
        case .messageReceived(let message):
            print("[ArtemisUI] Response:", message.content)
            print("[ArtemisUI] Metadata:", message.metadata?.mapValues { $0.value } ?? [:])
        case .messageChunk(let messageId, let chunk):
            print("[ArtemisUI] Chunk [\(messageId)]:", chunk)
        case .messageEnd(let messageId, let message):
            print("[ArtemisUI] Complete [\(messageId)]:", message.content)
            print("[ArtemisUI] Metadata:", message.metadata?.mapValues { $0.value } ?? [:])
        case .error(let error):
            print("[ArtemisUI] Error:", error.localizedDescription)
        default:
            break
        }
#endif
        messages = sdk?.getMessages() ?? messages
        switch event {
        case .typingIndicator(let value):
            isTyping = value && !Self.hasAssistantReply(messages)
        case .messageChunk, .messageEnd:
            // Streaming replaces an existing message without changing its count.
            scrollToBottomRequest &+= 1
            if Self.hasAssistantReply(messages) { isTyping = false }
        case .messageReceived:
            if Self.hasAssistantReply(messages) { isTyping = false }
        case .error(let error):
            isTyping = false
            errorMessage = error.localizedDescription
        default:
            break
        }
    }
    private static func hasAssistantReply(_ messages: [Message]) -> Bool {
        guard let last = messages.last, last.role == .assistant else { return false }
        if !last.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        return last.richContent != nil || !(last.actions?.elements.isEmpty ?? true)
    }
}

private extension SDKConfiguration {
    func copyForUI(context: SDKUserContext) -> SDKConfiguration {
        SDKConfiguration(environment: environment, connection: connection, channel: channel, userContext: UserContextConfig(userId: context.userId, customAttributes: context.customAttributes), websocket: websocket, voice: voice, chat: chat, storage: storage, performance: performance, accessibility: accessibility, theme: theme, debug: debug, features: features, localization: localization, security: security, analytics: analytics)
    }
}
