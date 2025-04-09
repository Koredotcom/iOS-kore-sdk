//
//  WelcomeVListHeaderView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 22/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class WelcomeVListHeaderView: UIView {
    let bundle = Bundle.sdkModule
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTilteLabel: UILabel!
    @IBOutlet weak var imagView: UIImageView!
    
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var imagVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagVWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imagVLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subImageV: UIImageView!
    let nibName = "WelcomeVListHeaderView"
    var view : UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetUp()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetUp()
    }

    func xibSetUp() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        
        titleLabel.textColor = UIColor(hexString: "#202124")
        subTilteLabel.textColor = UIColor(hexString: "#4B5565")
        
        
    }
    func configure(with StarterBoxDic: StarterBox?, iconStr:String?) {
        let titleText = StarterBoxDic?.title
        let subText = StarterBoxDic?.sub_text
        titleLabel.text = titleText
        subTilteLabel.text = subText
        var isIconUrl = true
        switch iconStr {
        case "icon-1":
            isIconUrl = false
        case "icon-2":
            isIconUrl = false
        case "icon-3":
            isIconUrl = false
        case "icon-4":
            isIconUrl = false
        default:
            break
        }
        if isIconUrl{
            if let icon = iconStr, let iconurl = URL.init(string: icon){
                imagView.af.setImage(withURL: iconurl, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
            }
        }else{
            let imgV = UIImage.init(named: "leftMBG", in: bundle, compatibleWith: nil)
            imagView.image = imgV?.withRenderingMode(.alwaysTemplate)
            imagView.tintColor = BubbleViewRightTint
            imagView.contentMode = .scaleAspectFit
            
            let subImgv = UIImage.init(named: iconStr ?? "Frame", in: bundle, compatibleWith: nil)
            subImageV.image = subImgv?.withRenderingMode(.alwaysTemplate)
            subImageV.tintColor = BubbleViewUserChatTextColor
            subImageV.contentMode = .scaleAspectFit
        }
        
        if let icon = StarterBoxDic?.icon, icon.show == false{
            imagVWidthConstraint.constant = 0.0
            imagVLeadingConstraint.constant = 5.0
        }
    }

    func loadViewFromNib() ->UIView {
        //let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
     
    
}

