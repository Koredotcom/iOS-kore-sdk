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

enum BubbleMaskType : Int {
    case full = 1, top = 2, middle = 3, bottom = 4
}

enum BubbleType : Int  {
    case view = 1, text = 2, image = 3, options = 4, quickReply = 5, list = 6
}

let BubbleViewRightTint: UIColor = Common.UIColorRGB(0x0578FE)
let BubbleViewRightContrastTint: UIColor = Common.UIColorRGB(0xFFFFFF)
let BubbleViewLeftTint: UIColor = Common.UIColorRGB(0xF4F4F4)
let BubbleViewLeftContrastTint: UIColor = Common.UIColorRGB(0xBCBCBC)

let BubbleViewCurveRadius: CGFloat = 20.0
let BubbleViewCurveControlPoint: CGFloat = 9.0

let BubbleViewSmallCurveRadius: CGFloat = 4.0
let BubbleViewSmallCurveControlPoint: CGFloat = 1.8

let kBubbleViewCurveControlPointRatio: CGFloat = (BubbleViewCurveControlPoint / BubbleViewCurveRadius)

let BubbleViewTailWidth: CGFloat = 9.0
let BubbleViewTailHeight: CGFloat = 14.0

let BubbleViewTailControlPointY: CGFloat = 6.0
let BubbleViewTailControlPointX: CGFloat = 5.0

let  BubbleViewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 110.0)


class MaskedBorderView : UIView {

    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if (self.superview!.layer.mask != nil && self.superview!.layer.mask!.isKind(of: CAShapeLayer.self) == true && self.superview!.isKind(of: BubbleView.self) == true) {
            
            let bubbleView: BubbleView = self.superview as! BubbleView
            let context:CGContext = UIGraphicsGetCurrentContext()!
            
            context.setStrokeColor(Common.UIColorRGB(0xebebeb).cgColor)
            context.setLineWidth(1.5)
            
            let mask: CAShapeLayer = bubbleView.layer.mask as! CAShapeLayer
            
            context.addPath(mask.path!)
            context.strokePath()
        }
    }
}


class BubbleView: UIView {
    var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.setNeedsLayout()
        }
    }
    var maskType: BubbleMaskType! 
    var bubbleType: BubbleType!
    var borderView: MaskedBorderView!
    var didSelectComponentAtIndex:((Int) -> Void)!

    var components:NSArray! {
        didSet(c) {
            self.populateComponents()
        }
    }
    
    var drawBorder: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    var roundedEdge: Bool = false
    
    // MARK: init
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: bubbleWithType
    static func bubbleWithType(_ bubbleType: BubbleType) -> BubbleView{
        var bubbleView: BubbleView!
        
        switch (bubbleType) {
        case .view:
            bubbleView = BubbleView()
            break
        case .text:
            bubbleView = TextBubbleView()
            break
        case .image:
            bubbleView = Bundle.main.loadNibNamed("MultiImageBubbleView", owner: self, options: nil)![0] as! BubbleView
            break
        case .options:
            bubbleView = OptionsBubbleView()
            break
        case .quickReply:
            break
        case .list:
            bubbleView = ListBubbleView()
            break

        }
        bubbleView.bubbleType = bubbleType
        
        return bubbleView
    }
    
    // MARK: 
    func initialize() {
        
    }
    
    func transitionImage() -> UIImage {
        return UIImage()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        if((self.layer.mask) != nil){
            self.clearBubbleMask()
        }
        self.applyBubbleMask()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(self.borderColor().cgColor)
        context.fill(rect)
    }
    
    func contentRect() -> CGRect {
        var rect: CGRect = self.bounds
        rect.origin.x += self.tailPosition == BubbleMaskTailPosition.left ? BubbleViewTailWidth + BubbleViewCurveRadius / 2.0 : BubbleViewCurveRadius / 2.0
        rect.origin.y += BubbleViewCurveRadius / 2.0
        rect.size.height -= BubbleViewCurveRadius
        rect.size.width -= BubbleViewCurveRadius + BubbleViewTailWidth
        
        return rect
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
        let path: UIBezierPath = UIBezierPath()
        let height: CGFloat = self.bounds.size.height
        let width: CGFloat = self.bounds.size.width
        
        var lOffset: CGFloat = 0.0
        var rOffset: CGFloat = 0.0
        
        switch (self.tailPosition!) {
        case .none:
            lOffset = 0
            rOffset = 0
            break
            
        case .left:
            lOffset = BubbleViewTailWidth
            rOffset = 0
            break
            
        case .right:
            lOffset = 0
            rOffset = BubbleViewTailWidth
            break
        }
//        self.clearBubbleMask()
        let mask: CAShapeLayer = CAShapeLayer()

        mask.path = self.createBezierPath().cgPath
        mask.position = CGPoint(x:0, y:0)
        self.layer.mask = mask
        
        if (self.drawBorder) {
            if (self.borderView == nil) {
                self.borderView = MaskedBorderView()
                self.borderView.isUserInteractionEnabled = false
                self.addSubview(borderView)
            }
            
            self.borderView.frame = self.bounds
        } else {
            if (self.borderView != nil) {
                self.borderView.removeFromSuperview()
                self.borderView = nil
            }

        }
        if (self.drawBorder) {
            self.borderView.isUserInteractionEnabled = false
        }

        self.setNeedsDisplay()
    }
    
    func clearBubbleMask() {
        self.layer.mask = nil
    }
    
    // MARK: populate components 
    func populateComponents() {
        
    }
    
    func createBezierPath() -> UIBezierPath {
        // Drawing code
        var cornerRadius: CGFloat = 20
        let padding: CGFloat = 0
        let aPath = UIBezierPath()
        let leftPadding:CGFloat = 10.0

        var frame = self.bounds
        if(frame.size.height > 300){
            cornerRadius = 4
        }
        
        if(self.tailPosition == .left){
            frame.origin.x += padding;
            
            aPath.move(to: CGPoint(x: CGFloat(frame.origin.x + leftPadding), y: CGFloat(frame.origin.y + cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + leftPadding + cornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x:frame.origin.x + leftPadding,y:frame.origin.y))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + cornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
            aPath.addLine(to: CGPoint(x: CGFloat(0.0), y: CGFloat(frame.maxY)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + leftPadding), y: CGFloat(frame.maxY - 2 * padding)), controlPoint: CGPoint(x: CGFloat(frame.origin.x + leftPadding), y: CGFloat(frame.maxY - padding)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x + leftPadding), y: CGFloat(frame.origin.y + cornerRadius)))
            
        }else{
            aPath.move(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.origin.y)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + cornerRadius)), controlPoint: frame.origin)
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY - cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX + padding), y: CGFloat(frame.maxY)))
            
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - 2 * padding)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - padding)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.origin.y)))
        }
        aPath.close()
        return aPath
    }
    

}
