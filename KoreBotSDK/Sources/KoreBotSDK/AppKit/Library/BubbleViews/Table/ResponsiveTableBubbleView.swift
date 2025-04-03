//
//  ResponsiveTableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Sowmya Ponangi on 28/03/18.
//  Copyright © 2018 Kore. All rights reserved.
//



import UIKit


class ResponsiveTableBubbleView: BubbleView, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var showMoreButton: UIButton!
    var cardView : UIView!
    let bundle = Bundle.sdkModule
    let cellReuseIdentifier = "CellIdentifier"
    let cellReuseIdentifier1 = "SubTableViewCell"
    var data: TableData = TableData()
    let rowsDataLimit = 3
    
    var selectedRowIndex : Int = -1
    var selectedIndex : IndexPath!
    var selected : Bool = false
    var indexPaths : Array<IndexPath> = []

    var rows: Array<Array<String>> = Array<Array<String>>()
    var tileBgv: UIView!
    var titleLbl: KREAttributedLabel!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var senderImageView: UIImageView!
    
    var showMore = false
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
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
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = BubbleViewLeftTint.cgColor
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
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-15-[cardView]-2-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[senderImageView(28)]", options: [], metrics: nil, views: cardViews))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[senderImageView(28)]-8-[tileBgv]", options: [], metrics: nil, views: cardViews))
        titleBgvLayout()
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
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(tableView)
        tableView.register(ResponsiveCustonCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(SubTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier1)
        
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        let row = -1
        let section = -1
        selectedIndex = IndexPath(row: row, section: section)
        
        self.showMoreButton = UIButton.init(frame: CGRect.zero)
        self.showMoreButton.setTitle("Show More", for: .normal)
        self.showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.showMoreButton.setTitleColor( themeColor, for: .normal)
        self.showMoreButton.titleLabel?.font = UIFont(name: regularCustomFont, size: 14.0)
        self.showMoreButton.titleLabel?.font = self.showMoreButton.titleLabel?.font.withSize(14.0)
     
        self.showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        self.showMoreButton.isHidden = false
        self.showMoreButton.clipsToBounds = true
        self.cardView.addSubview(self.showMoreButton)

        
        let views : [String: Any] = ["tableView": tableView as Any,  "showMoreButton": showMoreButton as Any]
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(34.0)]-5-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[showMoreButton]-15-|", options: [], metrics: nil, views: views))
        
    }
    
    //MARK: table view delegate methods
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPaths.count>0 {
            if indexPaths.contains(indexPath){
                return CGFloat((data.rows[indexPath.section].count)*44)
            }
            else {
                return UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return rowsDataLimit
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rows = data.rows
        
        //        if(selectedIndex as IndexPath == indexPath && selected == true && indexPath.row != rows.count-1) {
        if indexPaths.count>0 {
            if indexPaths.contains(indexPath){
                let subtableViewCell = SubTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier1)
                subtableViewCell.backgroundColor = UIColor.white

                subtableViewCell.accessoryView = UIImageView(image:  UIImage(named: "arrowSelected", in: bundle, compatibleWith: nil))
                subtableViewCell.rows = data.rows
                subtableViewCell.headers = data.headers
                subtableViewCell.sec = indexPath.section
                if indexPath.section % 2 == 0{
                    subtableViewCell.backgroundColor = BubbleViewLeftTint
                    subtableViewCell.subTableView.backgroundColor = BubbleViewLeftTint
                }else{
                    subtableViewCell.backgroundColor = .white
                    subtableViewCell.subTableView.backgroundColor = .white
                }
                return subtableViewCell
            }
            else{
                let cell : ResponsiveCustonCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResponsiveCustonCell
                print(rows[indexPath.section][indexPath.row])
                let row = rows[indexPath.section]
                if(row.count > indexPath.row*2){
                    cell.headerLabel.text = row[indexPath.row*2]
                }
                if(row.count > indexPath.row*2+1){
                    cell.secondLbl.text = row[indexPath.row*2+1]
                }
                cell.accessoryView = UIImageView(image:  UIImage(named: "arrowUnselected", in: bundle, compatibleWith: nil))
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 22)
                if indexPath.section % 2 == 0{
                    cell.backgroundColor = BubbleViewLeftTint
                }else{
                    cell.backgroundColor = .white
                }
                return cell
                
            }
        }else{
            let cell : ResponsiveCustonCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResponsiveCustonCell
            print(rows[indexPath.section][indexPath.row])
            let row = rows[indexPath.section]
            if(row.count > indexPath.row*2){
                cell.headerLabel.text = row[indexPath.row*2]
            }
            if(row.count > indexPath.row*2+1){
                cell.secondLbl.text = row[indexPath.row*2+1]
            }
            cell.accessoryView = UIImageView(image:  UIImage(named: "arrowUnselected", in: bundle, compatibleWith: nil))
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 22)

            if indexPath.section % 2 == 0{
                cell.backgroundColor = BubbleViewLeftTint
            }else{
                cell.backgroundColor = .white
            }
            return cell
            
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selected == false {
            selected = true
        }
        else{
            selected = false
        }
        
        if indexPath == selectedIndex {
            selectedIndex = NSIndexPath(row: -1, section: -1) as IndexPath
            selected = false
        } else {
            selectedIndex = indexPath
            selectedIndex = indexPath
            if !indexPaths.contains(selectedIndex!){
                indexPaths += [selectedIndex!]
            }
            else {
                let index = indexPaths.index(of: selectedIndex!)
                indexPaths.remove(at: index!)
            }
            selected = true
        }
        reloadTable()
        tableView.reloadData()
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let data: Dictionary<String, Any> = jsonObject as! Dictionary<String, Any>
                self.data = TableData(data)
                self.showMore = false
                var rowsDataCount = 0
                for _ in self.data.rows {
                    rowsDataCount += 1
                    if rowsDataCount == rowsDataLimit {
                        self.showMore = true
                        break
                    }
                }
                self.showMoreButton.isHidden = !self.showMore
                if let txt = jsonObject["text"] as? String{
                    self.titleLbl?.setHTMLString(txt, withWidth: kMaxTextWidth)
                }else{
                    self.titleLbl?.text = ""
                }
                
                let placeHolderIcon = UIImage(named: "kora", in: Bundle.sdkModule, compatibleWith: nil)
                self.senderImageView.image = placeHolderIcon
                if (botHistoryIcon != nil) {
                    if let fileUrl = URL(string: botHistoryIcon!) {
                        self.senderImageView.af.setImage(withURL: fileUrl, placeholderImage: placeHolderIcon)
                    }
               }
                self.tableView.reloadData()
                
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        var height: CGFloat = 44.0
        let noOfUnselectedRows = rowsDataLimit - indexPaths.count
        height = (CGFloat(noOfUnselectedRows * 44)) + 6
        for i in  0..<(indexPaths.count) {
            height = height + CGFloat(data.rows[i].count * 44)
        }
        
        if self.showMore {
            height += 36.0
        }
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        
        return CGSize(width: 0.0, height: height + 45 + Double(textSize.height))
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(showTableTemplateNotification), object: jsonString)
            }
        }
    }
    @objc fileprivate func reloadTable() {
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
}

