//
//  AdvancedMultiSelectHeaderV.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 12/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class AdvancedMultiSelectHeaderV: UIView {
    let bundle = Bundle.sdkModule
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var headerCheckBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var selectallVHeightConstraint: NSLayoutConstraint!
    let nibName = "AdvancedMultiSelectHeaderV"
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
    }

    func loadViewFromNib() ->UIView {
        //let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
