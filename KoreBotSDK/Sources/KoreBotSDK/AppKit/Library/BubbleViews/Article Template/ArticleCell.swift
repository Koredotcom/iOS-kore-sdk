//
//  ArticleCell.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 24/02/25.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var createdLbl: UILabel!
    @IBOutlet weak var updatedLbl: UILabel!
    @IBOutlet weak var showArticleBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
