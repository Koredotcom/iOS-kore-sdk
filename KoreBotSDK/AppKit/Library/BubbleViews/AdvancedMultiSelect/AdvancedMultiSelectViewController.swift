//
//  AdvancedMultiSelectViewController.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 08/05/25.
//

import UIKit
protocol AdvancedMultiSelectDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}
class AdvancedMultiSelectViewController: UIViewController {
    let bundle = Bundle.sdkModule
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var tabV: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    var jsonData : Componentss?
    var dataString: String!
    fileprivate let multiSelectCellIdentifier = "AdvancedMultiSelectCell"
    var sectionLimit = 1
    var isShowMoreIsHidden = false
    var checkboxIndexPath = [IndexPath]() //for Rows checkbox
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    var arrayOfHeaderCheck = [String]()
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: boldCustomFont, size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : BubbleViewUserChatTextColor]
    
    var arrayOfElements = [ComponentElements]()
    var arrayOfButtons = [ComponentItemAction]()
    var showMore = false
    var viewDelegate: AdvancedMultiSelectDelegate?
    
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerLbl.textColor = BubbleViewBotChatTextColor
        headerLbl.font = UIFont.init(name: boldCustomFont, size: 15.0)
        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            self.subView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
        getData()
        //self.tabV.tableFooterView = UIView(frame:.zero)
        self.tabV.register(Bundle.xib(named: multiSelectCellIdentifier), forCellReuseIdentifier: multiSelectCellIdentifier)
    }
    func getData(){
       let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
            let jsonDecoder = JSONDecoder()
            guard let jsonData1 = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData1) else {
                        return
                }
        jsonData = allItems
        headerLbl.text = jsonData?.heading ?? ""
        
        doneButton.backgroundColor = themeColor
        doneButton.clipsToBounds = true
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderColor = themeColor.cgColor
        doneButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 15.0)
        doneButton.layer.borderWidth = 1
        doneButton.setTitleColor(BubbleViewUserChatTextColor, for: .normal)
        doneButton.addTarget(self, action: #selector(self.doneButtonButtonAction(_:)), for: .touchUpInside)
    
        if arrayOfButtons.count>0{
            let btnTitle: String = arrayOfButtons[0].title!
            let attributeString = NSMutableAttributedString(string: btnTitle,
                                                            attributes: yourAttributes)
            doneButton.setAttributedTitle(attributeString, for: .normal)
        }
            
        arrayOfSeletedValues = []
        arrayOfSeletedTitles = []
        arrayOfElements = allItems.elements ?? []
        arrayOfButtons = allItems.buttons ?? []
        if !isShowMoreIsHidden{
            sectionLimit = allItems.limit ?? arrayOfElements.count
            for _ in 0..<arrayOfElements.count{
                arrayOfHeaderCheck.append("Uncheck")
            }
        }
        self.tabV.reloadData()
        hideDoneButton()
    }

    init(dataString: String) {
        super.init(nibName: "AdvancedMultiSelectViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func closeBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func dontButtonAction(_ sender: Any) {
    }
    

}

