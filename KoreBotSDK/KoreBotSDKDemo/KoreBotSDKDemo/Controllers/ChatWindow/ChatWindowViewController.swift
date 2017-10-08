//
//  ChatWindowViewController.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 07/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK
import AVFoundation
import googleapis
import TOWebViewController

let SAMPLE_RATE = 16000

class ChatWindowViewController: UIViewController, AudioControllerDelegate, BotMessagesViewDelegate {
    
    var audioData: NSMutableData!
    var thread: KREThread!
    var botClient: BotClient!
    
    @IBOutlet weak var textInputView: UIView!
    @IBOutlet weak var textScrollView: UIScrollView!
    @IBOutlet weak var threadContentView: UIView!
    @IBOutlet weak var bottomContentView: UIView!

    @IBOutlet weak var textInputViewHeightConstraint: NSLayoutConstraint!

    private var textLabel: UILabel!
    var audioView: AudioView!
    var botMessagesView: BotMessagesView!
    var speechSynthesizer: AVSpeechSynthesizer!
    
    init(thread: KREThread!) {
        super.init(nibName: "ChatWindowViewController", bundle: nil)
        self.thread = thread
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.textLabel = UILabel(frame: CGRect.zero)
        self.textLabel.numberOfLines = 1
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)!
        self.textLabel.textColor = .white
        self.textScrollView.addSubview(self.textLabel)
        self.setTextToLabel("")
        
        AudioController.sharedInstance.delegate = self
        
