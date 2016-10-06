//
//  BubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 26/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

enum BubbleMaskTailPosition : Int {
    case none = 1, left = 2, right = 3
}

enum BubbleMaskType : Int {
    case full = 1, top = 2, middle = 3, bottom = 4
}

enum BubbleType : Int  {
    case view = 1, text = 2, image = 3
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
            
            context.setStrokeColor(bubbleView.borderColor().cgColor)
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
        
        let smallRadius: CGFloat = BubbleViewSmallCurveRadius
        let smallRadiusControlPoint: CGFloat = BubbleViewSmallCurveControlPoint
        
        let largeRadius: CGFloat = self.roundedEdge ? height / 2.0 : BubbleViewCurveRadius
        let largeRadiusControlPoint: CGFloat = self.roundedEdge ? largeRadius * kBubbleViewCurveControlPointRatio : BubbleViewCurveControlPoint
        
        let leftOuterMargin: CGFloat = lOffset
        let rightOuterMargin: CGFloat = width - rOffset
        
        let isUpperMaskType: Bool = (self.maskType == BubbleMaskType.full) || (self.maskType == BubbleMaskType.top)
        let isLowerMaskType: Bool = (self.maskType == BubbleMaskType.full) || (self.maskType == BubbleMaskType.bottom)
        
        var upperRadiusLeft: CGFloat = self.tailPosition == BubbleMaskTailPosition.left ? smallRadius : largeRadius
        var upperControlPointLeft: CGFloat = self.tailPosition == BubbleMaskTailPosition.left ? smallRadiusControlPoint : largeRadiusControlPoint
        
        var upperRadiusRight: CGFloat = self.tailPosition != BubbleMaskTailPosition.left ? smallRadius : largeRadius
        var upperControlPointRight: CGFloat = self.tailPosition != BubbleMaskTailPosition.left ? smallRadiusControlPoint : largeRadiusControlPoint
        
        let lowerRadiusLeft: CGFloat = self.tailPosition == BubbleMaskTailPosition.left ? smallRadius : largeRadius
        let lowerControlPointLeft: CGFloat = self.tailPosition == BubbleMaskTailPosition.left ? smallRadiusControlPoint : largeRadiusControlPoint
        
        let lowerRadiusRight: CGFloat = self.tailPosition != BubbleMaskTailPosition.left ? smallRadius : largeRadius
        let lowerControlPointRight: CGFloat = self.tailPosition != BubbleMaskTailPosition.left ? smallRadiusControlPoint : largeRadiusControlPoint
        
        
        if (isUpperMaskType) {
            upperRadiusLeft = largeRadius
            upperControlPointLeft = largeRadiusControlPoint
            
            upperRadiusRight = largeRadius
            upperControlPointRight = largeRadiusControlPoint
        }
        
        // top left
        path.move(to: CGPoint(x: leftOuterMargin, y: upperRadiusLeft))
        path.addCurve(to: CGPoint(x: leftOuterMargin + upperRadiusLeft, y: 0),
            controlPoint1:CGPoint(x: leftOuterMargin, y: upperControlPointLeft),
            controlPoint2:CGPoint(x: leftOuterMargin + upperControlPointLeft, y: 0))
        
        // top right
        path.addLine(to: CGPoint(x: rightOuterMargin - upperRadiusRight, y: 0))
        path.addCurve(to: CGPoint(x: rightOuterMargin, y: upperRadiusRight),
            controlPoint1:CGPoint(x: rightOuterMargin - upperControlPointRight, y: 0),
            controlPoint2:CGPoint(x: rightOuterMargin, y: upperControlPointRight))
        
        // bottom right
        if ((self.tailPosition == BubbleMaskTailPosition.right) && isLowerMaskType == true) {
            path.addLine(to: CGPoint(x: rightOuterMargin, y: height - BubbleViewTailHeight))
            path.addCurve(to: CGPoint(x: rightOuterMargin + BubbleViewTailWidth, y: height),
                controlPoint1:CGPoint(x: rightOuterMargin, y: height - BubbleViewTailControlPointY),
                controlPoint2:CGPoint(x: rightOuterMargin + BubbleViewTailControlPointX, y: height))
        } else {
            
            path.addLine(to: CGPoint(x: rightOuterMargin, y: height - lowerRadiusRight))
            path.addCurve(to: CGPoint(x: rightOuterMargin - lowerRadiusRight, y: height),
                controlPoint1:CGPoint(x: rightOuterMargin, y: height - lowerControlPointRight),
                controlPoint2:CGPoint(x: rightOuterMargin - lowerControlPointRight, y: height))
        }
        
        // bottom left
        if ((self.tailPosition == BubbleMaskTailPosition.left) && isLowerMaskType == true) {
            path.addLine(to: CGPoint(x: leftOuterMargin - BubbleViewTailWidth, y: height))
            path.addCurve(to: CGPoint(x: leftOuterMargin, y: height - BubbleViewTailHeight),
                controlPoint1:CGPoint(x: leftOuterMargin - BubbleViewTailControlPointX, y: height),
                controlPoint2:CGPoint(x: leftOuterMargin, y: height - BubbleViewTailControlPointY))
        } else {
            path.addLine(to: CGPoint(x: leftOuterMargin + lowerRadiusLeft, y: height))
            path.addCurve(to: CGPoint(x: leftOuterMargin, y: height - lowerRadiusLeft),
                controlPoint1:CGPoint(x: leftOuterMargin + lowerControlPointLeft, y: height),
                controlPoint2:CGPoint(x: leftOuterMargin, y: height - lowerControlPointLeft))
        }
        
        path.close()
        
        let mask: CAShapeLayer = CAShapeLayer()
        mask.path = path.cgPath
        
        self.layer.mask = mask
        
        if (self.drawBorder) {
            if (self.borderView != nil) {
                self.borderView = MaskedBorderView()
                self.addSubview(borderView)
            }
            
            self.borderView.frame = self.bounds
        } else {
            if (self.borderView != nil) {
                self.borderView.removeFromSuperview()
                self.borderView = nil
            }

        }
        
        self.setNeedsDisplay()
    }
    
    func clearBubbleMask() {
        self.layer.mask = nil
    }
    
    // MARK: populate components 
    func populateComponents() {
        
    }
}
