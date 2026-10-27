import AVFoundation
import UIKit
import WebKit

enum AudioCodesCallMediaEvent {
    case ready
    case connected
    case terminated(String?)
    case failed(String)
    case muteChanged(Bool)
    case cameraChanged(Bool)
    case endRequested
}

/// Hosts the AudioCodes WebRTC client in a WKWebView, matching the web client
/// flow used by Artemis. SIP credentials are used only for the active call.
final class AudioCodesCallMediaController: NSObject, WKScriptMessageHandler, WKUIDelegate {
    private let scriptURL: URL?
    private let bundledScript: String?
    private let pageBaseURL: URL
    private var webView: WKWebView?
    private var readyWaiters: [(Error?) -> Void] = []
    private var readinessTimeout: DispatchWorkItem?
    private var isReady = false
    private var readinessError: Error?
    private var mediaCaptureAllowed = false
    private var isStopping = false
    private var stopFinalized = false

    var onEvent: ((AudioCodesCallMediaEvent) -> Void)?

    init(runtimeURL: String, scriptURLOverride: String? = nil) throws {
        guard let baseURL = URL(string: runtimeURL), Self.isSecureMediaURL(baseURL),
            baseURL.user == nil, baseURL.password == nil
        else { throw AudioCodesCallMediaError.invalidRuntimeURL }

        let selectedScriptURL: URL?
        let selectedBundledScript: String?
        if let override = scriptURLOverride?.trimmingCharacters(in: .whitespacesAndNewlines),
            !override.isEmpty
        {
            guard let candidate = URL(string: override), Self.isSecureMediaURL(candidate),
                candidate.user == nil, candidate.password == nil,
                baseURL.scheme?.lowercased() != "https" || candidate.scheme?.lowercased() == "https"
            else { throw AudioCodesCallMediaError.invalidSIPStackURL }
            selectedScriptURL = candidate
            selectedBundledScript = nil
        } else {
            guard let scriptURL = Self.bundledSDKURL(),
                let source = try? String(contentsOf: scriptURL, encoding: .utf8)
            else { throw AudioCodesCallMediaError.bundledSDKUnavailable }
            selectedScriptURL = nil
            selectedBundledScript = source
        }

        pageBaseURL = URL(string: "/", relativeTo: baseURL)?.absoluteURL ?? baseURL
        scriptURL = selectedScriptURL
        bundledScript = selectedBundledScript
        super.init()
    }

