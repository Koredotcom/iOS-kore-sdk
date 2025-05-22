//
//  SampleView1.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 01/04/24.
//  Copyright © 2024 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

 class SampleView1: BubbleView {
    var textLabel: UILabel!
    lazy var clickBtn: UIButton = {
        let clickBtn = UIButton(frame: .zero)
        clickBtn.setTitle("Help", for: .normal)
        clickBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        clickBtn.setTitleColor(.black, for: .normal)
        clickBtn.contentMode = .scaleAspectFit
        clickBtn.isHidden = false
        clickBtn.translatesAutoresizingMaskIntoConstraints = false
        return clickBtn
    }()
    lazy var linkBtn: UIButton = {
        let linkBtn = UIButton(frame: .zero)
        linkBtn.setTitle("link", for: .normal)
        linkBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        linkBtn.setTitleColor(.black, for: .normal)
        linkBtn.contentMode = .scaleAspectFit
        linkBtn.isHidden = false
        linkBtn.translatesAutoresizingMaskIntoConstraints = false
        return linkBtn
    }()
     let BubbleViewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 90.0)
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
     
     required init() {
         super.init()
     }
     
     @MainActor required init(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    public override func initialize() {
         super.initialize()
        
        self.textLabel = UILabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x444444)
        self.textLabel.backgroundColor = UIColor.clear
        self.textLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIView.ContentMode.topLeft
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textLabel)
        
        clickBtn.addTarget(self, action: #selector(clickBtnAct), for: .touchUpInside)
        self.addSubview(clickBtn)
        
        linkBtn.addTarget(self, action: #selector(linkBtnAct), for: .touchUpInside)
        self.addSubview(linkBtn)
       
        
        let views: [String: UIView] = ["textLabel": textLabel,"clickBtn": clickBtn ,"linkBtn":linkBtn]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textLabel]-0-[clickBtn(30)]-0-[linkBtn(30)]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[clickBtn]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[linkBtn]-10-|", options: [], metrics: nil, views: views))
    }
    
    @objc func clickBtnAct() {
        self.optionsAction?("help", "help")
    }
    @objc func linkBtnAct() {
        self.linkAction?("https://kore.ai/")
    }
    
    // MARK: populate components
     override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
               //print(jsonObject)
                let text = jsonObject["text"] ?? "sample text title here"
                let subText = jsonObject["subText"] ?? "sample text sub title here"
                let headerText = "\(text)\n" + "\(subText)"
                self.textLabel.text = headerText
            }
        }
    }
     override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let textSize: CGSize = self.textLabel.sizeThatFits(limitingSize)
        let buttonHeight = 60
        return CGSize(width: BubbleViewMaxWidth, height: textSize.height + 20 + CGFloat(buttonHeight))
    }
}
