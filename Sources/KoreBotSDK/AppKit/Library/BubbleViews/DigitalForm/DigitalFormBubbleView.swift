//
//  DigitalFormBubbleView.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 14/10/25.
//

import UIKit

class DigitalFormBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var cardView: UIView!
    var jsonObject: NSDictionary = [:]
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    var imageV: UIImageView!
    var documentView: UIView!
    var titleLbl: KREAttributedLabel!
    var collectionView: UICollectionView!
    let customCellIdentifier = "ButtonLinkCell"
    var isReloadBtnLink = true
    var arrayOfButtons = [ComponentItemAction]()
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor.clear.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.layer.cornerRadius = 10.0
        cardView.backgroundColor =  .white
        
        let documentViewHeight = 50.0
        documentView = UIView(frame:.zero)
        documentView.translatesAutoresizingMaskIntoConstraints = false
        documentView.layer.rasterizationScale =  UIScreen.main.scale
        documentView.layer.shouldRasterize = true
        documentView.layer.cornerRadius = documentViewHeight/2
        documentView.layer.borderColor = BubbleViewLeftTint.cgColor
        documentView.clipsToBounds = true
        documentView.layer.borderWidth = 1.0
        self.addSubview(self.documentView)
        self.documentView.backgroundColor = .white
        
        let cardViews: [String: UIView] = ["cardView": cardView,"documentView": documentView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[documentView(\(documentViewHeight))]", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[documentView(\(documentViewHeight))]", options: [], metrics: nil, views: cardViews))
        
        imageV = UIImageView(frame: CGRect.zero)
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.image = UIImage(named: "digitalForm", in: bundle, compatibleWith: nil)
        imageV.contentMode = .scaleAspectFit
        documentView.addSubview(self.imageV)
        
        let documentViews: [String: UIView] = ["imageV": imageV]
        self.documentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[imageV]-10-|", options: [], metrics: nil, views: documentViews))
        self.documentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[imageV]-15-|", options: [], metrics: nil, views: documentViews))
        
    }
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.mentionTextColor = .white
        self.titleLbl.hashtagTextColor = .white
        self.titleLbl.linkTextColor = .white
        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 16.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.titleLbl)
        
        let layout = TagFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        self.cardView.addSubview(self.collectionView)
        if let xib = Bundle.xib(named: "ButtonLinkCell") {
            self.collectionView.register(xib, forCellWithReuseIdentifier: customCellIdentifier)
        }
        let listViews: [String: UIView] = ["titleLbl": titleLbl, "collectionView": collectionView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[titleLbl(>=21)]-5-[collectionView]-0-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-23-[titleLbl]-16-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: listViews))
        setCornerRadiousToTitleView()

    }
    
    func setCornerRadiousToTitleView(){
        let bubbleStyle = brandingBodyDic.bubble_style
        let radius = 5.0
        let borderWidth = 1.0
        let borderColor = BubbleViewLeftTint
        if #available(iOS 11.0, *) {
            if bubbleStyle == "balloon"{
                self.cardView.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rounded"{
                self.cardView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
                
        }else if bubbleStyle == "rectangle"{
                self.cardView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                jsonObject = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let payload: NSDictionary = jsonObject["payload"] as? NSDictionary ?? [:]
                self.titleLbl.setHTMLString(payload["text"] as? String ?? "", withWidth: kMaxTextWidth)
                arrayOfButtons = []
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: payload as Any , options: .prettyPrinted),
                      let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                arrayOfButtons = allItems.buttons ?? []
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                // Ensure layout is updated so content size is correct, then invalidate intrinsic size
                DispatchQueue.main.async {
                    self.collectionView.layoutIfNeeded()
                    self.invalidateIntrinsicContentSize()
                }
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
        }
        // Ensure the collection view has laid out before reading its content size
        self.collectionView.layoutIfNeeded()
        let collectionviewHeight  = Double(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
        return CGSize(width: 0.0, height: textSize.height + 75 + CGFloat(collectionviewHeight))
    }
}

