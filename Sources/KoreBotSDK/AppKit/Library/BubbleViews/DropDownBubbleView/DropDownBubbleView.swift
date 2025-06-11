//
//  DropDownBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 20/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
#if SWIFT_PACKAGE
import ObjcSupport
#endif
class DropDownBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    static let buttonsLimit: Int = 3
    static let headerTextLimit: Int = 640
    
    var headingLabel: KREAttributedLabel!
    var textFBgV: UIView!
    var inlineTextField: UITextField!
    var inlineButton: UIButton!
    //public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    
    let dropDown = DropDown()
          lazy var dropDowns: [DropDown] = {
              return [
                  self.dropDown
              ]
          }()
    
    var arrayOfComponents = [ComponentElements]()
    var arrayOfElements = NSMutableArray()
    var seletedValue = ""
    public var maskview: UIView!
    override func prepareForReuse() {
        inlineTextField.text = ""
    }
    var messageId = ""
    var componentDescDic:[String:Any] = [:]
    let attributes = [
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.font : UIFont(name: regularCustomFont, size: 14) ?? UIFont.systemFont(ofSize: 14.0)
    ]
    override func initialize() {
        super.initialize()
        
        self.headingLabel = KREAttributedLabel(frame: CGRect.zero)
        self.headingLabel.textColor = BubbleViewBotChatTextColor
        self.headingLabel.backgroundColor = UIColor.clear
        self.headingLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.headingLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.headingLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.headingLabel.font = UIFont(name: mediumCustomFont, size: 16.0)
        self.headingLabel.numberOfLines = 0
        self.headingLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLabel.isUserInteractionEnabled = true
        self.headingLabel.contentMode = UIView.ContentMode.topLeft
        self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.headingLabel)
        
        
        self.textFBgV = UIView(frame: CGRect.zero)
        self.textFBgV.layer.cornerRadius = 5.0
        self.textFBgV.layer.borderWidth = 1.0
        self.textFBgV.layer.borderColor = UIColor.clear.cgColor
        self.textFBgV.clipsToBounds = true
        self.textFBgV.backgroundColor = .white
        self.textFBgV.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textFBgV)
        
        let footerBtn = UIButton(frame: CGRect.zero)
        footerBtn.backgroundColor = themeColor
        footerBtn.translatesAutoresizingMaskIntoConstraints = false
        footerBtn.clipsToBounds = true
        footerBtn.layer.cornerRadius = 5
        footerBtn.layer.borderColor = themeColor.cgColor
        footerBtn.layer.borderWidth = 1
        footerBtn.setTitleColor(.white, for: .normal)
        footerBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        footerBtn.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
        self.addSubview(footerBtn)
        footerBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        footerBtn.addTarget(self, action: #selector(self.footerBtnAction(_:)), for: .touchUpInside)
        footerBtn.setTitle("Submit", for: .normal)
    
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.maskview)
        self.maskview.isHidden = true
        self.maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["headingLabel": headingLabel, "textFBgV": textFBgV, "footerBtn": footerBtn, "maskview": maskview]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headingLabel]-5-[textFBgV(40)]-10-[footerBtn(35)]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headingLabel]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[textFBgV]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[footerBtn]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        self.inlineTextField = UITextField(frame: CGRect.zero)
        self.inlineTextField.borderStyle = .none
        self.inlineTextField.isSecureTextEntry = false
        inlineTextField.text = ""
        self.inlineTextField.translatesAutoresizingMaskIntoConstraints = false
        self.inlineTextField.attributedPlaceholder = NSAttributedString(string: "Select", attributes:attributes)
        self.textFBgV.addSubview(self.inlineTextField)
        
        self.inlineButton = UIButton(frame: CGRect.zero)
        self.inlineButton.translatesAutoresizingMaskIntoConstraints = false
        self.inlineButton.clipsToBounds = true
        let arrowimg = UIImage(named: "downarrow", in: bundle, compatibleWith: nil)
        self.inlineButton.setImage(arrowimg, for: .normal)
        self.inlineButton.layer.cornerRadius = 5
        self.inlineButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
        self.textFBgV.addSubview(self.inlineButton)
        self.inlineButton.contentHorizontalAlignment = .right
        inlineButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        
        inlineButton.addTarget(self, action: #selector(tapsOnInlineFormBtn), for: .touchUpInside)
        
        let subviews: [String: UIView] = ["inlineTextField": inlineTextField, "inlineButton": inlineButton]

        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[inlineTextField]-5-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[inlineButton]-0-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[inlineTextField]-5-|", options: [], metrics: nil, views: subviews))
        self.textFBgV.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[inlineButton]-0-|", options: [], metrics: nil, views: subviews))
        
    }
    @objc fileprivate func footerBtnAction(_ sender: AnyObject!) {
        if seletedValue != ""{
            insertSelectedValueIntoComponectDesc(value: seletedValue)
            self.optionsAction?(seletedValue,seletedValue)
            self.maskview.isHidden = false
        }
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                componentDescDic = jsonObject as! [String : Any]
                messageId = component.message?.messageId ?? ""
                
                let str = jsonObject["heading"] != nil ? jsonObject["heading"] as! String : ""
                var headerText: String = str.replacingOccurrences(of: "\n", with: "")
                if let text = KREUtilities.formatHTMLEscapedString(headerText) {
                    headerText = text
                }
                
                if(headerText.count > InLineFormBubbleView.headerTextLimit){
                    headerText = String(headerText[..<headerText.index(headerText.startIndex, offsetBy: InLineFormBubbleView.headerTextLimit)]) + "..."
                }
                let labelTxt = jsonObject["label"] != nil ? jsonObject["label"] as! String : ""
                if labelTxt == ""{
                    self.headingLabel.setHTMLString("*\(headerText)*", withWidth: BubbleViewMaxWidth - 20)
                }else{
                    self.headingLabel.setHTMLString("*\(headerText)* \n\n\(labelTxt)", withWidth: BubbleViewMaxWidth - 20)
                }
                
                
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                        return
                }
                arrayOfComponents = allItems.elements ?? []
                arrayOfElements = []
                for i in 0..<arrayOfComponents.count{
                    let elements = arrayOfComponents[i]
                    arrayOfElements.add(elements.title ?? "")
                }
                self.inlineTextField.attributedPlaceholder = NSAttributedString(string: "Select", attributes:attributes)
                if let slectedValue = jsonObject["selectedValue"] as? [String: Any]{
                    if let value = slectedValue["value"] as? String{
                        self.inlineTextField.attributedPlaceholder = NSAttributedString(string: value, attributes:attributes)
                    }
                }
                ConfigureDropDownView()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        let footerBtn = 50.0
        return CGSize(width: BubbleViewMaxWidth-60, height: headingLabelSize.height + 80 + footerBtn)
    }
    
    @objc func tapsOnInlineFormBtn(_ sender:UIButton) {
        dropDown.show()
    }
    func insertSelectedValueIntoComponectDesc(value: String){
        let dic = ["value": value]
        componentDescDic["selectedValue"] = dic
        self.updateMessage?(messageId, Utilities.stringFromJSONObject(object: componentDescDic))
    }
}
extension DropDownBubbleView {
    func ConfigureDropDownView(){
        //DropDown
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        dropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        dropDown.selectionBackgroundColor = BubbleViewLeftTint
        dropDown.separatorColor = .white//UIColor(white: 0.7, alpha: 0.8)
        dropDown.cornerRadius = 10
        dropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        dropDown.shadowOpacity = 0.9
        dropDown.shadowRadius = 25
        dropDown.animationduration = 0.25
        dropDown.textColor = BubbleViewBotChatTextColor
        setupColorDropDown()
    }
    // MARK: Setup DropDown
    func setupColorDropDown() {
        dropDown.anchorView = inlineButton
        dropDown.bottomOffset = CGPoint(x: 0, y: inlineButton.bounds.height)
        dropDown.dataSource = arrayOfElements as! [String]
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.inlineTextField.attributedPlaceholder = NSAttributedString(string: item, attributes:self?.attributes)
            self?.seletedValue = item
            //NotificationCenter.default.post(name: Notification.Name(dropDownTemplateNotification), object: item)
        }
        
    }
}
