//
//  CardTemplateListCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 31/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class CardTemplateListCell: UITableViewCell {
    let bundle = Bundle.module
    @IBOutlet weak var veriticalLblWidthConstaint: NSLayoutConstraint!
    @IBOutlet weak var verticalLbl: UILabel!
    @IBOutlet weak var collV: UICollectionView!
    var arr = [CardDescription]()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collV.register(UINib.init(nibName: "CardTemplateCollectionVCell", bundle: bundle), forCellWithReuseIdentifier: "CardTemplateCollectionVCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with arr: [CardDescription]) {
        self.arr = arr
        collV.reloadData()
        collV.layoutIfNeeded()
    }
    
}
extension CardTemplateListCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardTemplateCollectionVCell", for: indexPath) as! CardTemplateCollectionVCell
        cell.backgroundColor = .clear
        let details = arr[indexPath.item]
        cell.titleLbl.text = details.title
        cell.descLbl.text = details.descr
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 20 - 3*10)/3, height: 55)
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
