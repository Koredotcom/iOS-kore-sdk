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
var BubbleViewMaxWidth: CGFloat {
    let windowWidth = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.size.width ?? UIScreen.main.bounds.size.width
    let portraitBase = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    let ratio = portraitBase > 0 ? (portraitBase - 90.0) / portraitBase : 1.0
    return windowWidth * ratio
}

open class BubbleView: UIView {
    let brandingShared = BrandingSingleton.shared
    private static var lastKnownMaxWidth: CGFloat = 0.0
    private func updateMaxWidthConstraints(in view: UIView) {
        for constraint in view.constraints {
            if constraint.firstAttribute == .width && constraint.relation == .lessThanOrEqual {
                // Default to the dynamic bubble max width; subclasses can still override if needed
                let target = BubbleViewMaxWidth
                if abs(constraint.constant - target) > 0.5 {
                    constraint.constant = target
                }
            }
        }
        for subview in view.subviews {
            updateMaxWidthConstraints(in: subview)
        }
    }

    func bubbleWidthMaintainingPortraitRatio(margin: CGFloat) -> CGFloat {
        let windowWidth = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width ?? UIScreen.main.bounds.size.width
        let portraitBase = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let portraitMax = portraitBase - 90.0
        let ratio = portraitBase > 0 ? (portraitMax / portraitBase) : 1.0
        let bubbleMaxWidth = ratio * windowWidth
        return max(0.0, bubbleMaxWidth - margin)
    }
    var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = self.borderColor()
        }
    }
    var bubbleType: ComponentType!
    var didSelectComponentAtIndex:((Int) -> Void)!
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    var isLandscape: Bool! {
            if #available(iOS 13.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    return windowScene.interfaceOrientation.isLandscape
                }
            } else {
                return UIApplication.shared.statusBarOrientation.isLandscape
            }
            return nil
    }
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)?
    public var linkAction: ((_ text: String?) -> Void)?
    public var updateMessage: ((_ text: String?, _ componentDesc: String?) -> Void)?
    
    public var components:NSArray! {
        didSet(c) {
            self.populateComponents()
        }
    }
    
    var drawBorder: Bool = false
    
    // MARK: init
    required public init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: bubbleWithType
    static func bubbleWithType(_ bubbleType: ComponentType) -> BubbleView{
        var bubbleView: BubbleView!
        var isCustomTemplate = false
        var isCustomTemplateIndex = 0
        for i in 0..<arrayOfViews.count{
            let cleintTemplateTypeStr = arrayOfTemplateTypes[i]
            var tabledesign = "responsive"
            let clientTempateType =  Utilities.getComponentTypes(cleintTemplateTypeStr, tabledesign)
            if bubbleType == clientTempateType{
                isCustomTemplateIndex = i
                isCustomTemplate = true
            }
        }
        if isCustomTemplate{
            if arrayOfViews.count > 0{
                let vieww = arrayOfViews[isCustomTemplateIndex]
                bubbleView = vieww.init()
            }
        }else{
            switch (bubbleType) {
            case .text:
                bubbleView = TextBubbleView()
                break
            case .image, .video:
                bubbleView = Bundle.sdkModule.loadNibNamed("MultiImageBubbleView", owner: self, options: nil)![0] as? BubbleView
                break
            case .audio:
                //bubbleView = Bundle.sdkModule.loadNibNamed("AudioBubbleView", owner: self, options: nil)![0] as? BubbleView
                bubbleView = AudioNewBubbleView()
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
                bubbleView = MultiSelectBubbleView()
                break
            case .list_widget:
                bubbleView = ListWidgetNewBubbleView()//ListWidgetBubbleView()
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
            case .quick_replies_top:
                bubbleView = QuickReplyTopBubbleView()
                break
            case .articleTemplate:
                bubbleView = ArticleBubbleView()
                break
            case .answerTemplate:
                bubbleView = AnswerBubbleView()
                break
            case .OtpOrResetTemplate:
                bubbleView = OTPorResetBubbleView()
                break
            case .digital_form:
                bubbleView = DigitalFormBubbleView()
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
        // Update any width cap constraints to reflect current orientation
        updateMaxWidthConstraints(in: self)
        let currentWidth = BubbleViewMaxWidth
        if abs(currentWidth - BubbleView.lastKnownMaxWidth) > 0.5 {
            BubbleView.lastKnownMaxWidth = currentWidth
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        }
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
