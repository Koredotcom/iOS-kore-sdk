//
//  PdfDownloadCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 10/11/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class PdfDownloadCell: UITableViewCell {
    let bundle = KREResourceLoader.shared.resourceBundle()
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet var activityView: UIActivityIndicatorView!
    @IBOutlet var downloadBtnheightConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgV.layer.cornerRadius = 5
        bgV.clipsToBounds = true
        activityView.isHidden = true
        activityView.color = themeColor
        
        let downloadImage = UIImage(named: "download", in: bundle, compatibleWith: nil)
        let tintedImage = downloadImage?.withRenderingMode(.alwaysTemplate)
        downloadBtn.setImage(tintedImage, for: .normal)
        downloadBtn.tintColor = themeColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
