//
//  KRECardView.swift
//  Widgets
//
//  Created by anoop on 24/05/17.
//
//

import UIKit
import KoreWidgets

public class KRECardView: UIView, UIGestureRecognizerDelegate {
    
    static let kMaxRowHeight: CGFloat = 44
    static let buttonLimit: Int = 3
    static let titleCharLimit: Int = 80
    static let subtitleCharLimit: Int = 100
    var index: Int = 0
    var isFirst: Bool = false
    var isLast: Bool = false
    var urlString: String!
    
    var imageView: UIImageView!
    var optionsView: KREOptionsView!
    var textLabel: UILabel!
    var options: Array<KREOption> = Array<KREOption>()
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getAttributedString(data: NSDictionary) -> NSMutableAttributedString {
        var string = data["title"] as! String
        if(string.characters.count > titleCharLimit){
            string = string.substring(from: string.index(string.startIndex, offsetBy: titleCharLimit-3))
            string += "..."
        }
        
        var subtitle = data["subtitle"] as! String
        if(subtitle.characters.count > subtitleCharLimit){
            subtitle = subtitle.substring(to: subtitle.index(subtitle.startIndex, offsetBy: subtitleCharLimit-3))
            subtitle += "..."
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0.25 * 16.0
        let myAttributes = [NSForegroundColorAttributeName:Common.UIColorRGB(0x484848),
                            NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 16.0)!,
                            NSParagraphStyleAttributeName:paragraphStyle ]
        let mutableAttrString = NSMutableAttributedString(string: string, attributes: myAttributes)
        let myAttributes2 = [NSForegroundColorAttributeName:Common.UIColorRGB(0x777777),
                             NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 15.0)! ]
        let mutableAttrString2 = NSMutableAttributedString(string: "\n\(subtitle)", attributes: myAttributes2)
        mutableAttrString.append(mutableAttrString2)
        return mutableAttrString
    }
    
    static func getExpectedHeight(data: NSDictionary, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        
        height += width*0.5
        
        let buttons: Array<Dictionary<String, Any>> = data["buttons"] as! Array<Dictionary<String, Any>>
        let count: Int = min(buttons.count, KRECardView.buttonLimit)
        height += KRECardView.kMaxRowHeight*CGFloat(count)
        
        let attrString: NSMutableAttributedString = KRECardView.getAttributedString(data: data)
        let limitingSize: CGSize = CGSize(width: width-20.0, height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.size.height + 20.0
        
        return height
    }
    
    func setupView(data: NSDictionary, index: Int) {
        self.index = index
        
        let default_action = data["default_action"] as! NSDictionary
        self.urlString = default_action["url"] as! String
        
        let width = self.frame.size.width
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.backgroundColor = UIColor.gray
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 0.5
        self.imageView.layer.borderColor = UIColor.lightGray.cgColor
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.isUserInteractionEnabled = true
        self.addSubview(self.imageView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        self.imageView.addGestureRecognizer(gestureRecognizer)
        
        let image_url = data["image_url"] as! String
        self.imageView.setImageWith(NSURL(string: image_url) as URL!, placeholderImage: UIImage.init(named: "placeholder_image"))
        
        var views: [String: UIView] = ["imageView": self.imageView]
        var metrics = ["imageHeight": width*0.5, "imageWidth": width]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView(imageHeight)]", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView(imageWidth@1)]|", options: [], metrics: metrics, views: views))
        
        let buttons: Array<Dictionary<String, Any>> = data["buttons"] as! Array<Dictionary<String, Any>>
        let count: Int = min(buttons.count, KRECardView.buttonLimit)
        
        self.optionsView = KREOptionsView()
        self.optionsView.optionsViewType = 1
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.optionsView.contentMode = UIViewContentMode.topLeft
        self.optionsView.layer.borderWidth = 0.5
        self.optionsView.layer.borderColor = UIColor.lightGray.cgColor
        self.optionsView.optionsTableView.separatorInset = UIEdgeInsets.zero
        self.addSubview(self.optionsView)
        views = ["optionsView": self.optionsView]
        metrics = ["optionsViewHeight": KRECardView.kMaxRowHeight*CGFloat(count), "optionsViewWidth": width]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[optionsView(optionsViewHeight)]|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView(optionsViewWidth@1)]|", options: [], metrics: metrics, views: views))
        
        for i in 0..<count {
            let dictionary = buttons[i]
            let option: KREOption = KREOption(name: dictionary["title"] as! String, desc: dictionary["title"] as! String, type: dictionary["type"] as! String, index: i)
            option.setButtonInfo(info: dictionary as! Dictionary<String, String>)
            options.append(option)
        }
        self.optionsView.options = options
        self.optionsView.optionsButtonAction = {[weak self] (text) in
            if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
        self.optionsView.detailLinkAction = {[weak self] (text) in
            if(self?.linkAction != nil){
                self?.linkAction(text)
            }
        }
        
        self.textLabel = UILabel(frame: CGRect.zero)
        self.textLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.textLabel.textColor = Common.UIColorRGB(0x484848)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textLabel)
        views = ["imageView": self.imageView, "textLabel": self.textLabel, "optionsView": self.optionsView,]
        metrics = ["textLabelHeight": width, "textLabelWidth": width]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView]-[textLabel]-(>=10@1)-[optionsView]", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel(textLabelWidth@1)]-10-|", options: [], metrics: metrics, views: views))
        
        let textGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
        textGestureRecognizer.delegate = self
        self.textLabel.addGestureRecognizer(textGestureRecognizer)
        
        self.textLabel.attributedText = KRECardView.getAttributedString(data: data)
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        if(self.linkAction != nil){
            self.linkAction(self.urlString)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.applyBubbleMask()
    }
    
    func applyBubbleMask() {
        let mask: CAShapeLayer = CAShapeLayer()
        mask.path = self.createBezierPath().cgPath
        mask.position = CGPoint(x:0, y:0)
        self.layer.mask = mask
        
        // Add border
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path // Reuse the Bezier path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.lightGray.cgColor
        borderLayer.lineWidth = 1.0
        borderLayer.frame = self.bounds
        self.layer.addSublayer(borderLayer)
        self.setNeedsDisplay()
    }
    
    func createBezierPath() -> UIBezierPath {
        // Drawing code
        let cornerRadius: CGFloat = 5
        let extCornerRadius: CGFloat = 20
        let aPath = UIBezierPath()
        let frame = self.bounds
        
        if(self.isLast){
            aPath.move(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.origin.y)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + extCornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - extCornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
        }else{
            aPath.move(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + cornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
        }
        
        if(self.isFirst){
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + extCornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + extCornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.origin.y)))
        }else{
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.maxY)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY - cornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)))
        }
        
        aPath.close()
        return aPath
    }
}
