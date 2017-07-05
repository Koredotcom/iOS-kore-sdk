//
//  AudioComposer.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/5/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import SpeechToText
import SpeechToText.RequestManager

class AudioComposer: UIView, UITextViewDelegate, SpeechToTextDelegate {

    @IBOutlet weak var textViewHeightConstriant: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var animateBGView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var placeHolderTF: UITextField!
    let reuqestManager:RequestManager=RequestManager.init();
    var speechToTextToolBarString: NSMutableString!
    var speechToTextIntermediateString: NSMutableString!
    var speechToTextTempString: NSMutableString!
    var speechServerUrl: String!
    var identity: String!
    var audioIconButton:UIButton!
    var myTimer:Timer!;
    var animationTimer:Timer!
    var audioRecorderTimer:Timer!
    var waveRadius:Float = 25
    var sendTimeInterval:TimeInterval = 3
    var audioIconSize:CGFloat = 20
    var sendButtonAction: ((_ composeBar: AudioComposer?, _ composedMessage: Message?) -> Void)!
    var cancelledSpeechToText: (() -> ())?
    var viewWillResizeSubViews: (() -> ())?
    var keyBoardActivated: ((_ composedMessage: NSString?) -> ())!
    var showCursorForSpeechDone: (() -> ())?

    var audioPeakOutput:Float = 0.3
    var tapAudioGestureRecognizer: UITapGestureRecognizer!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.resignFirstResponder()
        self.textView.isEditable = true;
        self.textView.layer.borderColor = Common.UIColorRGB(0xDADCDC).cgColor
        self.textView.layer.borderWidth = 1.0;
        self.textView.layer.cornerRadius = 4;
        self.textView.textContainerInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 8.0);
        self.textView.delegate = self;
        self.placeHolderTF.isUserInteractionEnabled = false;
        self.placeHolderTF.resignFirstResponder()

    }
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
        

        let range: NSRange = self.textView.selectedRange
        if (range.location >= self.textView.text.characters.count) {
            self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.characters.count, 0))
            self.textView.isScrollEnabled = false
            self.textView.isScrollEnabled = true
        }
        if(self.audioIconButton != nil){
            self.audioIconButton.frame = CGRect(x: self.animateBGView.frame.size.width/2 - self.audioIconSize/2, y: self.animateBGView.frame.size.height/2 - self.audioIconSize/2, width: self.audioIconSize, height: self.audioIconSize)
        }
    }
    
    override func updateConstraints() {
        self.textViewHeightConstriant.constant = self.calculatedTextHeight()
        super.updateConstraints()
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.calculatedTextHeight() + 12)
    }

    func clear() {
        self.textView.text = "";
        self.speechToTextIntermediateString="";
        self.speechToTextToolBarString="";
        self.valueChanged()
    }

    func valueChanged() {
        self.updateTextView()
        if((self.viewWillResizeSubViews) != nil){
            self.viewWillResizeSubViews!()
        }
        self.textView.contentOffset = CGPoint(x:0, y:self.textView.contentSize.height - self.textView.frame.size.height + 2);

        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.layoutIfNeeded()

    }

    func composeBarFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 14.0)!
    }

    // MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.updateTextView()
    }
    func  textViewDidEndEditing(_ textView: UITextView) {
        self.updateTextView()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.updateTextView()
        self.valueChanged()
    }

    func updateTextView() {
        if(textView.text.characters.count == 0){
            self.placeHolderTF.text = nil;
            self.sendButton.isEnabled = false;
            self.cancelButton.setImage(UIImage.init(named: "policy_close"), for: UIControlState.normal)
        }else{
            self.placeHolderTF.text = " ";
            self.sendButton.isEnabled = true;
            self.cancelButton.setImage(UIImage.init(named: "done_icon"), for: UIControlState.normal)
        }
    }
    // MARK: Height Calculation

    func calculatedTextHeight() -> CGFloat {
        let sizingString: NSString = "\n\n\n\n\n\n\n";
        let rect: CGRect = sizingString.boundingRect(with: CGSize(width: self.textView.bounds.size.width, height: 50),
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSFontAttributeName: self.composeBarFont()],
                                                     context: nil)
        let textSize: CGSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.size.width, height: 60))
