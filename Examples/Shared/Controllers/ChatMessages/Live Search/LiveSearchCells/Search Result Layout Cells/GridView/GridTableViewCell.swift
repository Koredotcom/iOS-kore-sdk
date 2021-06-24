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
        let results = self.arr[indexPath.row]
        var gridImage: String? 
        let appearancetype:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType!)!
        switch appearancetype {
        case .faq:
           cell.titleLbl?.text = results.faqQuestion
            cell.descriptionLbl?.text = results.faqAnswer
             gridImage = results.imageUrl
        case .web:
            cell.titleLbl?.text = results.pageTitle
            cell.descriptionLbl?.text = results.pagePreview
            gridImage = results.pageImageUrl
        case .file:
            cell.titleLbl?.text = results.fileTitle
            cell.descriptionLbl?.text = results.filePreview
            gridImage = results.fileimageUrl
        case .data:
            cell.titleLbl?.text = results.category
            cell.descriptionLbl?.text = results.product
            gridImage = results.dataImageUrl
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
            let results = self.arr[indexPath.row]
                var titleTextHeight:CGFloat!
                var descTextHeight:CGFloat!
            
                let appearancetype:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType!)!
                switch appearancetype {
                case .faq:
                  titleTextHeight = requiredHeight(text: results.faqQuestion ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                   descTextHeight = requiredHeight(text: results.faqAnswer ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .web:
                    titleTextHeight = requiredHeight(text: results.pageTitle ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: results.pagePreview ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .file:
                    titleTextHeight = requiredHeight(text: results.fileTitle ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: results.filePreview ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
                case .data:
                    titleTextHeight = requiredHeight(text: results.category ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
                    descTextHeight = requiredHeight(text: results.product ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
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
