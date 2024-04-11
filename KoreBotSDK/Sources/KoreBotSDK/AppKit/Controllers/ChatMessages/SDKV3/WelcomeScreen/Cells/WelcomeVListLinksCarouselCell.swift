//
//  WelcomeVListLinksCarouselCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 11/09/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
protocol WelcomeVListLinksCarouselDelegate {
    func optionsButtonAction(text:String, payload:String)
    func linkButtonAction(urlString: String)
}
class WelcomeVListLinksCarouselCell: UITableViewCell {
    let bundle = Bundle.sdkModule
    var viewDelegate: WelcomeVListLinksCarouselDelegate?
    @IBOutlet weak var collectionV: UICollectionView!
    @IBOutlet weak var leftLineLbl: UILabel!
    @IBOutlet weak var underLineLbl: UILabel!
    @IBOutlet weak var rightLineLbl: UILabel!
    let borderColor = UIColor(hexString: "#E4E5E7")
    var linksArray = [Links]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        leftLineLbl.backgroundColor = borderColor
        underLineLbl.backgroundColor = borderColor
        rightLineLbl.backgroundColor = borderColor
        collectionV.register(UINib.init(nibName: "WelcomeVCarouselCell", bundle: bundle), forCellWithReuseIdentifier: "WelcomeVCarouselCell")
    }
    
    func configure(with arr: [Links]) {
        linksArray = arr
        collectionV.reloadData()
        collectionV.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension WelcomeVListLinksCarouselCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return linksArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeVCarouselCell", for: indexPath) as! WelcomeVCarouselCell
        cell.backgroundColor = UIColor.white
        cell.descLbl.numberOfLines = 2
        let linkDetails = linksArray[indexPath.row]
        cell.titleLbl.text = linkDetails.title
        cell.descLbl.text = linkDetails.descrip
        if useColorPaletteOnly{
            cell.bgV.layer.borderColor = UIColor.init(hexString: genaralSecondaryColor).cgColor
        }else{
            cell.bgV.layer.borderColor = UIColor(hexString: "#E4E5E7").cgColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if linksArray.count > 1{
            return CGSize(width: UIScreen.main.bounds.size.width - 90  , height: 95)
        }
        return CGSize(width: UIScreen.main.bounds.size.width - 50  , height: 95)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let linkDetails =  linksArray[indexPath.item]
        if let title = linkDetails.title{
            if let action = linkDetails.action, action.type == "postback"{
                viewDelegate?.optionsButtonAction(text: title, payload: action.value ?? title)
            }
            if let linkAction = linkDetails.action, linkAction.type == "url"{
                if let linkUrl = linkAction.value{
                    viewDelegate?.linkButtonAction(urlString: linkUrl)
                }
            }
        }
        
    }
    
    func maxContentWidth() -> CGFloat {
        if let collectionViewLayout = collectionV.collectionViewLayout as? UICollectionViewFlowLayout {
            let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
            return max(frame.size.width - sectionInset.left - sectionInset.right, 1.0)
        }
        return 1.0
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

