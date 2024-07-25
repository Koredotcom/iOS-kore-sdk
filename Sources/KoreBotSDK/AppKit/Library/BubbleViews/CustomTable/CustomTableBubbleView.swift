//
//  CustomTableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 05/01/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit
#if SWIFT_PACKAGE
import ObjcSupport
#endif
class CustomTableData {
    var headers: Array<Header> = Array<Header>()
    var rows: Array<Array<String>> = Array<Array<String>>()
     var columns: Array<Array<String>> = Array<Array<String>>()
    var elements:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var textOrBtnArrays: Array<Array<String>> = Array<Array<String>>()
    var btnActions:Array<Array<Dictionary<String, Any>>> = Array<Array<Dictionary<String, Any>>>()
    var tableDesign:String!
    
    convenience init(_ data: Dictionary<String, Any>){
        self.init()
        guard let columns = data["columns"] as? Array<Array<String>> else { return }
        guard let locelements = data["elements"] as? Array<Dictionary<String, Any>> else { return }
        elements = locelements
        self.columns = columns
        
        tableDesign = data["table_design"] != nil ? data["table_design"] as? String : "responsive"
        var percentage: Int = Int(floor(Double(100/columns.count)))
        for column in columns {
            let title = column[0]
            var alignment: NSTextAlignment = .left
            if column.count > 1, let align = column[1] as String? {
                if align == "right" {
                    alignment = .right
                } else if align == "center" {
                    alignment = .center
                }
            }
            if column.count > 2, let perc = column[2] as String? {
                percentage = Int(perc)!
            }
            headers.append(Header(title: title.uppercased(), alignment: alignment, percentage: percentage))
        }
        for element in elements {
            let values = element["Values"] as! Array<Any>
            var row = Array<String>()
            var textOrBtnArray = Array<String>()
            var btnAction = Array<Dictionary<String, Any>>()
            for value in values {
                let valueArray = value as! Array<Any>
                var val = ""
                var textOrBtnVal = ""
                var btnActionVal = [String: Any]()
                for i in 0..<valueArray.count{
                    
                    if i == 0 {
                        if let intt = valueArray[i] as? Int {
                             val = String(intt)
                          }
                          else if let str = valueArray[i] as? String {
                            val = str
                          }
                          else {
                            val = value as? String ?? ""
                          }
                    }else if i == 1{
                        if let intt = valueArray[i] as? Int {
                            textOrBtnVal = String(intt)
                          }
                          else if let str = valueArray[i] as? String {
                            textOrBtnVal = str
                          }
                          else {
                            textOrBtnVal = value as? String ?? ""
                          }
                    }else if i == 2{
                        btnActionVal =  valueArray[i] as? [String : Any] ?? [:]
                    }
                }
                row.append(val)
                textOrBtnArray.append(textOrBtnVal)
                btnAction.append(btnActionVal)
            }
            rows.append(row)
            textOrBtnArrays.append(textOrBtnArray)
            btnActions.append(btnAction)
            print(btnActions)
        }
        print(rows)
        print(headers)
        print(textOrBtnArrays)
        print(btnActions)
    }
}