extension DigitalFormBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! ButtonLinkCell
        cell.backgroundColor = .clear
       
        let elements = arrayOfButtons[indexPath.row]
        cell.textlabel.text = elements.title

        cell.textlabel.font = UIFont(name: mediumCustomFont, size: 16.0)
        cell.textlabel.textAlignment = .center
        cell.textlabel.numberOfLines = 2
        cell.imagvWidthConstraint.constant = 0.0
        
        cell.bgV.backgroundColor = UIColor.clear
        cell.textlabel.textColor = BubbleViewRightTint
        cell.layer.borderColor =  UIColor.clear.cgColor
        cell.backgroundColor = .clear
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let elements = arrayOfButtons[indexPath.row]
          if elements.type == "web_url" || elements.type == "url"{
              if let formDataDic = jsonObject["formData"] as? [String: Any] {
                  if let renderType = formDataDic["renderType"] as? String, renderType == "pop-up"{
                      isPopUpWebV = true
                  }
              }
             self.linkAction?(elements.url)
              isPopUpWebV = false
           }else{
             self.optionsAction?(elements.title, elements.payload)
          }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text:String?
            let elements = arrayOfButtons[indexPath.row]
            text = elements.title
        var textWidth = 10
        let size = text?.size(withAttributes:[.font: UIFont(name: mediumCustomFont, size: 16.0) as Any])
        if text != nil {
            textWidth = Int(size!.width)
        }
        return CGSize(width: min(Int(maxContentWidth()) - 10 , textWidth + 28) , height: 40)
    }
    
    func maxContentWidth() -> CGFloat {
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
            let baseWidth = (self.frame.size.width > 0.0) ? self.frame.size.width : kMaxTextWidth
            return max(baseWidth - sectionInset.left - sectionInset.right, 1.0)
        }
        return kMaxTextWidth
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
}










