    func makeWebView(
        agentName: String, profileIcon: String?, videoCall: Bool, clickToCall: Bool = false
    ) -> WKWebView {
        if let webView = webView { return webView }

        let contentController = WKUserContentController()
        contentController.add(self, name: "contactCenter")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        }

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.isOpaque = false
        view.backgroundColor = .clear
        view.scrollView.backgroundColor = .clear
        view.scrollView.isOpaque = false
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.scrollView.isScrollEnabled = false
        view.scrollView.bounces = false
        view.uiDelegate = self
        view.loadHTMLString(
            Self.document(
                bundledScript: bundledScript,
                scriptURL: scriptURL,
                presentation: [
                    "agentName": agentName,
                    "profileIcon": profileIcon ?? "",
                    "videoCall": videoCall,
                    "clickToCall": clickToCall,
                ]),
            baseURL: pageBaseURL)
        webView = view
        return view
    }

    func waitUntilReady(completion: @escaping (Error?) -> Void) {
        guard webView != nil else {
            completion(AudioCodesCallMediaError.stackNotReady)
            return
        }
        if isReady {
            completion(nil)
        } else if let readinessError = readinessError {
            completion(readinessError)
        } else {
            readyWaiters.append(completion)
            guard readinessTimeout == nil else { return }
            let timeout = DispatchWorkItem { [weak self] in
                self?.failReadiness(AudioCodesCallMediaError.stackLoadTimedOut.localizedDescription)
            }
            readinessTimeout = timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: timeout)
        }
    }

    func requestPermissions(forVideo videoCall: Bool, completion: @escaping (Error?) -> Void) {
        requestAccess(for: .audio) { [weak self] audioGranted in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                guard audioGranted else {
                    completion(AudioCodesCallMediaError.microphonePermissionDenied)
                    return
                }
                if videoCall {
                    strongSelf.requestAccess(for: .video) { videoGranted in
                        DispatchQueue.main.async {
                            guard videoGranted else {
                                completion(AudioCodesCallMediaError.cameraPermissionDenied)
                                return
                            }
                            strongSelf.activateAudioSession(videoCall: true, completion: completion)
                        }
                    }
                } else {
                    strongSelf.activateAudioSession(videoCall: false, completion: completion)
                }
            }
        }
    }

    func startCall(with rawCallData: [String: Any], sipIdentity: String?) throws {
        guard isReady, let webView else { throw AudioCodesCallMediaError.stackNotReady }
        let input = try Self.makeCallInput(rawCallData, sipIdentity: sipIdentity)
        guard JSONSerialization.isValidJSONObject(input),
            let data = try? JSONSerialization.data(withJSONObject: input),
            let json = String(data: data, encoding: .utf8)
        else { throw AudioCodesCallMediaError.invalidCallConfiguration }

        // The AudioCodes bridge returns a Promise; call results arrive through
        // the script message handler instead of evaluateJavaScript's result.
        webView.evaluateJavaScript("void window.startContactCenterCall(\(json));") { [weak self] _, error in
            if let error = error { self?.emit(.failed(error.localizedDescription)) }
        }
    }

    func startClickToCall(
        serverConfig: [String: Any], sipIdentity: String, botId: String,
        headers: [String]
    ) throws {
        guard isReady, let webView else { throw AudioCodesCallMediaError.stackNotReady }
        guard let domain = Self.firstString(serverConfig["domain"]) else {
            throw AudioCodesCallMediaError.missingSIPDomain
        }
        let addresses = Self.firstStrings(serverConfig["addresses"])
        guard !addresses.isEmpty else { throw AudioCodesCallMediaError.missingSIPAddresses }
        guard !sipIdentity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !botId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { throw AudioCodesCallMediaError.incompleteSIPIdentity }

        let input: [String: Any] = [
            "addresses": addresses,
            "domain": domain,
            "iceServers": Self.iceServerJSON(Self.firstArray(serverConfig["iceServers"])),
            "sipIdentity": sipIdentity,
            "target": botId,
            "callType": "audio",
            "headers": headers,
        ]
        guard JSONSerialization.isValidJSONObject(input),
            let data = try? JSONSerialization.data(withJSONObject: input),
            let json = String(data: data, encoding: .utf8)
        else { throw AudioCodesCallMediaError.invalidCallConfiguration }

        webView.evaluateJavaScript("void window.startContactCenterCall(\(json));") { [weak self] _, error in
            if let error = error { self?.emit(.failed(error.localizedDescription)) }
        }
    }

    func setMuted(_ muted: Bool) {
        webView?.evaluateJavaScript("window.setContactCenterMuted(\(muted));")
    }

    func setCameraEnabled(_ enabled: Bool) {
        webView?.evaluateJavaScript("window.setContactCenterCameraEnabled(\(enabled));")
    }

    func stopCall() {
        guard !isStopping else { return }
        isStopping = true
        readinessTimeout?.cancel()
        readinessTimeout = nil
        resumeReadiness(with: AudioCodesCallMediaError.callEnded)
        guard let webView = webView else {
            finalizeStop()
            return
        }
        webView.evaluateJavaScript("window.stopContactCenterCall && window.stopContactCenterCall();") {
            [weak self] _, _ in
            DispatchQueue.main.async { self?.finalizeStop() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.finalizeStop()
        }
    }

    func userContentController(
        _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
    ) {
        guard let body = message.body as? [String: Any], let type = body["type"] as? String else { return }
        switch type {
        case "ready":
            isReady = true
            readinessTimeout?.cancel()
            readinessTimeout = nil
            resumeReadiness()
            emit(.ready)
        case "connected": emit(.connected)
        case "terminated": emit(.terminated(body["reason"] as? String))
        case "error": emit(.failed(body["message"] as? String ?? "The call could not connect"))
        case "muteChanged": emit(.muteChanged(body["muted"] as? Bool == true))
        case "cameraChanged": emit(.cameraChanged(body["enabled"] as? Bool == true))
        case "endCall": emit(.endRequested)
        default: break
        }
    }

    @available(iOS 15.0, *)
    func webView(
        _ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        decisionHandler(mediaCaptureAllowed ? .grant : .deny)
    }

    private func requestAccess(for media: AVMediaType, completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: media) {
        case .authorized: completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: media, completionHandler: completion)
        default: completion(false)
        }
    }

    private func activateAudioSession(
        videoCall: Bool, completion: @escaping (Error?) -> Void
    ) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playAndRecord,
                mode: videoCall ? .videoChat : .voiceChat,
                options: [.allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
            mediaCaptureAllowed = true
            completion(nil)
        } catch {
            completion(error)
        }
    }

    private func failReadiness(_ message: String) {
        guard !isReady, readinessError == nil else { return }
        let error = AudioCodesCallMediaError.stackLoadFailed(message)
        readinessError = error
        resumeReadiness(with: error)
        emit(.failed(message))
    }

    private func finalizeStop() {
        guard !stopFinalized else { return }
        stopFinalized = true
        webView?.stopLoading()
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "contactCenter")
        webView?.uiDelegate = nil
        webView = nil
        mediaCaptureAllowed = false
        onEvent = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func resumeReadiness(with error: Error? = nil) {
        let waiters = readyWaiters
        readyWaiters.removeAll()
        waiters.forEach { $0(error) }
    }

    private func emit(_ event: AudioCodesCallMediaEvent) {
        guard !isStopping else { return }
        onEvent?(event)
    }

    private static func makeCallInput(
        _ rawCallData: [String: Any], sipIdentity: String?
    ) throws -> [String: Any] {
        let call = rawCallData["call"] as? [String: Any] ?? rawCallData
        guard let domain = firstString(call["domain"]) else {
            throw AudioCodesCallMediaError.missingSIPDomain
        }
        guard let identity = firstString(sipIdentity) else {
            throw AudioCodesCallMediaError.incompleteSIPIdentity
        }
        guard let sipURI = firstString(call["sipURI"]),
            let target = sipTarget(sipURI), !target.isEmpty
        else {
            throw AudioCodesCallMediaError.missingSIPTarget
        }
        let addresses = firstStrings(call["addresses"])
        guard !addresses.isEmpty else { throw AudioCodesCallMediaError.missingSIPAddresses }
        let iceServers = iceServerJSON(firstArray(call["iceServers"]))
        let isVideo = call["videoCall"] as? Bool == true || call["callType"] as? String == "video"
        let botName = firstString(call["botId"]) ?? ""
        let conversationId = firstString(call["conversationId"]) ?? ""

        return [
            "addresses": addresses,
            "domain": domain,
            "iceServers": iceServers,
            "sipIdentity": identity,
            "target": target,
            "callType": isVideo ? "video" : "audio",
            "headers": isVideo
                ? ["X-botName:\(botName)", "X-cId:\(conversationId)", "X-isVideoCall:true"] : [],
        ]
    }

    private static func firstString(_ values: Any?...) -> String? {
        values.compactMap { value -> String? in
            guard let string = value as? String else { return nil }
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }.first
    }

    private static func firstStrings(_ values: Any?...) -> [String] {
        for value in values {
            if let strings = value as? [String] {
                let trimmed = strings.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                if !trimmed.isEmpty { return trimmed }
            }
        }
        return []
    }

    private static func firstArray(_ values: Any?...) -> [[String: Any]] {
        values.compactMap { $0 as? [[String: Any]] }.first ?? []
    }

    private static func sipTarget(_ value: String) -> String? {
        var target = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if target.lowercased().hasPrefix("sips:") { target = String(target.dropFirst(5)) }
        else if target.lowercased().hasPrefix("sip:") { target = String(target.dropFirst(4)) }
        if let at = target.firstIndex(of: "@") { target = String(target[..<at]) }
        return target
    }

    private static func iceServerJSON(_ entries: [[String: Any]]) -> [[String: Any]] {
        entries.compactMap { entry in
            let urls: [String]
            if let url = firstString(entry["urls"], entry["url"]) {
                urls = [url]
            } else if let values = entry["urls"] as? [String] {
                urls = values
            } else {
                urls = []
            }
            guard !urls.isEmpty else { return nil }
            var server: [String: Any] = ["urls": urls]
            server["username"] = entry["username"]
            server["credential"] = entry["credential"]
            return server
        }
    }

    private static func isSecureMediaURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(), let host = url.host?.lowercased() else { return false }
        if scheme == "https" { return true }
        return scheme == "http" && ["localhost", "127.0.0.1", "::1"].contains(host)
    }

    private static func bundledSDKURL() -> URL? {
        let bundles = [Bundle.sdkModule, Bundle.main]
        for bundle in bundles {
            if let url = bundle.url(
                forResource: "ac_webrtc.min", withExtension: "js", subdirectory: "AudioCodes")
                ?? bundle.url(forResource: "ac_webrtc.min", withExtension: "js")
            {
                return url
            }
        }
        return nil
    }

    private static func document(
        bundledScript: String?, scriptURL: URL?, presentation: [String: Any]
    ) -> String {
        let sourceJSON = bundledScript.flatMap { source in
            try? JSONSerialization.data(withJSONObject: [source])
        }.flatMap { String(data: $0, encoding: .utf8) } ?? "[null]"
        let sourceLiteral = String(sourceJSON.dropFirst().dropLast())
        let urlJSON = scriptURL.flatMap { url in
            try? JSONSerialization.data(withJSONObject: [url.absoluteString])
        }.flatMap { String(data: $0, encoding: .utf8) } ?? "[null]"
        let urlLiteral = String(urlJSON.dropFirst().dropLast())
        let presentationJSON = (try? JSONSerialization.data(withJSONObject: presentation)) ?? Data()
        let presentationBase64 = presentationJSON.base64EncodedString()
        return """
            <!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover">
            <style>
            :root{font-family:-apple-system,BlinkMacSystemFont,"Helvetica Neue",sans-serif;color:#101828}
            *{box-sizing:border-box}html,body,#stage{margin:0;width:100%;height:100%;overflow:hidden}
            body{background:transparent}#stage{position:relative;width:100%;height:100%;background:transparent}
            video{background:rgba(0,0,0,.5)}#remote{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;display:none}
            body.video{background:transparent;color:#fff}body.video.connected #remote{display:block}
            #audioStage{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;padding:24px}
            body.video.connected #audioStage{display:none}
            .audio-card{width:min(100%,420px);padding:30px 24px 24px;border:1px solid #e3e8ef;border-radius:18px;background:#eef2f6;text-align:center;box-shadow:0 18px 48px rgba(16,24,40,.12)}
            .agent-avatar{position:relative;width:64px;height:64px;margin:0 auto 14px;border:2px solid #fff;border-radius:50%;background:#dbeafe;overflow:hidden;display:grid;place-items:center;color:#2b75e4;font-size:24px;font-weight:600}
            .agent-avatar img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;border-radius:50%}
            .agent-name{font-size:16px;font-weight:600;line-height:22px;color:#101828}
            .call-title{margin-top:5px;font-size:15px;font-weight:400;line-height:22px;color:#101828}
            .call-note{margin:6px 0 0;font-size:13px;font-weight:400;line-height:18px;color:#697586}
            .call-timer{margin-top:3px;font-size:13px;line-height:18px;color:#697586}
            .controls{display:none;align-items:flex-start;justify-content:center;gap:24px;margin-top:24px}
            body.connected .controls{display:flex}
            body.click-to-call:not(.connected) #audioControls{display:flex}
            body.click-to-call:not(.connected) #audioControls .mute-control,body.click-to-call:not(.connected) #audioControls .keypad-control{display:none}
            .control{display:flex;flex-direction:column;align-items:center;gap:7px;min-width:54px;border:0;background:transparent;color:#344054;font:inherit;padding:0}
            .control-button{width:52px;height:44px;border:1px solid #d4d4d4;border-radius:50px;background:#fff;color:#344054;display:grid;place-items:center}
            .control-button svg{width:20px;height:20px;fill:none;stroke:currentColor;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}
            .control-label{font-size:12px;line-height:16px;white-space:nowrap}
            .keypad-control{display:none}
            body.click-to-call .keypad-control{display:flex}
            .dtmf-panel{margin-top:14px}
            .dtmf-panel[hidden],.call-timer[hidden]{display:none}
            .dtmf-value{min-height:20px;margin-bottom:8px;font-size:16px;letter-spacing:2px;color:#344054}
            .dtmf-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px;max-width:210px;margin:0 auto}
            .dtmf-key{height:34px;border:1px solid #d0d5dd;border-radius:9px;background:#fff;color:#344054;font:500 16px -apple-system,BlinkMacSystemFont,sans-serif}
            .control.is-active .control-button{background:#4b4ede;border-color:#4b4ede;color:#fff}
            .control.end .control-button{background:#ef4444;border-color:#ef4444;color:#fff}
            #localPanel{display:none;position:absolute;z-index:2;top:calc(env(safe-area-inset-top) + 62px);right:16px;width:158px;height:92px;border:1px solid #ffffff77;border-radius:10px;background:#1d2939;box-shadow:0 8px 26px #0005;overflow:visible}
            body.video.connected #localPanel:not([hidden]){display:block}
            #localPanel[hidden],#showPreview[hidden]{display:none}
            #local{width:100%;height:100%;border-radius:9px;object-fit:cover}
            #localFallback{position:absolute;inset:0;display:none;place-items:center;border-radius:9px;background:#ffbeb6;color:#101828;font-size:12px;font-weight:700}
            #localPanel.camera-off #local{display:none}#localPanel.camera-off #localFallback{display:grid}
            .preview-action{position:absolute;top:-9px;right:-9px;z-index:3;width:26px;height:26px;border:0;border-radius:50%;background:#12131499;color:#fff;font-size:18px;line-height:24px}
            #showPreview{display:none;position:absolute;top:calc(env(safe-area-inset-top) + 68px);right:16px;width:42px;height:42px;border:1px solid #ffffff55;border-radius:50%;background:#12131499;color:#fff;z-index:2}
            body.video.connected #showPreview:not([hidden]){display:block}
            #showPreview svg{width:18px;height:18px;fill:none;stroke:currentColor;stroke-width:1.7;stroke-linecap:round;stroke-linejoin:round;vertical-align:middle}
            #videoControls{position:absolute;left:0;right:0;bottom:calc(env(safe-area-inset-bottom) + 26px);margin:0;gap:22px;align-items:center}
            body.audio #videoControls,body.video #audioControls{display:none!important}
            body.video .control{color:#fff}body.video .control-button{width:56px;height:56px;border:0;background:#ffffff45;color:#fff;backdrop-filter:blur(8px)}
            body.video .control.end .control-button{background:#ef4444}
            </style>
            </head><body><div id="stage">
            <video id="remote" autoplay playsinline></video>
            <div id="audioStage"><div class="audio-card">
              <div class="agent-avatar"><span id="agentFallback">A</span><img id="agentAvatar" alt="Agent" hidden></div>
              <div class="agent-name" id="agentName">Agent</div>
              <div class="call-title" id="audioStatus">Connecting audio call…</div>
              <div class="call-timer" id="callTimer" hidden>00:00</div>
              <p class="call-note" id="audioNote">Disconnecting audio call doesn't end conversation</p>
              <div class="controls" id="audioControls">
                <button class="control mute-control" type="button"><span class="control-button"><svg viewBox="0 0 24 24"><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3m-4 0h8"/></svg></span><span class="control-label">Mute</span></button>
                <button class="control keypad-control" id="keypadToggle" type="button" aria-label="Show keypad"><span class="control-button"><svg viewBox="0 0 24 24"><circle cx="6" cy="6" r="1"/><circle cx="12" cy="6" r="1"/><circle cx="18" cy="6" r="1"/><circle cx="6" cy="12" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="18" cy="12" r="1"/><circle cx="6" cy="18" r="1"/><circle cx="12" cy="18" r="1"/><circle cx="18" cy="18" r="1"/></svg></span><span class="control-label">Keypad</span></button>
                <button class="control end" type="button"><span class="control-button"><svg viewBox="0 0 24 24"><path d="M4.5 15.5c4.6-3.4 10.4-3.4 15 0l-1.2 4a1.5 1.5 0 0 1-1.9 1l-2.5-.8a1.5 1.5 0 0 1-1-1.4v-1.1a8 8 0 0 0-2 0v1.1a1.5 1.5 0 0 1-1 1.4l-2.5.8a1.5 1.5 0 0 1-1.9-1z"/></svg></span><span class="control-label">End</span></button>
              </div>
              <div class="dtmf-panel" id="dtmfPanel" hidden>
                <div class="dtmf-value" id="dtmfValue"></div>
                <div class="dtmf-grid">
                  <button class="dtmf-key" type="button">1</button><button class="dtmf-key" type="button">2</button><button class="dtmf-key" type="button">3</button>
                  <button class="dtmf-key" type="button">4</button><button class="dtmf-key" type="button">5</button><button class="dtmf-key" type="button">6</button>
                  <button class="dtmf-key" type="button">7</button><button class="dtmf-key" type="button">8</button><button class="dtmf-key" type="button">9</button>
                  <button class="dtmf-key" type="button">*</button><button class="dtmf-key" type="button">0</button><button class="dtmf-key" type="button">#</button>
                </div>
              </div>
            </div></div>
            <div id="localPanel" hidden><video id="local" autoplay muted playsinline></video><div id="localFallback">YOU</div><button class="preview-action" type="button" aria-label="Hide preview">×</button></div>
            <button id="showPreview" type="button" aria-label="Show preview" hidden><svg viewBox="0 0 24 24"><rect x="3" y="6" width="13" height="12" rx="2"/><path d="m16 10 5-3v10l-5-3"/></svg></button>
            <div class="controls" id="videoControls">
              <button class="control mute-control" type="button"><span class="control-button"><svg viewBox="0 0 24 24"><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3m-4 0h8"/></svg></span><span class="control-label">Mute</span></button>
              <button class="control camera-control" type="button"><span class="control-button"><svg viewBox="0 0 24 24"><rect x="3" y="6" width="13" height="12" rx="2"/><path d="m16 10 5-3v10l-5-3"/></svg></span><span class="control-label">Video off</span></button>
              <button class="control end" type="button"><span class="control-button"><svg viewBox="0 0 24 24"><path d="M4.5 15.5c4.6-3.4 10.4-3.4 15 0l-1.2 4a1.5 1.5 0 0 1-1.9 1l-2.5-.8a1.5 1.5 0 0 1-1-1.4v-1.1a8 8 0 0 0-2 0v1.1a1.5 1.5 0 0 1-1 1.4l-2.5.8a1.5 1.5 0 0 1-1.9-1z"/></svg></span><span class="control-label">End</span></button>
            </div></div>
            <script>
            (() => {
              const post = (type, value = {}) => { try { window.webkit.messageHandlers.contactCenter.postMessage({type, ...value}); } catch (_) {} };
              let phone = null, activeCall = null, loginPromise = null, loginResolve = null, loginReject = null, stopping = false, callTimer = null, callSeconds = 0;
              const presentation = JSON.parse(atob('\(presentationBase64)'));
              const remote = document.getElementById('remote'), local = document.getElementById('local');
              const localPanel = document.getElementById('localPanel');
              const setMuteUI = (muted) => document.querySelectorAll('.mute-control').forEach((button) => { button.classList.toggle('is-active', muted); button.querySelector('.control-label').textContent = muted ? 'Unmute' : 'Mute'; });
              const setCameraUI = (enabled) => { localPanel.classList.toggle('camera-off', !enabled); const button = document.querySelector('.camera-control'); if (button) { button.classList.toggle('is-active', !enabled); button.querySelector('.control-label').textContent = enabled ? 'Video off' : 'Video on'; } };
              document.body.classList.add(presentation.videoCall ? 'video' : 'audio');
              if (presentation.clickToCall) document.body.classList.add('click-to-call');
              const agentName = presentation.clickToCall ? 'Live voice agent' : (presentation.agentName || 'Agent');
              document.getElementById('agentName').textContent = agentName;
              document.getElementById('agentFallback').textContent = agentName.trim().slice(0, 1).toUpperCase() || 'A';
              if (presentation.profileIcon && presentation.profileIcon !== 'undefined') { const avatar = document.getElementById('agentAvatar'); avatar.onload = () => { avatar.hidden = false; document.getElementById('agentFallback').hidden = true; }; avatar.onerror = () => { avatar.hidden = true; }; avatar.src = presentation.profileIcon; }
              document.getElementById('audioStatus').textContent = `Connecting ${presentation.videoCall ? 'video' : 'audio'} call…`;
              document.getElementById('audioNote').textContent = presentation.clickToCall ? 'You can end this call at any time' : `Disconnecting ${presentation.videoCall ? 'video' : 'audio'} call doesn't end conversation`;
              const bindControls = (root) => {
                root.querySelectorAll('.mute-control').forEach((button) => button.addEventListener('click', () => { const muted = !button.classList.contains('is-active'); setMuteUI(muted); post('muteChanged', {muted}); }));
                root.querySelectorAll('.camera-control').forEach((button) => button.addEventListener('click', () => { const enabled = button.classList.contains('is-active'); setCameraUI(enabled); post('cameraChanged', {enabled}); }));
                root.querySelectorAll('.end').forEach((button) => button.addEventListener('click', () => post('endCall')));
              };
              bindControls(document.getElementById('audioControls'));
              bindControls(document.getElementById('videoControls'));
              document.getElementById('keypadToggle').addEventListener('click', () => { const panel = document.getElementById('dtmfPanel'); panel.hidden = !panel.hidden; });
              document.querySelectorAll('.dtmf-key').forEach((button) => button.addEventListener('click', () => {
                const digit = button.textContent.trim();
                const value = document.getElementById('dtmfValue');
                value.textContent = (value.textContent + digit).slice(-32);
                if (activeCall && activeCall.sendDTMF) activeCall.sendDTMF(digit);
              }));
              document.querySelector('.preview-action').addEventListener('click', () => { localPanel.hidden = true; document.getElementById('showPreview').hidden = false; });
              document.getElementById('showPreview').addEventListener('click', () => { localPanel.hidden = false; document.getElementById('showPreview').hidden = true; });
              const sdkAvailable = () => typeof AudioCodesUA === 'function' && typeof JsSIP !== 'undefined';
              const bundledSDKSource = \(sourceLiteral);
              const remoteSDKURL = \(urlLiteral);
              if (bundledSDKSource !== null) {
                const script = document.createElement('script');
                script.textContent = bundledSDKSource;
                document.head.appendChild(script);
                if (sdkAvailable()) post('ready');
                else post('error', {message:'The bundled AudioCodes WebRTC SDK is unavailable'});
              } else {
                const script = document.createElement('script');
                script.src = remoteSDKURL;
                script.onload = () => {
                  if (sdkAvailable()) post('ready');
                  else post('error', {message:'AudioCodes WebRTC SDK is unavailable at ' + script.src});
                };
                script.onerror = () => post('error', {message:'Unable to load the AudioCodes WebRTC SDK at ' + script.src});
                document.head.appendChild(script);
              };
              window.startContactCenterCall = async (input) => {
                try {
                  if (phone) window.stopContactCenterCall();
                  stopping = false;
                  phone = new AudioCodesUA();
                  loginPromise = new Promise((resolve, reject) => { loginResolve = resolve; loginReject = reject; });
                  phone.setServerConfig(input.addresses, input.domain, input.iceServers);
                  phone.setReconnectIntervals(2, 30);
                  phone.setRegisterExpires(600);
                  phone.setUseSessionTimer(false);
                  phone.setDtmfOptions(true, null, null);
                  phone.setBrowsersConstraints({
                    chrome: {audio: {echoCancellation: true}},
                    firefox: {audio: {echoCancellation: true}},
                    safari: {audio: {echoCancellation: true}},
                    ios_safari: {audio: {echoCancellation: true}}
                  });
                  phone.setEnableAddVideo(true);
                  phone.setAcLogger(console.log);
                  phone.setModes({ice_timeout_fix: 2000, chrome_rtp_timeout_fix: 13, sbc_ha_pairs_mode: undefined, ringing_header_mode: 'Allow-Events: talk,hold,conference'});
                  phone.setAccount(input.sipIdentity, input.sipIdentity, input.sipIdentity, input.sipIdentity);
                  const audioCodesDomains = ['audiocodes-webrtc-prod.kore.ai', 'audiocodes-jp-webrtc-prod.kore.ai', 'audiocodes-de-webrtc-prod.kore.ai', 'smartassist-agent-np.kore.ai'];
                  const serverDomain = new URL(input.addresses[0]).hostname;
                  if (!audioCodesDomains.includes(serverDomain)) {
                    phone.setCodecFilter({audio: {priority: ['opus'], remove: ['pcmu', 'pcma', 'g722']}});
                  }
                  phone.setListeners({
                    loginStateChanged: (_loggedIn, cause) => { if (cause === 'connected') loginResolve(); if (cause === 'login failed') loginReject(new Error('AudioCodes login failed')); },
                    callConfirmed: () => {
                      document.body.classList.add('connected');
                      document.getElementById('audioStatus').textContent = presentation.clickToCall ? 'Call connected' : `Connected ${input.callType} call…`;
                      if (presentation.clickToCall) {
                        const timer = document.getElementById('callTimer'); timer.hidden = false; callSeconds = 0;
                        const updateTimer = () => { callSeconds += 1; timer.textContent = `${String(Math.floor(callSeconds / 60)).padStart(2, '0')}:${String(callSeconds % 60).padStart(2, '0')}`; };
                        timer.textContent = '00:00'; callTimer = setInterval(updateTimer, 1000);
                      }
                      post('connected');
                    },
                    callTerminated: (_call, _message, cause) => { activeCall = null; if (callTimer) clearInterval(callTimer); callTimer = null; if (!stopping) post('terminated', {reason: typeof cause === 'string' ? cause : undefined}); },
                    callShowStreams: (_call, localStream, remoteStream) => { if (localStream instanceof MediaStream) { local.srcObject = localStream; localPanel.hidden = input.callType !== 'video'; } if (remoteStream instanceof MediaStream) { remote.srcObject = remoteStream; remote.volume = 0.5; } },
                    outgoingCallProgress: () => {}, incomingCall: (call) => call && call.reject && call.reject(),
                    callHoldStateChanged: () => {}, callScreenSharingEnded: () => {}
                  });
                  if (presentation.clickToCall) {
                    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) throw new Error('WebRTC audio is not available on this device');
                    if (phone.checkAvailableDevices) await phone.checkAvailableDevices();
                  }
                  phone.init(true);
                  await Promise.race([loginPromise, new Promise((_resolve, reject) => setTimeout(() => reject(new Error('Timed out connecting to the Contact Center SBC')), 15000))]);
                  if (input.callType === 'video') activeCall = phone.call(phone.VIDEO, input.target, input.headers);
                  else activeCall = phone.call(phone.AUDIO, input.target, input.headers || []);
                } catch (error) { post('error', {message: error && error.message ? error.message : String(error)}); }
              };
              window.setContactCenterMuted = (muted) => { if (activeCall && activeCall.muteAudio) activeCall.muteAudio(Boolean(muted)); setMuteUI(Boolean(muted)); };
              window.setContactCenterCameraEnabled = (enabled) => { if (activeCall && activeCall.muteVideo) activeCall.muteVideo(!enabled); setCameraUI(Boolean(enabled)); };
              window.stopContactCenterCall = () => {
                stopping = true;
                if (callTimer) clearInterval(callTimer);
                callTimer = null;
                try { if (activeCall && activeCall.terminate) activeCall.terminate(); } catch (_) {}
                try { if (phone && phone.logout) phone.logout(); } catch (_) {}
                try { if (phone && phone.deinit) phone.deinit(); } catch (_) {}
                activeCall = null; phone = null; loginPromise = null; loginResolve = null; loginReject = null;
                if (remote.srcObject) remote.srcObject.getTracks().forEach(track => track.stop());
                if (local.srcObject) local.srcObject.getTracks().forEach(track => track.stop());
                remote.srcObject = null; local.srcObject = null; local.hidden = true;
                localPanel.hidden = true;
              };
            })();
            </script></body></html>
            """
    }
}

