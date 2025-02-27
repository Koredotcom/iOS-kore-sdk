//
//  ChatVCHeaderView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 26/09/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
class ChatVCHeaderView: UIView {
    let bundle = Bundle.sdkModule
    var headerDic = HeaderModel()
    var headerHeight: Float?
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var compactHeaderTitleLbl: UILabel!
    @IBOutlet weak var compactHeaderDescLbl: UILabel!
    @IBOutlet weak var compactHeaderImagV: UIImageView!
    @IBOutlet weak var compactHeaderBackBtn: UIButton!
    @IBOutlet weak var compactHeaderHelpBtn: UIButton!
    @IBOutlet weak var compactHeaderSupportBtn: UIButton!
    @IBOutlet weak var compactHeaderCloseBtn: UIButton!
    @IBOutlet weak var compactHeaderImagVWidthconstraint: NSLayoutConstraint!
    @IBOutlet weak var compactHeaderHelpBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var compactHeaderSupportBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var compactHeaderCloseBtnWidthConstaraint: NSLayoutConstraint!
    
    @IBOutlet weak var compactHeaderSubImagV: UIImageView!
    
    
    @IBOutlet weak var RegulartHeaderView: UIView!
    @IBOutlet weak var RegulartHeaderTitleLbl: UILabel!
    @IBOutlet weak var RegulartHeaderDescLbl: UILabel!
    @IBOutlet weak var RegulartHeaderImagV: UIImageView!
    @IBOutlet weak var RegulartHeaderBackBtn: UIButton!
    @IBOutlet weak var RegulartHeaderSupportBtn: UIButton!
    @IBOutlet weak var RegulartHeaderHelpBtn: UIButton!
    @IBOutlet weak var RegulartHeaderCloseBtn: UIButton!
    @IBOutlet weak var RegulartHeaderImagVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var RegulartHeaderHelpBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var RegulartHeaderSupportBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var RegulartHeaderCloseBtnWidthConstaraint: NSLayoutConstraint!
    
    @IBOutlet weak var regularHeaderSubImgV: UIImageView!
    
    @IBOutlet weak var largeHeaderView: UIView!
    @IBOutlet weak var largeHeaderBgImgV: UIImageView!
    @IBOutlet weak var largeHeaderBackBtn: UIButton!
    @IBOutlet weak var largeHeaderHelpBtn: UIButton!
    @IBOutlet weak var largeHeaderSupportBtn: UIButton!
    @IBOutlet weak var largeHeaderCloseBtn: UIButton!
    @IBOutlet weak var largeHeaderSubView: UIView!
    @IBOutlet weak var largeHeaderImagV: UIImageView!
    @IBOutlet weak var largeHeaderTitleLbl: UILabel!
    @IBOutlet weak var largeHeaderDescLbl: UILabel!
    @IBOutlet weak var largeHeaderImagvHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var largeHeaderHelpBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var largeHeaderSupportBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var largeHeaderCloseBtnWidthConstaraint: NSLayoutConstraint!
    
    @IBOutlet weak var largeHeaderSubImagV: UIImageView!
    
    public var chatHeaderVBackBtnAct: ((_ text: String?) -> Void)?
    public var chatHeaderVHelpBtnAct: ((_ text: String?) -> Void)?
    public var chatHeaderVSupportBtnAct: ((_ text: String?) -> Void)?
    public var chatHeaderVCloseBtnAct: ((_ text: String?) -> Void)?
    
