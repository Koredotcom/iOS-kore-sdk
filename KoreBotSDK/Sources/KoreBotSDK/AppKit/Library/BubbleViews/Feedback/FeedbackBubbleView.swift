//
//  FeedbackBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 8/28/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class FeedbackBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var titleLbl: UILabel!
    var cardView: UIView!
    var collectionView: UICollectionView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    let customCellIdentifier = "FeedbackCell"
    let arrayOfEmojis = ["rating_1","rating_2","rating_3","rating_4","rating_5"]
    var arrayOfSmiley = [SmileyArraysAction]()
    var floatRatingView: FloatRatingView!
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: boldCustomFont, size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.blue,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]

    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    
    override func applyBubbleMask() {
        //nothing to put here
        
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
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 16.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.titleLbl)
        self.titleLbl.adjustsFontSizeToFitWidth = true
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.layer.cornerRadius = 6.0
        self.titleLbl.clipsToBounds = true
        self.titleLbl.sizeToFit()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.cardView.addSubview(self.collectionView)

        if let xib = Bundle.xib(named: "FeedbackCell") {
            self.collectionView.register(xib, forCellWithReuseIdentifier: "FeedbackCell")
        }
        floatRatingView = FloatRatingView(frame: CGRect.zero)
        floatRatingView.translatesAutoresizingMaskIntoConstraints = false
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        floatRatingView.type = .wholeRatings
        floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        floatRatingView.fullImage = UIImage(named: "StarFull")
        floatRatingView.minRating = 1
        floatRatingView.maxRating = 5
        floatRatingView.rating = 0
        cardView.addSubview(self.floatRatingView)
        
        let views: [String: UIView] = ["titleLbl": titleLbl, "collectionView": collectionView, "floatRatingView": floatRatingView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[titleLbl(>=31)]-5-[collectionView(50)]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[titleLbl(>=31)]-5-[floatRatingView(40)]", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[collectionView]-10-|", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[floatRatingView]-10-|", options: [], metrics: nil, views: views))

        setCornerRadiousToTitleView()
    }
    
    func setCornerRadiousToTitleView(){
        let bubbleStyle = brandingBodyDic.bubble_style
        let radius = 4.0
        let borderWidth = 1.0
        let borderColor = UIColor.init(hexString: templateBoarderColor)
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
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.backgroundColor =  BubbleViewLeftTint
        if #available(iOS 11.0, *) {
            self.cardView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 15.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        
    }
    
    // MARK: populate components
    override func populateComponents() {
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
                self.titleLbl.text = allItems.text ?? ""
                
                if allItems.feedbackView! == "emojis"{
                    collectionView.isHidden = false
                    floatRatingView.isHidden = true
                    arrayOfSmiley = allItems.smileyArrays ?? []
                }else if allItems.feedbackView! == "star"{
                    collectionView.isHidden = true
                    floatRatingView.isHidden = false
                    arrayOfSmiley = allItems.starArrays?.reversed() ?? []
                }else{
                    collectionView.isHidden = false
                    floatRatingView.isHidden = true
                }
                collectionView.reloadData()
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
        return CGSize(width: 0.0, height: textSize.height+40)
    }
    
}
extension FeedbackBubbleView : UICollectionViewDelegate, UICollectionViewDataSource{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrayOfSmiley.count > 0{
            return  arrayOfSmiley.count
        }
        return  arrayOfEmojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! FeedbackCell
        cell.backgroundColor = .clear
        cell.imageView.image = UIImage(named: "rating_\(indexPath.item+1)", in: bundle, compatibleWith: nil)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if arrayOfSmiley.count > 0{
            let elements = arrayOfSmiley[indexPath.item]
            self.optionsAction(String(elements.smileyId ?? indexPath.item+1),String(elements.value ?? indexPath.item+1))
            collectionView.reloadData()
        }else{
            self.optionsAction(String(indexPath.item+1),String(indexPath.item+1))
            collectionView.reloadData()
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
}
extension FeedbackBubbleView: FloatRatingViewDelegate {

    // MARK: FloatRatingViewDelegate
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {

    }
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        let index = Int(floatRatingView.rating) - 1
        if arrayOfSmiley.count > 0{
            let elements = arrayOfSmiley[index]
            self.optionsAction(String(elements.starId ?? 0),String(elements.value ?? 0))
        }else{
            self.optionsAction(String(index+1),String(index+1))
        }
    }
    
}
