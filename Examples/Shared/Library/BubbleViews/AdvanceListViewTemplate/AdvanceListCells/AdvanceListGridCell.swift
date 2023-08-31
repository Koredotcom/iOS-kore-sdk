//
//  AdvanceListGridCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 26/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class AdvanceListGridCell: UITableViewCell {
    var arr = [DropdownOptions]()
    @IBOutlet weak var collectionV: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionV.register(UINib.init(nibName: "AdvanceListCollectionViewCell", bundle: frameworkBundle), forCellWithReuseIdentifier: "AdvanceListCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with arr: [DropdownOptions]) {
        self.arr = arr
        collectionV.reloadData()
        collectionV.layoutIfNeeded()
    }

}

extension AdvanceListGridCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdvanceListCollectionViewCell", for: indexPath) as! AdvanceListCollectionViewCell
        cell.backgroundColor = .white
        let details = arr[indexPath.item]
        cell.titleLbl.text = details.title
        cell.valueLbl.text = details.descr
        if let iconImg = details.icon{
            if iconImg.contains("base64"){
                let image = Utilities.base64ToImage(base64String: iconImg)
                cell.imagV.image = image
            }else{
                if let url = URL(string: iconImg){
                    cell.imagV.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: frameworkBundle, compatibleWith: nil))
                }
            }
            
             let iconSize = details.iconSize ?? "medium"
            if iconSize == "large"{
                cell.imagVwidthConstraint.constant = 65.0
                cell.imagVHeightConstraint.constant = 65.0
            }else if iconSize == "medium"{
                cell.imagVwidthConstraint.constant = 40.0
                cell.imagVHeightConstraint.constant = 40.0
            }else if iconSize == "small"{
                cell.imagVwidthConstraint.constant = 20.0
                cell.imagVHeightConstraint.constant = 20.0
            }
                
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width-3*10)/2, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        let sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
