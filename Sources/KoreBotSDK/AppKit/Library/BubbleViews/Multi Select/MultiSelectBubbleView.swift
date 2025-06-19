//
//  MultiSelectBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 8/17/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class MultiSelectBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let multiSelectCellIdentifier = "MultiSelectCell"
    let rowsDataLimit = 4
    var arrayOfHeaderCheck = [String]()
    var checkboxIndexPath = [IndexPath]() //for Rows checkbox
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: boldCustomFont, size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.blue,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    public var maskview: UIView!
    var arrayOfElements = [ComponentElements]()
    var arrayOfButtons = [ComponentItemAction]()
    var showMore = false
    var messageId = ""
    var componentDescDic:[String:Any] = [:]
    //public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    //public var linkAction: ((_ text: String?) -> Void)!
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
    
    override func prepareForReuse() {
        checkboxIndexPath = [IndexPath]()
         arrayOfSeletedValues = [String]()
    }
    
    override func initialize() {
        super.initialize()
       // UserDefaults.standard.set(false, forKey: "SliderKey")
        intializeCardLayout()
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = true
        self.tableView.register(Bundle.xib(named: multiSelectCellIdentifier), forCellReuseIdentifier: multiSelectCellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        self.maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[tableView]-5-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        if #available(iOS 15.0, *){
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
    }
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.backgroundColor =  UIColor.white
        cardView.layer.cornerRadius = 4.0
        cardView.layer.borderWidth = 0.0
        cardView.layer.borderColor = BubbleViewLeftTint.cgColor
        cardView.clipsToBounds = true
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.message != nil) {
                let jsonString = component.message?.messageId
                print(jsonString!)
                
            }
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                componentDescDic = jsonObject as! [String : Any]
                messageId = component.message?.messageId ?? ""
                let jsonDecoder = JSONDecoder()
                 guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                arrayOfSeletedValues = []
                arrayOfElements = allItems.elements ?? []
                arrayOfButtons = allItems.buttons ?? []
                arrayOfHeaderCheck = []
                arrayOfHeaderCheck.append("UnCheck")
                if let slectedValue = jsonObject["selectedValue"] as? [String: Any]{
                    print(slectedValue)
                    if let value = slectedValue["value"] as? [[String: Any]]{
                        for i in 0..<value.count{
                            let selectedIndexpath = value[i]
                            let section = selectedIndexpath["section"] as! Int
                            let row = selectedIndexpath["row"] as! Int
                            let indexPath = IndexPath(row: row , section: section)
                            checkboxIndexPath.append(indexPath)
                        }
                    }
                    if arrayOfElements.count == checkboxIndexPath.count{
                        arrayOfHeaderCheck = []
                        arrayOfHeaderCheck.append("Check")
                    }
                }
                self.tableView.reloadData()
                
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        var cellHeight : CGFloat = 0.0
        let rows = arrayOfElements.count //> rowsDataLimit ? rowsDataLimit : arrayOfElements.count
        var finalHeight: CGFloat = 0.0
        for i in 0..<rows {
            let row = tableView.dequeueReusableCell(withIdentifier: multiSelectCellIdentifier, for: IndexPath(row: i, section: 0))as! MultiSelectCell
            cellHeight = row.bounds.height
            finalHeight += cellHeight
        }
        let footerViewHeight = 50.0
        let headerViewHeight = 50.0
        return CGSize(width: 0.0, height: finalHeight+footerViewHeight + headerViewHeight)
    }
    
    @objc fileprivate func SelectAllButtonAction(_ sender: UIButton!) {
        if arrayOfHeaderCheck[sender.tag] == "Check" {
            arrayOfHeaderCheck[sender.tag] = "Uncheck"
            
            for i in 0..<arrayOfElements.count{
                let elements = arrayOfElements[i]
                    let indexPath = IndexPath(row: i , section: sender.tag)
                    if checkboxIndexPath.contains(indexPath) {
                        removeSelectedValues(value: elements.value ?? "", title: elements.title ?? "")
                        checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
                    }
            }
        }else{
            arrayOfHeaderCheck[sender.tag] = "Check"
            for i in 0..<arrayOfElements.count{
                    let indexPath = IndexPath(row: i , section: sender.tag)
                   let elements = arrayOfElements[i]
                    if checkboxIndexPath.contains(indexPath) {
                        
                    }else{
                        checkboxIndexPath.append(indexPath)
                        let value = "\(elements.value ?? "")"
                        arrayOfSeletedValues.append(value)
                        let title = "\(elements.title ?? "")"
                        arrayOfSeletedTitles.append(title)
                    }
            }
        }
        tableView.reloadData()
    }
    
    func insertSelectedValueIntoComponectDesc(value: [IndexPath]){
        var indexPathArry: [[String: Any]] = []
        var indexpathDic:[String:Any] = [:]
        for indexPath in value {
            print("Selected section: \(indexPath.section), row: \(indexPath.row)")
            indexpathDic["section"] = indexPath.section
            indexpathDic["row"] = indexPath.row
            indexPathArry.append(indexpathDic)
        }
        let dic = ["value": indexPathArry]
        componentDescDic["selectedValue"] = dic
        self.updateMessage?(messageId, Utilities.stringFromJSONObject(object: componentDescDic))
    }
}
extension MultiSelectBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfElements.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : MultiSelectCell = self.tableView.dequeueReusableCell(withIdentifier: multiSelectCellIdentifier) as! MultiSelectCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let elements = arrayOfElements[indexPath.row]
        cell.titleLabel.text = elements.title
        cell.titleLabel.textColor = BubbleViewBotChatTextColor
        cell.titleLabel.font = UIFont.init(name: regularCustomFont, size: 15.0)
        
        cell.bgV.backgroundColor = .white
        cell.bgV.layer.borderColor = BubbleViewLeftTint.cgColor
        cell.bgV.layer.borderWidth = 1.0
        cell.bgV.layer.cornerRadius = 3.0
        cell.bgV.clipsToBounds = true
        
        if checkboxIndexPath.contains(indexPath) {
            let imgV = UIImage.init(named: "check", in: bundle, compatibleWith: nil)
            cell.checkImage.image = imgV?.withRenderingMode(.alwaysTemplate)
            cell.checkImage.tintColor = themeColor
        }else{
            let imgV = UIImage.init(named: "uncheck", in: bundle, compatibleWith: nil)
            cell.checkImage.image = imgV?.withRenderingMode(.alwaysTemplate)
            cell.checkImage.tintColor = BubbleViewLeftTint
        }
        return cell
        
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let elements = arrayOfElements[indexPath.row]
//        if checkboxIndexPath.contains(indexPath) {
//            removeSelectedValues(value: elements.title!)
//            checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
//        }else{
//            checkboxIndexPath.append(indexPath)
//            let value = "\(elements.title!)"
//            arrayOfSeletedValues.append(value)
//        }
//        tableView.reloadRows(at: [indexPath], with: .none)
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfElements[indexPath.row]
        
        if checkboxIndexPath.contains(indexPath) {
            removeSelectedValues(value: elements.value ?? "", title: elements.title ?? "")
            checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
        }else{
            checkboxIndexPath.append(indexPath)
            let value = "\(elements.value ?? "")"
            arrayOfSeletedValues.append(value)
            let title = "\(elements.title ?? "")"
            arrayOfSeletedTitles.append(title)
        }
        var zzz = 0
        
        for i in 0..<arrayOfElements.count{
                let elementsCollection = arrayOfElements[i]
                let collectionTitle = elementsCollection.value
                for j in 0..<arrayOfSeletedValues.count{
                    let selectedTitles = arrayOfSeletedValues[j]
                    if collectionTitle == selectedTitles{
                        zzz += 1
                    }
                }
            
            if zzz == arrayOfElements.count{
                arrayOfHeaderCheck[indexPath.section] = "Check"
            }else{
                arrayOfHeaderCheck[indexPath.section] = "Uncheck"
            }
        }
        tableView.reloadData()
    }
    func removeSelectedValues(value:String,title:String){
        arrayOfSeletedValues = arrayOfSeletedValues.filter(){$0 != value}
        arrayOfSeletedTitles = arrayOfSeletedTitles.filter(){$0 != title}
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return 50
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
            let showMoreButton = UIButton(frame: CGRect.zero)
            showMoreButton.backgroundColor = .clear
            showMoreButton.translatesAutoresizingMaskIntoConstraints = false
            showMoreButton.clipsToBounds = true
            showMoreButton.layer.cornerRadius = 5
            showMoreButton.layer.borderColor = UIColor.clear.cgColor
            showMoreButton.layer.borderWidth = 1
            showMoreButton.setTitleColor(.blue, for: .normal)
            showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            showMoreButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 12.0)
            view.addSubview(showMoreButton)
            showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
            showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
            if arrayOfButtons.count>0{
                let btnTitle: String = arrayOfButtons[0].title ?? "Done"
                let attributeString = NSMutableAttributedString(string: btnTitle,
                                                                attributes: yourAttributes)
               // showMoreButton.setAttributedTitle(attributeString, for: .normal)
                showMoreButton.setTitle(btnTitle, for: .normal)
            }
        
            showMoreButton.backgroundColor = bubbleViewBotChatButtonBgColor
            showMoreButton.setTitleColor(bubbleViewBotChatButtonTextColor, for: .normal)
            let views: [String: UIView] = ["showMoreButton": showMoreButton]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(35)]-0-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[showMoreButton]-0-|", options:[], metrics:nil, views:views))
        return view
    }
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if arrayOfSeletedValues.count > 0{
            self.maskview.isHidden = false
            insertSelectedValueIntoComponectDesc(value: checkboxIndexPath)
            let joinedValues = arrayOfSeletedValues.joined(separator: ", ")
            let joinedTitles = arrayOfSeletedTitles.joined(separator: ", ")
            self.optionsAction?(joinedTitles,joinedValues)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let checkImg = UIButton(frame: CGRect.zero)
        checkImg.backgroundColor = .clear
        checkImg.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(checkImg)
        if arrayOfHeaderCheck[section] == "Check" {
            let menuImage = UIImage(named: "check", in: bundle, compatibleWith: nil)
            let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
            checkImg.setImage(tintedMenuImage, for: .normal)
            checkImg.tintColor = themeColor
        }else{
            let menuImage = UIImage(named: "uncheck", in: bundle, compatibleWith: nil)
            let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
            checkImg.setImage(tintedMenuImage, for: .normal)
            checkImg.tintColor = BubbleViewLeftTint
        }
        
        let titleLbl = UILabel(frame: CGRect.zero)
        titleLbl.textColor = BubbleViewBotChatTextColor
        titleLbl.font = UIFont(name: regularCustomFont, size: 15.0)
        titleLbl.text = "Select All"
        titleLbl.numberOfLines = 0
        titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLbl.isUserInteractionEnabled = true
        titleLbl.contentMode = UIView.ContentMode.topLeft
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLbl)
        titleLbl.adjustsFontSizeToFitWidth = true
        titleLbl.backgroundColor = .clear
        titleLbl.layer.cornerRadius = 6.0
        titleLbl.clipsToBounds = true
        titleLbl.sizeToFit()
        
        let checkBtn = UIButton(frame: CGRect.zero)
        checkBtn.backgroundColor = .clear
        checkBtn.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(checkBtn)
        checkBtn.addTarget(self, action: #selector(self.SelectAllButtonAction(_:)), for: .touchUpInside)
        checkBtn.tag = section
        
        let views: [String: UIView] = ["checkImg": checkImg, "titleLbl": titleLbl,"checkBtn": checkBtn]
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[checkImg(20)]", options:[], metrics:nil, views:views))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[titleLbl(20)]", options:[], metrics:nil, views:views))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-1-[checkImg(20)]-10-[titleLbl]-10-|", options:[], metrics:nil, views:views))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[checkBtn]-0-|", options:[], metrics:nil, views:views))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[checkBtn]-0-|", options:[], metrics:nil, views:views))
        return headerView
    }

   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//       if (cell.responds(to: #selector(getter: UIView.tintColor))) {
