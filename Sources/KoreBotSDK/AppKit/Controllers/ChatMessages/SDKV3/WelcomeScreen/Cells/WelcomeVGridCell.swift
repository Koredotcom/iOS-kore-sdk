//
//  WelcomeVGridCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 22/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
protocol WelcomeVGridCellDelegate {
    func optionsButtonAction(text:String, payload:String)
}
class WelcomeVGridCell: UITableViewCell {
    let bundle = Bundle.sdkModule
    var viewDelegate: WelcomeVGridCellDelegate?
    var btnsArray = [Buttons]()
    @IBOutlet weak var collectionV: UICollectionView!
    let staticArray = ["Contact Sales", "Free Trail", "Support", "Hours of operation","Just checking about the site"]
    @IBOutlet weak var leftLineLbl: UILabel!
    @IBOutlet weak var rightLineLbl: UILabel!
    let borderColor = UIColor(hexString: "#E4E5E7")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let layout = TagFlowLayout()
        layout.scrollDirection = .vertical
        collectionV.collectionViewLayout = layout
        collectionV.register(UINib.init(nibName: "ButtonLinkCell", bundle: bundle), forCellWithReuseIdentifier: "ButtonLinkCell")
        leftLineLbl.backgroundColor = .clear
        rightLineLbl.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with arr: [Buttons]) {
        btnsArray = arr
        collectionV.reloadData()
        collectionV.layoutIfNeeded()
    }

}
extension WelcomeVGridCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return btnsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonLinkCell", for: indexPath) as! ButtonLinkCell
        cell.backgroundColor = .clear
        cell.bgV.backgroundColor = .clear
        cell.textlabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
        let buttons =  btnsArray[indexPath.item]
        cell.textlabel.text = buttons.title
        cell.textlabel.textAlignment = .center
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 5
        cell.textlabel.textColor = UIColor(hexString: "#404040")
        if useColorPaletteOnly{
            cell.layer.borderColor = UIColor.init(hexString: genaralSecondaryColor).cgColor
        }else{
            cell.layer.borderColor = borderColor.cgColor
        }
        cell.backgroundColor = .white
        cell.imagvWidthConstraint.constant = 0.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text:String?
        let buttons =  btnsArray[indexPath.item]
        text = buttons.title
        var textWidth = 10
        let size = text?.size(withAttributes:[.font: UIFont(name: "HelveticaNeue", size: 14.0) as Any])
        if text != nil {
            textWidth = Int(size!.width)
        }
      return CGSize(width: min(Int(maxContentWidth()) - 10 , textWidth + 32) , height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let buttons =  btnsArray[indexPath.item]
        if let title = buttons.title{
            if let action = buttons.action, action.type == "postback"{
                viewDelegate?.optionsButtonAction(text: title, payload: action.value ?? title)
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
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
}

