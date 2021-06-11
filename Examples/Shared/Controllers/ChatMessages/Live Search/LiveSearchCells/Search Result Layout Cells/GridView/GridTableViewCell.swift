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
     
    
    func configure(with arr: [TemplateResultElements], appearanceType: String, layOutType:String ) {
        self.arr = arr
        self.appearanceType = appearanceType
        self.layOutType = layOutType
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
    }
    
}

extension GridTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCollectionViewCell", for: indexPath) as! GridCollectionViewCell
        let results = self.arr[indexPath.row]
        var gridImage: String?
        if appearanceType == "FAQS" {
            cell.titleLbl?.text = results.question
            cell.descriptionLbl?.text = results.answer
            gridImage = results.imageUrl
        }else{
            cell.titleLbl?.text = results.pageTitle
            cell.descriptionLbl?.text = results.pagePreview
            gridImage = results.pageImageUrl
        }
        cell.backgroundColor = .white
        
        switch layOutType {
        case "tileWithText":
            cell.leftImgVWidthConstraint.constant = 0
            cell.titleLblLeadingConstraint.constant = 10
            cell.descriptionLblTopConstraint.constant = 10
            cell.topImavHeightConstraint.constant = 5
            cell.topImgV.isHidden = true
            cell.leftImagV.isHidden = true
        case "tileWithImage":
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
        case "tileWithCenteredContent":
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
        case "tileWithHeader":
             cell.topImavHeightConstraint.constant = 5
             cell.leftImgVWidthConstraint.constant = 0
             cell.titleLblLeadingConstraint.constant = 10
             cell.descriptionLblTopConstraint.constant = 10
             cell.topImgV.isHidden = true
             cell.leftImagV.isHidden = true
            cell.descriptionLbl?.text = ""
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let results = self.arr[indexPath.row]
        let titleTextHeight:CGFloat!
        let descTextHeight:CGFloat!
        
        if appearanceType == "FAQS" {
            titleTextHeight = requiredHeight(text: results.question ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
            descTextHeight = requiredHeight(text: results.answer ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
        }else{
            titleTextHeight = requiredHeight(text: results.pageTitle ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Bold",  fontSize: 16.0)
            descTextHeight = requiredHeight(text: results.pagePreview ?? "", cellWidth: (collectionView.frame.size.width-3*10)/2, fontName: "HelveticaNeue-Medium",  fontSize: 14.0)
        }
        
        switch layOutType {
        case "tileWithText":
           return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: titleTextHeight+descTextHeight+55) //40
        case "tileWithImage":
            //let leftImagevSpaceing = 25
            return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: titleTextHeight+descTextHeight+55+25)
        case "tileWithCenteredContent":
            //let topImagevSpaceing = 100
            return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: titleTextHeight+descTextHeight+55+100)
        case "tileWithHeader":
          return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: titleTextHeight+35)
        default:
            break
        }
        return CGSize(width: 0.0, height: 0.0)
        
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