private enum AudioCodesCallMediaError: Error, LocalizedError {
    case invalidRuntimeURL
    case invalidSIPStackURL
    case bundledSDKUnavailable
    case stackLoadTimedOut
    case stackLoadFailed(String)
    case stackNotReady
    case missingSIPDomain
    case missingSIPAddresses
    case missingSIPTarget
    case incompleteSIPIdentity
    case invalidCallConfiguration
    case microphonePermissionDenied
    case cameraPermissionDenied
    case callEnded

    var errorDescription: String? {
        switch self {
        case .invalidRuntimeURL: return "The Contact Center Runtime URL is invalid"
        case .invalidSIPStackURL: return "The AudioCodes WebRTC SDK URL is invalid"
        case .bundledSDKUnavailable: return "The bundled AudioCodes WebRTC SDK could not be found in the SDK resources"
        case .stackLoadTimedOut: return "Timed out loading the AudioCodes WebRTC SDK"
        case .stackLoadFailed(let message): return message
        case .stackNotReady: return "The AudioCodes WebRTC SDK is not ready"
        case .missingSIPDomain: return "The incoming call is missing its SIP domain"
        case .missingSIPAddresses: return "The incoming call is missing its AudioCodes server addresses"
        case .missingSIPTarget: return "The incoming call is missing its SIP target"
        case .incompleteSIPIdentity: return "The incoming call is missing its SIP identity"
        case .invalidCallConfiguration: return "The incoming call configuration is invalid"
        case .microphonePermissionDenied: return "Microphone access is required for agent calls"
        case .cameraPermissionDenied: return "Camera access is required for video calls"
        case .callEnded: return "The call ended before the AudioCodes WebRTC SDK was ready"
        }
    }
}