//           let cornerRadius: CGFloat = 5
//           cell.backgroundColor = UIColor.clear
//           let layer: CAShapeLayer  = CAShapeLayer()
//           let pathRef: CGMutablePath  = CGMutablePath()
//           let bounds: CGRect  = cell.bounds.insetBy(dx: 0, dy: 0)
//           var addLine: Bool  = false
//           if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
//               pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
//           } else if (indexPath.row == 0) {
//               pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.maxY))
//               pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.minY), tangent2End: CGPoint(x:bounds.midX,y:bounds.minY), radius: cornerRadius)
//
//               pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.minY), tangent2End: CGPoint(x:bounds.maxX,y:bounds.midY), radius: cornerRadius)
//               pathRef.addLine(to: CGPoint(x:bounds.maxX,y:bounds.maxY))
//               addLine = true;
//           } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
//
//               pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.minY))
//               pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.midX,y:bounds.maxY), radius: cornerRadius)
//
//               pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.maxX,y:bounds.midY), radius: cornerRadius)
//               pathRef.addLine(to: CGPoint(x:bounds.maxX,y:bounds.minY))
//
//           } else {
//               pathRef.addRect(bounds)
//               addLine = true
//           }
//           layer.path = pathRef
//           //CFRelease(pathRef)
//           //set the border color
//           layer.strokeColor = BubbleViewLeftTint.cgColor;
//           //set the border width
//           layer.lineWidth = 1
//           layer.fillColor = UIColor(white: 1, alpha: 1.0).cgColor
//
//
//           if (addLine == true) {
//               let lineLayer: CALayer = CALayer()
//               let lineHeight: CGFloat  = (0.5 / UIScreen.main.scale)
//               lineLayer.frame = CGRect(x:bounds.minX, y:bounds.size.height-lineHeight, width:bounds.size.width, height:lineHeight)
//               lineLayer.backgroundColor = tableView.separatorColor!.cgColor
//               layer.addSublayer(lineLayer)
//           }
//
//           let testView: UIView = UIView(frame:bounds)
//           testView.layer.insertSublayer(layer, at: 0)
//           testView.backgroundColor = UIColor.clear
//           cell.backgroundView = testView
//       }
       
   }
}

