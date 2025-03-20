//
//  EmptyBubbleView.swift
//  KoreBotSDK
//
//  Created by Kartheek Pagidimarri on 02/04/24.
//

import UIKit

class EmptyBubbleView: BubbleView{
        var tileBgv: UIView!
        var titleLbl: UILabel!
        var cardView: UIView!
        let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
        let kMinTextWidth: CGFloat = 20.0
       
        override func applyBubbleMask() {
            //nothing to put here
            if(self.maskLayer == nil){
                self.maskLayer = CAShapeLayer()
            
            }
            self.maskLayer.path = self.createBezierPath().cgPath
            self.maskLayer.position = CGPoint(x:0, y:0)
        }
        
        override var tailPosition: BubbleMaskTailPosition! {
            didSet {
                self.backgroundColor = .clear
            }
        }
        
        override func initialize() {
            super.initialize()
           // UserDefaults.standard.set(false, forKey: "SliderKey")
            intializeCardLayout()
            
           self.tileBgv = UIView(frame:.zero)
            self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
            self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
            self.tileBgv.layer.shouldRasterize = true
            self.tileBgv.layer.cornerRadius = 10.0
            self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
            self.tileBgv.clipsToBounds = true
            self.tileBgv.layer.borderWidth = 1.0
            self.cardView.addSubview(self.tileBgv)
            self.tileBgv.backgroundColor = BubbleViewLeftTint
            if #available(iOS 11.0, *) {
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 1.5)
            }
            
            let views: [String: UIView] = ["tileBgv": tileBgv]
                   self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
            self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]", options: [], metrics: nil, views: views))
                 
            self.titleLbl = UILabel(frame: CGRect.zero)
            self.titleLbl.textColor = BubbleViewBotChatTextColor
            self.titleLbl.font = UIFont(name: mediumCustomFont, size: 16.0)
            self.titleLbl.numberOfLines = 0
            self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.titleLbl.isUserInteractionEnabled = true
            self.titleLbl.contentMode = UIView.ContentMode.topLeft
            self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
            self.tileBgv.addSubview(self.titleLbl)
            self.titleLbl.adjustsFontSizeToFitWidth = true
            self.titleLbl.backgroundColor = .clear
            self.titleLbl.layer.cornerRadius = 6.0
            self.titleLbl.clipsToBounds = true
            self.titleLbl.sizeToFit()
            
            let subView: [String: UIView] = ["titleLbl": titleLbl]
            let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
            self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLbl]-10-|", options: [], metrics: metrics, views: subView))
            self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-16-|", options: [], metrics: metrics, views: subView))
        }
        
        func intializeCardLayout(){
            self.cardView = UIView(frame:.zero)
            self.cardView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.cardView)
            cardView.backgroundColor =  UIColor.clear
            let cardViews: [String: UIView] = ["cardView": cardView]
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
            
        }
        
        // MARK: populate components
        override func populateComponents() {
            self.tileBgv.layer.borderWidth = 0.0
            if (components.count > 0) {
                 let component: KREComponent = components.firstObject as! KREComponent
                if (component.componentDesc != nil) {
                    let jsonString = component.componentDesc
                    let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                    let jsonDecoder = JSONDecoder()
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                        let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                                                    return
                        }
                    self.titleLbl.text = allItems.text_message ?? "Template not available"
                }
            }
        }
        
        //MARK: View height calculation
        override var intrinsicContentSize : CGSize {
            
            let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
            var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
            if textSize.height < self.titleLbl.font.pointSize {
                textSize.height = self.titleLbl.font.pointSize
            }
            return CGSize(width: 0.0, height: textSize.height)
        }
    }
