//
//  AdvancedListHeaderView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 21/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class AdvancedListHeaderView: UIView {
    let bundle = KREResourceLoader.shared.resourceBundle()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTilteLabel: UILabel!
    @IBOutlet weak var imagView: UIImageView!
    
    @IBOutlet weak var imagVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagVWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var dropDownBtnWidthConstraint: NSLayoutConstraint!
    
    let nibName = "AdvancedListHeaderView"
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
        
        btn.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        btn.layer.cornerRadius = 4.0
        btn.clipsToBounds = true
    }

    func loadViewFromNib() ->UIView {
        //let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
     
    
}
