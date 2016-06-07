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
    func setupImageView(component: ImageComponent!, completion: (() -> Void)?) {
        if (component.isKindOfClass(ImageComponent)) {
            self.contentMode = .ScaleAspectFill
            self.component = component as ImageComponent!
            
            self.setupImageView(completion)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
    func setupImageView(completion:(() -> Void)?) {
        self.contentMode = .ScaleAspectFill
        
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
            self.backgroundColor = UIColor.clearColor()
        }
    }

    var isViewing: Bool = false {
        didSet {
            self.displayView.hidden = isViewing
            self.backgroundColor = isViewing ? UIColor.init(white:0.0, alpha:0.1) : UIColor.clearColor()
        }
    }

    func transitionImage() -> UIImage {
        return self.imageComponent.image!
    }
    
    func transitionContentMode() -> UIViewContentMode {
        return .ScaleAspectFill
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.whiteColor().CGColor
        self.dimmingView.hidden = true
        self.displayView.hidden = false
    }
    
    override func prepareForReuse() {
        self.imageComponent.image = nil
        self.plusCountLabel.text = "";
        self.plusCountLabel.hidden = true
        self.dimmingView.hidden = true
        self.displayView.hidden = false
    }
}