        self.configureThreadView()
        self.configureAudioComposer()
        self.configureBotClient()
        self.speechSynthesizer = AVSpeechSynthesizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        if(self.botClient != nil){
            self.botClient.disconnect()
        }
        self.deConfigureBotClient()
        self.stopTTS()
        AudioController.sharedInstance.delegate = nil
    }
    
    
    // MARK: configuring views
    
    func configureThreadView() {
        self.botMessagesView = BotMessagesView()
        self.botMessagesView.translatesAutoresizingMaskIntoConstraints = false
        self.botMessagesView.thread = self.thread
        self.botMessagesView.viewDelegate = self
        self.botMessagesView.backgroundColor = .clear
        self.botMessagesView.tableView.backgroundColor = .clear
        self.botMessagesView.clearBackground = true
        self.threadContentView.addSubview(self.botMessagesView!)
        
        self.threadContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[botMessagesView]|", options:[], metrics:nil, views:["botMessagesView" : self.botMessagesView!]))
        self.threadContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[botMessagesView]|", options:[], metrics:nil, views:["botMessagesView" : self.botMessagesView!]))
    }
    
    func configureAudioComposer()  {
        self.audioView = AudioView()
        self.audioView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomContentView.addSubview(self.audioView!)
        
        self.bottomContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[audioView]|", options:[], metrics:nil, views:["audioView" : self.audioView!]))
        self.bottomContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[audioView]|", options:[], metrics:nil, views:["audioView" : self.audioView!]))
        
        self.audioView.cancelledSpeechToText = {
            self.closeAction(self.audioView)
        }
        self.audioView.voiceRecordingStarted = { [weak self] (composeBar) in
            composeBar?.isActive = true
            self?.recordAudio(composeBar as Any)
        }
        self.audioView.voiceRecordingStopped = { (composeBar) in

        }
        self.audioView.getAudioPeakOutputPower = { () in
            return 0.0
        }
    }
    
    func configureBotClient() {
        if(botClient != nil){
            // events
            botClient.connectionWillOpen =  { () in
                
            }
            
            botClient.connectionDidOpen = { () in
                
            }
            
            botClient.connectionReady = { () in
                
            }
            
            botClient.connectionDidClose = { (code, reason) in
                NSLog("botClient: connectionDidClose")
                
            }
            
            botClient.connectionDidFailWithError = { (error) in
                NSLog("botClient: connectionDidFailWithError")
            }
            
            botClient.onMessage = { [weak self] (object) in
                self?.onReceiveMessage(object: object)
            }
            
            botClient.onMessageAck = { (ack) in
                
            }
        }
    }
    
    func onReceiveMessage(object: BotMessageModel?) {
        let message: Message = Message()
        message.messageType = .reply
        message.sentDate = Date()
        
        if (object?.iconUrl != nil) {
            message.iconUrl = object?.iconUrl
        }
        
        let messageObject = ((object?.messages.count)! > 0) ? (object?.messages[0]) : nil
        if (messageObject?.component == nil) {
            
        } else {
            let componentModel: ComponentModel = messageObject!.component!
            var ttsBody: String? = nil
            
            if (componentModel.type == "text") {
                
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: NSString = payload["text"] as! NSString
                let textComponent: TextComponent = TextComponent()
                textComponent.text = text
                ttsBody = text as String
                
                message.addComponent(textComponent)
            } else if (componentModel.type == "template") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: String = payload["text"] != nil ? payload["text"] as! String : ""
                let type: String = payload["type"] != nil ? payload["type"] as! String : ""
                ttsBody = payload["speech_hint"] != nil ? payload["speech_hint"] as? String : nil
                
                if(type == "template"){
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let templateType: String = dictionary["template_type"] as! String
                    
                    if (templateType == "quick_replies") {
                        ttsBody = dictionary["text"] as? String
                        let quickRepliesComponent: QuickRepliesComponent = QuickRepliesComponent()
                        quickRepliesComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(quickRepliesComponent)
                    } else if (templateType == "button") {
                        ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : dictionary["text"] as? String
                        let optionsComponent: OptionsComponent = OptionsComponent()
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(optionsComponent)
                    }else if (templateType == "list") {
                        ttsBody = dictionary["text"] as? String
                        let optionsComponent: ListComponent = ListComponent()
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(optionsComponent)
                    }else if (templateType == "carousel") {
                        
                        let carouselComponent: CarouselComponent = CarouselComponent()
                        carouselComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(carouselComponent)
                    }else if (templateType == "piechart") {
                        
                        let piechartComponent: PiechartComponent = PiechartComponent()
                        piechartComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(piechartComponent)
                    }
                }else if(type == "error"){
                    
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let errorComponent: ErrorComponent = ErrorComponent()
                    errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                    
                    message.addComponent(errorComponent)
                }else if text != "" {
                    
                    let textComponent: TextComponent = TextComponent()
                    textComponent.text = text as NSString!
                    
                    message.addComponent(textComponent)
                }
            }
            
            if (message.components.count > 0) {
                let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
                dataStoreManager.createNewMessageIn(thread: self.thread, message: message, completionBlock: { (success) in
                })
                if ttsBody != nil {
                    self.audioView.stopRecording()
                    self.readOutText(text: ttsBody!)
                }
            }
        }
    }
    
    // MARK: Helper functions
    
    func sendMessage(_ message:Message){
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        let composedMessage: Message = message
        if (composedMessage.components.count > 0) {
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.createNewMessageIn(thread: self.thread, message: composedMessage, completionBlock: { (success) in
                let textComponent: TextComponent = composedMessage.components[0] as! TextComponent
                let text: String = textComponent.text as String
                if(self.botClient != nil){
                    self.botClient.sendMessage(text, options: [] as AnyObject)
                }
                self.textMessageSent()
            })
        }
    }
    
    func sendTextMessage(_ text:String) {
        let message: Message = Message()
        message.messageType = .default
        message.sentDate = Date()
        let textComponent: TextComponent = TextComponent()
        textComponent.text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString!
        message.addComponent(textComponent)
        self.sendMessage(message)
    }
    
    func textMessageSent() {
//        self.botMessagesView.scrollToBottom(animated: true)
    }
    
    func deConfigureBotClient() {
        if(botClient != nil){
            // events
            botClient.connectionWillOpen = nil
            botClient.connectionDidOpen = nil
            botClient.connectionReady = nil
            botClient.connectionDidClose = nil
            botClient.connectionDidFailWithError = nil
            botClient.onMessage = nil
            botClient.onMessageAck = nil
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        prepareForDeinit()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        stopTTS()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    @IBAction func stopAudio(_ sender: Any) {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData, completion:{ [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = error {
                    strongSelf.setTextToLabel(error.localizedDescription)
                } else if let response = response {
                    var finished = false
                    var transcript = ""
                    print(response)
                    
                    if let result = response.resultsArray[0] as? StreamingRecognitionResult {
                        if result.stability > 0.5 {
                            if let speechResult = result.alternativesArray[0] as? SpeechRecognitionAlternative {
                                transcript = speechResult.transcript
                            }
                        }
                    }
                    
                    for result in response.resultsArray! {
                        if let result = result as? StreamingRecognitionResult {
                            if result.isFinal {
                                finished = true
                                if let speechResult = result.alternativesArray[0] as? SpeechRecognitionAlternative {
                                    transcript = speechResult.transcript
                                }
                            }
                        }
                    }
                    strongSelf.setTextToLabel(transcript)
                    if finished {
                        strongSelf.stopAudio(strongSelf)
                        let deadline = DispatchTime.now() + .milliseconds(500)
                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                            strongSelf.audioView.stopRecording()
                            strongSelf.setTextToLabel("")
                            strongSelf.sendTextMessage(transcript)
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
    func setTextToLabel(_ text: String) {
        self.textInputViewHeightConstraint.constant = (text.characters.count) > 0 ? 50.0 : 0.0
        self.textLabel.text = text
        let size = self.textLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: self.textScrollView.frame.size.height))
        let frame = CGRect(x: self.textScrollView.frame.size.width - size.width, y: 0.0, width: size.width, height: self.textScrollView.frame.size.height)
        self.textLabel.frame = frame
//        self.textScrollView.contentSize = CGSize. frame.size
//        let rect = CGRect(x: frame.size.width - 1.0, y: 0.0, width: 1.0, height: self.textScrollView.frame.size.height)
//        self.textScrollView.scrollRectToVisible(rect, animated: false)
    }
    
    func readOutText(text:String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setMode(AVAudioSessionModeDefault)
        } catch {

        }
        let string = text
        print("Reading text: ", text);
        let speechUtterance = AVSpeechUtterance(string: string)
        self.speechSynthesizer.speak(speechUtterance)
    }
    
    func stopTTS(){
        if(self.speechSynthesizer.isSpeaking){
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    // MARK: BotMessagesDelegate methods
    func optionsButtonTapAction(text: String) {
        self.sendTextMessage(text)
    }
    
    func linkButtonTapAction(urlString: String) {
        if (urlString.characters.count > 0) {
            let url: URL = URL(string: urlString)!
            let webViewController: TOWebViewController = TOWebViewController(url: url)
            let webNavigationController: UINavigationController = UINavigationController(rootViewController: webViewController)
            webNavigationController.tabBarItem.title = "Bots"
            self.present(webNavigationController, animated: true, completion:nil)
        }
    }
    
    func populateQuickReplyCards(with message: KREMessage?) {
//        if (message?.templateType == 5) {
//            let component: KREComponent = message!.components![0] as! KREComponent
//            if (!component.isKind(of: KREComponent.self)) {
//                return;
//            }
//            if ((component.componentDesc) != nil) {
//                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: component.componentDesc!) as! NSDictionary
//                let quickReplies: Array<Dictionary<String, String>> = jsonObject["quick_replies"] as! Array<Dictionary<String, String>>
//                var words: Array<Word> = Array<Word>()
//                
//                for dictionary in quickReplies {
//                    let title: String = dictionary["title"] != nil ? dictionary["title"]! : ""
//                    let payload: String = dictionary["payload"] != nil ? dictionary["payload"]! : ""
//                    let imageURL: String = dictionary["image_url"] != nil ? dictionary["image_url"]! : ""
//                    
//                    let word: Word = Word(title: title, payload: payload, imageURL: imageURL)
//                    words.append(word)
//                }
//                self.quickReplyView.setWordsList(words: words)
//                
//                self.updateQuickSelectViewConstraints()
//            }
//        } else if(message != nil) {
//            self.closeQuickSelectViewConstraints()
//        }
    }
    
    func closeQuickReplyCards(){
//        self.closeQuickSelectViewConstraints()
    }
    
    func updateQuickSelectViewConstraints() {
//        if self.quickSelectContainerHeightConstraint.constant == 60.0 {return}
//        
//        var contentInset = self.botMessagesView.tableView.contentInset
//        contentInset.bottom = 60
//        self.botMessagesView.tableView.contentInset = contentInset
//        self.quickSelectContainerHeightConstraint.constant = 60.0
//        
//        UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {
//            self.view.layoutIfNeeded()
//        }) { (Bool) in
//            
//        }
    }
    
    func closeQuickSelectViewConstraints() {
//        if self.quickSelectContainerHeightConstraint.constant == 0.0 {return}
//        
//        var contentInset = self.botMessagesView.tableView.contentInset
//        contentInset.bottom = 0
//        self.botMessagesView.tableView.contentInset = contentInset
//        self.quickSelectContainerHeightConstraint.constant = 0.0
//        
//        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
//            self.view.layoutIfNeeded()
//        }) { (Bool) in
//            
//        }
    }
}