    let nibName = "ChatVCHeaderView"
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

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func loadViewFromNib() ->UIView {
        //let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func configure(headerDic: HeaderModel, headerHeight: Float){
        self.headerHeight = headerHeight
        self.headerDic = headerDic
        var titleTxt = headerDic.title?.name
        if titleTxt == ""{
            titleTxt = SDKConfiguration.botConfig.chatBotName
        }
        var titleTxtColor = "#000000"
        let titleFont = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        let subTitleTxt = headerDic.sub_title?.name
        var subTitleTxtColor = headerDic.sub_title?.color
        let subTitleFont = UIFont(name: "HelveticaNeue", size: 14.0)
        let deafaultColor = "#ffffff"
        let bgColor = headerDic.bg_color
        let size = headerDic.size
        let showIcon  = headerDic.icon?.show ?? true
        let iconUrl  = headerDic.icon?.icon_url
        var headerIconColor = "#000000"
        if useColorPaletteOnly{
            headerIconColor = genaralPrimaryColor
            titleTxtColor = genaralPrimary_textColor
            subTitleTxtColor = genaralPrimary_textColor
        }else{
            headerIconColor = headerDic.icons_color ?? headerIconColor
            titleTxtColor = headerDic.title?.color ?? headerIconColor
            subTitleTxtColor = headerDic.sub_title?.color ?? headerIconColor
        }
        let backImage = UIImage(named: "cheveron-left", in: bundle, compatibleWith: nil)
        let tintedBackImage = backImage?.withRenderingMode(.alwaysTemplate)
        
        let helpImage = UIImage(named: "Help", in: bundle, compatibleWith: nil)
        let tintedHelpImage = helpImage?.withRenderingMode(.alwaysTemplate)
        
        let supportImage = UIImage(named: "Support", in: bundle, compatibleWith: nil)
        let tintedSupportImage = supportImage?.withRenderingMode(.alwaysTemplate)
        
        let closeImage = UIImage(named: "Close", in: bundle, compatibleWith: nil)
        let tintedCloseImage = closeImage?.withRenderingMode(.alwaysTemplate)
        
   //RegulartHeaderSupportBtn: UIButton!
    //RegulartHeaderHelpBtn: UIButton!
    //RegulartHeaderCloseBtn
        
        var isIconUrl = true
        switch iconUrl {
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
        
        RegulartHeaderView.isHidden = true
        largeHeaderView.isHidden = true
        if size == "compact"{
            self.headerViewHeightConstraint.constant = 70.0 //headerHeight
            compactHeaderTitleLbl.text = titleTxt
            compactHeaderTitleLbl.textColor = UIColor.init(hexString: titleTxtColor ?? deafaultColor)
            compactHeaderTitleLbl.font = titleFont
            compactHeaderDescLbl.text = subTitleTxt
            compactHeaderDescLbl.textColor = UIColor.init(hexString: subTitleTxtColor ?? deafaultColor)
            compactHeaderDescLbl.font = subTitleFont
            headerView.backgroundColor = UIColor.init(hexString: bgColor ?? deafaultColor)
            if isIconUrl{
                if let urlStr = iconUrl, let url = URL(string: urlStr){
                    compactHeaderImagV.af.setImage(withURL: url, placeholderImage: UIImage(named: "Avatar", in: bundle, compatibleWith: nil))
                }
            }else{
                let imgV = UIImage.init(named: "leftMBG", in: bundle, compatibleWith: nil)
                compactHeaderImagV.image = imgV?.withRenderingMode(.alwaysTemplate)
                compactHeaderImagV.tintColor = BubbleViewRightTint
                compactHeaderImagV.contentMode = .scaleAspectFit
                
                let subimgV = UIImage.init(named: iconUrl ?? "Avatar", in: bundle, compatibleWith: nil)
                compactHeaderSubImagV.image = subimgV?.withRenderingMode(.alwaysTemplate)
                compactHeaderSubImagV.tintColor = BubbleViewUserChatTextColor
                compactHeaderSubImagV.contentMode = .scaleAspectFit
            }
            
            if !showIcon{
                compactHeaderImagV.isHidden = true
                compactHeaderImagVWidthconstraint.constant = 0.0
            }

            if let showHelpBtn = headerDic.buttons?.help?.show, showHelpBtn == false{
                compactHeaderHelpBtnWidthConstraint.constant = 0.0
            }

            if let showSupportBtn = headerDic.buttons?.live_agent?.show, showSupportBtn == false{
                compactHeaderSupportBtnWidthConstraint.constant = 0.0
            }
            if let showCloseBtn = headerDic.buttons?.close?.show, showCloseBtn == false{
                compactHeaderCloseBtnWidthConstaraint.constant = 0.0
            }
            compactHeaderBackBtn.setBackgroundImage(tintedBackImage, for: .normal)
            compactHeaderBackBtn.tintColor = UIColor.init(hexString: headerIconColor)
            compactHeaderHelpBtn.setImage(tintedHelpImage, for: .normal)
            compactHeaderHelpBtn.tintColor = UIColor.init(hexString: headerIconColor)
            compactHeaderSupportBtn.setImage(tintedSupportImage, for: .normal)
            compactHeaderSupportBtn.tintColor = UIColor.init(hexString: headerIconColor)
            compactHeaderCloseBtn.setImage(tintedCloseImage, for: .normal)
            compactHeaderCloseBtn.tintColor = UIColor.init(hexString: headerIconColor)
            
            compactHeaderBackBtn.addTarget(self, action: #selector(self.backButtonAction(_:)), for: .touchUpInside)
            compactHeaderHelpBtn.addTarget(self, action: #selector(self.helpButtonAction(_:)), for: .touchUpInside)
            compactHeaderSupportBtn.addTarget(self, action: #selector(self.supportButtonAction(_:)), for: .touchUpInside)
            compactHeaderCloseBtn.addTarget(self, action: #selector(self.closeButtonAction(_:)), for: .touchUpInside)
            if useColorPaletteOnly == true{
                headerView.backgroundColor = UIColor.init(hexString: genaralSecondaryColor)
            }
        }else if size == "regular"{
            self.headerViewHeightConstraint.constant = 112.0 // headerHeight
            RegulartHeaderView.isHidden = false
            RegulartHeaderTitleLbl.text = titleTxt
            RegulartHeaderTitleLbl.font = titleFont
            RegulartHeaderTitleLbl.textColor = UIColor.init(hexString: titleTxtColor ?? deafaultColor)
            RegulartHeaderDescLbl.text = subTitleTxt
            RegulartHeaderDescLbl.textColor = UIColor.init(hexString: subTitleTxtColor ?? deafaultColor)
            RegulartHeaderDescLbl.font = subTitleFont
            RegulartHeaderView.backgroundColor = UIColor.init(hexString: bgColor ?? deafaultColor)
            if isIconUrl{
                if let urlStr = iconUrl, let url = URL(string: urlStr){
                    RegulartHeaderImagV.af.setImage(withURL: url, placeholderImage: UIImage(named: "Avatar", in: bundle, compatibleWith: nil))
                }
            }else{
                let imgV = UIImage.init(named: "leftMBG", in: bundle, compatibleWith: nil)
                RegulartHeaderImagV.image = imgV?.withRenderingMode(.alwaysTemplate)
                RegulartHeaderImagV.tintColor = BubbleViewRightTint
                RegulartHeaderImagV.contentMode = .scaleAspectFit
                
                let subImgv = UIImage.init(named: iconUrl ?? "Avatar", in: bundle, compatibleWith: nil)
                regularHeaderSubImgV.image = subImgv?.withRenderingMode(.alwaysTemplate)
                regularHeaderSubImgV.tintColor = BubbleViewUserChatTextColor
                regularHeaderSubImgV.contentMode = .scaleAspectFit
                
            }
            
            if !showIcon{
                RegulartHeaderImagV.isHidden = true
                RegulartHeaderImagVHeightConstraint.constant = 0.0
            }

            if let showHelpBtn = headerDic.buttons?.help?.show, showHelpBtn == false{
                RegulartHeaderHelpBtnWidthConstraint.constant = 0.0
            }

            if let showSupportBtn = headerDic.buttons?.live_agent?.show, showSupportBtn == false{
                RegulartHeaderSupportBtnWidthConstraint.constant = 0.0
            }
            if let showCloseBtn = headerDic.buttons?.close?.show, showCloseBtn == false{
                RegulartHeaderCloseBtnWidthConstaraint.constant = 0.0
            }
            RegulartHeaderBackBtn.setBackgroundImage(tintedBackImage, for: .normal)
            RegulartHeaderBackBtn.tintColor = UIColor.init(hexString: headerIconColor)
            RegulartHeaderHelpBtn.setImage(tintedHelpImage, for: .normal)
            RegulartHeaderHelpBtn.tintColor = UIColor.init(hexString: headerIconColor)
            RegulartHeaderSupportBtn.setImage(tintedSupportImage, for: .normal)
            RegulartHeaderSupportBtn.tintColor = UIColor.init(hexString: headerIconColor)
            RegulartHeaderCloseBtn.setImage(tintedCloseImage, for: .normal)
            RegulartHeaderCloseBtn.tintColor = UIColor.init(hexString: headerIconColor)
            
            RegulartHeaderBackBtn.addTarget(self, action: #selector(self.backButtonAction(_:)), for: .touchUpInside)
            RegulartHeaderHelpBtn.addTarget(self, action: #selector(self.helpButtonAction(_:)), for: .touchUpInside)
            RegulartHeaderSupportBtn.addTarget(self, action: #selector(self.supportButtonAction(_:)), for: .touchUpInside)
            largeHeaderCloseBtn.addTarget(self, action: #selector(self.closeButtonAction(_:)), for: .touchUpInside)
            if useColorPaletteOnly == true{
                RegulartHeaderView.backgroundColor = UIColor.init(hexString: genaralSecondaryColor)
            }
        }
        else if size == "large"{
            self.headerViewHeightConstraint.constant = 170.0 //headerHeight
            largeHeaderView.isHidden = false
            largeHeaderSubView.layer.cornerRadius = 4.0
            largeHeaderSubView.layer.shadowOffset = CGSize(width: 0, height: 3)
            largeHeaderSubView.layer.shadowOpacity = 0.6
            largeHeaderSubView.layer.shadowRadius = 2.0
            largeHeaderSubView.layer.shadowColor = UIColor.lightGray.cgColor
            largeHeaderSubView.backgroundColor = UIColor.init(hexString: bgColor ?? deafaultColor)

            let backImage = UIImage(named: "cheveron-left", in: bundle, compatibleWith: nil)
            let tintedBackImage = backImage?.withRenderingMode(.alwaysTemplate)
            largeHeaderBackBtn.setImage(tintedBackImage, for: .normal)
            largeHeaderBackBtn.tintColor = UIColor.init(hexString: deafaultColor)

            let helpImage = UIImage(named: "Help", in: bundle, compatibleWith: nil)
            let tintedHelpImage = helpImage?.withRenderingMode(.alwaysTemplate)
            largeHeaderHelpBtn.setImage(tintedHelpImage, for: .normal)
            largeHeaderHelpBtn.tintColor =  UIColor.init(hexString: deafaultColor)

            let supportImage = UIImage(named: "Support", in: bundle, compatibleWith: nil)
            let tintedSupportImage = supportImage?.withRenderingMode(.alwaysTemplate)
            largeHeaderSupportBtn.setImage(tintedSupportImage, for: .normal)
            largeHeaderSupportBtn.tintColor =  UIColor.init(hexString: deafaultColor)
            
            let closeImage = UIImage(named: "Close", in: bundle, compatibleWith: nil)
            let tintedCloseImage = closeImage?.withRenderingMode(.alwaysTemplate)
            largeHeaderCloseBtn.setImage(tintedCloseImage, for: .normal)
            largeHeaderCloseBtn.tintColor =  UIColor.init(hexString: deafaultColor)

            largeHeaderTitleLbl.text = titleTxt
            largeHeaderTitleLbl.textColor = UIColor.init(hexString: titleTxtColor ?? deafaultColor)
            largeHeaderTitleLbl.font = titleFont
            largeHeaderDescLbl.text = subTitleTxt
            largeHeaderDescLbl.textColor = UIColor.init(hexString: subTitleTxtColor ?? deafaultColor)
            largeHeaderDescLbl.font = subTitleFont
            if isIconUrl{
                if let urlStr = iconUrl, let url = URL(string: urlStr){
                    largeHeaderImagV.af.setImage(withURL: url, placeholderImage: UIImage(named: "Avatar", in: bundle, compatibleWith: nil))
                }
            }else{
                let imgV = UIImage.init(named: "leftMBG", in: bundle, compatibleWith: nil)
                largeHeaderImagV.image = imgV?.withRenderingMode(.alwaysTemplate)
                largeHeaderImagV.tintColor = BubbleViewRightTint
                largeHeaderImagV.contentMode = .scaleAspectFit
                let subImgv = UIImage.init(named: iconUrl ?? "Avatar", in: bundle, compatibleWith: nil)
                largeHeaderSubImagV.image = subImgv?.withRenderingMode(.alwaysTemplate)
                largeHeaderSubImagV.tintColor = BubbleViewUserChatTextColor
                largeHeaderSubImagV.contentMode = .scaleAspectFit
                
            }
            
            if !showIcon{
                largeHeaderImagV.isHidden = true
                largeHeaderImagvHeightConstraint.constant = 35.0
            }

            if let showHelpBtn = headerDic.buttons?.help?.show, showHelpBtn == false{
                largeHeaderHelpBtnWidthConstraint.constant = 0.0
            }

            if let showSupportBtn = headerDic.buttons?.live_agent?.show, showSupportBtn == false{
                largeHeaderSupportBtnWidthConstraint.constant = 0.0
            }
            if let showCloseBtn = headerDic.buttons?.close?.show, showCloseBtn == false{
                largeHeaderCloseBtnWidthConstaraint.constant = 0.0
            }
            
            largeHeaderBackBtn.setBackgroundImage(tintedBackImage, for: .normal)
            largeHeaderBackBtn.tintColor = UIColor.init(hexString: headerIconColor)
            largeHeaderHelpBtn.setImage(tintedHelpImage, for: .normal)
            largeHeaderHelpBtn.tintColor = UIColor.init(hexString: headerIconColor)
            largeHeaderSupportBtn.setImage(tintedSupportImage, for: .normal)
            largeHeaderSupportBtn.tintColor = UIColor.init(hexString: headerIconColor)
            largeHeaderCloseBtn.setImage(tintedCloseImage, for: .normal)
            largeHeaderCloseBtn.tintColor = UIColor.init(hexString: headerIconColor)
            
            largeHeaderBackBtn.addTarget(self, action: #selector(self.backButtonAction(_:)), for: .touchUpInside)
            largeHeaderHelpBtn.addTarget(self, action: #selector(self.helpButtonAction(_:)), for: .touchUpInside)
            largeHeaderSupportBtn.addTarget(self, action: #selector(self.supportButtonAction(_:)), for: .touchUpInside)
            largeHeaderCloseBtn.addTarget(self, action: #selector(self.closeButtonAction(_:)), for: .touchUpInside)
            if useColorPaletteOnly == true{
                largeHeaderSubView.backgroundColor = UIColor.init(hexString: genaralSecondaryColor)
            }
        }
    }
    @objc fileprivate func backButtonAction(_ sender: AnyObject!) {
        chatHeaderVBackBtnAct?("back")
    }
    @objc fileprivate func helpButtonAction(_ sender: AnyObject!) {
        chatHeaderVHelpBtnAct?("help")
    }
    @objc fileprivate func supportButtonAction(_ sender: AnyObject!) {
        chatHeaderVSupportBtnAct?("support")
    }
    @objc fileprivate func closeButtonAction(_ sender: AnyObject!) {
        chatHeaderVCloseBtnAct?("close")
    }

}

