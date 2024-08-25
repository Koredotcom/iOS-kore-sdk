//
//  CardTemplateHedaderView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 01/08/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class CardTemplateHedaderView: UIView {
    let bundle = Bundle.module
    @IBOutlet weak var cardBoaderTopLbl: UILabel!
    @IBOutlet weak var cardVerLbl: UILabel!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTilteLabel: UILabel!
    @IBOutlet weak var imagView: UIImageView!
    @IBOutlet weak var verticalLabel: UILabel!
    @IBOutlet weak var verticalLblWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalLblLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imagVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagVWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var dropDownBtnWidthConstraint: NSLayoutConstraint!
    
    let nibName = "CardTemplateHedaderView"
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
        
        btn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 14.0)
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
