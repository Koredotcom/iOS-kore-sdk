//
//  GridTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 01/06/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class GridTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arr = [TemplateResultElements]()
    var appearanceType:String?
    var layOutType:String?
    var templateType:String?
    var isSearchScreen:String?
    var hashMapArray: Array<Any> = Array()
    
    var fileHeading = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.heading ?? ""
    var fileDescription = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.descrip ?? ""
    var fileImg = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.img ?? ""
    var fileUrl = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.url ?? ""
    
    var faqHeading = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.heading ?? ""
    var faqDescription = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.descrip ?? ""
    var faqImg = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.img ?? ""
    var faqUrl = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.url ?? ""
    
    var webHeading = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.heading ?? ""
    var webDescription = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.descrip ?? ""
    var webImg = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.img ?? ""
    var webUrl = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.url ?? ""
    
    var dataHeading = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.heading ?? ""
    var dataDescription = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.descrip ?? ""
    var dataImg = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.img ?? ""
    var dataUrl = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.url ?? ""
    
    enum LiveSearchHeaderTypes: String{
           case faq = "FAQS"
           case web = "WEB"
           case task = "TASKS"
           case file = "Files"
           case data = "DATA"
       }
       enum LiveSearchLayoutTypes: String{
           case tileWithText = "tileWithText"
           case tileWithImage = "tileWithImage"
           case tileWithCenteredContent = "tileWithCenteredContent"
           case tileWithHeader = "tileWithHeader"
       }
     
    
    func configure(with arr: [TemplateResultElements], appearanceType: String, layOutType:String, templateType:String ) {
        self.arr = arr
        self.appearanceType = appearanceType
        self.layOutType = layOutType
        self.templateType = templateType
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
        if  templateType ==  "carousel"{
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
        }else{
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical  // .horizontal
            }
        }
    }
    
}

