//
//  CarouselBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by anoop on 23/05/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import KoreWidgets

class CarouselBubbleView: BubbleView {
    
    let viewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 80.0)
    
    var carouselView: KRECarouselView!
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override init() {
        super.init()
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialize() {
        super.initialize()
        self.backgroundColor = UIColor.clear
        
        self.carouselView = KRECarouselView(frame: CGRect.zero)
        self.addSubview(self.carouselView)
        let views: [String: UIView] = ["carouselView": carouselView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[carouselView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[carouselView]|", options: [], metrics: nil, views: views))
        
        self.carouselView.optionsAction = {[weak self] (text) in
            if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
        self.carouselView.linkAction = {[weak self] (text) in
            if(self?.linkAction != nil){
                self?.linkAction(text)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func borderColor() -> UIColor {
        return UIColor.clear
    }
    
    override var components: NSArray! {
        didSet {
            self.prepareForReuse()
            if (components.count > 0) {
                let component: KREComponent = components.firstObject as! KREComponent
                if (component.componentDesc != nil) {
                    let jsonString = component.componentDesc
                    let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                    let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] as! Array<Dictionary<String, Any>>
                    self.carouselView.initializeViewForElements(elements: elements, maxWidth: viewMaxWidth)
                }
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0.0, height: self.carouselView.maxHeight)
    }
    
    override func prepareForReuse() {
        self.carouselView.prepareForReuse()
    }
}