extension AdvancedMultiSelectViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionLimit
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let elementsCollection = arrayOfElements[section]
        return elementsCollection.collection?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : AdvancedMultiSelectCell = tableView.dequeueReusableCell(withIdentifier: multiSelectCellIdentifier) as! AdvancedMultiSelectCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let elements = arrayOfElements[indexPath.section]
        let elementsCollection = elements.collection?[indexPath.row]
        cell.titleLbl.text = elementsCollection?.title
        cell.descLbl.text = elementsCollection?.descrip
        
        if let urlStr = elementsCollection?.image_url, let url = URL(string: urlStr){
            cell.imagV.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image"))
            cell.imgVWidthConstraint.constant = 52.0
            cell.imgVLeadingConstraint.constant = 5.0
        }else{
            cell.imgVWidthConstraint.constant = 0.0
            cell.imgVLeadingConstraint.constant = 0.0
        }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfElements[indexPath.section]
        let elementsCollection = elements.collection?[indexPath.row]
        if checkboxIndexPath.contains(indexPath) {
            removeSelectedValues(value: elementsCollection?.value ?? "", title: elementsCollection?.title ?? "")
            checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
        }else{
            checkboxIndexPath.append(indexPath)
            let value = "\(elementsCollection?.value ?? "")"
            arrayOfSeletedValues.append(value)
            let title = "\(elementsCollection?.title ?? "")"
            arrayOfSeletedTitles.append(title)
        }
        var zzz = 0
        if let collectionCount = elements.collection?.count{
            for i in 0..<collectionCount{
                let elementsCollection = elements.collection?[i]
                let collectionTitle = elementsCollection?.value
                for j in 0..<arrayOfSeletedValues.count{
                    let selectedTitles = arrayOfSeletedValues[j]
                    if collectionTitle == selectedTitles{
                        zzz += 1
                    }
                }
            }
            if zzz == collectionCount{
                arrayOfHeaderCheck[indexPath.section] = "Check"
            }else{
                arrayOfHeaderCheck[indexPath.section] = "Uncheck"
            }
        }
        tableView.reloadData()
        hideDoneButton()
    }
    func hideDoneButton(){
        if arrayOfSeletedValues.count > 0{
            doneButton.isHidden = false
        }else{
            doneButton.isHidden = true
        }
    }
    func removeSelectedValues(value:String,title:String){
        arrayOfSeletedValues = arrayOfSeletedValues.filter(){$0 != value}
        arrayOfSeletedTitles = arrayOfSeletedTitles.filter(){$0 != title}
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let elements = arrayOfElements[section]
        if let elementsCollection = elements.collection?.count, elementsCollection == 1{
            return 45.0
        }else{
            return 75.0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let headerSubView  = AdvancedMultiSelectHeaderV()
        headerSubView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerSubView)
        let elements = arrayOfElements[section]
        if let elementsCollection = elements.collection?.count, elementsCollection == 1{
            headerSubView.selectallVHeightConstraint.constant = 0.0
        }else{
            headerSubView.selectallVHeightConstraint.constant = 30.0
        }
        headerSubView.titleLbl.text = elements.collectionTitle
        headerSubView.titleLbl.font =  UIFont(name: boldCustomFont, size: 15.0)
        headerSubView.descLbl.font =  UIFont(name: mediumCustomFont, size: 14.0)
        headerSubView.descLbl.textColor = BubbleViewBotChatTextColor
        headerSubView.headerCheckBtn.addTarget(self, action: #selector(self.SelectAllButtonAction(_:)), for: .touchUpInside)
        headerSubView.headerCheckBtn.tag = section
        
        if arrayOfHeaderCheck[section] == "Check" {
            let menuImage = UIImage(named: "check", in: bundle, compatibleWith: nil)
            let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
            headerSubView.headerCheckBtn.setImage(tintedMenuImage, for: .normal)
            headerSubView.headerCheckBtn.tintColor = themeColor
        }else{
            let menuImage = UIImage(named: "uncheck", in: bundle, compatibleWith: nil)
            let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
            headerSubView.headerCheckBtn.setImage(tintedMenuImage, for: .normal)
            headerSubView.headerCheckBtn.tintColor = BubbleViewLeftTint
        }
        
        let views: [String: UIView] = ["headerSubView": headerSubView]
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerSubView]-5-|", options:[], metrics:nil, views:views))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-1-[headerSubView]-1-|", options:[], metrics:nil, views:views))
        return headerView
    }
    @objc fileprivate func SelectAllButtonAction(_ sender: UIButton!) {
        let elements = arrayOfElements[sender.tag]
        if arrayOfHeaderCheck[sender.tag] == "Check" {
            arrayOfHeaderCheck[sender.tag] = "Uncheck"
            if let collectionCount = elements.collection?.count{
                for i in 0..<collectionCount{
                    let indexPath = IndexPath(row: i , section: sender.tag)
                    let elementsCollection = elements.collection?[i]
                    if checkboxIndexPath.contains(indexPath) {
                        removeSelectedValues(value: elementsCollection?.value ?? "", title: elementsCollection?.title ?? "")
                        checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
                    }
                }
            }
        }else{
            arrayOfHeaderCheck[sender.tag] = "Check"
            if let collectionCount = elements.collection?.count{
                for i in 0..<collectionCount{
                    let indexPath = IndexPath(row: i , section: sender.tag)
                    let elementsCollection = elements.collection?[i]
                    if checkboxIndexPath.contains(indexPath) {
                        
                    }else{
                        checkboxIndexPath.append(indexPath)
                        let value = "\(elementsCollection?.value ?? "")"
                        arrayOfSeletedValues.append(value)
                        let title = "\(elementsCollection?.title ?? "")"
                        arrayOfSeletedTitles.append(title)
                    }
                }
            }
        }
        tabV.reloadData()
        hideDoneButton()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if arrayOfElements.count > 1{
            let lastIndex = sectionLimit - 1
            if lastIndex == section{
                return 40
            }
            return 00
        }
        return 00
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        let showMoreButton = UIButton(frame: CGRect.zero)
        showMoreButton.backgroundColor = .clear
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.clipsToBounds = true
        showMoreButton.layer.cornerRadius = 5
        showMoreButton.layer.borderWidth = 1
        showMoreButton.layer.borderColor = UIColor.clear.cgColor
        showMoreButton.setTitleColor(BubbleViewBotChatTextColor, for: .normal)
        showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreButton.setTitle("View more", for: .normal)
        showMoreButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 15.0)
        view.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        showMoreButton.isHidden = isShowMoreIsHidden
        
        let doneButton = UIButton(frame: CGRect.zero)
        doneButton.backgroundColor = themeColor
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.clipsToBounds = true
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderColor = themeColor.cgColor
        doneButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 12.0)
        doneButton.layer.borderWidth = 1
        doneButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        view.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(self.doneButtonButtonAction(_:)), for: .touchUpInside)
        doneButton.isHidden = true
        if arrayOfButtons.count>0{
            let btnTitle: String = arrayOfButtons[0].title!
            let attributeString = NSMutableAttributedString(string: btnTitle,
                                                            attributes: yourAttributes)
            doneButton.setAttributedTitle(attributeString, for: .normal)
        }
        
        
        let views: [String: UIView] = ["showMoreButton": showMoreButton, "doneButton": doneButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton(40)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[showMoreButton(100)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[doneButton(40)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[doneButton(100)]-10-|", options:[], metrics:nil, views:views))
        return view
    }
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
            isShowMoreIsHidden = true
            sectionLimit = arrayOfElements.count
            tabV.reloadData()
    }
    
    @objc fileprivate func doneButtonButtonAction(_ sender: AnyObject!) {
        if arrayOfSeletedValues.count > 0{
            let joinedValues = arrayOfSeletedValues.joined(separator: ", ")
            let joinedTitles = arrayOfSeletedTitles.joined(separator: ", ")
            print(joinedTitles)
            self.dismiss(animated: true, completion: nil)
            self.viewDelegate?.optionsButtonTapNewAction(text: "Here are selected items: \(joinedTitles)", payload: joinedValues)
        }
    }
}
