//
//  InComingCallView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 05/12/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
protocol inComingCallDelegate{
    func acceptCallIncomingCall()
    func rejectIncomingCall()
}
class InComingCallView: UIView {

    let bundle = Bundle.sdkModule
    let nibName = "InComingCallView"
    var view : UIView!
    @IBOutlet weak var inComingCallImgV: UIImageView!
    @IBOutlet weak var inComingCallNameLbl: UILabel!
    @IBOutlet weak var inComingVideoOrVoiceLbl: UILabel!
    @IBOutlet weak var inComingCallDeclineBtn: UIButton!
    @IBOutlet weak var inComingCallAcceptBtn: UIButton!
    var viewDelegate: inComingCallDelegate?
    @IBOutlet weak var bgView: UIView!
    
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
        
        self.view.backgroundColor = .clear
        
        inComingCallDeclineBtn.layer.cornerRadius = 4.0
        inComingCallAcceptBtn.clipsToBounds = true
        
        inComingCallAcceptBtn.layer.cornerRadius = 4.0
        inComingCallAcceptBtn.clipsToBounds = true
        
        bgView.layer.cornerRadius = 4.0
        bgView.layer.borderWidth = 1.0
        bgView.layer.borderColor = UIColor.init(hexString: "#E3E8EF").cgColor
        bgView.clipsToBounds = true
    }
    
    func configure(imageUrlStr: String, nameStr:String, isVideoCall:Bool) {
        inComingCallNameLbl.text = nameStr
        inComingVideoOrVoiceLbl.text = "Incoming Audio call..."
        if isVideoCall{
            inComingVideoOrVoiceLbl.text = "Incoming Video call..."
        }
        
        if imageUrlStr.contains("base64"){
            let image = Utilities.base64ToImage(base64String: imageUrlStr)
            inComingCallImgV.image = image
        }else{
            if let url = URL(string: imageUrlStr){
                inComingCallImgV.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
            }
        }
    }
    
    func loadViewFromNib() ->UIView {
        //let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    @IBAction func acceptCallBtnAct(_ sender: Any) {
        viewDelegate?.acceptCallIncomingCall()
    }
    
    @IBAction func rejectCallBtnAct(_ sender: Any) {
        viewDelegate?.rejectIncomingCall()
    }
    
}
