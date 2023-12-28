//
//  DropDownBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 20/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import ChatBotObjc
class DropDownBubbleView: BubbleView {
    static let buttonsLimit: Int = 3
    static let headerTextLimit: Int = 640
    
    var headingLabel: KREAttributedLabel!
    var textFBgV: UIView!
    var inlineTextField: UITextField!
    var inlineButton: UIButton!
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    
    let dropDown = DropDown()
          lazy var dropDowns: [DropDown] = {
              return [
                  self.dropDown
              ]
          }()
    
    var arrayOfComponents = [ComponentElements]()
    var arrayOfElements = NSMutableArray()
    
    override func prepareForReuse() {
        inlineTextField.text = ""
    }
    
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
        self.textFBgV.layer.cornerRadius = 2.0
        self.textFBgV.layer.borderWidth = 1.0
        self.textFBgV.layer.borderColor = UIColor.gray.cgColor
        self.textFBgV.clipsToBounds = true
        self.textFBgV.backgroundColor = .white
        self.textFBgV.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textFBgV)
    
        
        let views: [String: UIView] = ["headingLabel": headingLabel, "textFBgV": textFBgV]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headingLabel]-5-[textFBgV(40)]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headingLabel]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[textFBgV]-15-|", options: [], metrics: nil, views: views))
        
        self.inlineTextField = UITextField(frame: CGRect.zero)
        self.inlineTextField.borderStyle = .none
        self.inlineTextField.isSecureTextEntry = false
        inlineTextField.text = ""
        self.inlineTextField.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font : UIFont(name: mediumCustomFont, size: 14) ?? UIFont.systemFont(ofSize: 14.0)
        ]
        self.inlineTextField.attributedPlaceholder = NSAttributedString(string: "Select", attributes:attributes)
        self.textFBgV.addSubview(self.inlineTextField)
        
        self.inlineButton = UIButton(frame: CGRect.zero)
        self.inlineButton.translatesAutoresizingMaskIntoConstraints = false
        self.inlineButton.clipsToBounds = true
        self.inlineButton.setImage(UIImage.init(named: "downarrow"), for: .normal)
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
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let str = jsonObject["heading"] != nil ? jsonObject["heading"] as! String : ""
                var headerText: String = str.replacingOccurrences(of: "\n", with: "")
                headerText = KREUtilities.formatHTMLEscapedString(headerText);
                
                if(headerText.count > InLineFormBubbleView.headerTextLimit){
                    headerText = String(headerText[..<headerText.index(headerText.startIndex, offsetBy: InLineFormBubbleView.headerTextLimit)]) + "..."
                }
                self.headingLabel.setHTMLString(headerText, withWidth: BubbleViewMaxWidth - 20)
                
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
                ConfigureDropDownView()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        return CGSize(width: BubbleViewMaxWidth-60, height: headingLabelSize.height + 80)
    }
    
    @objc func tapsOnInlineFormBtn(_ sender:UIButton) {
        dropDown.show()
    }
    
}
extension DropDownBubbleView {
    func ConfigureDropDownView(){
        //DropDown
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        dropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        dropDown.selectionBackgroundColor = .clear//UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        dropDown.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        dropDown.cornerRadius = 10
        dropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        dropDown.shadowOpacity = 0.9
        dropDown.shadowRadius = 25
        dropDown.animationduration = 0.25
        dropDown.textColor = .darkGray
        setupColorDropDown()
    }
    // MARK: Setup DropDown
    func setupColorDropDown() {
        dropDown.anchorView = inlineButton
        dropDown.bottomOffset = CGPoint(x: 0, y: inlineButton.bounds.height)
        dropDown.dataSource = arrayOfElements as! [String]
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self!.inlineTextField.text = item
            NotificationCenter.default.post(name: Notification.Name(dropDownTemplateNotification), object: item)
        }
        
    }
}
