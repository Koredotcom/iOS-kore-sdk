//
//  BubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 26/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

enum BubbleMaskTailPosition : Int {
    case none = 1, left = 2, right = 3
}

var BubbleViewRightTint: UIColor =  UIColor.init(hexString: "#4B4EDE")
let BubbleViewRightContrastTint: UIColor = Common.UIColorRGB(0xFFFFFF)
var BubbleViewLeftTint: UIColor = UIColor.init(hexString: "#F0F1F2")
let BubbleViewLeftContrastTint: UIColor = Common.UIColorRGB(0xBCBCBC)

var BubbleViewUserChatTextColor: UIColor = UIColor.init(hexString: "#FFFFFF")
var BubbleViewBotChatTextColor: UIColor = UIColor.init(hexString: "#000000")

let BubbleViewCurveRadius: CGFloat = 20.0
let BubbleViewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 90.0)

class BubbleView: UIView {
    var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = self.borderColor()
        }
    }
    var bubbleType: ComponentType!
    var didSelectComponentAtIndex:((Int) -> Void)!
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    
    var components:NSArray! {
        didSet(c) {
            self.populateComponents()
        }
    }
    
    var drawBorder: Bool = false
    
    // MARK: init
    init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: bubbleWithType
    static func bubbleWithType(_ bubbleType: ComponentType) -> BubbleView{
        var bubbleView: BubbleView!
        
        switch (bubbleType) {
        case .text:
            bubbleView = TextBubbleView()
            break
        case .image, .video:
            //.sdkModule
            //bubbleView = Bundle.main.loadNibNamed("MultiImageBubbleView", owner: self, options: nil)![0] as? BubbleView
            bubbleView = Bundle.sdkModule.loadNibNamed("MultiImageBubbleView", owner: self, options: nil)![0] as? BubbleView
            break
        case .audio:
            bubbleView = Bundle.sdkModule.loadNibNamed("AudioBubbleView", owner: self, options: nil)![0] as? BubbleView
            break
        case .options:
            bubbleView = OptionsBubbleView()
            break
        case .quickReply:
            bubbleView = QuickReplyBubbleView()
            break
        case .list:
            bubbleView = ListBubbleView()
            break
        case .carousel:
            bubbleView = CarouselBubbleView()
            break
        case .error:
            bubbleView = ErrorBubbleView()
            break
        case .chart:
            bubbleView = ChartBubbleView()
            break
        case .table:
            bubbleView = TableBubbleView()
            break
        case .minitable:
            bubbleView = MiniTableBubbleView()
            break
        case .responsiveTable:
            bubbleView = ResponsiveTableBubbleView()
            break
        case .menu:
            bubbleView = MenuBubbleView()
            break
        case .newList:
            bubbleView = NewListBubbleView()
            break
        case .tableList:
            bubbleView = TableListBubbleView()
            break
        case .calendarView:
            bubbleView = CalenderBubbleView()
            break
        case .quick_replies_welcome:
            bubbleView = QuickReplyWelcomeBubbleView()
            break
        case .notification:
            bubbleView = NotificationBubbleView()
            break
        case .multiSelect:
            bubbleView = MultiSelectNewBubbleView()
            break
        case .list_widget:
            bubbleView = ListWidgetBubbleView()
            break
        case .feedbackTemplate:
            bubbleView = FeedbackBubbleView()
            break
        case .inlineForm:
            bubbleView = InLineFormBubbleView()
            break
        case .dropdown_template:
            bubbleView = DropDownBubbleView()
            break
        case .custom_table:
            bubbleView = CustomTableBubbleView()
            break
        case .advancedListTemplate:
            bubbleView = AdvanceListBubbleView()
            break
        case .cardTemplate:
            bubbleView = CardTemplateBubbleView()
            break
        case .linkDownload:
            bubbleView = PDFBubbleView()
            break
        case .stackedCarousel:
            bubbleView = StackedCarouselBubbleView()
            break
        case .advanced_multi_select:
            bubbleView =  AdvancedMultiSelectBubbleView()
            break
        case .radioOptionTemplate:
            bubbleView =  RadioOptionBubbleView()
            break
        }
        bubbleView.bubbleType = bubbleType
        
        return bubbleView
    }
    
    // MARK: 
    func initialize() {
        
    }
    
    // MARK: populate components
    func populateComponents() {
        
    }
    
    //MARK:- Method to be overridden
    func prepareForReuse() {
        
    }
    
    func transitionImage() -> UIImage {
        return UIImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyBubbleMask()
    }
    
    func contrastTintColor() -> UIColor {
        if (self.tailPosition == BubbleMaskTailPosition.left) {
            return BubbleViewLeftContrastTint
        }
        
        return BubbleViewRightContrastTint
    }
    
    func borderColor() -> UIColor {
        if (self.tailPosition == BubbleMaskTailPosition.left) {
            return BubbleViewLeftTint
        }
        
        return BubbleViewRightTint
    }
    
    func applyBubbleMask() {
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
            self.layer.mask = self.maskLayer
        }
        self.maskLayer.path = self.createBezierPath().cgPath
        self.maskLayer.position = CGPoint(x:0, y:0)
        
        if (self.drawBorder) {
            if(self.borderLayer == nil){
                self.borderLayer = CAShapeLayer()
                self.layer.addSublayer(self.borderLayer)
            }
            self.borderLayer.path = self.maskLayer.path // Reuse the Bezier path
            self.borderLayer.fillColor = UIColor.clear.cgColor
            self.borderLayer.strokeColor = Common.UIColorRGB(0xebebeb).cgColor
            self.borderLayer.lineWidth = 1.5
            self.borderLayer.frame = self.bounds
        } else {
            if (self.borderLayer != nil) {
                self.borderLayer.removeFromSuperlayer()
                self.borderLayer = nil
            }
        }
    }
    
    func createBezierPath() -> UIBezierPath {
        // Drawing code
        let cornerRadius: CGFloat = BubbleViewCurveRadius
        var aPath = UIBezierPath()
        let bubbleStyle = brandingBodyDic.bubble_style
        if(self.tailPosition == .left){
            if bubbleStyle == "balloon"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 10.0, height: 0.0))
            }else if bubbleStyle == "rounded"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 15.0, height: 0.0))
            }else if bubbleStyle == "rectangle"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomRight],
                                     cornerRadii: CGSize(width: 10.0, height: 0.0))
            }else{
                aPath.move(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + cornerRadius)))
                aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x:frame.origin.x, y:frame.origin.y))
                aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)))
                aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + cornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
                aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - cornerRadius)))
                aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
                aPath.addLine(to: CGPoint(x: CGFloat(0.0), y: CGFloat(frame.maxY)))
                aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
                aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + cornerRadius)))
            }
            
            
        }else{
            if bubbleStyle == "balloon"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 10.0, height: 0.0))
            }else if bubbleStyle == "rounded"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 15.0, height: 0.0))
            }else if bubbleStyle == "rectangle"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft],
                                     cornerRadii: CGSize(width: 10.0, height: 0.0))
            }else{
                aPath.move(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.origin.y)))
                aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + cornerRadius)), controlPoint: frame.origin)
                aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY - cornerRadius)))
                aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
                aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
                aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
                aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + cornerRadius)))
                aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
                aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.origin.y)))
            }
            
            
        }
        aPath.close()
        return aPath
    }
}
