//
//  ImageComponentCollectionViewCell.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ImageComponentView : UIImageView {

    var component: Component!
    var block: (() -> Void)!
    func setupImageView(_ component: Component!, completion: (() -> Void)?) {
        if (component.componentType == .image) {
            self.contentMode = .scaleAspectFill
            self.component = component
            
            self.setupImageView(completion)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
    func setupImageView(_ completion:(() -> Void)?) {
        self.contentMode = .scaleAspectFill
        
        if let payload = component.payload {
            self.image = UIImage(named: payload)
        }
        completion?()
    }
}

class ImageComponentCollectionViewCell : UICollectionViewCell {

    @IBOutlet weak var imageComponent: ImageComponentView!
    @IBOutlet weak var plusCountLabel: UILabel!
    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var videoPlayerView: UIView!
    
    lazy var menuBtn: UIButton = {
    let menuBtn = UIButton(frame: CGRect(x: 60, y: 8, width: 45, height: 30))
    menuBtn.backgroundColor = .black
    menuBtn.alpha = 0.4
    menuBtn.layer.cornerRadius = 5.0
    menuBtn.setImage(UIImage(named: "more"), for: .normal)
    
    menuBtn.imageEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    return menuBtn
    }()
    
    var player: AVPlayer!
    var playerViewController: AVPlayerViewController!
    
    var index: NSNumber!
    var component: Component! {
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
    
    func transitionContentMode() -> UIView.ContentMode {
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
        
       //player
       // playerViewController
        
    }
}
