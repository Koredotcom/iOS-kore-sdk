//
//  ImageComponentCollectionViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

class ImageComponentView : UIImageView {

    var component: ImageComponent!
    var block: (() -> Void)!
    func setupImageView(_ component: ImageComponent!, completion: (() -> Void)?) {
        if (component.isKind(of: ImageComponent.self)) {
            self.contentMode = .scaleAspectFill
            self.component = component as ImageComponent!
            
            self.setupImageView(completion)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
    func setupImageView(_ completion:(() -> Void)?) {
        self.contentMode = .scaleAspectFill
        
        self.image = UIImage(named: self.component.imageFile)
        if (completion != nil) {
            completion!()
        }
    }
}

class ImageComponentCollectionViewCell : UICollectionViewCell {

    @IBOutlet weak var imageComponent: ImageComponentView!
    @IBOutlet weak var plusCountLabel: UILabel!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var displayView: UIView!
    
    var index: NSNumber!
    var component: ImageComponent! {
        didSet {
            self.imageComponent.setupImageView(component) { 
                
            }
            self.backgroundColor = UIColor.clear
        }
    }

    var isViewing: Bool = false {
        didSet {
            self.displayView.isHidden = isViewing
            self.backgroundColor = isViewing ? UIColor.init(white:0.0, alpha:0.1) : UIColor.clear
        }
    }

    func transitionImage() -> UIImage {
        return self.imageComponent.image!
    }
    
    func transitionContentMode() -> UIViewContentMode {
        return .scaleAspectFill
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.white.cgColor
        self.dimmingView.isHidden = true
        self.displayView.isHidden = false
    }
    
    override func prepareForReuse() {
        self.imageComponent.image = nil
        self.plusCountLabel.text = "";
        self.plusCountLabel.isHidden = true
        self.dimmingView.isHidden = true
        self.displayView.isHidden = false
    }
}
