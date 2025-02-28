//
//  StackedCarouselCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 03/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
protocol StackedCarouselCellDelegate {
    func stackedButtonActionText(text:String, payload:String)
    func stackedButtonActionUrl(text: String)
}

class StackedCarouselCell: UICollectionViewCell {

    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var bottomDescLbl: UILabel!
    @IBOutlet weak var bottomTitleLbl: UILabel!
    @IBOutlet weak var tabv: UITableView!
    var btnsArray = [ComponentItemAction]()
    var viewDelegate: StackedCarouselCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tabv.register(Bundle.xib(named: "StackedButtonCell"), forCellReuseIdentifier: "StackedButtonCell")
        self.bringSubviewToFront(tabv)
    }

    func configure(with arr: [ComponentItemAction]) {
        btnsArray = arr
        tabv.reloadData()
        tabv.layoutIfNeeded()
    }

}
extension StackedCarouselCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return btnsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StackedButtonCell", for: indexPath) as! StackedButtonCell
        let btnDetails = btnsArray[indexPath.row]
        cell.textLbl?.text = btnDetails.title
        cell.textLbl.font = UIFont(name: mediumCustomFont, size: 14.0)
        cell.bgV.layer.cornerRadius = 2.0
        cell.bgV.layer.borderWidth = 1.0
        cell.bgV.layer.borderColor = themeColor.cgColor
        cell.bgV.clipsToBounds = true
        cell.bgV.backgroundColor = .clear
        cell.textLbl.textColor = themeColor
        if indexPath.row == 1{
            cell.bgV.backgroundColor = themeColor
            cell.textLbl.textColor = .white
            cell.bgV.layer.borderWidth = 0.0
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let btnDetails = btnsArray[indexPath.row]
        if let type = btnDetails.type, type == "postback"{
            if let payload = btnDetails.payload{
                viewDelegate?.stackedButtonActionText(text: btnDetails.title ?? "", payload: payload)
            }
            
        }
        if let type = btnDetails.type, type == "url"{
            if let url = btnDetails.url{
                viewDelegate?.stackedButtonActionUrl(text: url)
            }
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