class CustomTableBubbleView: BubbleView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    var showMoreButton: UIButton!
    var cardView: UIView!
    
    let customCellIdentifier = "CustomTableViewCell"
    var data: CustomTableData = CustomTableData()
    var rowsDataLimit = 5
    var rows: Array<Array<String>> = Array<Array<String>>()
    var itemWidth:CGFloat = 0.0
    var count = 0
    var tileBgv: UIView!
    var titleLbl: UILabel!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var senderImageView: UIImageView!
    
    var showMore = false
    
    //public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    //public var linkAction: ((_ text: String?) -> Void)!
    
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
        cardView.layer.shadowRadius = 10.0
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.white
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.tileBgv)
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 2.0
        self.tileBgv.clipsToBounds = true
        self.tileBgv.backgroundColor =  .white
        if #available(iOS 11.0, *) {
            self.tileBgv.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 15.0, borderColor: UIColor.clear, borderWidth: 1.5)
        } else {
            
        }
        
        self.senderImageView = UIImageView()
        self.senderImageView.contentMode = .scaleAspectFit
        self.senderImageView.clipsToBounds = true
        self.senderImageView.layer.cornerRadius = 15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.senderImageView)
        
        let cardViews: [String: UIView] = ["senderImageView": senderImageView, "tileBgv": tileBgv, "cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[senderImageView(30)]", options: [], metrics: nil, views: cardViews))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[senderImageView(0)]-10-[tileBgv]", options: [], metrics: nil, views: cardViews))
        
        
        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
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
        
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-16-|", options: [], metrics: metrics, views: subView))
        
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
        
        self.collectionView.register(Bundle.xib(named: "CustomTableViewCell"),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        self.showMoreButton = UIButton.init(frame: CGRect.zero)
        self.showMoreButton.setTitle("Show More", for: .normal)
        self.showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.showMoreButton.setTitleColor(UIColor(red: 95/255, green: 107/255, blue: 247/255, alpha: 1), for: .normal)
        self.showMoreButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
        self.showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        self.showMoreButton.isHidden = true
        self.showMoreButton.clipsToBounds = true
        self.cardView.addSubview(self.showMoreButton)
        
        let views: [String: UIView] = ["collectionView": collectionView, "showMoreButton": showMoreButton]
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[collectionView]-15-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[collectionView]-15-|", options: [], metrics: nil, views: views))
        
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(36.0)]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[showMoreButton]-15-|", options: [], metrics: nil, views: views))
    }
    
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return rowsDataLimit + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            let headers = self.data.headers
            return headers.count
        } else if section == 1 {
            return 1
        } else {
            let headers = self.data.headers
            return headers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomTableViewCell
        cell.backgroundColor = .clear
        cell.bgView.backgroundColor = .white
        cell.textLabel.textColor = .black
        let headers = self.data.headers
        let header = headers[indexPath.row]
        cell.bgView.layer.cornerRadius = 0.0
        
        cell.underLineLbl.backgroundColor = .blue
        
        //let bgColor = self.data.elementsStyle[indexPath.row]
        //cell.bgView.backgroundColor = UIColor.init(hexString: bgColor)
        cell.textLabel.attributedText = nil
        if indexPath.section == 0 {
            cell.textLabel.numberOfLines = 2
            cell.textLabel.text = header.title
            cell.textLabel.font = UIFont(name: boldCustomFont, size: 14.0)
            cell.textLabel.textAlignment = header.alignment
            cell.bgView.backgroundColor = .clear
            cell.textLabel.textColor = .black
        } else if indexPath.section == 1 {
            cell.textLabel.text = ""
            cell.backgroundColor = .clear
            cell.textLabel.textAlignment = header.alignment
            cell.underLineLbl.backgroundColor = .lightGray
        } else {
            cell.underLineLbl.backgroundColor = .lightGray
            let rows = self.data.rows
            let sec = indexPath.section - 2
            let row = rows[sec]
            let text = row[indexPath.row]
            //cell.bgView.backgroundColor = UIColor.init(hexString: self.data.elementsStyle[sec])
           // cell.underLineLbl.backgroundColor = UIColor.init(hexString: self.data.elementsStyle[sec])
            
            let textOrBtnArrays = self.data.textOrBtnArrays
            let textOrBtnArray = textOrBtnArrays[sec]
            let textOrBtn = textOrBtnArray[indexPath.row]
            
            if text == "---" {
                cell.textLabel.text = ""
                cell.backgroundColor = .white
            } else {
                cell.textLabel.text = row[indexPath.row]
                cell.textLabel.numberOfLines = 2
                cell.textLabel.font = UIFont(name: regularCustomFont, size: 14.0)
                cell.textLabel.textAlignment = header.alignment
                
                if textOrBtn == "button"{
                    cell.textLabel.textColor = .blue
                    
                    let btnActions = self.data.btnActions
                    let btnAction = btnActions[sec]
                    let action = btnAction[indexPath.row]
                    print("\(action)")
                    if action["type"] as? String == "web_url"{
                        cell.textLabel.attributedText = NSAttributedString(string: row[indexPath.row], attributes:
                                                                            [.underlineStyle: NSUnderlineStyle.single.rawValue])
                    }else if action["type"] as? String == "postback"{
                        
                    }
                }
                
                //Set Corner Radious
                if indexPath.row == 0 {
                    if #available(iOS 11.0, *) {
                        cell.bgView.roundCorners([ .layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 6.0, borderColor: UIColor.clear, borderWidth: 1.5)
                    }
                }
                if indexPath.row == row.count - 1 {
                    if #available(iOS 11.0, *) {
                        cell.bgView.roundCorners([ .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 6.0, borderColor: UIColor.clear, borderWidth: 1.5)
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let headers = self.data.headers
        let header = headers[indexPath.row]
        let percentage = header.percentage
        let count = CGFloat(headers.count)
        
        let viewWidth = UIScreen.main.bounds.size.width - 40
        let maxWidth: CGFloat = viewWidth - 5*(count-1)
        if(data.headers.count<5){
            itemWidth = floor((maxWidth*CGFloat(percentage)/100))
        }
        else{
            let width : CGFloat = (header.title as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont(name: boldCustomFont, size: 14.0) as Any]).width*2.0
            itemWidth = width
        }
        
        if indexPath.section == 0 {
            return CGSize(width: itemWidth - 2, height: 60)
        } else if indexPath.section == 1 {
            return CGSize(width: -1, height: 1)
        } else {
            let rows = self.data.rows
            let row = rows[indexPath.section - 2]
            let text = row[indexPath.row]
            if text == "---" {
                return CGSize(width: 0, height: 1)
            }
            return CGSize(width: itemWidth - 6, height: 50)//kk 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
           
        } else if indexPath.section == 1 {
            
        } else {
            let rows = self.data.rows
            let sec = indexPath.section - 2
            let row = rows[sec]
            let text = row[indexPath.row]
          
            let textOrBtnArrays = self.data.textOrBtnArrays
            let textOrBtnArray = textOrBtnArrays[sec]
            let textOrBtn = textOrBtnArray[indexPath.row]
            
            if text == "---" {
               
            } else {
                if textOrBtn == "button"{
                    
                    let btnActions = self.data.btnActions
                    let btnAction = btnActions[sec]
                    let action = btnAction[indexPath.row]
                    print("\(action)")
                    if action["type"] as? String == "web_url"{
                        print("\(action["url"] ?? "")")
                        self.linkAction?(action["url"] as? String)
                    }else if action["type"] as? String == "postback"{
                        self.optionsAction?(row[indexPath.row] ,action["payload"] as? String)
                    }
                    
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if(data.columns.count > 0){
            return  0.0//(CGFloat(100/data.columns.count))
        }
        else{
            return 100.0
        }
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                let data: Dictionary<String, Any> = jsonObject as! Dictionary<String, Any>
                self.data = CustomTableData(data)
                let rowsData = self.data.rows
                self.showMore = false
                var rowsDataCount = 0
                var index = 0
                for row in self.data.rows {
                    index += 1
                    let text = row[0]
                    if text != "---" {
                        rowsDataCount += 1
                    }
                    if rowsDataCount == rowsDataLimit {
                        self.showMore = true
                        break
                    }
                }
                let  rowLimit = self.data.rows.count > rowsDataLimit ? rowsDataLimit : self.data.rows.count
                self.showMore = self.data.rows.count > 5 ? true : false
                rowsDataLimit = rowLimit
                
                self.rows = Array(rowsData.dropLast(rowsData.count - index))
                if self.showMore && self.data.rows[self.data.rows.count-1][0] != "---" {
//                    self.data.rows.append(["---"])
                }
                self.titleLbl.text = jsonObject["text"] as? String
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                self.showMoreButton.isHidden = !self.showMore
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        
        
        let rows = self.data.rows
        var height: CGFloat =  50.0
        for i in 0..<rowsDataLimit {  //rowsDataLimit self.rows.count
            let row = rows[i]
            let text = row[0]
            if text == "---" {
                height += 1.0
            } else {
                height += 50.0
            }
        }
        if self.showMore {
            height += 44.0
        }
        
        return CGSize(width: 0.0, height: textSize.height + height + 60)
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(showCustomTableTemplateNotification), object: jsonString)
            }
        }
    }
}
