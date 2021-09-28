//
//  MultiSelectNewBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 8/17/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class MultiSelectNewBubbleView: BubbleView {
    static let elementsLimit: Int = 4
    
    var tileBgv: UIView!
    var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let multiSelectCellIdentifier = "MultiSelectCell"
    let rowsDataLimit = 4
    
    var checkboxIndexPath = [IndexPath]() //for Rows checkbox
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    
    override func prepareForReuse() {
        checkboxIndexPath = [IndexPath]()
         arrayOfSeletedValues = [String]()
        arrayOfSeletedTitles = [String]()
    }
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Gilroy-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.blue,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    var arrayOfElements = [ComponentElements]()
    var arrayOfButtons = [ComponentItemAction]()
    var showMore = false
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
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
                   self.tileBgv.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 1.5)
               } else {
                   // Fallback on earlier versions
               }
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .singleLine
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = true
        self.tableView.register(UINib(nibName: multiSelectCellIdentifier, bundle: frameworkBundle), forCellReuseIdentifier: multiSelectCellIdentifier)
        
        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[tileBgv]-10-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))

        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.font = UIFont(name: "Gilroy-Medium", size: 16.0)
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
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[titleLbl(>=31)]-5-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-10-|", options: [], metrics: nil, views: subView))
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
    
    // MARK: populate components
    override func populateComponents() {
        if selectedTheme == "Theme 1"{
            self.tileBgv.layer.borderWidth = 0.0
        }else{
            self.tileBgv.layer.borderWidth = 0.0
        }
        
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.message != nil) {
                let jsonString = component.message?.messageId
                print(jsonString!)
                
            }
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                 guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                
                self.titleLbl.text = allItems.heading ?? ""
                arrayOfElements = allItems.elements ?? []
                arrayOfButtons = allItems.buttons ?? []
                self.tableView.reloadData()
                
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
        
        var cellHeight : CGFloat = 0.0
        let rows = arrayOfElements.count //> rowsDataLimit ? rowsDataLimit : arrayOfElements.count
        var finalHeight: CGFloat = 0.0
        for i in 0..<rows {
            let row = tableView.dequeueReusableCell(withIdentifier: multiSelectCellIdentifier, for: IndexPath(row: i, section: 0))as! MultiSelectCell
            cellHeight = row.bounds.height
            finalHeight += cellHeight
        }
        return CGSize(width: 0.0, height: textSize.height+40+finalHeight+40)
    }
    
    @objc fileprivate func SelectAllButtonAction(_ sender: AnyObject!) {

    }
}
extension MultiSelectNewBubbleView: UITableViewDelegate,UITableViewDataSource{
    
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
        
        if checkboxIndexPath.contains(indexPath) {
            cell.checkImage.image = UIImage(named:"check")
        }else{
             cell.checkImage.image = UIImage(named:"uncheck")
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfElements[indexPath.row]
        if checkboxIndexPath.contains(indexPath) {
            removeSelectedTitles(title: elements.title!)
            if elements.value != nil{
                removeSelectedValues(value: elements.value!)
            }
            checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
        }else{
            checkboxIndexPath.append(indexPath)
            let title = "\(elements.title!)"
            arrayOfSeletedTitles.append(title)
            
            if elements.value != nil{
                let valaue = "\(elements.value!)"
                arrayOfSeletedValues.append(valaue)
            }
            
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    func removeSelectedValues(value:String){
        arrayOfSeletedValues = arrayOfSeletedValues.filter(){$0 != value}
        print(arrayOfSeletedValues)
    }
    func removeSelectedTitles(title:String){
        arrayOfSeletedTitles = arrayOfSeletedTitles.filter(){$0 != title}
        print(arrayOfSeletedTitles)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return 40
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
            let showMoreButton = UIButton(frame: CGRect.zero)
            showMoreButton.backgroundColor = .clear
            showMoreButton.translatesAutoresizingMaskIntoConstraints = false
            showMoreButton.clipsToBounds = true
            showMoreButton.layer.cornerRadius = 5
            showMoreButton.layer.borderColor = UIColor.lightGray.cgColor
            showMoreButton.layer.borderWidth = 1
            showMoreButton.setTitleColor(.blue, for: .normal)
            showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            showMoreButton.titleLabel?.font = UIFont(name: "Gilroy-Bold", size: 16.0)!
            view.addSubview(showMoreButton)
            showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
            showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
            if arrayOfButtons.count>0{
                let btnTitle: String = arrayOfButtons[0].title!
                let attributeString = NSMutableAttributedString(string: btnTitle,
                                                                attributes: yourAttributes)
                showMoreButton.setAttributedTitle(attributeString, for: .normal)
            }
            let views: [String: UIView] = ["showMoreButton": showMoreButton]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton(40)]-0-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[showMoreButton]-0-|", options:[], metrics:nil, views:views))
        return view
    }
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if arrayOfSeletedTitles.count > 0{
            let titles = arrayOfSeletedTitles.joined(separator: ", ")
            print(titles)
            
            var enter = 0
            if arrayOfSeletedValues.count > 0{
                let payload = arrayOfSeletedValues.joined(separator: ", ")
                print(payload)
                enter = 1
                self.optionsAction(titles,payload)
            }
            if enter == 0{
                self.optionsAction(titles,titles)
            }
        }
    }
   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       if (cell.responds(to: #selector(getter: UIView.tintColor))) {
           let cornerRadius: CGFloat = 5
           cell.backgroundColor = UIColor.clear
           let layer: CAShapeLayer  = CAShapeLayer()
           let pathRef: CGMutablePath  = CGMutablePath()
           let bounds: CGRect  = cell.bounds.insetBy(dx: 0, dy: 0)
           var addLine: Bool  = false
           if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
               pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
           } else if (indexPath.row == 0) {
               pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.maxY))
               pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.minY), tangent2End: CGPoint(x:bounds.midX,y:bounds.minY), radius: cornerRadius)
               
               pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.minY), tangent2End: CGPoint(x:bounds.maxX,y:bounds.midY), radius: cornerRadius)
               pathRef.addLine(to: CGPoint(x:bounds.maxX,y:bounds.maxY))
               addLine = true;
           } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
               
               pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.minY))
               pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.midX,y:bounds.maxY), radius: cornerRadius)
               
               pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.maxX,y:bounds.midY), radius: cornerRadius)
               pathRef.addLine(to: CGPoint(x:bounds.maxX,y:bounds.minY))
               
           } else {
               pathRef.addRect(bounds)
               addLine = true
           }
           layer.path = pathRef
           //CFRelease(pathRef)
           //set the border color
           layer.strokeColor = UIColor.lightGray.cgColor;
           //set the border width
           layer.lineWidth = 1
           layer.fillColor = UIColor(white: 1, alpha: 1.0).cgColor
           
           
           if (addLine == true) {
               let lineLayer: CALayer = CALayer()
               let lineHeight: CGFloat  = (0.5 / UIScreen.main.scale)
               lineLayer.frame = CGRect(x:bounds.minX, y:bounds.size.height-lineHeight, width:bounds.size.width, height:lineHeight)
               lineLayer.backgroundColor = tableView.separatorColor!.cgColor
               layer.addSublayer(lineLayer)
           }
           
           let testView: UIView = UIView(frame:bounds)
           testView.layer.insertSublayer(layer, at: 0)
           testView.backgroundColor = UIColor.clear
           cell.backgroundView = testView
       }
       
   }
}

