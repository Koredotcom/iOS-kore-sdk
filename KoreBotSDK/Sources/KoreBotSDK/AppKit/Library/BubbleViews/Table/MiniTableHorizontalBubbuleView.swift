//
//  MiniTableHorizontalBubbuleView.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 28/03/25.
//

import UIKit

class MiniTableHorizontalBubbuleView: BubbleView {

    var titleLbl: UILabel!
    var cardView: UIView!
   
    var align0:NSTextAlignment = .left
    var align1:NSTextAlignment = .left
    
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0

    var senderImageView: UIImageView!
    var tileBgv: UIView!
    var collectionView: UICollectionView!
    let customCellIdentifier = "MiniTableHorizontalCell"
    var data: MiniTableData = MiniTableData()
    
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
            self.tileBgv.layer.mask = self.maskLayer
        }
        self.maskLayer.path = self.createBezierPath().cgPath
        self.maskLayer.position = CGPoint(x:0, y:0)
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func intializeCardLayout(){
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.tileBgv)
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 2.0
        self.tileBgv.clipsToBounds = true
        self.tileBgv.backgroundColor =  BubbleViewLeftTint
        
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor.clear.cgColor
        cardView.layer.cornerRadius = 4.0
//        cardView.layer.borderWidth = 0.0
//        cardView.layer.borderColor = BubbleViewLeftTint.cgColor
        cardView.clipsToBounds = true
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.white
        
        self.senderImageView = UIImageView()
        self.senderImageView.contentMode = .scaleAspectFit
        self.senderImageView.clipsToBounds = true
        self.senderImageView.layer.cornerRadius = 0.0//15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.senderImageView)
        
        let cardViews: [String: UIView] = ["senderImageView": senderImageView, "tileBgv": tileBgv, "cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-15-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[senderImageView(28)]", options: [], metrics: nil, views: cardViews))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[senderImageView(28)]-8-[tileBgv]", options: [], metrics: nil, views: cardViews))
        titleBgvLayout()
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)

    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        let collectionViewLayout = CustomCollectionViewLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.cardView.addSubview(self.collectionView)
        collectionView.register(MiniTableHorizontalCell.self, forCellWithReuseIdentifier: customCellIdentifier)
        
        let views: [String: UIView] = ["collectionView": collectionView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
    }
    
    func titleBgvLayout(){
        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
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
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLbl]-10-|", options: [], metrics: metrics, views: subView))
        
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-10-|", options: [], metrics: metrics, views: subView))
        setCornerRadiousToTitleView()
    }
    func setCornerRadiousToTitleView(){
        let bubbleStyle = brandingBodyDic.bubble_style
        let radius = 10.0
        let borderWidth = 0.0
        let borderColor = UIColor.clear
        if #available(iOS 11.0, *) {
            if bubbleStyle == "balloon"{
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rounded"{
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
                
        }else if bubbleStyle == "rectangle"{
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }
        }
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let data: Dictionary<String, Any> = jsonObject as! Dictionary<String, Any>
                self.titleLbl.text = "\(data["text"] ?? "")"
                let placeHolderIcon = UIImage(named: "kora", in: Bundle.sdkModule, compatibleWith: nil)
                self.senderImageView.image = placeHolderIcon
                if (botHistoryIcon != nil) {
                    if let fileUrl = URL(string: botHistoryIcon!) {
                        self.senderImageView.af.setImage(withURL: fileUrl, placeholderImage: placeHolderIcon)
                    }
               }
                self.data = MiniTableData(data)
                var rowsDataCount = 0
                var index = 0
                for row in self.data.rows {
                    index += 1
                    let text = row[0]
                    if text != "---" {
                        rowsDataCount += 1
                    }
                    
                    if  self.data.rows[self.data.rows.count-1][0] != "---" {
                        self.data.rows.append(["---"])
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        
        var cellHeight : CGFloat = 0.0
        let eleemts = data.elements
        let rows = self.data.rows
        var finalHeight: CGFloat = 0.0
        var tableviewHeight  = 0.0
        for z in 0..<eleemts.count{
            finalHeight = 0.0
            for i in 0..<data.rows[z].count/2 {
                let row = data.rows[i]
                cellHeight = 50.0
                finalHeight += cellHeight
            }
            if tableviewHeight == 0.0{
                tableviewHeight = finalHeight
            }
            if tableviewHeight < finalHeight{
                tableviewHeight = finalHeight
            }
        }
        var tableviewHeaderHeight  = 50.0
        return CGSize(width: 0.0, height: textSize.height + 35.0 + tableviewHeight + tableviewHeaderHeight)
    }
    

}

extension MiniTableHorizontalBubbuleView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! MiniTableHorizontalCell
        let headers = data.headers
        let rows = data.rows
        let eleemts = data.elements
        cell.collecvData(data: data, dataHeaders: headers, sectionIndex: indexPath.item)
        cell.layer.borderColor = BubbleViewLeftTint.cgColor
        cell.layer.borderWidth = 1.0
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellHeight : CGFloat = 0.0
        let eleemts = data.elements
        let rows = self.data.rows
        var finalHeight: CGFloat = 0.0
        var tableviewHeight  = 0.0
        for z in 0..<eleemts.count{
            finalHeight = 0.0
            for i in 0..<data.rows[z].count/2 {
                let row = data.rows[i]
                cellHeight = 50.0
                finalHeight += cellHeight
            }
            if tableviewHeight == 0.0{
                tableviewHeight = finalHeight
            }
            if tableviewHeight < finalHeight{
                tableviewHeight = finalHeight
            }
        }
        var tableviewHeaderHeight  = 50.0
        
        return CGSize(width:BubbleViewMaxWidth, height: tableviewHeaderHeight + tableviewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}
