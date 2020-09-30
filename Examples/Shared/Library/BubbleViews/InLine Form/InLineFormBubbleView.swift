//
//  InLineFormBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 05/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

class InLineFormBubbleView: BubbleView {
    static let buttonsLimit: Int = 3
    static let headerTextLimit: Int = 640
    
    var headingLabel: KREAttributedLabel!
    var titleLbl: UILabel!
    var textFBgV: UIView!
    var inlineTextField: UITextField!
    var inlineButton: UIButton!
     public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    
    override func initialize() {
        super.initialize()
        
        self.headingLabel = KREAttributedLabel(frame: CGRect.zero)
        self.headingLabel.textColor = Common.UIColorRGB(0x444444)
        self.headingLabel.backgroundColor = UIColor.clear
        self.headingLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.headingLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.headingLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.headingLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.headingLabel.numberOfLines = 0
        self.headingLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLabel.isUserInteractionEnabled = true
        self.headingLabel.contentMode = UIView.ContentMode.topLeft
        self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.headingLabel)
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x444444)
        self.titleLbl.backgroundColor = UIColor.clear
        self.titleLbl.font = UIFont(name: "HelveticaNeue-Regular", size: 20.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLbl)
        
        self.textFBgV = UIView(frame: CGRect.zero)
        self.textFBgV.layer.cornerRadius = 2.0
        self.textFBgV.layer.borderWidth = 1.0
        self.textFBgV.layer.borderColor = UIColor.gray.cgColor
        self.textFBgV.clipsToBounds = true
        self.textFBgV.backgroundColor = .white
        self.textFBgV.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textFBgV)
    
        
        let views: [String: UIView] = ["headingLabel": headingLabel, "titleLbl": titleLbl, "textFBgV": textFBgV]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headingLabel]-10-[titleLbl]-5-[textFBgV(40)]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headingLabel]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLbl]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[textFBgV]-15-|", options: [], metrics: nil, views: views))
        
        self.inlineTextField = UITextField(frame: CGRect.zero)
        self.inlineTextField.borderStyle = .none
        self.inlineTextField.isSecureTextEntry = true
        self.inlineTextField.delegate = self
        self.inlineTextField.text = ""
        self.inlineTextField.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Medium", size: 15)!
        ]
        self.inlineTextField.attributedPlaceholder = NSAttributedString(string: "", attributes:attributes)
        self.textFBgV.addSubview(self.inlineTextField)
        
        self.inlineButton = UIButton(frame: CGRect.zero)
        self.inlineButton.backgroundColor = .gray
        self.inlineButton.translatesAutoresizingMaskIntoConstraints = false
        self.inlineButton.clipsToBounds = true
        self.inlineButton.backgroundColor = userColor
        self.inlineButton.layer.cornerRadius = 5
        self.inlineButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.inlineButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.inlineButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.textFBgV.addSubview(self.inlineButton)
        inlineButton.addTarget(self, action: #selector(tapsOnInlineFormBtn), for: .touchUpInside)
        
        let subviews: [String: UIView] = ["inlineTextField": inlineTextField, "inlineButton": inlineButton]

        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[inlineTextField]-5-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[inlineButton]-5-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[inlineTextField]-5-[inlineButton(40)]-5-|", options: [], metrics: nil, views: subviews))
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let textfeilds: Array<Dictionary<String, Any>> = jsonObject["formFields"] != nil ? jsonObject["formFields"] as! Array<Dictionary<String, Any>> : []
                let textfeildsCount: Int = min(textfeilds.count, InLineFormBubbleView.buttonsLimit)
                for i in 0..<textfeildsCount {
                    let dictionary = textfeilds[i]
                    let title: String = dictionary["label"] != nil ? dictionary["label"] as! String : ""
                    let placeHolder: String = dictionary["placeholder"] != nil ? dictionary["placeholder"] as! String : ""
                    let btnTitle: String = (dictionary["fieldButton"] as AnyObject).object(forKey: "title") != nil ? ((dictionary["fieldButton"] as AnyObject).object(forKey: "title") as! String) : ""
                    self.titleLbl.text = "\(title) :"
                    self.inlineTextField.placeholder = placeHolder
                    self.inlineButton.setTitle(btnTitle, for: .normal)
                   
                }
              var headerText: String = jsonObject["heading"] != nil ? jsonObject["heading"] as! String : ""
                headerText = KREUtilities.formatHTMLEscapedString(headerText);
                
                if(headerText.count > InLineFormBubbleView.headerTextLimit){
                    headerText = String(headerText[..<headerText.index(headerText.startIndex, offsetBy: InLineFormBubbleView.headerTextLimit)]) + "..."
                }
                self.headingLabel.setHTMLString(headerText, withWidth: BubbleViewMaxWidth - 20)
                
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        let titleLblSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        return CGSize(width: BubbleViewMaxWidth-60, height: headingLabelSize.height + titleLblSize.height + 80)
    }
    
    @objc func tapsOnInlineFormBtn(_ sender:UIButton) {
        
        if !inlineTextField.text!.isEmpty{
            let secureTxt = inlineTextField.text?.regEx()
            self.optionsAction(secureTxt!, inlineTextField.text!)
            inlineTextField.resignFirstResponder()
            inlineTextField.text = ""
            
        }
    }
    
}
extension InLineFormBubbleView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
}
