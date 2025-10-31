//
//  AnswerBubbleView.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 28/02/25.
//

import UIKit
#if SWIFT_PACKAGE
import ObjcSupport
#endif
class AnswerBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var tileBgv: UIView!
    var titleLbl: KREAttributedTextView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = (UIScreen.main.bounds.size.width - 74.0)
    let kMinTextWidth: CGFloat = 00.0
    var titleStr: String?

    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
        }
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    
    override func initialize() {
        super.initialize()
        
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
        self.tileBgv.backgroundColor = .white
        
        let views: [String: UIView] = ["tileBgv": tileBgv]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-1-[tileBgv]-1-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-1-[tileBgv]-1-|", options: [], metrics: nil, views: views))
        
        self.titleLbl = KREAttributedTextView(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
        self.titleLbl.mentionTextColor = .white
        self.titleLbl.hashtagTextColor = .white
        self.titleLbl.linkTextColor = .white
        self.titleLbl.font =  UIFont(name: mediumCustomFont, size: 16.0)
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.isEditable = false
        self.titleLbl.isScrollEnabled = false
        self.titleLbl.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.titleLbl.linkTextColor = BubbleViewBotChatTextColor
        self.titleLbl.tintColor = BubbleViewBotChatTextColor
        self.tileBgv.addSubview(self.titleLbl)
        
        let aiColor = UIColor.init(hexString: "#623AE6")
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        let imgV = UIImage.init(named: "Ai", in: bundle, compatibleWith: nil)
        imageView.image = imgV?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = aiColor
        imageView.layer.cornerRadius = 14
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.tileBgv.addSubview(imageView)
        
        
        var ailabel = UILabel()
        ailabel.text = "Answered by AI"
        ailabel.translatesAutoresizingMaskIntoConstraints = false
        ailabel.textColor = UIColor(red: 97/255, green: 104/255, blue: 231/255, alpha: 1)
        ailabel.textAlignment = NSTextAlignment.left
        ailabel.font = UIFont(name: regularCustomFont, size: 10.0)
        ailabel.clipsToBounds = true
        ailabel.textColor = aiColor
        tileBgv.addSubview(ailabel)
        
        let subView: [String: UIView] = ["titleLbl": titleLbl, "imageView": imageView, "ailabel": ailabel]
        //let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl]-10-[imageView(21)]-9-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl]-10-[ailabel(21)]-9-|", options: [], metrics: nil, views: subView))
        //self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-16-|", options: [], metrics: metrics, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))
        
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[imageView(21)]-5-[ailabel]-16-|", options: [], metrics: nil, views: subView))
        
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
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if ((component.componentDesc) != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                var finalStr = ""
                var linkStr =  ""
                if let answerPayload = jsonObject["answer_payload"] as? [String: Any]{
                    if let canterPanel = answerPayload["center_panel"] as? [String: Any]{
                        if let data = canterPanel["data"] as? Array<[String: Any]>, data.count > 0{
                            if let dataDetails = data[0] as? [String: Any] {
                                if let snippet_content = dataDetails["snippet_content"] as? Array<[String: Any]>, snippet_content.count > 0{
                                    
                                    for i in 0..<snippet_content.count{
                                        var addNextLine = "\n"
                                        if i == 0{
                                            addNextLine = ""
                                        }
                                        if let snippet_contentDetails = snippet_content[i] as? [String: Any] {
                                            finalStr += "\(addNextLine)\(snippet_contentDetails["answer_fragment"] as? String ?? "")"
                                            
                                            if let source = snippet_contentDetails["sources"] as? Array<[String: Any]>{
                                                if source.count > 0{
                                                    if let sourceDetails = source[0] as? [String: Any]{
                                                        if let title = sourceDetails["title"] as? String{
                                                            if let url = sourceDetails["url"] as? String, url != ""{
                                                                linkStr  += "\(i+1). \(addNextLine)[\(title)](\(url))"
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    finalStr += "\n\n\(linkStr)"
                    var newString = finalStr.replacingOccurrences(of: ":)", with: "\u{1f642}")
                    newString = newString.replacingOccurrences(of: "&quot;", with: "\"")
                    newString = newString.replacingOccurrences(of: "&quot;", with: "\"")
                    self.titleLbl.setHTMLString(newString, withWidth: kMaxTextWidth)
                }
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.mentionTextColor = BubbleViewBotChatTextColor
        self.titleLbl.hashtagTextColor = BubbleViewBotChatTextColor
        self.titleLbl.linkTextColor = BubbleViewBotChatTextColor
        self.titleLbl.tintColor = themeColor

        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
        }
        
        return CGSize(width: 0, height: textSize.height)
    }
}
