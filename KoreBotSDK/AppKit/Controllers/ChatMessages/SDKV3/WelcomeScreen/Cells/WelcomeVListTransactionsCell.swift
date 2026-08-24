//
//  WelcomeVListTransactionsCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 23/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class WelcomeVListTransactionsCell: UITableViewCell {

    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var transactionIdTitleLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var recivedFromLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var transactionIDLbl: UILabel!
    
    @IBOutlet weak var leftLineLbl: UILabel!
    @IBOutlet weak var underLineLbl: UILabel!
    @IBOutlet weak var rightLineLbl: UILabel!
    let borderColor = UIColor(hexString: "#E4E5E7")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        transactionIdTitleLbl.font = UIFont(name: "HelveticaNeue", size: 12.0)
        transactionIdTitleLbl.textColor = UIColor(hexString: "#697586")
        
        transactionIDLbl.font = UIFont(name: "HelveticaNeue", size: 17.0)
        transactionIDLbl.textColor = UIColor(hexString: "#202124")
        
        amountLbl.font = UIFont(name: "HelveticaNeue", size: 16.0)
        amountLbl.textColor = UIColor(hexString: "#000000")
        
        dateLbl.font = UIFont(name: "HelveticaNeue", size: 12.0)
        dateLbl.textColor = UIColor(hexString: "#697586")
        
        recivedFromLbl.font = UIFont(name: "HelveticaNeue", size: 12.0)
        recivedFromLbl.textColor = UIColor(hexString: "#697586")
        
        nameLbl.font = UIFont(name: "HelveticaNeue", size: 15.0)
        nameLbl.textColor = UIColor(hexString: "#202124")
        
        bgV.layer.borderWidth = 0.0
        bgV.layer.borderColor = borderColor.cgColor
        bgV.layer.cornerRadius = 4.0
        bgV.clipsToBounds = true
        
        leftLineLbl.backgroundColor = borderColor
        underLineLbl.backgroundColor = borderColor
        rightLineLbl.backgroundColor = borderColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
