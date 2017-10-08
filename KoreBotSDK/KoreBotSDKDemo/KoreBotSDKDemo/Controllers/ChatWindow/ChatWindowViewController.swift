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

let SAMPLE_RATE = 16000

class ChatWindowViewController: UIViewController, AudioControllerDelegate {
    
    var audioData: NSMutableData!
    var thread: KREThread!
    var botClient: BotClient!
    
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var textScrollView: UIScrollView!
    @IBOutlet weak var resTextScrollView: UIScrollView!
    @IBOutlet weak var bottomContentView: UIView!

    private var textLabel: UILabel!
    private var resTextLabel: UILabel!
    var audioView: AudioView!

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
        
        self.textLabel = UILabel(frame: CGRect.zero)
        self.textLabel.numberOfLines = 1
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)!
        self.textLabel.textColor = .white
        self.textScrollView.addSubview(self.textLabel)
        
        self.resTextLabel = UILabel(frame: CGRect.zero)
        self.resTextLabel.numberOfLines = 0
        self.resTextLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)!
        self.resTextLabel.textColor = .white
        self.resTextScrollView.addSubview(self.resTextLabel)
        
        AudioController.sharedInstance.delegate = self
        
        self.configureAudioComposer()
        self.configureBotClient()
        self.speechSynthesizer = AVSpeechSynthesizer()
        setTextToLabel("Say something...")
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
        self.audioView.voiceRecordingStopped = {  [weak self] (composeBar) in

        }
        self.audioView.getAudioPeakOutputPower = { [weak self]() in
            return 0.0
        }
    }
    
    func configureBotClient() {
        if(botClient != nil){
            // events
            botClient.connectionWillOpen =  { [weak self] () in
            }
            
            botClient.connectionDidOpen = { [weak self] () in
            }
            
            botClient.connectionReady = { () in
                
            }
            
            botClient.connectionDidClose = { [weak self] (code, reason) in
                NSLog("botClient: connectionDidClose")
                
            }
            
            botClient.connectionDidFailWithError = { [weak self] (error) in
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
        let messageObject = ((object?.messages.count)! > 0) ? (object?.messages[0]) : nil
        if (messageObject?.component == nil) {
            
        } else {
            let componentModel: ComponentModel = messageObject!.component!
            var body: String? = nil
            
            if (componentModel.type == "text") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: NSString = payload["text"] as! NSString
                body = text as String
            } else if (componentModel.type == "template") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                body = Utilities.stringFromJSONObject(object: dictionary) as String
            }
            
            self.setTextToResLabel(body!)
            self.audioView.stopRecording()
            self.readOutText(text: body!)
        }
    }
    
    func sendMessage(_ message: String){
        if(self.botClient != nil){
            self.botClient.sendMessage(message, options: [] as AnyObject)
        }
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
        if(self.botClient != nil){
            self.botClient.disconnect()
        }
        deConfigureBotClient()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        stopTTS()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
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
                    strongSelf.textLabel.text = error.localizedDescription
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
                        strongSelf.audioView.stopRecording()
                        strongSelf.sendMessage(transcript)
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
    func setTextToLabel(_ text: String) {
        self.textLabel.text = text
        let size = self.textLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: self.textScrollView.frame.size.height))
        let frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: self.textScrollView.frame.size.height)
        self.textLabel.frame = frame
        self.textScrollView.contentSize = frame.size
        let rect = CGRect(x: frame.size.width - 1.0, y: 0.0, width: 1.0, height: self.textScrollView.frame.size.height)
        self.textScrollView.scrollRectToVisible(rect, animated: false)
    }
    
    func setTextToResLabel(_ text: String) {
        self.resTextLabel.text = text
        let size = self.resTextLabel.sizeThatFits(CGSize(width: self.resTextScrollView.frame.size.width, height: .greatestFiniteMagnitude))
        let frame = CGRect(x: 0.0, y: 0.0, width: self.resTextScrollView.frame.size.width, height: size.height)
        self.resTextLabel.frame = frame
        self.resTextScrollView.contentSize = frame.size
    }
    
    func readOutText(text:String) {
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
}