////
////  DigitalFormBubbleView.swift
////  KoreBotSDK
////
////  Created by Pagidimarri Kartheek on 14/10/25.
////
//
//import UIKit
//
//class DigitalFormBubbleView: BubbleView {
//    let bundle = Bundle.sdkModule
//    var cardView: UIView!
//    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
//    var jsonObject: NSDictionary = [:]
//    var imageV: UIImageView!
//    var documentView: UIView!
//    var titleLbl: KREAttributedLabel!
//    var collectionView: UICollectionView!
//    let customCellIdentifier = "ButtonLinkCell"
//    var isReloadBtnLink = true
//    var arrayOfButtons = [ComponentItemAction]()
//    override func applyBubbleMask() {
//        //nothing to put here
//    }
//    
//    override var tailPosition: BubbleMaskTailPosition! {
//        didSet {
//            self.backgroundColor = .clear
//        }
//    }
//    func intializeCardLayout(){
//        self.cardView = UIView(frame:.zero)
//        self.cardView.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(self.cardView)
//        cardView.layer.rasterizationScale =  UIScreen.main.scale
//        cardView.layer.shadowColor = UIColor.clear.cgColor
//        cardView.layer.shadowOpacity = 1
//        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
//        cardView.layer.shadowRadius = 6.0
//        cardView.layer.shouldRasterize = true
//        cardView.layer.cornerRadius = 10.0
//        cardView.backgroundColor =  .white
//        
//        let documentViewHeight = 50.0
//        documentView = UIView(frame:.zero)
//        documentView.translatesAutoresizingMaskIntoConstraints = false
//        documentView.layer.rasterizationScale =  UIScreen.main.scale
//        documentView.layer.shouldRasterize = true
//        documentView.layer.cornerRadius = documentViewHeight/2
//        documentView.layer.borderColor = BubbleViewLeftTint.cgColor
//        documentView.clipsToBounds = true
//        documentView.layer.borderWidth = 1.0
//        self.addSubview(self.documentView)
//        self.documentView.backgroundColor = .white
//        
//        let cardViews: [String: UIView] = ["cardView": cardView,"documentView": documentView]
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[documentView(\(documentViewHeight))]", options: [], metrics: nil, views: cardViews))
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[documentView(\(documentViewHeight))]", options: [], metrics: nil, views: cardViews))
//        
//        imageV = UIImageView(frame: CGRect.zero)
//        imageV.translatesAutoresizingMaskIntoConstraints = false
//        imageV.image = UIImage(named: "digitalForm", in: bundle, compatibleWith: nil)
//        imageV.contentMode = .scaleAspectFit
//        documentView.addSubview(self.imageV)
//        
//        let documentViews: [String: UIView] = ["imageV": imageV]
//        self.documentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[imageV]-10-|", options: [], metrics: nil, views: documentViews))
//        self.documentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[imageV]-15-|", options: [], metrics: nil, views: documentViews))
//        
//    }
//    override func initialize() {
//        super.initialize()
//        intializeCardLayout()
//        
//        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
//        self.titleLbl.textColor = BubbleViewBotChatTextColor
//        self.titleLbl.mentionTextColor = .white
//        self.titleLbl.hashtagTextColor = .white
//        self.titleLbl.linkTextColor = .white
//        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 16.0)
//        self.titleLbl.numberOfLines = 0
//        self.titleLbl.backgroundColor = .clear
//        self.titleLbl.isUserInteractionEnabled = true
//        self.titleLbl.contentMode = UIView.ContentMode.topLeft
//        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
//        self.cardView.addSubview(self.titleLbl)
//        
//        let layout = TagFlowLayout()
//        layout.scrollDirection = .vertical
//        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
//        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
//        self.collectionView.dataSource = self
//        self.collectionView.delegate = self
//        self.collectionView.backgroundColor = .clear
//        self.collectionView.showsHorizontalScrollIndicator = false
//        self.collectionView.showsVerticalScrollIndicator = false
//        self.collectionView.bounces = false
//        self.collectionView.isScrollEnabled = false
//        self.cardView.addSubview(self.collectionView)
//        if let xib = Bundle.xib(named: "ButtonLinkCell") {
//            self.collectionView.register(xib, forCellWithReuseIdentifier: customCellIdentifier)
//        }
//        let listViews: [String: UIView] = ["titleLbl": titleLbl, "collectionView": collectionView]
//        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[titleLbl(>=21)]-5-[collectionView]-15-|", options: [], metrics: nil, views: listViews))
//        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-23-[titleLbl]-16-|", options: [], metrics: nil, views: listViews))
//        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: listViews))
//        setCornerRadiousToTitleView()
//        if isReloadBtnLink {
//            isReloadBtnLink = false
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
//              NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
//            }
//        }
//    }
//    
//    func setCornerRadiousToTitleView(){
//        let bubbleStyle = brandingBodyDic.bubble_style
//        let radius = 5.0
//        let borderWidth = 1.0
//        let borderColor = BubbleViewLeftTint
//        if #available(iOS 11.0, *) {
//            if bubbleStyle == "balloon"{
//                self.cardView.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
//            }else if bubbleStyle == "rounded"{
//                self.cardView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
//                
//        }else if bubbleStyle == "rectangle"{
//                self.cardView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
//            }
//        }
//    }
//    
//    /*
//     // Only override draw() if you perform custom drawing.
//     // An empty implementation adversely affects performance during animation.
//     override func draw(_ rect: CGRect) {
//     // Drawing code
//     }
//     */
//    // MARK: populate components
//    override func populateComponents() {
//        if (components.count > 0) {
//            let component: KREComponent = components.firstObject as! KREComponent
//            if (component.componentDesc != nil) {
//                let jsonString = component.componentDesc
//                jsonObject = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
//                let tilteStr = jsonObject["text"] as? String ?? ""
//                self.titleLbl.setHTMLString(tilteStr, withWidth: kMaxTextWidth)
//                arrayOfButtons = []
//                let jsonDecoder = JSONDecoder()
//                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
//                      let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
//                    return
//                }
//                arrayOfButtons = allItems.buttons ?? []
//                self.collectionView.collectionViewLayout.invalidateLayout()
//                self.collectionView.reloadData()
//            }
//        }
//    }
//    
//    override var intrinsicContentSize : CGSize {
//        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
//        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
//        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
//            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
//        }
//        let collectionviewHeight  = Double(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
//        return CGSize(width: 0.0, height: textSize.height + 70 + CGFloat(collectionviewHeight))
//    }
//}
//
//extension DigitalFormBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    //MARK: collection view delegate methods
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return arrayOfButtons.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        // swiftlint:disable force_cast
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! ButtonLinkCell
//        cell.backgroundColor = .clear
//       
//        let elements = arrayOfButtons[indexPath.row]
//        cell.textlabel.text = elements.title
//
//        cell.textlabel.font = UIFont(name: mediumCustomFont, size: 16.0)
//        cell.textlabel.textAlignment = .center
//        cell.textlabel.numberOfLines = 2
//        cell.imagvWidthConstraint.constant = 0.0
//        
//        cell.bgV.backgroundColor = UIColor.clear
//        cell.textlabel.textColor = BubbleViewRightTint
//        cell.layer.borderColor =  UIColor.clear.cgColor
//        cell.backgroundColor = .clear
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let elements = arrayOfButtons[indexPath.row]
//          if elements.type == "web_url" || elements.type == "url"{
//             self.linkAction?(elements.url)
//           }else{
//             self.optionsAction?(elements.title, elements.payload)
//          }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var text:String?
//            let elements = arrayOfButtons[indexPath.row]
//            text = elements.title
//        var textWidth = 10
//        let size = text?.size(withAttributes:[.font: UIFont(name: mediumCustomFont, size: 16.0) as Any])
//        if text != nil {
//            textWidth = Int(size!.width)
//        }
//        return CGSize(width: min(Int(maxContentWidth()) - 10 , textWidth + 28) , height: 40)        
//    }
//    
//    func maxContentWidth() -> CGFloat {
//        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
//            return max(frame.size.width - sectionInset.left - sectionInset.right, 1.0)
//        }
//        return 1.0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10.0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10.0
//    }
//    
//}






