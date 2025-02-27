//
//  ResetPinViewController.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 14/07/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
protocol resetPinDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}
class ResetPinViewController: UIViewController, UITextFieldDelegate {
    let bundle = Bundle.sdkModule
    var viewDelegate: resetPinDelegate?
    var dataString: String!
    @IBOutlet weak var HeadingLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    
    @IBOutlet weak var enterPinlbl: UILabel!
    @IBOutlet weak var reEnterPinLbl: UILabel!
    
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var secondTF: UITextField!
    @IBOutlet weak var thirdTF: UITextField!
    @IBOutlet weak var foruthTF: UITextField!
    @IBOutlet weak var fifthTF: UITextField!
    @IBOutlet weak var sixthTF: UITextField!
    
    @IBOutlet weak var firstTFre: UITextField!
    @IBOutlet weak var secondTFre: UITextField!
    @IBOutlet weak var thirdTFre: UITextField!
    @IBOutlet weak var foruthTFre: UITextField!
    @IBOutlet weak var fifthTFre: UITextField!
    @IBOutlet weak var sixthTFre: UITextField!
    
    var textfeildViews = "EnterPinV"
    var errorMessage = "Pin mismatch"
    var WarningMessage = "Pin mismatch"
    var piiSuffix = ""
    @IBOutlet weak var underToplineLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    var isPinLengthSix = true
    
    let tfBorderColor = "#738794"
    let tfBgColor = "#FBFBFB"
    
    let tfSelectedBorderColor = "#333333"
    let tfSelectedBgColor = "#FFFFFF"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        underToplineLbl.layer.cornerRadius = 3.0
        underToplineLbl.clipsToBounds = true
        
        HeadingLbl.font = UIFont(name: boldCustomFont, size: 22.0)
        enterPinlbl.font = UIFont(name: regularCustomFont, size: 14.0)
        reEnterPinLbl.font = UIFont(name: regularCustomFont, size: 14.0)
        errorLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
        errorLbl.textColor = themeColor
        
        firstTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        secondTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        thirdTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        foruthTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        fifthTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        sixthTF.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        
        firstTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        secondTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        thirdTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        foruthTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        fifthTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        sixthTFre.font = UIFont(name: semiBoldCustomFont, size: 20.0)
        
        firstTF.layer.cornerRadius = 4.0
        firstTF.layer.borderWidth = 1.0
        firstTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        firstTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        firstTF.clipsToBounds = true
        
        secondTF.layer.cornerRadius = 4.0
        secondTF.layer.borderWidth = 1.0
        secondTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        secondTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        secondTF.clipsToBounds = true
        
        thirdTF.layer.cornerRadius = 4.0
        thirdTF.layer.borderWidth = 1.0
        thirdTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        thirdTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        thirdTF.clipsToBounds = true
        
        foruthTF.layer.cornerRadius = 4.0
        foruthTF.layer.borderWidth = 1.0
        foruthTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        foruthTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        foruthTF.clipsToBounds = true
        
        fifthTF.layer.cornerRadius = 4.0
        fifthTF.layer.borderWidth = 1.0
        fifthTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        fifthTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        fifthTF.clipsToBounds = true
        
        sixthTF.layer.cornerRadius = 4.0
        sixthTF.layer.borderWidth = 1.0
        sixthTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        sixthTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        sixthTF.clipsToBounds = true
        
        firstTFre.layer.cornerRadius = 4.0
        firstTFre.layer.borderWidth = 1.0
        firstTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        firstTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        firstTFre.clipsToBounds = true
        
        secondTFre.layer.cornerRadius = 4.0
        secondTFre.layer.borderWidth = 1.0
        secondTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        secondTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        secondTFre.clipsToBounds = true
        
        thirdTFre.layer.cornerRadius = 4.0
        thirdTFre.layer.borderWidth = 1.0
        thirdTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        thirdTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        thirdTFre.clipsToBounds = true
        
        foruthTFre.layer.cornerRadius = 4.0
        foruthTFre.layer.borderWidth = 1.0
        foruthTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        foruthTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        foruthTFre.clipsToBounds = true
        
