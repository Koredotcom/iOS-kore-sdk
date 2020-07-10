//
//  KREMessageComposeViewController.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 06/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking
import KoreBotSDK

public protocol KREMessageComposeViewControllerDelegate: class {
    func validateAndSendMessage(_ message: String, dictionary: [String: Any]?, options: [String: Any]?, completion block: (() -> Void)?)
    func sendButtonAction(message: String, dictionary: [String: Any]?, options: [String: Any]?, completion block: (() -> Void)?)
}

public enum KREMessageAction: String {
    case startSpeaking = "StartSpeakingNowNotificationName"
    case stopSpeaking = "StopSpeakingNowNotificationName"
    case utteranceHandler = "utteranceHandler"
    case navigateToComposeBar = "navigateToComposeBar"
    case validateAgainstSkill = "ValidateAgainstSkill"
    case keyboardWillShow = "keyboardWillShow"
    case keyboardWillHide = "keyboardWillHide"
    case keyboardDidShow = "keyboardDidShow"
    case keyboardDidHide = "keyboardDidHide"

    public var notification: Notification.Name {
        switch self {
        case .startSpeaking:
            return Notification.Name(rawValue: KREMessageAction.startSpeaking.rawValue)
        case .stopSpeaking:
            return Notification.Name(rawValue: KREMessageAction.stopSpeaking.rawValue)
        case .utteranceHandler:
            return Notification.Name(rawValue: KREMessageAction.utteranceHandler.rawValue)
        case .navigateToComposeBar:
            return Notification.Name(rawValue: KREMessageAction.navigateToComposeBar.rawValue)
        case .validateAgainstSkill:
            return Notification.Name(rawValue: KREMessageAction.validateAgainstSkill.rawValue)
        case .keyboardWillShow:
            return Notification.Name(rawValue: KREMessageAction.keyboardWillShow.rawValue)
        case .keyboardWillHide:
            return Notification.Name(rawValue: KREMessageAction.keyboardWillHide.rawValue)
        case .keyboardDidShow:
            return Notification.Name(rawValue: KREMessageAction.keyboardDidShow.rawValue)
        case .keyboardDidHide:
            return Notification.Name(rawValue: KREMessageAction.keyboardDidHide.rawValue)
        }
    }
}

open class KREMessageComposeViewController: UIViewController, KREComposeBarViewDelegate, KREGrowingTextViewDelegate {
    // keyboard management
    internal enum KeyboardState {
        case visible
        case resigned
        case showing
        case hiding
    }
    internal var keyboardState: KeyboardState = .resigned
    // MARK: - properties
    let bannerHeight: CGFloat = 54.0
    private(set) var foundPrefix = ""
    private(set) var foundPrefixRange: NSRange?
    private(set) var foundWord = ""
    private(set) var isAutoCompleting = false
    private(set) var registeredPrefixes = ["@"]

    @IBOutlet public weak var containerView: UIView!
    @IBOutlet public weak var composeBarContainerView: UIView!
    @IBOutlet public weak var audioComposeContainerView: UIView!
    @IBOutlet public weak var informationView: UIView!
    @IBOutlet public weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet public weak var informationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet public weak var audioBottomConstraint: NSLayoutConstraint!

    public weak var messageComposeViewControllerDelegate: KREMessageComposeViewControllerDelegate?

