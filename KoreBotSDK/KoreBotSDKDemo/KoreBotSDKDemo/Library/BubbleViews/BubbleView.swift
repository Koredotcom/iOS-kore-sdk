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
    case view = 1, text = 2, image = 3, options = 4, quickReply = 5, list = 6, carousel = 7
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

let BubbleViewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 110.0)

class BubbleView: UIView {
    var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.setNeedsLayout()
        }
    }
    var maskType: BubbleMaskType! 
    var bubbleType: BubbleType!
    var didSelectComponentAtIndex:((Int) -> Void)!
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!

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
                bubbleView = QuickReplyBubbleView()
                break
            case .list:
                bubbleView = ListBubbleView()
                break
            case .carousel:
                bubbleView = CarouselBubbleView()
                break
        }
        bubbleView.bubbleType = bubbleType
        
        return bubbleView
    }
    
    // MARK: 
    func initialize() {
        
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

        self.setNeedsDisplay()
    }
    
    // MARK: populate components 
    func populateComponents() {
        
    }
    
    func createBezierPath() -> UIBezierPath {
        // Drawing code
        let cornerRadius: CGFloat = 20
        let padding: CGFloat = 0
        let aPath = UIBezierPath()
        let leftPadding:CGFloat = 10.0

        var frame = self.bounds
        
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
