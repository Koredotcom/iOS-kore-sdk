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
    
    var tableView: UITableView!
    fileprivate let cellIdentifier = "InlineFormTableViewCell"
    var footerButtonTitle:NSString?
    
    var headingLabel: KREAttributedLabel!
    var textfeilds: Array<Dictionary<String, Any>> = []
    //var titleLbl: UILabel!
    var textFBgV: UIView!
    var inlineTextField: UITextField!
    var inlineButton: UIButton!
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font : UIFont(name: "Gilroy-Medium", size: 15.0) as Any,
    NSAttributedString.Key.foregroundColor : BubbleViewBotChatTextColor]
    var arrayOfTextFieldsText = NSMutableArray()
    
    override func prepareForReuse() {
        arrayOfTextFieldsText = []
    }
    
    override func initialize() {
        super.initialize()
        
        self.headingLabel = KREAttributedLabel(frame: CGRect.zero)
        self.headingLabel.textColor = BubbleViewBotChatTextColor
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
        
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        self.tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        let views: [String: UIView] = ["headingLabel": headingLabel, "tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headingLabel]-10-[tableView]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headingLabel]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))
        
        
        
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                textfeilds = jsonObject["formFields"] != nil ? jsonObject["formFields"] as! Array<Dictionary<String, Any>> : []
                arrayOfTextFieldsText = []
                for _ in 0..<textfeilds.count{
                    arrayOfTextFieldsText.add("")
                }
                var headerText: String = jsonObject["heading"] != nil ? jsonObject["heading"] as! String : ""
                headerText = KREUtilities.formatHTMLEscapedString(headerText);
                
                if(headerText.count > InLineFormBubbleView.headerTextLimit){
                    headerText = String(headerText[..<headerText.index(headerText.startIndex, offsetBy: InLineFormBubbleView.headerTextLimit)]) + "..."
                }
                self.headingLabel.setHTMLString(headerText, withWidth: BubbleViewMaxWidth - 20)
                if jsonObject["fieldButton"] != nil {
                    let btnTitle = (jsonObject["fieldButton"] as AnyObject).object(forKey: "title") != nil ? ((jsonObject["fieldButton"] as AnyObject).object(forKey: "title") as! String) : ""
                    footerButtonTitle = btnTitle as NSString
                }
                
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let headingLabelSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        var tableviewHeight: CGFloat = 0.0
        for _ in 0..<textfeilds.count{
            tableviewHeight += 70.0
        }
        return CGSize(width: BubbleViewMaxWidth-60, height: headingLabelSize.height + tableviewHeight + 40)
    }
    
    @objc func tapsOnInlineFormBtn(_ sender:UIButton) {

        var isempty = false
        var isSecure = false
        var finalString = ""
        var secureString = ""
        for i in 0..<arrayOfTextFieldsText.count{
            if arrayOfTextFieldsText[i] as! String == "" {
                isempty = true
            }else{
                let dictionary = textfeilds[i]
                let formFeildType: String = dictionary["type"] != nil ? dictionary["type"] as! String : ""
                let textStr = arrayOfTextFieldsText[i] as? String
                if formFeildType == "password"{
                    let secureTxt = textStr?.regEx()
                    finalString.append("\(formFeildType): \(textStr!) ")
                    secureString.append("\(formFeildType): \(secureTxt!) ")
                    isSecure = true
                }else{
                    finalString.append("\(formFeildType): \(textStr!) ")
                    secureString.append("\(formFeildType): \(textStr!) ")
                }
            }
        }
        
        if !isempty{
            for i in 0..<arrayOfTextFieldsText.count{
                let indexPath = IndexPath(row: i, section: sender.tag)
                let cell = tableView.cellForRow(at: indexPath) as! InlineFormTableViewCell
                cell.textFeildName.resignFirstResponder()
                arrayOfTextFieldsText.replaceObject(at: i, with: "")
            }
            tableView.reloadData()
            if isSecure {
                self.optionsAction(secureString, finalString)
            }else{
                self.optionsAction(finalString, finalString)
            }
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

extension InLineFormBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textfeilds.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : InlineFormTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! InlineFormTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let dictionary = textfeilds[indexPath.row]
        let title: String = dictionary["label"] != nil ? dictionary["label"] as! String : ""
        let placeHolder: String = dictionary["placeholder"] != nil ? dictionary["placeholder"] as! String : ""
        let formFeildType: String = dictionary["type"] != nil ? dictionary["type"] as! String : ""
        cell.tiltLbl.text = "\(title) :"
        cell.textFeildName.placeholder = placeHolder
        
        cell.tiltLbl .textColor = BubbleViewBotChatTextColor
        cell.textFeildName.borderStyle = .bezel
        if formFeildType == "password"{
            cell.textFeildName.isSecureTextEntry = true
        }else{
            cell.textFeildName.isSecureTextEntry = false
        }
        cell.textFeildName.backgroundColor = .white
        cell.textFeildName.delegate = self
        cell.textFeildName.text = arrayOfTextFieldsText[indexPath.row] as? String
        cell.textFeildName.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        cell.textFeildName.tag = indexPath.row
        cell.textFeildName.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.clear,
            NSAttributedString.Key.font : UIFont(name: "Gilroy-Medium", size: 15)!
        ]
        cell.textFeildName.attributedPlaceholder = NSAttributedString(string: "", attributes:attributes)
        return cell
        
    }
     @objc func valueChanged(_ textField: UITextField){
        arrayOfTextFieldsText.replaceObject(at: textField.tag, with: textField.text ?? "")
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        let sendButton = UIButton(frame: CGRect.zero)
        sendButton.backgroundColor = BubbleViewRightTint
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.clipsToBounds = true
        sendButton.layer.cornerRadius = 5
        sendButton.setTitleColor(BubbleViewBotChatTextColor, for: .normal)
        sendButton.titleLabel?.font = UIFont(name: "Gilroy-Bold", size: 14.0)!
        view.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(self.tapsOnInlineFormBtn(_:)), for: .touchUpInside)
        sendButton.tag = section
        let attributeString = NSMutableAttributedString(string: (footerButtonTitle ?? "Send") as String,
                                                                   attributes: yourAttributes)
                   sendButton.setAttributedTitle(attributeString, for: .normal)
        
        let views: [String: UIView] = ["sendButton": sendButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[sendButton(30)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[sendButton]-10-|", options:[], metrics:nil, views:views))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  40
    }
}