    open var canSpeakUtterance: Bool = false
    open var isComposeBarActive: Bool = false
    open var composeBarContainerHeightConstraint: NSLayoutConstraint!
    open var composeViewBottomConstraint: NSLayoutConstraint!
    open var audioComposeContainerHeightConstraint: NSLayoutConstraint!
    open var composeView: KREComposeBarView!
    open var audioComposeView: KREAudioComposeView!
    open var informationLabel: UILabel!
    open var connectionState: BotClientConnectionState = .NONE {
        didSet(newValue) {
            if newValue != connectionState {
                updateConnectionStatus()
            }
        }
    }
    open var leftWidgetButton: UIButton {
        return audioComposeView.leftWidgetBtn
    }
    open var rightWidgetButton: UIButton {
        return audioComposeView.rightWidgetBtn
    }
    open var thunderBoltActionButton: UIButton {
        return audioComposeView.thunderBoltActionButton
    }
    open var inputContainerView: UIView {
        return audioComposeView.inputContainerView
    }
    open var audioContainerView: UIView {
        return audioComposeView.containerView
    }
    open var keyboardButton: UIButton {
        return audioComposeView.keyboardButton
    }
    open var enableLeftWidgetAction: Bool = true
    open var enableRightWidgetAction: Bool = true
    open var isSpeakingEnabled: Bool = false
    @objc public var noficationInfoHandler: ((_ info: [String: Any]?) -> (Void))?
    var hasNotificationValue: Bool = false
    @objc public var noficationDicionary: [String: Any]?
    open var localTimeZoneName: String { return TimeZone.current.identifier }
    
    let sttClient = KREASRService.shared
    var transcriptStr = String()
    var speechSynthesizer: AVSpeechSynthesizer!
    var textView: UITextView! {
        get {
            return composeView.growingTextView.textView
        }
    }
    public var actionsView: UIView = {
        let actionsView = UIView(frame: .zero)
        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.backgroundColor = .clear
        return actionsView
    }()
    public var actionsViewHeightConstraint: NSLayoutConstraint!

    // MARK: init
    @objc public init() {
        let bundle = Bundle(for: KREMessageComposeViewController.self)
        super.init(nibName: "KREMessageComposeViewController", bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(utteranceHandler(_:)), name: KREMessageAction.utteranceHandler.notification, object: nil)

        // initialize elements
        configureContainerView()
        configureComposeBar()
        configureAudioComposer()
        configureSTTClient()
        configureAutoCompletionView()
        configureInformationView()
        configureSnackBarView()
        configureActionsView()
        speechSynthesizer = AVSpeechSynthesizer()
        addNotificationToCompose()
        addNotifications()
    }
    