extension GridTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCollectionViewCell", for: indexPath) as! GridCollectionViewCell
        cell.backgroundColor = .white
        
        if isSearchScreen == "liveSearch"{
             fileHeading = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.heading ?? ""
             fileDescription = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.descrip ?? ""
             fileImg = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.img ?? ""
             fileUrl = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.url ?? ""
            
             faqHeading = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.heading ?? ""
             faqDescription = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.descrip ?? ""
             faqImg = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.img ?? ""
             faqUrl = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.url ?? ""
            
             webHeading = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.heading ?? ""
             webDescription = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.descrip ?? ""
             webImg = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.img ?? ""
             webUrl = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.url ?? ""
            
             dataHeading = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.heading ?? ""
             dataDescription = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.descrip ?? ""
             dataImg = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.img ?? ""
             dataUrl = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.url ?? ""
        }else if isSearchScreen == "Search"{
             fileHeading = resultViewSettingItems?.settings?[0].appearance?[0].template?.mapping?.heading ?? ""
             fileDescription = resultViewSettingItems?.settings?[0].appearance?[0].template?.mapping?.descrip ?? ""
             fileImg = resultViewSettingItems?.settings?[0].appearance?[0].template?.mapping?.img ?? ""
             fileUrl = resultViewSettingItems?.settings?[0].appearance?[0].template?.mapping?.url ?? ""
            
             faqHeading = resultViewSettingItems?.settings?[0].appearance?[1].template?.mapping?.heading ?? ""
             faqDescription = resultViewSettingItems?.settings?[0].appearance?[1].template?.mapping?.descrip ?? ""
             faqImg = resultViewSettingItems?.settings?[0].appearance?[1].template?.mapping?.img ?? ""
             faqUrl = resultViewSettingItems?.settings?[0].appearance?[1].template?.mapping?.url ?? ""
            
             webHeading = resultViewSettingItems?.settings?[0].appearance?[2].template?.mapping?.heading ?? ""
             webDescription = resultViewSettingItems?.settings?[0].appearance?[2].template?.mapping?.descrip ?? ""
             webImg = resultViewSettingItems?.settings?[0].appearance?[2].template?.mapping?.img ?? ""
             webUrl = resultViewSettingItems?.settings?[0].appearance?[2].template?.mapping?.url ?? ""
            
             dataHeading = resultViewSettingItems?.settings?[0].appearance?[3].template?.mapping?.heading ?? ""
             dataDescription = resultViewSettingItems?.settings?[0].appearance?[3].template?.mapping?.descrip ?? ""
             dataImg = resultViewSettingItems?.settings?[0].appearance?[3].template?.mapping?.img ?? ""
             dataUrl = resultViewSettingItems?.settings?[0].appearance?[3].template?.mapping?.url ?? ""
            
        }else if isSearchScreen == "fullSearch"{
            fileHeading = resultViewSettingItems?.settings?[1].appearance?[0].template?.mapping?.heading ?? ""
             fileDescription = resultViewSettingItems?.settings?[1].appearance?[0].template?.mapping?.descrip ?? ""
             fileImg = resultViewSettingItems?.settings?[1].appearance?[0].template?.mapping?.img ?? ""
             fileUrl = resultViewSettingItems?.settings?[1].appearance?[0].template?.mapping?.url ?? ""
            
             faqHeading = resultViewSettingItems?.settings?[1].appearance?[1].template?.mapping?.heading ?? ""
             faqDescription = resultViewSettingItems?.settings?[1].appearance?[1].template?.mapping?.descrip ?? ""
             faqImg = resultViewSettingItems?.settings?[1].appearance?[1].template?.mapping?.img ?? ""
             faqUrl = resultViewSettingItems?.settings?[1].appearance?[1].template?.mapping?.url ?? ""
            
             webHeading = resultViewSettingItems?.settings?[1].appearance?[2].template?.mapping?.heading ?? ""
             webDescription = resultViewSettingItems?.settings?[1].appearance?[2].template?.mapping?.descrip ?? ""
             webImg = resultViewSettingItems?.settings?[1].appearance?[2].template?.mapping?.img ?? ""
             webUrl = resultViewSettingItems?.settings?[1].appearance?[2].template?.mapping?.url ?? ""
            
             dataHeading = resultViewSettingItems?.settings?[1].appearance?[3].template?.mapping?.heading ?? ""
             dataDescription = resultViewSettingItems?.settings?[1].appearance?[3].template?.mapping?.descrip ?? ""
             dataImg = resultViewSettingItems?.settings?[1].appearance?[3].template?.mapping?.img ?? ""
             dataUrl = resultViewSettingItems?.settings?[1].appearance?[3].template?.mapping?.url ?? ""
        }
        //hashMapArray
        let mappingResults = hashMapArray[indexPath.row]
        //let results = self.arr[indexPath.row]
        var gridImage: String?
        let appearancetype:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType!)!
        switch appearancetype {
        case .faq:
           cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(faqHeading)") as? String)
            cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(faqDescription)") as? String)
            gridImage = ((mappingResults as AnyObject).object(forKey: "\(faqImg)") as? String)
        case .web:
            cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(webHeading)") as? String)
            cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(webDescription)") as? String)
            gridImage = ((mappingResults as AnyObject).object(forKey: "\(webImg)") as? String)
        case .file:
           cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(fileHeading)") as? String)
            cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(fileDescription)") as? String)
            gridImage = ((mappingResults as AnyObject).object(forKey: "\(fileImg)") as? String)
        case .data:
            cell.titleLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(dataHeading)") as? String)
            cell.descriptionLbl?.text = ((mappingResults as AnyObject).object(forKey: "\(dataDescription)") as? String)
            gridImage = ((mappingResults as AnyObject).object(forKey: "\(dataImg)") as? String)
        case .task:
            break
        }
        let layoutType:LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: layOutType!)!
        switch layoutType {
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
        case .tileWithHeader:
             cell.topImavHeightConstraint.constant = 5
             cell.leftImgVWidthConstraint.constant = 0
             cell.titleLblLeadingConstraint.constant = 10
             cell.descriptionLblTopConstraint.constant = 10
             cell.topImgV.isHidden = true
             cell.leftImagV.isHidden = true
            cell.descriptionLbl?.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if templateType ==  "carousel"{
            return CGSize(width: ((collectionView.frame.size.width-3*10)/1) - 40, height: 150) //240
        }else{
            let mappingResults = hashMapArray[indexPath.row]
            //let results = self.arr[indexPath.row]
                var titleTextHeight:CGFloat!
                var descTextHeight:CGFloat!
                var headingTxt:String?
                var descriptionTxt:String?
            
                let appearancetype:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType!)!
                switch appearancetype {
                case .faq:
                headingTxt = ((mappingResults as AnyObject).object(forKey: "\(faqHeading)") as? String)
                descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(faqDescription)") as? String)
                
                titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .web:
                    headingTxt = ((mappingResults as AnyObject).object(forKey: "\(webHeading)") as? String)
                    descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(webDescription)") as? String)
                    
                    titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .file:
                    headingTxt = ((mappingResults as AnyObject).object(forKey: "\(fileHeading)") as? String)
                    descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(fileDescription)") as? String)
                    
                    titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .data:
                    headingTxt = ((mappingResults as AnyObject).object(forKey: "\(dataHeading)") as? String)
                    descriptionTxt = ((mappingResults as AnyObject).object(forKey: "\(dataDescription)") as? String)
                    
                    titleTextHeight = requiredHeight(text: headingTxt ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: descriptionTxt ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .task:
                    break
                }
                
                let layoutType:LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: layOutType!)!
                switch layoutType {
                case .tileWithText:
                   return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: titleTextHeight+descTextHeight+55) //40
                case .tileWithImage:
                    //let leftImagevSpaceing = 25
                    return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: titleTextHeight+descTextHeight+55+25)
                case .tileWithCenteredContent:
                    //let topImagevSpaceing = 100
                    return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: titleTextHeight+descTextHeight+55+100)
                case .tileWithHeader:
                  return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: titleTextHeight+35)
                }
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
