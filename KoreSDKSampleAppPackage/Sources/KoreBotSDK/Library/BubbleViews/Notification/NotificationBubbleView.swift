//
//  NotificationBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/23/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class NotificationBubbleView: BubbleView {
    var cardView: UIView!
    var subView: UIView!
    var profileImageview: UIImageView!
    var headingLabel: UILabel!
    var titleLbl: UILabel!
    var subTitleLbl: UILabel!
    var underLineLbl: UILabel!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth
    let kMinTextWidth: CGFloat = 20.0
    var notificationView: NotificationCustomView!
    var arrayOfButtons = [ComponentItemAction]()
    var collectionView: UICollectionView!
    let customCellIdentifier = "CustomCellIdentifier"
    
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
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
        cardView.layer.shadowColor = UIColor(red: 232/255, green: 232/255, blue: 230/255, alpha: 1).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.blue
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()

        self.headingLabel = UILabel(frame: CGRect.zero)
        self.headingLabel.textColor = .white
        self.headingLabel.font = UIFont(name: mediumCustomFont, size: 16.0)
        self.headingLabel.numberOfLines = 0
        self.headingLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.headingLabel.isUserInteractionEnabled = true
        self.headingLabel.contentMode = UIView.ContentMode.topLeft
        self.headingLabel.textAlignment = .center
        self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.headingLabel)
        self.headingLabel.adjustsFontSizeToFitWidth = true
        self.headingLabel.backgroundColor = .clear
        self.headingLabel.layer.cornerRadius = 6.0
        self.headingLabel.clipsToBounds = true
        self.headingLabel.sizeToFit()
        
        self.underLineLbl = UILabel(frame: CGRect.zero)
        self.underLineLbl.textColor = .white
        self.underLineLbl.font = UIFont(name: mediumCustomFont, size: 16.0)
        self.underLineLbl.numberOfLines = 0
        self.underLineLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.underLineLbl.isUserInteractionEnabled = true
        self.underLineLbl.contentMode = UIView.ContentMode.topLeft
        self.underLineLbl.textAlignment = .center
        self.underLineLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.underLineLbl)
        self.underLineLbl.adjustsFontSizeToFitWidth = true
        self.underLineLbl.backgroundColor = .white
        self.underLineLbl.layer.cornerRadius = 6.0
        self.underLineLbl.clipsToBounds = true
        self.underLineLbl.alpha = 0.5
        self.underLineLbl.sizeToFit()
        
        self.subView = UIView(frame:.zero)
        self.subView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.subView)
        subView.layer.rasterizationScale =  UIScreen.main.scale
        subView.layer.shouldRasterize = true
        subView.backgroundColor =  UIColor.clear
       
        let views: [String: UIView] = ["headingLabel": headingLabel, "underLineLbl": underLineLbl, "subView": subView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headingLabel(>=21)]-12-[underLineLbl(1)]-3-[subView]-5-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[headingLabel]-30-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[subView]-5-|", options: [], metrics: nil, views: views))
        underLineLbl.widthAnchor.constraint(equalToConstant: 80).isActive = true
        underLineLbl.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        
        notificationView = NotificationCustomView()
        notificationView.backgroundColor = .clear
        notificationView.profileImageView.clipsToBounds = true
        notificationView.profileImageView.layer.cornerRadius = 25
        notificationView.profileImageView.contentMode = .scaleAspectFit
        self.subView.addSubview(notificationView)
        
        createCollectionView()
    }
    
    func createCollectionView(){
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
         self.subView.addSubview(self.collectionView)
        
         self.collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        let views: [String: UIView] = ["collectionView": collectionView]
        self.subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[collectionView]-5-|", options: [], metrics: nil, views: views))
        self.subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
       
    }
    
    func initializeSubView() {
        self.profileImageview = UIImageView()
        self.profileImageview.contentMode = .scaleAspectFit
        self.profileImageview.clipsToBounds = true
        self.profileImageview.layer.cornerRadius = 25
        self.profileImageview.translatesAutoresizingMaskIntoConstraints = false
        self.subView.addSubview(self.profileImageview)
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = .white
        self.titleLbl.font = UIFont(name: boldCustomFont, size: 15.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.textAlignment = .left
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.subView.addSubview(self.titleLbl)
        self.titleLbl.adjustsFontSizeToFitWidth = true
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.layer.cornerRadius = 6.0
        self.titleLbl.clipsToBounds = true
        self.titleLbl.sizeToFit()
        
        self.subTitleLbl = UILabel(frame: CGRect.zero)
        self.subTitleLbl.textColor = .white
        self.subTitleLbl.font = UIFont(name: mediumCustomFont, size: 13.0)
        self.subTitleLbl.numberOfLines = 0
        self.subTitleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.subTitleLbl.isUserInteractionEnabled = true
        self.subTitleLbl.contentMode = UIView.ContentMode.topLeft
        self.subTitleLbl.textAlignment = .left
        self.subTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.subView.addSubview(self.subTitleLbl)
        self.subTitleLbl.adjustsFontSizeToFitWidth = true
        self.subTitleLbl.backgroundColor = .clear
        self.subTitleLbl.layer.cornerRadius = 6.0
        self.subTitleLbl.clipsToBounds = true
        self.subTitleLbl.sizeToFit()
        
        let views: [String: UIView] = ["profileImageview": profileImageview, "titleLbl": titleLbl, "subTitleLbl": subTitleLbl]
        self.subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[profileImageview(50)]-5-|", options: [], metrics: nil, views: views))
        self.subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[titleLbl]-2-[subTitleLbl]", options: [], metrics: nil, views: views))
        self.subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[profileImageview(50)]-5-[titleLbl]-5-|", options: [], metrics: nil, views: views))
        self.subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[profileImageview(50)]-5-[subTitleLbl]-5-|", options: [], metrics: nil, views: views))
       
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
               self.headingLabel.text = allItems.text ?? ""
               
                if allItems.image_url != nil {
                    let imageurl = URL.init(string: allItems.image_url!)
                    self.notificationView.profileImageView.af.setImage(withURL: imageurl!)
                }
                self.notificationView.titleLabel.text = allItems.title ?? ""
                self.notificationView.subTilteLabel.text = allItems.subtitle ?? ""
                
                self.arrayOfButtons = allItems.buttons ?? []
                
                if  self.arrayOfButtons.count>0 {
                    self.underLineLbl.isHidden = true
                    self.collectionView.isHidden = false
                    self.notificationView.isHidden = true
                    self.collectionView.reloadData()
                }else{
                    self.notificationView.isHidden = false
                    self.underLineLbl.isHidden = false
                    self.collectionView.isHidden = true
                }
            }
        }
    }
    
    //MARK: View height calculation
       override var intrinsicContentSize : CGSize {
          
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.headingLabel.sizeThatFits(limitingSize)
        if textSize.height < self.headingLabel.font.pointSize {
            textSize.height = self.headingLabel.font.pointSize
        }
        
        var subViewHeight = 0.0
        if arrayOfButtons.count > 0 {
            subViewHeight = 130
        }else{
            subViewHeight = 70
        }
        return CGSize(width: 0.0, height: Double(textSize.height)+subViewHeight)
       }
    
}

extension NotificationBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCollectionViewCell
        cell.backgroundColor = .clear
        let elements = arrayOfButtons[indexPath.row]
        cell.textLabel.text = elements.name
        cell.textLabel.font = UIFont(name: regularCustomFont, size: 15.0)
        cell.textLabel.textAlignment = .center
        cell.layer.borderColor = UIColor.white.cgColor
        cell.textLabel.textColor = .white
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 5.0
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let elements = arrayOfButtons[indexPath.row]
        if elements.type == "postback" {
            if elements.postback != nil{
                self.optionsAction(elements.name, elements.postback?.value)
            }
        }
      
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let elements = arrayOfButtons[indexPath.row]
        let text = elements.name
         let indexPath = IndexPath(row: indexPath.item, section: indexPath.section)
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCollectionViewCell
        cell.textLabel.text = text
         return CGSize(width: cell.textLabel.intrinsicContentSize.width + 20, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
}




