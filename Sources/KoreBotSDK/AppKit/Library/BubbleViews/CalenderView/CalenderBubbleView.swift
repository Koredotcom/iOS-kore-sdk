//
//  CalenderBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/13/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class CalenderBubbleView: BubbleView {
    var tileBgv: UIView!
    var titleLbl: UILabel!
    var cardView: UIView!
    private let answeredByAIStackView = UIStackView()
    private let answeredByAIImageView = UIImageView()
    private let answeredByAILabel = UILabel()
    private var answeredByAIWidthConstraint: NSLayoutConstraint!
    private var answeredByAITopConstraint: NSLayoutConstraint!
    private var answeredByAIBottomConstraint: NSLayoutConstraint!
    private var titleLabelBottomConstraint: NSLayoutConstraint!
    private var answeredByAIHeightConstraint: NSLayoutConstraint!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0

    var isShowAnswerdByAi = false {
        didSet { updateAnsweredByAIView() }
    }

    var isAgentConnectedMessage = false {
        didSet { updateAnsweredByAIView() }
    }
   
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
               self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tileBgv]-5-|", options: [], metrics: nil, views: views))
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

        answeredByAIImageView.translatesAutoresizingMaskIntoConstraints = false
        let imageWidthConstraint = answeredByAIImageView.widthAnchor.constraint(equalToConstant: 16.0)
        imageWidthConstraint.priority = .defaultHigh
        imageWidthConstraint.isActive = true
        let imageHeightConstraint = answeredByAIImageView.heightAnchor.constraint(equalToConstant: 16.0)
        imageHeightConstraint.priority = .defaultHigh
        imageHeightConstraint.isActive = true
        answeredByAIImageView.image = UIImage(named: "Ai", in: Bundle.sdkModule, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        answeredByAIImageView.tintColor = BubbleViewRightTint
        answeredByAIImageView.contentMode = .scaleAspectFit

        answeredByAILabel.text = answeredByAI
        answeredByAILabel.textColor = BubbleViewRightTint
        answeredByAILabel.font = UIFont(name: regularCustomFont, size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
        answeredByAILabel.numberOfLines = 1

        answeredByAIStackView.axis = .horizontal
        answeredByAIStackView.alignment = .center
        answeredByAIStackView.spacing = 4.0
        answeredByAIStackView.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(answeredByAIStackView)
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLbl]", options: [], metrics: metrics, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-10-|", options: [], metrics: metrics, views: subView))
        answeredByAIStackView.leadingAnchor.constraint(equalTo: tileBgv.leadingAnchor, constant: 8.0).isActive = true
        answeredByAIStackView.trailingAnchor.constraint(lessThanOrEqualTo: tileBgv.trailingAnchor, constant: -10.0).isActive = true
        answeredByAIWidthConstraint = answeredByAIStackView.widthAnchor.constraint(equalToConstant: 0.0)
        answeredByAIHeightConstraint = answeredByAIStackView.heightAnchor.constraint(equalToConstant: 0.0)
        answeredByAITopConstraint = answeredByAIStackView.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 10.0)
        answeredByAIBottomConstraint = answeredByAIStackView.bottomAnchor.constraint(equalTo: tileBgv.bottomAnchor, constant: -10.0)
        titleLabelBottomConstraint = titleLbl.bottomAnchor.constraint(equalTo: tileBgv.bottomAnchor, constant: -10.0)
        answeredByAIHeightConstraint.isActive = true
        updateAnsweredByAIView()
        setCornerRadiousToTitleView()
    }

    private func updateAnsweredByAIView() {
        let shouldShow = isShowAnswerdByAi && !isAgentConnectedMessage && tailPosition == .left

        if shouldShow {
            answeredByAIWidthConstraint.isActive = false
            if answeredByAIImageView.superview == nil {
                answeredByAIStackView.addArrangedSubview(answeredByAIImageView)
            }
            if answeredByAILabel.superview == nil {
                answeredByAIStackView.addArrangedSubview(answeredByAILabel)
            }
            titleLabelBottomConstraint.isActive = false
            answeredByAIHeightConstraint.constant = 18.0
            answeredByAITopConstraint.isActive = true
            answeredByAIBottomConstraint.isActive = true
        } else {
            answeredByAITopConstraint.isActive = false
            answeredByAIBottomConstraint.isActive = false
            answeredByAIStackView.removeArrangedSubview(answeredByAIImageView)
            answeredByAIImageView.removeFromSuperview()
            answeredByAIStackView.removeArrangedSubview(answeredByAILabel)
            answeredByAILabel.removeFromSuperview()
            answeredByAIWidthConstraint.isActive = true
            answeredByAIHeightConstraint.constant = 0.0
            titleLabelBottomConstraint.isActive = true
        }
        answeredByAIStackView.isHidden = !shouldShow
        answeredByAILabel.text = answeredByAI
        invalidateIntrinsicContentSize()
        setNeedsLayout()
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
    
    func setCornerRadiousToTitleView(){
        let bubbleStyle = brandingShared.bubbleShape
        var radius = 10.0
        let borderWidth = 0.0
        let borderColor = UIColor.clear
        if #available(iOS 11.0, *) {
            if bubbleStyle == "balloon"{
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rounded" || bubbleStyle == "circle"{
                radius = 15.0
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rectangle"{
                radius = 8.0
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "square"{
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else{
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0.0)
            }
        }
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
                self.titleLbl.text = allItems.text_message ?? allItems.title ??  ""
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
        let attributionHeight = (isShowAnswerdByAi && !isAgentConnectedMessage && tailPosition == .left) ? 24.0 : 0.0
        return CGSize(width: 0.0, height: textSize.height + 20 + attributionHeight)
    }
    
    @objc fileprivate func SelectAllButtonAction(_ sender: AnyObject!) {

    }
}
