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

let brandingShared = BrandingSingleton.shared
var BubbleViewRightTint: UIColor = themeColor
let BubbleViewRightContrastTint: UIColor = Common.UIColorRGB(0xFFFFFF)
var BubbleViewLeftTint: UIColor = .white
let BubbleViewLeftContrastTint: UIColor = Common.UIColorRGB(0xBCBCBC)

let BubbleViewCurveRadius: CGFloat = 20.0
let BubbleViewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 90.0)

var BubbleViewUserChatTextColor: UIColor = UIColor.init(hexString: "#FFFFFF")
var BubbleViewBotChatTextColor: UIColor = UIColor.init(hexString: "#000000")

var bubbleViewBotChatButtonBgColor: UIColor = UIColor.init(hexString: "#f3f3f5")
var bubbleViewBotChatButtonTextColor: UIColor = UIColor.init(hexString: "#2881DF")

open class BubbleView: UIView {
    var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = self.borderColor()
        }
    }
    var bubbleType: ComponentType!
    var didSelectComponentAtIndex:((Int) -> Void)!
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!

    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)?
    public var linkAction: ((_ text: String?) -> Void)?
    
    public var components:NSArray! {
        didSet(c) {
            self.populateComponents()
        }
    }
    
    var drawBorder: Bool = false
    
    // MARK: init
    public init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: bubbleWithType
    static func bubbleWithType(_ bubbleType: ComponentType) -> BubbleView{
        var bubbleView: BubbleView!
        var isClientCustomTemplate = false
        var isClientTemplateIndex = 0
        for i in 0..<arrayOfViews.count{
            let cleintTemplateTypeStr = arrayOfTemplateTypes[i]
            var tabledesign = "responsive"
            let clientTempateType =  Utilities.getComponentTypes(cleintTemplateTypeStr, tabledesign)
            if bubbleType == clientTempateType{
                isClientTemplateIndex = i
                isClientCustomTemplate = true
            }
        }
        if isClientCustomTemplate{
            if arrayOfViews.count > 0{
                let vieww = arrayOfViews[isClientTemplateIndex]
                bubbleView = vieww as? BubbleView
            }
        }else{
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
            case .minitable_Horizontal:
                bubbleView = MiniTableHorizontalBubbuleView()
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
            case .quick_replies_top:
                bubbleView = QuickReplyTopBubbleView()
                break
            case .noTemplate:
                bubbleView = EmptyBubbleView()
                break
            }
        }
        bubbleView.bubbleType = bubbleType
        
        return bubbleView
    }
    
    // MARK: 
    open func initialize() {
        
    }
    
    // MARK: populate components
    open func populateComponents() {
        
    }
    
    //MARK:- Method to be overridden
    func prepareForReuse() {
        
    }
    
    func transitionImage() -> UIImage {
        return UIImage()
    }
    
    open override func layoutSubviews() {
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
            self.borderLayer.lineWidth = 0.0
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
        let bubbleStyle =  brandingShared.bubbleShape
        if(self.tailPosition == .left){
            if bubbleStyle == "balloon"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 10.0, height: 0.0))
            }else if bubbleStyle == "rounded" || bubbleStyle == "circle"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 15.0, height: 0.0))
            }else if bubbleStyle == "rectangle"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 8.0, height: 0.0))
            }else if bubbleStyle == "square"{
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
            }else if bubbleStyle == "rounded" || bubbleStyle == "circle"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 15.0, height: 0.0))
            }else if bubbleStyle == "rectangle"{
                aPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight, .bottomLeft,.bottomRight],
                                     cornerRadii: CGSize(width: 8.0, height: 0.0))
            }else if bubbleStyle == "square"{
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