//        print("height  val --  ",min(textSize.height, rect.size.height + 5));
        var height:CGFloat = CGFloat(min(textSize.height, rect.size.height + 5));
        if(height > 66){
            height = 58;
        }
        return height;
    }
    


    // MARK: Speech Output - sttDelegate

    public func speech(toTextdataDictionary dataDictionary: [AnyHashable : Any]!) {
        if(dataDictionary == nil){
            return;
        }
        
        self.myTimer.invalidate()
//        self.startTimeIntervalToSendMessage()
        
        let final:Bool = (dataDictionary["final"] as? Bool)!
        let hypotheses:NSDictionary! = (dataDictionary["hypotheses"] as! NSArray!).firstObject as! NSDictionary!;
        let str:String = hypotheses.value(forKey: "transcript") as! String;
        let transcript:NSString = ((str.characters.count > 0) ? str : "") as NSString;
        
        DispatchQueue.main.async {
            if final{
                self.speechToTextToolBarString.append(transcript as String);
                self.textView.text=self.speechToTextToolBarString as String!;
                self.speechToTextIntermediateString="";
                self.valueChanged()
                
            }else{
                let mainString:NSMutableString!=self.speechToTextToolBarString?.mutableCopy() as? NSMutableString;
                self.speechToTextIntermediateString=mainString;
                self.speechToTextIntermediateString.append(transcript as String);
                self.textView.text=self.speechToTextIntermediateString as String!;
                self.valueChanged()
            }
        }
    }
    
    // MARK: Message Sending
    @IBAction func sendButtonAction(_ sender: Any) {
        initiateSendingMessage();
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
    }
    func initiateSendingMessage(){
        let speechText:NSString = self.textView.text as NSString;
        let trimmedText:String = speechText.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        if(trimmedText.characters.count > 0){
            self.sendSpeechToTextMessage()
            self.stopVoiceRecording()
        }else{
//            self.startTimeIntervalToSendMessage()
        }
        
    }
    
    func sendSpeechToTextMessage()  {
        
        let message: Message = Message()
        message.messageType = .default
        message.sentDate = Date()
        
        self.speechToTextToolBarString="";
        self.speechToTextIntermediateString="";
        self.textView.resignFirstResponder()

        // is there any text?
        if (self.textView.text.characters.count > 0) {
            let textComponent: TextComponent = TextComponent()
            textComponent.text = self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString!
            
            message.addComponent(textComponent)
        }
        
        if((self.sendButtonAction) != nil){
            self.sendButtonAction!(self, message)
        }
        self.textView.text = ""
        self.sendButton.isEnabled = false;
        self.valueChanged()
        
    }

    
    // MARK: Cancel SpeechToText

    @IBAction func cancelButtonAction(_ sender: Any) {
        if((self.showCursorForSpeechDone) != nil){
            self.showCursorForSpeechDone!()
        }
        
        self.disableSpeech()
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
    }

    func cancelSpeech(){

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        self.stopVoiceRecording()
        if((self.cancelledSpeechToText) != nil){
            self.cancelledSpeechToText!()
        }

    }
    // MARK: Wave Animations initiation

    func triggerAudioAnimation(radius:NSInteger) {
        NotificationCenter.default.addObserver(self, selector: #selector(AudioComposer.willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        if(self.audioIconButton == nil){
            self.audioIconButton = UIButton(type: UIButtonType.custom) as UIButton
            self.audioIconButton.frame = CGRect(x: self.animateBGView.frame.size.width/2 - 7, y: self.animateBGView.frame.size.height/2 - 7, width: CGFloat(15), height: CGFloat(15))
            self.animateBGView.addSubview(self.audioIconButton)
            self.audioIconButton.isUserInteractionEnabled = false
            self.tapAudioGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(AudioComposer.startVoiceRecording))
            self.animateBGView.addGestureRecognizer(tapAudioGestureRecognizer)

        }
        self.audioIconButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.startVoiceRecording()
    }
    
    func showCircleWaveAnimation() {
        let circleView = UIView()
        circleView.frame = CGRect(x: self.animateBGView.frame.size.width/2 - 2.5, y: self.animateBGView.frame.size.height/2 - 2.5, width: CGFloat(5), height: CGFloat(5))

        self.animateBGView.addSubview(circleView)
        circleView.backgroundColor = Common.UIColorRGB(0x009FA7)
        circleView.layer.cornerRadius = circleView.frame.size.width / 2
        circleView.alpha = 1.0
        var radius:CGFloat
        
        if(self.audioPeakOutput > 0.9){
            radius = CGFloat(self.randomInt(min: 17, max: 25))
        }else{
            radius = 7//CGFloat(self.randomInt(min: 5, max: 9));
        }
        self.animateBGView.bringSubview(toFront: self.audioIconButton)
        circleView.layer.shadowColor = UIColor.white.cgColor
        circleView.layer.shadowOpacity = 0.6
        circleView.layer.shadowRadius = 1.0
        circleView.layer.shadowOffset = CGSize(width: CGFloat(0.0), height: CGFloat(0.0))
        UIView.animate(withDuration: 1.95, animations: {() -> Void in
            circleView.transform = CGAffineTransform(scaleX: radius, y: radius)
            circleView.alpha = 0.0
        }, completion: {(_ finished: Bool) -> Void in
            circleView.removeFromSuperview()
        })
        
    }
    
    // MARK: Start/Stop Voice Recording
    
    func startVoiceRecording()  {
        
        self.textView.resignFirstResponder()
        reuqestManager.intializeSocket(withUrl: ServerConfigs.BOT_SPEECH_SERVER, identity: "");
        reuqestManager.sttdelegate=self;
        self.audioIconSize = 20;
        self.animateBGView.isUserInteractionEnabled = false
        self.audioIconButton.setImage(UIImage(named: "audio_icon")!, for: .normal)
        self.infoLabel.isHidden = true
        self.speechToTextToolBarString="";
        self.speechToTextIntermediateString="";
        self.startAnimationWaveTimer()
        self.startTimeIntervalToSendMessage()
        self.audioRecordTimer()
        self.valueChanged()
    }
    
    func stopVoiceRecording()  {
        //stop timers
        if(self.animationTimer != nil){
            self.animationTimer.invalidate()
            self.animationTimer = nil;
        }
        
        if(self.audioRecorderTimer != nil){
            self.audioRecorderTimer.invalidate()
            self.audioRecorderTimer = nil
        }
        
        if(self.myTimer != nil){
            self.myTimer.invalidate()
            self.myTimer = nil
        }
       
        self.speechToTextToolBarString="";
        self.speechToTextIntermediateString="";
        reuqestManager.sttdelegate=nil;
        reuqestManager.stopAudioQueueRecording();
        self.textView.text = ""
        self.animateBGView.isUserInteractionEnabled = true
        self.audioIconButton.setImage(UIImage(named: "speech")!, for: .normal)
        self.audioIconSize = 30;
        self.infoLabel.isHidden = false
        self.valueChanged()

// commented for now
//        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
//            self.audioIconButton.alpha = 0;
//            self.audioIconSize = 30;
//            self.layoutIfNeeded()
//            }, completion: { finished in
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.audioIconButton.setImage(UIImage(named: "speech")!, for: .normal)
//                    self.audioIconButton.alpha = 1;
//                    self.layoutIfNeeded();
//
//                })
//        })
        
    }

    
    // MARK: Timers

    func  startAnimationWaveTimer() {
        self.animationTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(self.showCircleWaveAnimation), userInfo: nil, repeats: true)
        RunLoop.main.add(self.animationTimer, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    
    func startTimeIntervalToSendMessage()  {
        if(self.myTimer != nil){
            self.myTimer.invalidate()
            self.myTimer = nil;
        }
        self.myTimer = Timer.scheduledTimer(timeInterval: sendTimeInterval, target: self, selector: #selector(self.initiateSendingMessage), userInfo: nil, repeats: false)
        RunLoop.main.add(self.myTimer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func audioRecordTimer() {
        self.audioRecorderTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateRecordTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(self.audioRecorderTimer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func updateRecordTimer() {
        if((reuqestManager.audioQueueRecorder) != nil){
            reuqestManager.audioQueueRecorder.updateMeters()
            self.audioPeakOutput =  self.decibelToLinear(power: reuqestManager.audioQueueRecorder.peakPower(forChannel: 0));
        }
//        print("audio wave val --  ",self.audioPeakOutput);
    }
    
    // MARK: Decibel to Linear conversion

    func decibelToLinear(power:Float) -> (Float) {
        let normalizedDecbl:Float = pow (10, power / 20);// converted to linear
        return normalizedDecbl * waveRadius ;
    }

    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }

    func willShowKeyboard(_ notification: Notification!) {
        self.disableSpeech()
    }
    
    func disableSpeech(){
        
        if((self.keyBoardActivated) != nil){
            if(self.textView.text.characters.count > 0){
                self.keyBoardActivated(self.textView.text as NSString?)
            }
            self.clear()
            self.cancelSpeech()
            
        }
    }
    
}
