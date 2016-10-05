//
//  BubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 26/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

enum BubbleMaskTailPosition : Int {
    case None = 1, Left = 2, Right = 3
}

enum BubbleMaskType : Int {
    case Full = 1, Top = 2, Middle = 3, Bottom = 4
}

enum BubbleType : Int  {
    case View = 1, Text = 2, Image = 3
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

let  BubbleViewMaxWidth: CGFloat = (UIScreen.mainScreen().bounds.size.width - 110.0)


class MaskedBorderView : UIView {

    init() {
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if (self.superview!.layer.mask != nil && self.superview!.layer.mask!.isKindOfClass(CAShapeLayer) == true && self.superview!.isKindOfClass(BubbleView) == true) {
            
            let bubbleView: BubbleView = self.superview as! BubbleView
            
            let context:CGContextRef = UIGraphicsGetCurrentContext()!
            
            CGContextSetStrokeColorWithColor(context, bubbleView.borderColor().CGColor)
            CGContextSetLineWidth(context, 1.5)
            
            let mask: CAShapeLayer = bubbleView.layer.mask as! CAShapeLayer
            
            CGContextAddPath(context, mask.path!)
            CGContextStrokePath(context)
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
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    // MARK: bubbleWithType
    static func bubbleWithType(bubbleType: BubbleType) -> BubbleView{
        var bubbleView: BubbleView!
        
        switch (bubbleType) {
        case .View:
            bubbleView = BubbleView()
            break
            
        case .Text:
            bubbleView = TextBubbleView()
            break
            
        case .Image:
            bubbleView = NSBundle.mainBundle().loadNibNamed("MultiImageBubbleView", owner: self, options: nil)![0] as! BubbleView
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
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(context, self.borderColor().CGColor)
        CGContextFillRect(context, rect)
    }
    
    func contentRect() -> CGRect {
        var rect: CGRect = self.bounds
        rect.origin.x += self.tailPosition == BubbleMaskTailPosition.Left ? BubbleViewTailWidth + BubbleViewCurveRadius / 2.0 : BubbleViewCurveRadius / 2.0
        rect.origin.y += BubbleViewCurveRadius / 2.0
        rect.size.height -= BubbleViewCurveRadius
        rect.size.width -= BubbleViewCurveRadius + BubbleViewTailWidth
        
        return rect
    }
    
    func contrastTintColor() -> UIColor {
        if (self.tailPosition == BubbleMaskTailPosition.Left) {
            return BubbleViewLeftContrastTint
        }
        
        return BubbleViewRightContrastTint
    }
    
    func borderColor() -> UIColor {
        if (self.tailPosition == BubbleMaskTailPosition.Left) {
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
        case .None:
            lOffset = 0
            rOffset = 0
            break
            
        case .Left:
            lOffset = BubbleViewTailWidth
            rOffset = 0
            break
            
        case .Right:
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
        
        let isUpperMaskType: Bool = (self.maskType == BubbleMaskType.Full) || (self.maskType == BubbleMaskType.Top)
        let isLowerMaskType: Bool = (self.maskType == BubbleMaskType.Full) || (self.maskType == BubbleMaskType.Bottom)
        
        var upperRadiusLeft: CGFloat = self.tailPosition == BubbleMaskTailPosition.Left ? smallRadius : largeRadius
        var upperControlPointLeft: CGFloat = self.tailPosition == BubbleMaskTailPosition.Left ? smallRadiusControlPoint : largeRadiusControlPoint
        
        var upperRadiusRight: CGFloat = self.tailPosition != BubbleMaskTailPosition.Left ? smallRadius : largeRadius
        var upperControlPointRight: CGFloat = self.tailPosition != BubbleMaskTailPosition.Left ? smallRadiusControlPoint : largeRadiusControlPoint
        
        let lowerRadiusLeft: CGFloat = self.tailPosition == BubbleMaskTailPosition.Left ? smallRadius : largeRadius
        let lowerControlPointLeft: CGFloat = self.tailPosition == BubbleMaskTailPosition.Left ? smallRadiusControlPoint : largeRadiusControlPoint
        
        let lowerRadiusRight: CGFloat = self.tailPosition != BubbleMaskTailPosition.Left ? smallRadius : largeRadius
        let lowerControlPointRight: CGFloat = self.tailPosition != BubbleMaskTailPosition.Left ? smallRadiusControlPoint : largeRadiusControlPoint
        
        
        if (isUpperMaskType) {
            upperRadiusLeft = largeRadius
            upperControlPointLeft = largeRadiusControlPoint
            
            upperRadiusRight = largeRadius
            upperControlPointRight = largeRadiusControlPoint
        }
        
        // top left
        path.moveToPoint(CGPointMake(leftOuterMargin, upperRadiusLeft))
        path.addCurveToPoint(CGPointMake(leftOuterMargin + upperRadiusLeft, 0),
            controlPoint1:CGPointMake(leftOuterMargin, upperControlPointLeft),
            controlPoint2:CGPointMake(leftOuterMargin + upperControlPointLeft, 0))
        
        // top right
        path.addLineToPoint(CGPointMake(rightOuterMargin - upperRadiusRight, 0))
        path.addCurveToPoint(CGPointMake(rightOuterMargin, upperRadiusRight),
            controlPoint1:CGPointMake(rightOuterMargin - upperControlPointRight, 0),
            controlPoint2:CGPointMake(rightOuterMargin, upperControlPointRight))
        
        // bottom right
        if ((self.tailPosition == BubbleMaskTailPosition.Right) && isLowerMaskType == true) {
            path.addLineToPoint(CGPointMake(rightOuterMargin, height - BubbleViewTailHeight))
            path.addCurveToPoint(CGPointMake(rightOuterMargin + BubbleViewTailWidth, height),
                controlPoint1:CGPointMake(rightOuterMargin, height - BubbleViewTailControlPointY),
                controlPoint2:CGPointMake(rightOuterMargin + BubbleViewTailControlPointX, height))
        } else {
            
            path.addLineToPoint(CGPointMake(rightOuterMargin, height - lowerRadiusRight))
            path.addCurveToPoint(CGPointMake(rightOuterMargin - lowerRadiusRight, height),
                controlPoint1:CGPointMake(rightOuterMargin, height - lowerControlPointRight),
                controlPoint2:CGPointMake(rightOuterMargin - lowerControlPointRight, height))
        }
        
        // bottom left
        if ((self.tailPosition == BubbleMaskTailPosition.Left) && isLowerMaskType == true) {
            path.addLineToPoint(CGPointMake(leftOuterMargin - BubbleViewTailWidth, height))
            path.addCurveToPoint(CGPointMake(leftOuterMargin, height - BubbleViewTailHeight),
                controlPoint1:CGPointMake(leftOuterMargin - BubbleViewTailControlPointX, height),
                controlPoint2:CGPointMake(leftOuterMargin, height - BubbleViewTailControlPointY))
        } else {
            path.addLineToPoint(CGPointMake(leftOuterMargin + lowerRadiusLeft, height))
            path.addCurveToPoint(CGPointMake(leftOuterMargin, height - lowerRadiusLeft),
                controlPoint1:CGPointMake(leftOuterMargin + lowerControlPointLeft, height),
                controlPoint2:CGPointMake(leftOuterMargin, height - lowerControlPointLeft))
        }
        
        path.closePath()
        
        let mask: CAShapeLayer = CAShapeLayer()
        mask.path = path.CGPath
        
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
