//
//  SearchGridTemplate.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 02/04/24.
//  Copyright © 2024 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

class SearchGridTemplate: BubbleView {
    let BubbleViewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 90.0)

    lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.contentMode = .scaleAspectFit
        textLabel.isHidden = false
        textLabel.textColor = .black
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public override func initialize() {
         super.initialize()
        
       
        self.addSubview(self.textLabel)
        
       
        let views: [String: UIView] = ["textLabel": textLabel]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textLabel]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel]-10-|", options: [], metrics: nil, views: views))
    }
    
   
    
    // MARK: populate components
     override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
               //print(jsonObject)
                let text = jsonObject["text"] ?? "sample text New template"
                let headerText = "\(text)"
                self.textLabel.text = headerText
            }
        }
    }

     override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let textSize: CGSize = self.textLabel.sizeThatFits(limitingSize)
        return CGSize(width: BubbleViewMaxWidth, height: textSize.height + 20)
    }

}