        fifthTFre.layer.cornerRadius = 4.0
        fifthTFre.layer.borderWidth = 1.0
        fifthTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        fifthTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        fifthTFre.clipsToBounds = true
        
        sixthTFre.layer.cornerRadius = 4.0
        sixthTFre.layer.borderWidth = 1.0
        sixthTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        sixthTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        sixthTFre.clipsToBounds = true
        
        
        // Do any additional setup after loading the view.
        firstTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        secondTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        thirdTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        foruthTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        fifthTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        sixthTF.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        firstTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        secondTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        thirdTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        foruthTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        fifthTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        sixthTFre.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        
        if #available(iOS 11.0, *) {
            self.bgV.roundCorners([ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 0)
            
        } else {
            // Fallback on earlier versions
        }
        
        errorLbl.isHidden = true
        
        getData()
        
        submitBtn.backgroundColor = UIColor.init(hexString: btnBgColor)
        submitBtn.setTitleColor( UIColor.init(hexString:btnTextColor), for: .normal)
        submitBtn.layer.cornerRadius = 4.0
        submitBtn.clipsToBounds = true
        
        firstTF.isSecureTextEntry = false
        secondTF.isSecureTextEntry = false
        thirdTF.isSecureTextEntry = false
        foruthTF.isSecureTextEntry = false
        fifthTF.isSecureTextEntry = false
        sixthTF.isSecureTextEntry = false
        
