//
//  KREKnowledgeArticleBottom.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 17/01/20.
//

import UIKit

class KREKnowledgeArticleBottom: UIView {
    // MARK: - init
    var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .center
        return imageView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
   
    }
}
