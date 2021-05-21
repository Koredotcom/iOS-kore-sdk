//
//  NotificationCustomView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/23/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class NotificationCustomView: UIView
{
     
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTilteLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let nibName = "NotificationCustomView"
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
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    
        return view
    }
     
    
}