        firstTFre.isSecureTextEntry = false
        secondTFre.isSecureTextEntry = false
        thirdTFre.isSecureTextEntry = false
        foruthTFre.isSecureTextEntry = false
        fifthTFre.isSecureTextEntry = false
        sixthTFre.isSecureTextEntry = false
    }
    
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "ResetPinViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //firstTF.becomeFirstResponder()
    }
    @IBAction func closeBtnAct(_ sender: Any) {
        self.view.endEditing(true)
        self.viewDelegate?.optionsButtonTapNewAction(text: "cancel", payload: "cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    func getData(){
        let jsonDic: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        print(jsonDic)
        let title = jsonDic["title"] as? String
        let enterpintitle = jsonDic["enterPinTitle"] as? String
        
        let renterPintitle = jsonDic["reEnterPinTitle"] as? String
        WarningMessage = jsonDic["warningMessage"] as? String ?? "Pin mismatch"
        errorMessage = jsonDic["errorMessage"] as? String ?? "Do not use repetitive numbers like 1234 or 1111."
        piiSuffix = jsonDic["piiSuffix"] as? String ?? jsonDic["piiReductionChar"] as? String ?? ""
        HeadingLbl.text = title
        if let pintitle = enterpintitle{
            enterPinlbl.text = pintitle
        }
        if let reenterPinTitle = renterPintitle{
            reEnterPinLbl.text = reenterPinTitle
        }
        
        if let enterTitle = jsonDic["enterTitle"] as? String{
            enterPinlbl.text = enterTitle
        }
        if let reEnterTitle = jsonDic["reEnterTitle"] as? String{
            reEnterPinLbl.text = reEnterTitle
        }
        
        if let otpBtns = jsonDic["resetButtons"] as? Array<[String: Any]>{
            if otpBtns.count > 0{
                if let btns = otpBtns[0] as? [String: Any] {
                    let btnTitle = btns["title"] as? String ?? "Reset Pin"
                    submitBtn.setTitle(btnTitle, for: .normal)
                }
            }
        }
        
        if let pinLength = jsonDic["pinLength"] as? Int, pinLength == 4{
            isPinLengthSix = false
            fifthTF.isHidden = true
            sixthTF.isHidden = true
            
            fifthTFre.isHidden = true
            sixthTFre.isHidden = true
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("TextField did begin editing method called")
        if firstTF == textField || secondTF == textField || thirdTF == textField || foruthTF == textField || fifthTF == textField || sixthTF == textField{
            textfeildViews = "EnterPinV"
        }else{
            textfeildViews = "ReEnterPinV"
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        firstTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        firstTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        firstTF.layer.borderWidth = 1.0
        secondTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        secondTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        secondTF.layer.borderWidth = 1.0
        thirdTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        thirdTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        thirdTF.layer.borderWidth = 1.0
        foruthTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        foruthTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        foruthTF.layer.borderWidth = 1.0
        fifthTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        fifthTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        fifthTF.layer.borderWidth = 1.0
        sixthTF.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        sixthTF.backgroundColor = UIColor.init(hexString: tfBgColor)
        sixthTF.layer.borderWidth = 1.0
        
        firstTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        firstTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        firstTFre.layer.borderWidth = 1.0
        secondTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        secondTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        secondTFre.layer.borderWidth = 1.0
        thirdTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        thirdTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        thirdTFre.layer.borderWidth = 1.0
        foruthTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        foruthTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        foruthTFre.layer.borderWidth = 1.0
        fifthTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        fifthTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        fifthTFre.layer.borderWidth = 1.0
        sixthTFre.layer.borderColor = UIColor.init(hexString: tfBorderColor).cgColor
        sixthTFre.backgroundColor = UIColor.init(hexString: tfBgColor)
        sixthTFre.layer.borderWidth = 1.0
        
        
        switch textField{
        case firstTF:
            firstTF.layer.borderColor = themeColor.cgColor
            firstTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            firstTF.layer.borderWidth = 2.0
        case secondTF:
            secondTF.layer.borderColor = themeColor.cgColor
            secondTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            secondTF.layer.borderWidth = 2.0
        case thirdTF:
            thirdTF.layer.borderColor = themeColor.cgColor
            thirdTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            thirdTF.layer.borderWidth = 2.0
        case foruthTF:
            foruthTF.layer.borderColor = themeColor.cgColor
            foruthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            foruthTF.layer.borderWidth = 2.0
        case fifthTF:
            fifthTF.layer.borderColor = themeColor.cgColor
            fifthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            fifthTF.layer.borderWidth = 2.0
        case sixthTF:
            sixthTF.layer.borderColor = themeColor.cgColor
            sixthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            sixthTF.layer.borderWidth = 2.0
            
        case firstTFre:
            firstTFre.layer.borderColor = themeColor.cgColor
            firstTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            firstTFre.layer.borderWidth = 2.0
        case secondTFre:
            secondTFre.layer.borderColor = themeColor.cgColor
            secondTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            secondTFre.layer.borderWidth = 2.0
        case thirdTFre:
            thirdTFre.layer.borderColor = themeColor.cgColor
            thirdTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            thirdTFre.layer.borderWidth = 2.0
        case foruthTFre:
            foruthTFre.layer.borderColor = themeColor.cgColor
            foruthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            foruthTFre.layer.borderWidth = 2.0
        case fifthTFre:
            fifthTFre.layer.borderColor = themeColor.cgColor
            fifthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            fifthTFre.layer.borderWidth = 2.0
        case sixthTFre:
            sixthTFre.layer.borderColor = themeColor.cgColor
            sixthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
            sixthTFre.layer.borderWidth = 2.0
        default:
            break
        }
        return true
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text
        if textfeildViews == "EnterPinV"{
            if isPinLengthSix{ //6 textfeilds
                if  text?.count == 1 {
                    switch textField{
                    case firstTF:
                        secondTF.layer.borderColor = themeColor.cgColor
                        secondTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        secondTF.layer.borderWidth = 2.0
                        secondTF.becomeFirstResponder()
                    case secondTF:
                        thirdTF.layer.borderColor = themeColor.cgColor
                        thirdTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        thirdTF.layer.borderWidth = 2.0
                        thirdTF.becomeFirstResponder()
                    case thirdTF:
                        foruthTF.layer.borderColor = themeColor.cgColor
                        foruthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        foruthTF.layer.borderWidth = 2.0
                        foruthTF.becomeFirstResponder()
                    case foruthTF:
                        fifthTF.layer.borderColor = themeColor.cgColor
                        fifthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        fifthTF.layer.borderWidth = 2.0
                        fifthTF.becomeFirstResponder()
                    case fifthTF:
                        sixthTF.layer.borderColor = themeColor.cgColor
                        sixthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        sixthTF.layer.borderWidth = 2.0
                        sixthTF.becomeFirstResponder()
                    case sixthTF:
                        sixthTF.becomeFirstResponder()
                        firstTFre.layer.borderColor = themeColor.cgColor
                        firstTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTFre.layer.borderWidth = 2.0
                        firstTFre.becomeFirstResponder()
                    default:
                        break
                    }
                }
                if  text?.count == 0 {
                    switch textField{
                    case firstTF:
                        firstTF.layer.borderColor = themeColor.cgColor
                        firstTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTF.layer.borderWidth = 2.0
                        firstTF.becomeFirstResponder()
                    case secondTF:
                        firstTF.layer.borderColor = themeColor.cgColor
                        firstTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTF.layer.borderWidth = 2.0
                        firstTF.becomeFirstResponder()
                    case thirdTF:
                        secondTF.layer.borderColor = themeColor.cgColor
                        secondTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        secondTF.layer.borderWidth = 2.0
                        secondTF.becomeFirstResponder()
                    case foruthTF:
                        thirdTF.layer.borderColor = themeColor.cgColor
                        thirdTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        thirdTF.layer.borderWidth = 2.0
                        thirdTF.becomeFirstResponder()
                    case fifthTF:
                        foruthTF.layer.borderColor = themeColor.cgColor
                        foruthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        foruthTF.layer.borderWidth = 2.0
                        foruthTF.becomeFirstResponder()
                    case sixthTF:
                        fifthTF.layer.borderColor = themeColor.cgColor
                        fifthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        fifthTF.layer.borderWidth = 2.0
                        fifthTF.becomeFirstResponder()
                    default:
                        break
                    }
                }
            }else{
                if  text?.count == 1 {
                    switch textField{
                    case firstTF:
                        secondTF.layer.borderColor = themeColor.cgColor
                        secondTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        secondTF.layer.borderWidth = 2.0
                        secondTF.becomeFirstResponder()
                    case secondTF:
                        thirdTF.layer.borderColor = themeColor.cgColor
                        thirdTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        thirdTF.layer.borderWidth = 2.0
                        thirdTF.becomeFirstResponder()
                    case thirdTF:
                        foruthTF.layer.borderColor = themeColor.cgColor
                        foruthTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        foruthTF.layer.borderWidth = 2.0
                        foruthTF.becomeFirstResponder()
                    case foruthTF:
                        foruthTF.becomeFirstResponder()
                        firstTFre.layer.borderColor = themeColor.cgColor
                        firstTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTFre.layer.borderWidth = 2.0
                        firstTFre.becomeFirstResponder()
                        //self.view.endEditing(true)
                    default:
                        break
                    }
                }
                if  text?.count == 0 {
                    switch textField{
                    case firstTF:
                        firstTF.layer.borderColor = themeColor.cgColor
                        firstTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTF.layer.borderWidth = 2.0
                        firstTF.becomeFirstResponder()
                    case secondTF:
                        firstTF.layer.borderColor = themeColor.cgColor
                        firstTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTF.layer.borderWidth = 2.0
                        firstTF.becomeFirstResponder()
                    case thirdTF:
                        secondTF.layer.borderColor = themeColor.cgColor
                        secondTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        secondTF.layer.borderWidth = 2.0
                        secondTF.becomeFirstResponder()
                    case foruthTF:
                        thirdTF.layer.borderColor = themeColor.cgColor
                        thirdTF.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        thirdTF.layer.borderWidth = 2.0
                        thirdTF.becomeFirstResponder()
                    default:
                        break
                    }
                }
            }
            
            
        }else{ //ReEnterPinV
            if isPinLengthSix{ //6 textfeilds
                if  text?.count == 1 {
                    switch textField{
                    case firstTFre:
                        secondTFre.layer.borderColor = themeColor.cgColor
                        secondTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        secondTFre.layer.borderWidth = 2.0
                        secondTFre.becomeFirstResponder()
                    case secondTFre:
                        thirdTFre.layer.borderColor = themeColor.cgColor
                        thirdTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        thirdTFre.layer.borderWidth = 2.0
                        thirdTFre.becomeFirstResponder()
                    case thirdTFre:
                        foruthTFre.layer.borderColor = themeColor.cgColor
                        foruthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        foruthTFre.layer.borderWidth = 2.0
                        foruthTFre.becomeFirstResponder()
                    case foruthTFre:
                        fifthTFre.layer.borderColor = themeColor.cgColor
                        fifthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        fifthTFre.layer.borderWidth = 2.0
                        fifthTFre.becomeFirstResponder()
                    case fifthTFre:
                        sixthTFre.layer.borderColor = themeColor.cgColor
                        sixthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        sixthTFre.layer.borderWidth = 2.0
                        sixthTFre.becomeFirstResponder()
                    case sixthTFre:
                        sixthTFre.layer.borderColor = themeColor.cgColor
                        sixthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        sixthTFre.layer.borderWidth = 2.0
                        sixthTFre.becomeFirstResponder()
                    default:
                        break
                    }
                }
                if  text?.count == 0 {
                    switch textField{
                    case firstTFre:
                        firstTFre.layer.borderColor = themeColor.cgColor
                        firstTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTFre.layer.borderWidth = 2.0
                        firstTFre.becomeFirstResponder()
                    case secondTFre:
                        firstTFre.layer.borderColor = themeColor.cgColor
                        firstTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTFre.layer.borderWidth = 2.0
                        firstTFre.becomeFirstResponder()
                    case thirdTFre:
                        secondTFre.layer.borderColor = themeColor.cgColor
                        secondTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        secondTFre.layer.borderWidth = 2.0
                        secondTFre.becomeFirstResponder()
                    case foruthTFre:
                        thirdTFre.layer.borderColor = themeColor.cgColor
                        thirdTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        thirdTFre.layer.borderWidth = 2.0
                        thirdTFre.becomeFirstResponder()
                    case fifthTFre:
                        foruthTFre.layer.borderColor = themeColor.cgColor
                        foruthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        foruthTFre.layer.borderWidth = 2.0
                        foruthTFre.becomeFirstResponder()
                    case sixthTFre:
                        fifthTFre.layer.borderColor = themeColor.cgColor
                        fifthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        fifthTFre.layer.borderWidth = 2.0
                        fifthTFre.becomeFirstResponder()
                    default:
                        break
                    }
                }
            }else{ //4 textfeilds
                if  text?.count == 1 {
                    switch textField{
                    case firstTFre:
                        secondTFre.layer.borderColor = themeColor.cgColor
                        secondTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        secondTFre.layer.borderWidth = 2.0
                        secondTFre.becomeFirstResponder()
                    case secondTFre:
                        thirdTFre.layer.borderColor = themeColor.cgColor
                        thirdTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        thirdTFre.layer.borderWidth = 2.0
                        thirdTFre.becomeFirstResponder()
                    case thirdTFre:
                        foruthTFre.layer.borderColor = themeColor.cgColor
                        foruthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        foruthTFre.layer.borderWidth = 2.0
                        foruthTFre.becomeFirstResponder()
                    case foruthTFre:
                        foruthTFre.layer.borderColor = themeColor.cgColor
                        foruthTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        foruthTFre.layer.borderWidth = 2.0
                        foruthTFre.becomeFirstResponder()
                        //self.dismissKeyboard()
                    default:
                        break
                    }
                }
                if  text?.count == 0 {
                    switch textField{
                    case firstTFre:
                        firstTFre.layer.borderColor = themeColor.cgColor
                        firstTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTFre.layer.borderWidth = 2.0
                        firstTFre.becomeFirstResponder()
                    case secondTFre:
                        firstTFre.layer.borderColor = themeColor.cgColor
                        firstTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        firstTFre.layer.borderWidth = 2.0
                        firstTFre.becomeFirstResponder()
                    case thirdTFre:
                        secondTFre.layer.borderColor = themeColor.cgColor
                        secondTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        secondTFre.layer.borderWidth = 2.0
                        secondTFre.becomeFirstResponder()
                    case foruthTFre:
                        thirdTFre.layer.borderColor = themeColor.cgColor
                        thirdTFre.backgroundColor = UIColor.init(hexString: tfSelectedBgColor)
                        thirdTFre.layer.borderWidth = 2.0
                        thirdTFre.becomeFirstResponder()
                    default:
                        break
                    }
                }
            }
        }
        
    }
    
    func dismissKeyboard(){
        var otpText = ""
        var otpReText = ""
        if isPinLengthSix{
            otpText = "\(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.foruthTF.text ?? "")\(self.fifthTF.text ?? "")\(self.sixthTF.text ?? "")"
            otpReText = "\(self.firstTFre.text ?? "")\(self.secondTFre.text ?? "")\(self.thirdTFre.text ?? "")\(self.foruthTFre.text ?? "")\(self.fifthTFre.text ?? "")\(self.sixthTFre.text ?? "")"
        }else{
            otpText = "\(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.foruthTF.text ?? "")"
            otpReText = "\(self.firstTFre.text ?? "")\(self.secondTFre.text ?? "")\(self.thirdTFre.text ?? "")\(self.foruthTFre.text ?? "")"
        }
        let rules: [ValidationRule] = []//[ FourDigitNumberRule(), NoConsecutiveDigitsRule() ] //, NotYearRule(), NonRepeatRule()
        let test = [ otpText ]
        var isValid = "invalid"
        for string in test {
            isValid = string.isValid(rules: rules) ? "valid" : "invalid"
        }
        if otpText != otpReText{
            showErrorLbl(message: WarningMessage)
        }else if isValid == "invalid" {
            showErrorLbl(message: errorMessage)
        }
        else{
            self.view.endEditing(true)
            let secureTxt = otpText.regEx()
            self.viewDelegate?.optionsButtonTapNewAction(text: secureTxt, payload: "\(otpText)\(piiSuffix)")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func showErrorLbl(message:String){
        firstTF.text = ""
        secondTF.text = ""
        thirdTF.text = ""
        foruthTF.text = ""
        fifthTF.text = ""
        sixthTF.text = ""
        
        firstTFre.text = ""
        secondTFre.text = ""
        thirdTFre.text = ""
        foruthTFre.text = ""
        fifthTFre.text = ""
        sixthTFre.text = ""
        firstTF.becomeFirstResponder()
        
        errorLbl.text = message
        errorLbl.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
            self.errorLbl.isHidden = true
        }
    }
    
    
    @IBAction func submitBtnAct(_ sender: Any) {
        self.dismissKeyboard()
    }
    
}

protocol ValidationRule {
    
    func isValid(for number: Int) -> Bool
}

class FourDigitNumberRule: ValidationRule {
    let allowedRange = 1000...9999
    func isValid(for number: Int) -> Bool {
        return allowedRange.contains(number)
    }
}

class NoConsecutiveDigitsRule: ValidationRule {
    func isValid(for number: Int) -> Bool {
        let coef = 10
        var remainder = number
        var curr: Int? = nil
        var prev: Int? = nil
        var diff: Int?
        
        while remainder > 0 {
            
            defer { remainder = Int(remainder / coef) }
            prev = curr
            curr = remainder % coef
            guard let p = prev, let c = curr else { continue }
            let lastDiff = diff
            diff = p - c
            guard let ld = lastDiff else { continue }
            if ld != diff { return true }
            if diff != 1 && diff != -1 { return true }
        }
        return false
    }
}

class NotYearRule: ValidationRule {
    
    func isValid(for number: Int) -> Bool {
        let hundreds = number / 100
        if hundreds == 19 || hundreds == 20 {
            return false
        }
        return true
    }
}

class NonRepeatRule: ValidationRule {
    
    func isValid(for number: Int) -> Bool {
        let coef = 10
        var map = [Int: Int]()
        for i in 0...9 {
            
            map[i] = 0
        }
        var remainder = number
        while remainder > 0 {
            let i = remainder % coef
            map[i]! += 1
            remainder = Int(remainder / coef)
        }
        for i in 0...9 {
            if map[i]! > 2 { return false }
        }
        return true
    }
}

extension String {
    
    func isValid(rules: [ValidationRule]) -> Bool {
        
        guard let number = Int(self) else { return false }
        
        for rule in rules {
            
            if !rule.isValid(for: number) { return false }
        }
        
        return true
    }
}