    func addNotificationToCompose() {
        //As notification is added in view didAppear and removed in view did Disappear in some case were navigation is there, Observer is removed, so adding in view didload and removing from view didAppear
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToComposeBar(_:)), name: KREMessageAction.navigateToComposeBar.notification, object: nil)

    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            audioBottomConstraint.constant = 0
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (audioComposeContainerView.isHidden) {
            _ = composeView.resignFirstResponder()
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - deinit
    deinit {
        prepareForDeinit()
        speechSynthesizer = nil
        composeView = nil
        audioComposeView = nil
        removeNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        deConfigureSTTClient()
        stopTTS()
        composeView.growingTextView.viewDelegate = nil
        composeView.delegate = nil
        audioComposeView.prepareForDeinit()
    }
    
    // MARK: cancel
    func cancel(_ sender: AnyObject) {
        prepareForDeinit()
        
        //Addition fade in animation
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        navigationController?.view.layer.add(transition, forKey: nil)
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: configuring views
    open func configureContainerView() {

    }
    
    func configureComposeBar() {
        composeView = KREComposeBarView()
        
        composeView.translatesAutoresizingMaskIntoConstraints = false
        composeView.growingTextView.viewDelegate = self
        composeView.delegate = self
        composeView.growingTextView.textView.delegate = self
        composeBarContainerView.addSubview(self.composeView!)
        
        composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[composeView]|", options:[], metrics: nil, views:["composeView" : composeView!]))
        composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[composeView]", options:[], metrics: nil, views:["composeView" : composeView!]))
        
        composeViewBottomConstraint = NSLayoutConstraint.init(item: composeBarContainerView, attribute: .bottom, relatedBy: .equal, toItem: composeView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        composeBarContainerView.addConstraint(composeViewBottomConstraint)
        composeViewBottomConstraint.isActive = false
        
        composeBarContainerHeightConstraint = NSLayoutConstraint.init(item: composeBarContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        view.addConstraint(self.composeBarContainerHeightConstraint)
        let composebarGesture = UITapGestureRecognizer(target: self, action: #selector(handleComposeBarTap(_:)))
        
        composeBarContainerView.addGestureRecognizer(composebarGesture)
    }
    
    func configureActionsView() {
        view.addSubview(actionsView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[actionsView]|", options:[], metrics: nil, views: ["actionsView": actionsView]))
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            actionsView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0.0).isActive = true
        } else {
            let standardSpacing: CGFloat = 10.0
            actionsView.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing).isActive = true
        }
        
        actionsViewHeightConstraint = NSLayoutConstraint(item: actionsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 54.0)
        view.addConstraint(actionsViewHeightConstraint)
        actionsViewHeightConstraint.isActive = false
    }
    
    @objc func handleComposeBarTap(_ sender: UITapGestureRecognizer) {
        if !self.composeView.isKeyboardEnabled && !self.composeBarContainerHeightConstraint.isActive {
            composeView.isKeyboardEnabled = true
            audioComposeView.onKeyboardButtonAction?()
        }
    }
    
    func configureAutoCompletionView() {

    }
    
    func configureAudioComposer()  {
        audioComposeView = KREAudioComposeView()
        audioComposeView.translatesAutoresizingMaskIntoConstraints = false
        audioComposeContainerView.addSubview(self.audioComposeView!)
        
        audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[audioComposeView]|", options:[], metrics:nil, views:["audioComposeView" : audioComposeView!]))
        audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[audioComposeView]|", options:[], metrics:nil, views:["audioComposeView" : audioComposeView!]))
        
        audioComposeContainerHeightConstraint = NSLayoutConstraint.init(item: audioComposeContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        view.addConstraint(self.audioComposeContainerHeightConstraint)
        audioComposeContainerHeightConstraint.isActive = false
        
        audioComposeView.voiceRecordingStarted = { [weak self] (composeBar) in
            self?.stopTTS()
        }
        audioComposeView.voiceRecordingStopped = { [weak self] (composeBar) in
            self?.sttClient.stopRecording()
        }
        audioComposeView.getAudioPeakOutputPower = { [weak self] () in
            return self?.sttClient.peakOutputPower ?? 0.0
        }
        audioComposeView.onKeyboardButtonAction = { [weak self] () in
            _ = self?.composeView.becomeFirstResponder()
            self?.configureViewForKeyboard(true)
            self?.composeView.isKeyboardEnabled = true
            self?.audioComposeView.stopRecording()
        }
        audioComposeView.onHelpButtonAction = { [weak self] () in
            self?.openHelpPhrasesViewController()
        }
        audioComposeView.onRightWidgetButtonAction = { [weak self] () in
            _ = self?.composeView.resignFirstResponder()
            if let weakSelf = self, weakSelf.enableRightWidgetAction {
                weakSelf.audioComposeView.leftWidgetBtn.layer.borderColor = UIColor.lightGreyBlue.cgColor
                weakSelf.audioComposeView.leftWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
                weakSelf.audioComposeView.containerView.layer.borderColor = UIColor.lightGreyBlue.cgColor
                weakSelf.audioComposeView.audioView.imageView?.tintColor = UIColor.lightGreyBlue
                weakSelf.audioComposeView.thunderBoltActionButton.imageView?.tintColor = UIColor.lightGreyBlue
                weakSelf.audioComposeView.keyboardButton.imageView?.tintColor = UIColor.lightGreyBlue
                weakSelf.audioComposeView.rightWidgetBtn.layer.borderColor = UIColor.lightRoyalBlue.cgColor
                weakSelf.audioComposeView.rightWidgetBtn.imageView?.tintColor = UIColor.lightRoyalBlue
                weakSelf.audioComposeView.leftWidgetBtn.layer.borderWidth = 1
                weakSelf.audioComposeView.rightWidgetBtn.layer.borderWidth = 2
            }

            self?.rightWidgetAction()
        }
        audioComposeView.onLeftWidgetButtonAction = { [weak self] () in
            _ = self?.composeView.resignFirstResponder()
            if let weakSelf = self, weakSelf.enableLeftWidgetAction {
                weakSelf.audioComposeView.containerView.layer.borderColor = UIColor.lightGreyBlue.cgColor
                weakSelf.audioComposeView.audioView.imageView?.tintColor = UIColor.lightGreyBlue
                weakSelf.audioComposeView.thunderBoltActionButton.imageView?.tintColor = UIColor.lightGreyBlue
                weakSelf.audioComposeView.keyboardButton.imageView?.tintColor = UIColor.lightGreyBlue
                weakSelf.audioComposeView.rightWidgetBtn.layer.borderColor = UIColor.lightGreyBlue.cgColor
                weakSelf.audioComposeView.rightWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
                weakSelf.audioComposeView.leftWidgetBtn.layer.borderColor = UIColor.lightRoyalBlue.cgColor
                weakSelf.audioComposeView.leftWidgetBtn.imageView?.tintColor = UIColor.lightRoyalBlue
                weakSelf.audioComposeView.leftWidgetBtn.layer.borderWidth = 2
                weakSelf.audioComposeView.rightWidgetBtn.layer.borderWidth = 1
            }
            
            self?.leftWidgetAction()
        }
        audioComposeView.onContainertTapAction = { [weak self] () in
            self?.audioComposeView.containerView.layer.borderColor = UIColor.lightRoyalBlue.cgColor
            self?.audioComposeView.audioView.imageView?.tintColor = UIColor.lightRoyalBlue
            self?.audioComposeView.thunderBoltActionButton.imageView?.tintColor = UIColor.battleshipGrey
            self?.audioComposeView.keyboardButton.imageView?.tintColor = UIColor.battleshipGrey
            self?.audioComposeView.rightWidgetBtn.layer.borderColor = UIColor.lightGreyBlue.cgColor
            self?.audioComposeView.rightWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
            self?.audioComposeView.leftWidgetBtn.layer.borderColor = UIColor.lightGreyBlue.cgColor
            self?.audioComposeView.leftWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
            self?.audioComposeView.leftWidgetBtn.layer.borderWidth = 1
            self?.audioComposeView.rightWidgetBtn.layer.borderWidth = 1

            self?.composeWidgetAction()
        }
    }
    
    func configureInformationView() {
        informationLabel = UILabel(frame: .zero)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.backgroundColor = .clear
        informationLabel.textColor = .white
        informationLabel.font = UIFont.textFont(ofSize: 16.0, weight: .bold)
        informationLabel.textAlignment = .center
        informationView.addSubview(informationLabel)
        
        informationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[informationLabel]|", options:[], metrics:nil, views:["informationLabel": informationLabel]))
        informationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[informationLabel]|", options:[], metrics:nil, views:["informationLabel": informationLabel]))
    }
    
    func configureSnackBarView() {

    }
    
    func configureSTTClient() {
        sttClient.onError = { [weak self] (error, userInfo) in
            guard let weakSelf = self else {
                return
            }
            if !weakSelf.composeView.isKeyboardEnabled {
                weakSelf.audioComposeView.stopRecording()
                weakSelf.composeView.setText("")
                weakSelf.composeViewBottomConstraint.isActive = false
                weakSelf.composeBarContainerHeightConstraint.isActive = true
                weakSelf.composeBarContainerView.isHidden = true
            } else {
                weakSelf.audioComposeView.onKeyboardButtonAction?()
            }
            
            if let message = userInfo?["message"] as? String {
                let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
                
                if let navigateToSettings = userInfo?["settings"] as? Bool, navigateToSettings {
                    let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: .default, handler: { (action) in
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                        }
                    })
                    let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: { (action) in
                        
                    })
                    alert.addAction(settingsAction)
                    alert.addAction(cancelAction)
                } else {
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel, handler: { (action) in
                        
                    })
                    alert.addAction(cancelAction)
                }
                weakSelf.present(alert, animated: true, completion: nil)
            }
        }
        sttClient.onResponse = { [weak self] (transcript, isFinal) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.transcriptStr = transcript
            weakSelf.composeView.setText(transcript)
            weakSelf.composeBarContainerHeightConstraint.isActive = false
            weakSelf.composeViewBottomConstraint.isActive = true
            weakSelf.composeBarContainerView.isHidden = false
        }
        sttClient.processTranscript = { [weak self] in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.audioComposeView.stopRecording()
            if !weakSelf.composeView.isKeyboardEnabled {
                let text = weakSelf.transcriptStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if text.count > 0 {
                    weakSelf.audioComposeView.onKeyboardButtonAction?()
                }
                weakSelf.transcriptStr = ""
            } else {
                weakSelf.audioComposeView.onKeyboardButtonAction?()
            }
        }
    }
    
    func deConfigureSTTClient() {
        sttClient.onError = nil
        sttClient.onResponse = nil
    }
    
    // MARK: notifications
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(startSpeaking(_:)), name: KREMessageAction.startSpeaking.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpeaking(_:)), name: KREMessageAction.stopSpeaking.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(validateAgainstSkill(_:)), name: KREMessageAction.validateAgainstSkill.notification, object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: KREMessageAction.startSpeaking.notification, object: nil)
        NotificationCenter.default.removeObserver(self, name: KREMessageAction.stopSpeaking.notification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: KREMessageAction.validateAgainstSkill.notification, object: nil)
    }
    
    // MARK: notification handlers
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let animationCurveUserInfoKey = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber, let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        
        let options = UIView.AnimationOptions(rawValue: UInt((animationCurveUserInfoKey).intValue << 16))
        let duration = durationValue.doubleValue
        var keyboardHeight = keyboardFrameEnd.size.height
        if #available(iOS 11.0, *) {
            keyboardHeight -= view.safeAreaInsets.bottom
        }
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            
            switch weakSelf.keyboardState {
            case .visible:
                break
            default:
                NotificationCenter.default.post(name: KREMessageAction.keyboardWillShow.notification, object: notification.object, userInfo: notification.userInfo)
            }
            
            weakSelf.keyboardState = .showing
            weakSelf.bottomConstraint.constant = keyboardHeight
            weakSelf.view.layoutIfNeeded()
            weakSelf.inputKeyboardWillShow()
            weakSelf.keyboardState = .visible
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        keyboardState = .hiding
        guard let userInfo = notification.userInfo, let animationCurveUserInfoKey = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber, let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
            return
        }
        
        let options = UIView.AnimationOptions(rawValue: UInt((animationCurveUserInfoKey).intValue << 16))
        let duration = durationValue.doubleValue
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
            NotificationCenter.default.post(name: KREMessageAction.keyboardWillHide.notification, object: notification.object, userInfo: notification.userInfo)
            self?.bottomConstraint.constant = 0.0
            self?.view.layoutIfNeeded()
            self?.inputKeyboardWillHide()
            self?.keyboardState = .resigned
        })
    }
    
    @objc func keyboardWillChange(_ notification: Notification) {
        
    }
    
    @objc func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        if (self.composeView.isFirstResponder) {
            _ = composeView.resignFirstResponder()
        }
    }
    
    open func dismissKeyboardBasedOnTemplateType() {
        if (self.composeView.isFirstResponder) {
            _ = composeView.resignFirstResponder()
        }
    }
    
    // MARK: Helper functions
    func sendMessage(_ message: Any, options: [String: Any]?) {
        NotificationCenter.default.post(name: KREMessageAction.stopSpeaking.notification, object: nil)
    }
    
    open func sendTextMessage(_ text: String, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        messageComposeViewControllerDelegate?.sendButtonAction(message: text, dictionary: dictionary, options: options, completion: { [weak self] in
            self?.composeView.clear()
            self?.processTextForAutoCompletion()
        })
    }
    
    open func validateAndSendMessage(_ text: String, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        messageComposeViewControllerDelegate?.validateAndSendMessage(text, dictionary: dictionary, options: options, completion: { [weak self] in
            self?.composeView.clear()
            self?.processTextForAutoCompletion()
        })
    }
    
    func speechToTextButtonAction() {
        configureViewForKeyboard(false)
        _ = composeView.resignFirstResponder()
        stopTTS()
        audioComposeView.startRecording()
        
        let options = UIView.AnimationOptions(rawValue: UInt(7 << 16))
        let duration = 0.25
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    public func configureViewForKeyboard(_ prepare: Bool) {
        if prepare {
            composeBarContainerHeightConstraint.isActive = false
            composeViewBottomConstraint.isActive = true
        } else {
            composeViewBottomConstraint.isActive = false
            composeBarContainerHeightConstraint.isActive = true
        }
        audioComposeContainerHeightConstraint.isActive = prepare
        audioComposeContainerView.clipsToBounds = prepare
        composeView.configureViewForKeyboard(prepare)
        composeBarContainerView.isHidden = !prepare
        audioComposeContainerView.isHidden = prepare
        isComposeBarActive = prepare
    }
    
    // MARK: -
    open func openHelpPhrasesViewController() {
        
    }
    
    open func inputKeyboardWillShow() {
        
    }
    
    open func inputKeyboardWillHide() {
        
    }
    
    // MARK: - BotMessagesDelegate methods
    func updateTaskCount(_ count: Int) {
        sttClient.stopRecording()
        _ = composeView.resignFirstResponder()
    }
    
    func setupNavigationBarForTask() {
        composeBarContainerView.isHidden = true
        audioComposeContainerView.isHidden = true
    }
    
    func optionsButtonTapAction(_ title: String?, _ payload: String?) {
        if let title = title, let payload = payload {
            sendTextMessage(title, options: ["params": payload])
        } else if let title = title {
            sendTextMessage(title, options: nil)
        }
    }
    
    open func copyTextToComposeBar(_ text: String?) {
        composeView.growingTextView.textView.text = text
        let _ = composeView.becomeFirstResponder()
        configureViewForKeyboard(true)
        composeView.isHidden = false
    }
    
    func setPlaceholderText(with message: String) {
        composeView.placeholderText = message
    }

    // MARK: -
    func configureViews(_ prepare: Bool) {
        if (prepare) {
            composeBarContainerHeightConstraint.isActive = prepare
            composeViewBottomConstraint.isActive = prepare
            audioComposeContainerHeightConstraint.isActive = prepare
            audioComposeContainerView.clipsToBounds = prepare
            composeView.configureViewForKeyboard(prepare)
            composeBarContainerView.isHidden = prepare
            audioComposeContainerView.isHidden = prepare
        } else {
            composeViewBottomConstraint.isActive = prepare
            composeBarContainerHeightConstraint.isActive = !prepare
            audioComposeContainerHeightConstraint.isActive = prepare
            audioComposeContainerView.clipsToBounds = prepare
            composeView.configureViewForKeyboard(prepare)
            composeBarContainerView.isHidden = !prepare
            audioComposeContainerView.isHidden = prepare
        }
    }
    
    func updateConnectionStatus() {
        let updateConnectionState:((String, UIColor, CGFloat) -> Void) = { (text, backgroundColor, height) in
            UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: { [weak self] in
                self?.informationLabel.text = text
                self?.informationView.backgroundColor = backgroundColor.withAlphaComponent(0.8)
            }) { [weak self] (success) in
                self?.informationViewHeightConstraint.constant = height
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                })
            }
        }
        
        var text = "Connecting..."
        var backgroundColor = UIColor.lightRoyalBlue
        switch connectionState {
        case .CONNECTING:
            text = NSLocalizedString("Connecting...", comment: "Connecting...")
            backgroundColor = UIColor.lightRoyalBlue
            updateConnectionState(text, backgroundColor, bannerHeight)
        case .CONNECTED:
            text = NSLocalizedString("Connected", comment: "Connected")
            backgroundColor = UIColor.lightRoyalBlue
            updateConnectionState(text, backgroundColor, 0.0)
        case .NO_NETWORK:
            text = NSLocalizedString("No internet connection", comment: "No internet connection")
            backgroundColor = UIColor.lightGreyBlue
            updateConnectionState(text, backgroundColor, bannerHeight)
        case .FAILED:
            text = NSLocalizedString("Something is not right. We will be connecting shortly.", comment: "Something is not right. We will be connecting shortly")
            backgroundColor = UIColor.lightGreyBlue
            updateConnectionState(text, backgroundColor, bannerHeight)
        default:
            break
        }
    }
    
    // MARK: KREComposeBarViewDelegate methods
    public func composeBarView(_: KREComposeBarView, sendButtonAction text: String) {
        sendTextMessage(text, options: nil)
    }
    
    public func composeBarViewSpeechToTextButtonAction(_: KREComposeBarView) {
        speechToTextButtonAction()
    }
    
    public func composeBarHelpButtonAction(_: KREComposeBarView) {
        openHelpPhrasesViewController()
    }
    
    open func composeBarViewDidBecomeFirstResponder(_: KREComposeBarView) {
        audioComposeView.stopRecording()
        processTextForAutoCompletion()
    }
    
    open func composeBarCancelButtonAction(_: KREComposeBarView) {

    }
    
    // MARK: KREGrowingTextViewDelegate methods
    public func growingTextView(_: KREGrowingTextView, changingHeight height: CGFloat, animate: Bool) {
        UIView.animate(withDuration: animate ? 0.25: 0.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    public func growingTextView(_: KREGrowingTextView, willChangeHeight height: CGFloat) {
        
    }
    
    public func growingTextView(_: KREGrowingTextView, didChangeHeight height: CGFloat) {
        
    }
    
    // MARK: - notification handlers
    @objc open func utteranceHandler(_ notification: Notification) {
        
    }
    
    @objc open func navigateToComposeBar(_ notification: Notification) {
        
    }
    
    @objc open func validateAgainstSkill(_ notification: Notification) {
        
    }
    
    @objc func startSpeaking(_ notification: Notification) {
        if let string = notification.object as? String {
            readOutText(text: string)
        }
    }
    
    @objc func stopSpeaking(_ notification: Notification) {
        stopTTS()
    }
    
    func readOutText(text:String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 10.0, *) {
                try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            } else {
                // Fallback on earlier versions
            }
            try audioSession.setMode(.default)
        } catch {
            
        }
        if (canSpeakUtterance && isSpeakingEnabled) {
            let string = text
            let speechUtterance = AVSpeechUtterance(string: string)
            speechUtterance.voice = AVSpeechSynthesisVoice()
            speechSynthesizer.speak(speechUtterance)
        }
    }
    
    open func stopTTS() {
        if (self.speechSynthesizer.isSpeaking) {
            speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    // MARK: -
    open func rightWidgetAction() {
        
    }
    
    open func composeWidgetAction() {
        
    }
    
    open func leftWidgetAction() {
        
    }
    
    open func didSelectLeftWidget() {
        audioComposeView.containerView.layer.borderColor = UIColor.lightGreyBlue.cgColor
        audioComposeView.audioView.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.thunderBoltActionButton.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.keyboardButton.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.rightWidgetBtn.layer.borderColor = UIColor.lightGreyBlue.cgColor
        audioComposeView.rightWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.leftWidgetBtn.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        audioComposeView.leftWidgetBtn.imageView?.tintColor = UIColor.lightRoyalBlue
        audioComposeView.leftWidgetBtn.layer.borderWidth = 2
        audioComposeView.rightWidgetBtn.layer.borderWidth = 1
    }
    
    open func didSelectComposeWidget() {
        audioComposeView.leftWidgetBtn.layer.borderColor = UIColor.lightGreyBlue.cgColor
        audioComposeView.leftWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.containerView.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        audioComposeView.audioView.imageView?.tintColor = UIColor.lightRoyalBlue
        audioComposeView.thunderBoltActionButton.imageView?.tintColor = UIColor.battleshipGrey
        audioComposeView.keyboardButton.imageView?.tintColor = UIColor.battleshipGrey
        audioComposeView.rightWidgetBtn.layer.borderColor = UIColor.lightGreyBlue.cgColor
        audioComposeView.rightWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.leftWidgetBtn.layer.borderWidth = 1
        audioComposeView.rightWidgetBtn.layer.borderWidth = 1
    }
    
    open func didSelectRightWidget() {
        audioComposeView.leftWidgetBtn.layer.borderColor = UIColor.lightGreyBlue.cgColor
        audioComposeView.leftWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.containerView.layer.borderColor = UIColor.lightGreyBlue.cgColor
        audioComposeView.audioView.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.thunderBoltActionButton.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.keyboardButton.imageView?.tintColor = UIColor.lightGreyBlue
        audioComposeView.rightWidgetBtn.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        audioComposeView.rightWidgetBtn.imageView?.tintColor = UIColor.lightRoyalBlue
        audioComposeView.leftWidgetBtn.layer.borderWidth = 1
        audioComposeView.rightWidgetBtn.layer.borderWidth = 2
    }
    
    // MARK: -
    open func populateAutoSuggestions(token: String, prefix: String?) {
        
    }
    
    open func registerPrefixes(forAutoCompletion prefixes: [String]) {
        var array = registeredPrefixes
        for prefix: String in prefixes {
            // skips if the prefix is not a valid string
            if prefix.count == 0 {
                continue
            }
            // adds the prefix if not contained already
            if !array.contains(prefix) {
                array.append(prefix)
            }
        }
        registeredPrefixes = array
    }
    
    open func heightForAutoCompletionView() -> CGFloat {
        return 12.0
    }
    
    open func maximumHeightForAutoCompletionView() -> CGFloat {
        return 0
    }
    
    open func cancelAutoCompletion(prefix: String? = nil) {
        foundPrefix = ""
        foundWord = ""
        foundPrefixRange = NSMakeRange(0, 0)
    }
    
    open func acceptAutoCompletion(with string: String) {
        if string.count == 0 {
            return
        }
        
        let textView = composeView.growingTextView.textView
        var location = foundPrefixRange?.location ?? 0
        let range = NSRange(location: location, length: foundWord.count)
        let insertionRange: NSRange = textView.slk_insertText(string, in: range)
        textView.selectedRange = NSRange(location: insertionRange.location, length: 0)
        cancelAutoCompletion()
        textView.slk_scrollToCaretPositon(animated: false)
    }
    
    func processTextForAutoCompletion() {
        guard let text = textView.text, text.count > 0 else {
            return cancelAutoCompletion()
        }
        
        var range: NSRange =  NSRange(location: 0, length: 0)
        let word: String = textView.slk_word(atCaretRange: &range)
        for sign in registeredPrefixes {
            let keyRange: NSRange? = (word as NSString).range(of: sign)
            if keyRange!.location == 0 || (keyRange!.length >= 1) {
                foundPrefix = sign
                foundPrefixRange = NSRange(location: (range.location), length: sign.count)
            }
        }
        if let prefixRange = foundPrefixRange, textView.selectedRange.location <= prefixRange.location {
            return cancelAutoCompletion(prefix: foundWord)
        }
        
        if foundPrefix.count > 0 {
            if range.length == 0 || range.length != word.count {
                return cancelAutoCompletion(prefix: foundWord)
            }
            if word.count > 0 {
                let token = word.substring(from: 1)
                if token.count == 0 || token.contains(foundPrefix) {
                    return cancelAutoCompletion(prefix: foundWord)
                } else {
                    foundWord = word
                    populateAutoSuggestions(token: token, prefix: foundWord)
                }
            }
        } else {
            foundWord = text
            populateAutoSuggestions(token: text, prefix: nil)
        }
    }
}

// MARK: - UITextViewDelegate
extension KREMessageComposeViewController: UITextViewDelegate {
    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        processTextForAutoCompletion()
    }
}
