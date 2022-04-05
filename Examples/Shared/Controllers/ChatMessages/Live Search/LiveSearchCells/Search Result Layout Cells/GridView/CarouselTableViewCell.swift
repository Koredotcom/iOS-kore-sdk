//
//  CarouselTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 01/03/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit

class CarouselTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arr = [TemplateResultElements]()
    var appearanceType:String?
    var layOutType:String?
    var templateType:String?
    var isSearchScreen:String?
    var hashMapArray: Array<Any> = Array()
    
    var fileHeading =  ""
    var fileDescription =  ""
    var fileImg = ""
    var fileUrl = ""
    
    var faqHeading = ""
    var faqDescription = ""
    var faqImg = ""
    var faqUrl = ""
    
    var webHeading = ""
    var webDescription = ""
    var webImg = ""
    var webUrl = ""
    
    var dataHeading = ""
    var dataDescription = ""
    var dataImg = ""
    var dataUrl = ""
    
    
    var headingStr = ""
    var descriptionStr = ""
    var imageStr = ""
    var urlStr = ""
    
    enum LiveSearchHeaderTypes: String{
           case faq = "FAQS"
           case web = "WEB"
           case task = "TASKS"
           case file = "Files"
           case data = "DATA"
       }
       enum LiveSearchLayoutTypes: String{
        case tileWithHeader = "l1"
        case descriptionText = "l2"
        case tileWithText = "l3"
        case tileWithImage = "l4"
        case collectionVTypeL5 = "l5"
        case tileWithCenteredContent = "l7"
        case collectionVTypeL8 = "l8"
        case collectionVTypeL9 = "l9"
       }
     
    
    func configure(with arr: [TemplateResultElements], appearanceType: String, layOutType:String, templateType:String, hashMapArray: NSArray, isSearchScreen: String, headingStr: String, descriptionStr: String, imageStr: String, urlStr: String) {
        self.arr = arr
        self.appearanceType = appearanceType
        self.layOutType = layOutType
        self.templateType = templateType
        self.hashMapArray = hashMapArray as! Array<Any>
        self.isSearchScreen = isSearchScreen
        self.headingStr = headingStr
        self.descriptionStr = descriptionStr
        self.imageStr = imageStr
        self.urlStr = urlStr
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
    }
    
    func configureNew(with arr: [TemplateResultElements], appearanceType: String, layOutType:String, templateType:String, hashMapArray: NSArray, isSearchScreen: String) {
        self.arr = arr
        self.appearanceType = appearanceType
        self.layOutType = layOutType
        self.templateType = templateType
        self.hashMapArray = hashMapArray as! Array<Any>
        self.isSearchScreen = isSearchScreen
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
    }
   

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib.init(nibName: "GridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal //vertical
            }
    }
    
}
extension CarouselTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCollectionViewCell", for: indexPath) as! GridCollectionViewCell
        cell.backgroundColor = .white
      
       
       /* for i in 0..<(resultViewSettingItems?.settings?.count ?? 0){
            let settings = resultViewSettingItems?.settings?[i]
            if settings?.interface == isSearchScreen{
                for j in 0..<(settings?.groupSetting?.conditions?.count ?? 0){
                    let condtion = settings?.groupSetting?.conditions?[j]
                    if condtion?.fieldValue == "file"{
                         fileHeading = condtion?.template?.mapping?.heading ?? ""
                         fileDescription = condtion?.template?.mapping?.descrip ?? ""
                         fileImg = condtion?.template?.mapping?.img ?? ""
                         fileUrl = condtion?.template?.mapping?.url ?? ""
                        
                    }else if condtion?.fieldValue == "faq"{
                         faqHeading = condtion?.template?.mapping?.heading ?? ""
                         faqDescription = condtion?.template?.mapping?.descrip ?? ""
                         faqImg = condtion?.template?.mapping?.img ?? ""
                         faqUrl = condtion?.template?.mapping?.url ?? ""
                        
                    }else if condtion?.fieldValue == "web"{
                         webHeading = condtion?.template?.mapping?.heading ?? ""
                         webDescription = condtion?.template?.mapping?.descrip ?? ""
                         webImg = condtion?.template?.mapping?.img ?? ""
                         webUrl = condtion?.template?.mapping?.url ?? ""
                        
                    }else if condtion?.fieldValue == "data"{
                         dataHeading = condtion?.template?.mapping?.heading ?? ""
                         dataDescription = condtion?.template?.mapping?.descrip ?? ""
                         dataImg = condtion?.template?.mapping?.img ?? ""
                         dataUrl = condtion?.template?.mapping?.url ?? ""
                    }else if condtion?.fieldValue == "task"{
                        
                    }
                    
                }
            }
        }*/
        
        
        //hashMapArray
        let mappingResults = hashMapArray[indexPath.row]
        //let results = self.arr[indexPath.row]
        var gridImage: String?
         cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(headingStr)") as? String)
         cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(descriptionStr)") as? String)
         gridImage = ((mappingResults as AnyObject).object(forKey: "\(imageStr)") as? String)
         cell.priceLbl.text = "$160"
        
        /*let appearancetype:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType!)!
        switch appearancetype {
        case .faq:
           cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(faqHeading)") as? String)
            cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(faqDescription)") as? String)
            gridImage = ((mappingResults as AnyObject).object(forKey: "\(faqImg)") as? String)
            cell.priceLbl.text = "$160"
        case .web:
            cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(webHeading)") as? String)
            cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(webDescription)") as? String)
            gridImage = ((mappingResults as AnyObject).object(forKey: "\(webImg)") as? String)
            cell.priceLbl.text = "$160"
        case .file:
           cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(fileHeading)") as? String)
            cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(fileDescription)") as? String)
            gridImage = ((mappingResults as AnyObject).object(forKey: "\(fileImg)") as? String)
            cell.priceLbl.text = "$160"
        case .data:
            cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(dataHeading)") as? String)
            cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(dataDescription)") as? String)
            gridImage = ((mappingResults as AnyObject).object(forKey: "\(dataImg)") as? String)
            cell.priceLbl.text = "$160"
        case .task:
            break
        }*/
        
        
        cell.priceLblHeightConstraint.constant = 0.0
        
        let layoutType:LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: layOutType!)!
        switch layoutType {
        case .tileWithHeader:
             cell.topImavHeightConstraint.constant = 5
             cell.leftImgVWidthConstraint.constant = 0
             cell.titleLblLeadingConstraint.constant = 10
             cell.descriptionLblTopConstraint.constant = 0
             cell.descriptionLblHeightConstaraint.constant = 0
             cell.topImgV.isHidden = true
             cell.leftImagV.isHidden = true
            cell.descriptionLbl?.text = ""

            cell.titleLblHeightConstraint.constant = 0
            cell.titleLbl.numberOfLines = 0
        case .descriptionText:
            cell.leftImgVWidthConstraint.constant = 0
            cell.titleLblLeadingConstraint.constant = 10
            cell.descriptionLblTopConstraint.constant = 10
            cell.topImavHeightConstraint.constant = 5
            cell.topImgV.isHidden = true
            cell.leftImagV.isHidden = true
            
            cell.titleLblHeightConstraint.constant = 0
            cell.descriptionLblTopConstraint.constant = 0
            //cell.descriptionLbl.numberOfLines = 2
            
        case .tileWithText:
            cell.leftImgVWidthConstraint.constant = 0
            cell.titleLblLeadingConstraint.constant = 10
            cell.descriptionLblTopConstraint.constant = 10
            cell.topImavHeightConstraint.constant = 5
            cell.topImgV.isHidden = true
            cell.leftImagV.isHidden = true
        case .tileWithImage:
            cell.leftImgVWidthConstraint.constant = 50
            cell.titleLblLeadingConstraint.constant = 68
            cell.descriptionLblTopConstraint.constant = 10
            cell.topImavHeightConstraint.constant = 5
            cell.topImgV.isHidden = true
            cell.leftImagV.isHidden = false
            cell.leftImagV.layer.cornerRadius = 5.0
            if gridImage == nil || gridImage == ""{
                cell.leftImagV.image = UIImage(named: "placeholder_image")
                
            }else{
                let url = URL(string: gridImage!)
                cell.leftImagV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                
            }
        case .collectionVTypeL5:
            cell.leftImgVWidthConstraint.constant = 0
            cell.titleLblLeadingConstraint.constant = 0
            cell.descriptionLblTopConstraint.constant = 0
            cell.topImavHeightConstraint.constant = 150
            cell.topImgV.isHidden = false
            cell.leftImagV.isHidden = true
            
            cell.descriptionLblHeightConstaraint.constant = 0
            cell.titleLblHeightConstraint.constant = 0
            
            if gridImage == nil || gridImage == ""{
                cell.leftImagV.image = UIImage(named: "placeholder_image")
                
            }else{
                let url = URL(string: gridImage!)
                cell.leftImagV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
            }
        case .tileWithCenteredContent:
            cell.leftImgVWidthConstraint.constant = 0
            cell.titleLblLeadingConstraint.constant = 10
            cell.descriptionLblTopConstraint.constant = 10
            cell.topImavHeightConstraint.constant = 100
            cell.topImgV.isHidden = false
            cell.leftImagV.isHidden = true
            if gridImage == nil || gridImage == ""{
                cell.leftImagV.image = UIImage(named: "placeholder_image")
                
            }else{
                let url = URL(string: gridImage!)
                cell.leftImagV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                
            }
        case .collectionVTypeL8:
            cell.titleLblLeadingConstraint.constant = 10
            cell.descriptionLblTopConstraint.constant = 10
            cell.topImavHeightConstraint.constant = 80
            cell.topImgV.isHidden = false
            cell.leftImagV.isHidden = true
            //cell.topImgV.backgroundColor = .red
            cell.titleLblHeightConstraint.constant = 0
            if gridImage == nil || gridImage == ""{
                cell.leftImagV.image = UIImage(named: "placeholder_image")
                
            }else{
                let url = URL(string: gridImage!)
                cell.leftImagV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                
            }
        case . collectionVTypeL9:
            cell.leftImgVWidthConstraint.constant = 0
            cell.titleLblLeadingConstraint.constant = 10
            cell.descriptionLblTopConstraint.constant = 10
            cell.topImavHeightConstraint.constant = 80
            cell.topImgV.isHidden = false
            cell.leftImagV.isHidden = true
            cell.priceLblHeightConstraint.constant = 16
            if gridImage == nil || gridImage == ""{
                cell.leftImagV.image = UIImage(named: "placeholder_image")
                
            }else{
                let url = URL(string: gridImage!)
                cell.leftImagV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
                let cellWidth = ((collectionView.frame.size.width-3*10)/1) - 40
                let cellHeight = 150
                let mappingResults = hashMapArray[indexPath.row]
            
                var titleTextHeight:CGFloat!
                var descTextHeight:CGFloat!
                var headingTxt:String?
                var descriptionTxt:String?
                
                headingTxt = ((mappingResults as AnyObject).object(forKey: "\(headingStr)") as? String)
                descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(descriptionStr)") as? String)
        
                titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
        
                /*let appearancetype:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType!)!
                switch appearancetype {
                case .faq:
                headingTxt = ((mappingResults as AnyObject).object(forKey: "\(faqHeading)") as? String)
                descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(faqDescription)") as? String)
                
                titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .web:
                    headingTxt = ((mappingResults as AnyObject).object(forKey: "\(webHeading)") as? String)
                    descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(webDescription)") as? String)
                    
                    titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .file:
                    headingTxt = ((mappingResults as AnyObject).object(forKey: "\(fileHeading)") as? String)
                    descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(fileDescription)") as? String)
                    
                    titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .data:
                    headingTxt = ((mappingResults as AnyObject).object(forKey: "\(dataHeading)") as? String)
                    descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(dataDescription)") as? String)
                    
                    titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: cellWidth, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .task:
                    break
                }*/
        
                
            if layOutType == "l6"{
                layOutType = "l7"
            }
                let layoutType:LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: layOutType!)!
                switch layoutType {
                case .tileWithHeader:
                  return CGSize(width: cellWidth, height: 65)
                case .descriptionText:
                    return CGSize(width: cellWidth, height: 65)
                case .tileWithText:
                   return CGSize(width: cellWidth, height: 150)
                case .tileWithImage:
                    return CGSize(width: cellWidth, height: 150)
                case .collectionVTypeL5:
                    return CGSize(width: cellWidth, height: 150)
                case .tileWithCenteredContent:
                    return CGSize(width: cellWidth, height: 150)
                case .collectionVTypeL8:
                    return CGSize(width: cellWidth, height: 150)
                case .collectionVTypeL9:
                    return CGSize(width: cellWidth, height: 150)
                }
      
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        let sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return sectionInset
    }
    
    func requiredHeight(text:String , cellWidth : CGFloat, fontName:String, fontSize:CGFloat) -> CGFloat {

        let font = UIFont(name: fontName, size: fontSize)
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: cellWidth, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height

    }
    
}
