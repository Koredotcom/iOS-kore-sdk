//
//  WelcomeScreenView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 21/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
protocol WelcomeScreenViewDelegate {
    func welcomeScreenBtnsAction(text:String, payload:String)
    func hidewelcomeScreenView()
    func linkButtonTapAction(urlString: String)
    func keyBoardShow()
}

class WelcomeScreenView: UIView {
    let bundle = Bundle.sdkModule
    var viewDelegate: WelcomeScreenViewDelegate?
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var powerdByfooterView: UIView!
    @IBOutlet weak var headerImageV: UIImageView!
    @IBOutlet weak var topImageV: UIImageView!
    @IBOutlet weak var centeredImageV: UIImageView!
    @IBOutlet weak var bottomImagV: UIImageView!
    @IBOutlet weak var poweredByViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bgSubV: UIView!
    @IBOutlet weak var bgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var centeredImagVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var tabVBackV: UIView!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    var searchTf: UITextField!
    let nibName = "WelcomeScreenView"
    var view : UIView!
    let borderColor = UIColor(hexString: "#E4E5E7")
    let defaultColor = "#4B4EDE"
    var welcomeScreenDic = WelcomeScreen()
    var staticLinksDic = Static_links()
    var BannersDic = Promotional_Content()
    var regularLayoutType = "regular"
    var largeLayoutType = "large"
    var mediumLayoutType = "medium"
    var arrayOfHideTableSections = [Bool]()
    var arrayOfSectionsType = [String]()
    
    let StartConversationStr = "Start Conversation"
    let LinksStr = "Links"
    let TransactionStr = "Transactions"
    let BannersStr = "Banners"
    //var useColorPaletteOnly = false
    //var useColorPaletteOnlyTxtColor = "#FFFFFF"
    
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
        poweredByViewHeightConstraint.constant = 0.0
        powerdByfooterView.isHidden = true
        headingLbl.font = UIFont(name: boldCustomFont, size: 20.0)
        titleLbl.font = UIFont(name: boldCustomFont, size: 17.0)
        descLbl.font = UIFont(name: mediumCustomFont, size: 14.0)
        
        if #available(iOS 15.0, *) {
            tableview.sectionHeaderTopPadding = 0
        }
       tableview.register(UINib(nibName: "WelcomeVGridCell", bundle: bundle), forCellReuseIdentifier: "WelcomeVGridCell")
       tableview.register(UINib(nibName: "WelcomeVListLinksCell", bundle: bundle), forCellReuseIdentifier: "WelcomeVListLinksCell")
       tableview.register(UINib(nibName: "WelcomeVListTransactionsCell", bundle: bundle), forCellReuseIdentifier: "WelcomeVListTransactionsCell")
        tableview.register(UINib(nibName: "WelcomeVListLinksCarouselCell", bundle: bundle), forCellReuseIdentifier: "WelcomeVListLinksCarouselCell")
        tableview.register(UINib(nibName: "BannersCell", bundle: bundle), forCellReuseIdentifier: "BannersCell")
        tableview.register(UINib(nibName: "WelcomeScreenStartConsvCell", bundle: bundle), forCellReuseIdentifier: "WelcomeScreenStartConsvCell")
        tableview.backgroundColor = UIColor(hexString: "#F8FAFC")
    
    }
    
    func configure(with welcomeScreenDic: WelcomeScreen?, generalDic: General?) { //regular -- c, large -- bottom , medium  -- top
        self.welcomeScreenDic = welcomeScreenDic ?? WelcomeScreen()
        
        let welcomeScreenLayout = welcomeScreenDic?.layout

        let logo_url = welcomeScreenDic?.logo?.logo_url
        //let defaultColor = "#ffffff"
        let defaultBgColor = "#4B4EDE"
        let bgType = welcomeScreenDic?.background?.type
        headerImageV.isHidden = true
        if bgType == "image"{
            if let imageUrlStr = welcomeScreenDic?.background?.img, let url = URL(string: imageUrlStr){
                headerImageV.isHidden = false
                headerImageV.contentMode = .scaleToFill
                headerImageV.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image", in: bundle, compatibleWith: nil))
            }else{
                let bgColor = welcomeScreenDic?.background?.color
                bgSubV.backgroundColor = UIColor(hexString: bgColor ?? defaultBgColor)
            }
            
        }else{
            let bgColor = welcomeScreenDic?.background?.color
            bgSubV.backgroundColor = UIColor(hexString: bgColor ?? defaultBgColor)
        }
        

        let headingName = welcomeScreenDic?.title?.name
        //let headingColor = welcomeScreenDic?.title?.color
        headingLbl.text =  "\(headingName ?? "") 🙂"
        

        let subTitleName = welcomeScreenDic?.sub_title?.name
        //let subtitleColor = welcomeScreenDic?.sub_title?.color
        titleLbl.text = subTitleName
        

        let noteName = welcomeScreenDic?.note?.name
        //let noteColor = welcomeScreenDic?.note?.color
        descLbl.text = noteName
        

        if let topLabelsColor = welcomeScreenDic?.top_fonts?.color{
            headingLbl.textColor = UIColor(hexString: topLabelsColor)
            titleLbl.textColor = UIColor(hexString: topLabelsColor)
            descLbl.textColor = UIColor(hexString: topLabelsColor)
        }
        
        powerdByfooterView.backgroundColor = .clear
        if let footerBgColor = welcomeScreenDic?.bottom_background?.color{
            powerdByfooterView.backgroundColor = UIColor(hexString: footerBgColor)
        }

        if welcomeScreenLayout == mediumLayoutType{
            topImageV.isHidden = false
            centeredImageV.isHidden = true
            bottomImagV.isHidden = true
            if let imageUrlStr = logo_url, let url = URL(string: imageUrlStr){
                topImageV.af.setImage(withURL: url, placeholderImage: UIImage(named: "Circlelogo", in: bundle, compatibleWith: nil))
            }
        }
        if welcomeScreenLayout == regularLayoutType{
            topImageV.isHidden = true
            centeredImageV.isHidden = false
            bottomImagV.isHidden = true
            if let imageUrlStr = logo_url, let url = URL(string: imageUrlStr){
                centeredImageV.af.setImage(withURL: url, placeholderImage: UIImage(named: "Standard chartered logo", in: bundle, compatibleWith: nil))
            }
        }
        if welcomeScreenLayout == largeLayoutType{
            topImageV.isHidden = true
            centeredImageV.isHidden = true
            bottomImagV.isHidden = false
            if let imageUrlStr = logo_url, let url = URL(string: imageUrlStr){
                bottomImagV.af.setImage(withURL: url, placeholderImage: UIImage(named: "Circlelogo", in: bundle, compatibleWith: nil))
            }
        }

        if topImageV.isHidden{
            bgViewTopConstraint.constant = 0.0
        }
        if centeredImageV.isHidden{
            centeredImagVHeightConstraint.constant = 0.0
        }
        if bottomImagV.isHidden{
            tableViewTopConstraint.constant = 10.0
        }
        
        arrayOfSectionsType = []
        
        if let starterShow = welcomeScreenDic?.starter_box?.show, starterShow == true{
            arrayOfHideTableSections.append(starterShow)
        }else{
            arrayOfHideTableSections.append(false)
        }
        arrayOfSectionsType.append(StartConversationStr)
        
        if let linksShow = welcomeScreenDic?.static_links?.show, linksShow == true{
            arrayOfHideTableSections.append(linksShow)
        }else{
            arrayOfHideTableSections.append(false)
        }
        arrayOfSectionsType.append(LinksStr)
        
        arrayOfHideTableSections.append(false) //Transactions
        arrayOfSectionsType.append(TransactionStr)
        
        if let bannersShow = welcomeScreenDic?.promotional_content?.show, bannersShow == true{
            arrayOfHideTableSections.append(bannersShow)
        }else{
            arrayOfHideTableSections.append(false)
        }
        arrayOfSectionsType.append(BannersStr)
        
        staticLinksDic = welcomeScreenDic?.static_links ?? Static_links()
        BannersDic = welcomeScreenDic?.promotional_content ?? Promotional_Content()
        
        tabVBackV.backgroundColor = .clear
        if useColorPaletteOnly{
            bgSubV.backgroundColor = UIColor(hexString: genaralPrimaryColor)
            let txtColor = UIColor.init(hexString: genaralSecondary_textColor)
            headingLbl.textColor = txtColor
            titleLbl.textColor = txtColor
            descLbl.textColor = txtColor
            tabVBackV.backgroundColor = UIColor(hexString: genaralSecondaryColor)
            powerdByfooterView.backgroundColor = UIColor(hexString: genaralPrimaryColor)
            tableview.backgroundColor = .clear
        }
        
        tableview.reloadData()
    }
    
    
    
    func loadViewFromNib() ->UIView {
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
}
extension WelcomeScreenView: UITableViewDataSource, UITableViewDelegate, WelcomeVGridCellDelegate, WelcomeVListLinksCarouselDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfSectionsType.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrayOfSectionsType[section] == StartConversationStr{
            if arrayOfHideTableSections[section] == true{
                if let btns = welcomeScreenDic.starter_box?.quick_start_buttons, btns.show == true{
                    if welcomeScreenDic.starter_box?.quick_start_buttons?.style == "slack"{
                        return 1
                    }else{
                        guard let totalBtnsCount = btns.buttons?.count else { return 0 }
                        return totalBtnsCount
                    }
                }
                return 0
            }
            return 0
        }else if arrayOfSectionsType[section] == LinksStr{
            if arrayOfHideTableSections[section] == true{
                if let linksLayout = staticLinksDic.layout, linksLayout == "carousel"{
                    return staticLinksDic.links?.count ?? 0 > 0 ? 1 : 0
                }else{
                    return staticLinksDic.links?.count ?? 0
                }
            }
            return 0
        }else if arrayOfSectionsType[section] == TransactionStr{
            if arrayOfHideTableSections[section] == true{
                return 3
            }
            return 0
        }else if arrayOfSectionsType[section] == BannersStr{
            if arrayOfHideTableSections[section] == true{
                return BannersDic.promotions?.count ?? 0
            }
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if arrayOfSectionsType[indexPath.section] == StartConversationStr{
            if welcomeScreenDic.starter_box?.quick_start_buttons?.style == "slack"{
                let cell : WelcomeVGridCell = self.tableview.dequeueReusableCell(withIdentifier: "WelcomeVGridCell") as! WelcomeVGridCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.viewDelegate = self
                let StarterBoxBtns = welcomeScreenDic.starter_box?.quick_start_buttons?.buttons
                cell.configure(with: StarterBoxBtns ?? [])
                return cell
            }else{
                let cell : WelcomeScreenStartConsvCell = self.tableview.dequeueReusableCell(withIdentifier: "WelcomeScreenStartConsvCell") as! WelcomeScreenStartConsvCell
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                let StarterBoxBtns = welcomeScreenDic.starter_box?.quick_start_buttons?.buttons
                let buttons =  StarterBoxBtns?[indexPath.row]
                cell.bgV.backgroundColor = .white
                cell.textlabel.font = UIFont(name: "HelveticaNeue", size: 14.0)
                cell.textlabel.text = buttons?.title
                cell.textlabel.textAlignment = .center
                cell.textlabel.textColor = UIColor(hexString: "#404040")
                cell.bgV.layer.borderWidth = 1.0
                cell.bgV.layer.cornerRadius = 5
                cell.bgV.layer.borderColor = borderColor.cgColor
                
                cell.addBorder(edge: .left, color: borderColor, borderWidth: 1.0)
                cell.addBorder(edge: .right, color: borderColor, borderWidth: 1.0)
                cell.layer.cornerRadius = 2.0
                cell.clipsToBounds = true
                
                return cell
            }
        }else if arrayOfSectionsType[indexPath.section] == LinksStr{
            if let linksLayout = staticLinksDic.layout, linksLayout == "carousel"{
                let cell : WelcomeVListLinksCarouselCell = self.tableview.dequeueReusableCell(withIdentifier: "WelcomeVListLinksCarouselCell") as! WelcomeVListLinksCarouselCell
                cell.backgroundColor = UIColor.white
                cell.viewDelegate = self
                cell.configure(with: staticLinksDic.links ?? [])
                return cell
            }else{
                let cell : WelcomeVListLinksCell = self.tableview.dequeueReusableCell(withIdentifier: "WelcomeVListLinksCell") as! WelcomeVListLinksCell
                cell.backgroundColor = UIColor.white
                cell.selectionStyle = .none
                cell.descLbl.numberOfLines = 2
                cell.underLineLbl.isHidden = true
                cell.layer.cornerRadius = 0.0
                cell.clipsToBounds = false
                let links = staticLinksDic.links
                let linkDetails = links?[indexPath.row]
                cell.titleLbl.text = linkDetails?.title
                cell.descLbl.text = linkDetails?.descrip
                let totalRows = tableView.numberOfRows(inSection: indexPath.section)
                if indexPath.row == totalRows - 1 {
                    cell.underLineLbl.isHidden = false
                    cell.layer.cornerRadius = 2.0
                    cell.clipsToBounds = true
                }
                return cell
            }
            
        }else if arrayOfSectionsType[indexPath.section] == TransactionStr{
            let cell : WelcomeVListTransactionsCell = self.tableview.dequeueReusableCell(withIdentifier: "WelcomeVListTransactionsCell") as! WelcomeVListTransactionsCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.layer.cornerRadius = 0.0
            cell.clipsToBounds = false
            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
            if indexPath.row == totalRows - 1 {
                cell.layer.cornerRadius = 2.0
                cell.clipsToBounds = true
            }
            return cell
        }else if arrayOfSectionsType[indexPath.section] == BannersStr{
            let cell : BannersCell = self.tableview.dequeueReusableCell(withIdentifier: "BannersCell") as! BannersCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let promotios = BannersDic.promotions
            let details = promotios?[indexPath.row]
            cell.bgV.layer.cornerRadius = 5.0
            cell.bgV.clipsToBounds = true
            cell.bannerImagV.contentMode = .scaleAspectFill
            if let imageUrlStr = details?.banner, let url = URL(string: imageUrlStr){
                cell.bannerImagV.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image", in: bundle, compatibleWith: nil))
            }
            return cell
        }else{
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrayOfSectionsType[indexPath.section] == StartConversationStr{
            if let btns = welcomeScreenDic.starter_box?.quick_start_buttons, btns.show == true{
                //return 100.0 //150
                if welcomeScreenDic.starter_box?.quick_start_buttons?.style == "slack"{
                    let cell : WelcomeVGridCell = self.tableview.dequeueReusableCell(withIdentifier: "WelcomeVGridCell") as! WelcomeVGridCell
                    let StarterBoxBtns = welcomeScreenDic.starter_box?.quick_start_buttons?.buttons
                    cell.configure(with: StarterBoxBtns ?? [])
                    cell.layoutIfNeeded()
                    cell.collectionV.reloadData()
                    let collectionViewHeight = cell.collectionV.collectionViewLayout.collectionViewContentSize.height
                        return collectionViewHeight
                    }else{
                        return UITableView.automaticDimension
                    }
                }
            return 0
        }else if arrayOfSectionsType[indexPath.section] == LinksStr{
            if let linksLayout = staticLinksDic.layout, linksLayout == "carousel"{
                return staticLinksDic.links?.count ?? 0 > 0 ? 100 : 0
            }
            return UITableView.automaticDimension
        }
        else if arrayOfSectionsType[indexPath.section] == BannersStr{
            return 200.0
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if arrayOfSectionsType[section] == StartConversationStr{
            if arrayOfHideTableSections[section] == true{
                return 70.0
            }
            return 0.0
        }else if arrayOfSectionsType[section] == BannersStr{
            return 0.0
        } else{
            if arrayOfHideTableSections[section] == true{
                return 50.0
            }
            return 0.0
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 2.0
        headerView.clipsToBounds = true
        let topLineLbl = UILabel(frame: CGRect.zero)
        topLineLbl.translatesAutoresizingMaskIntoConstraints = false
        topLineLbl.backgroundColor = borderColor
        headerView.addSubview(topLineLbl)
        
        let leftLineLbl = UILabel(frame: CGRect.zero)
        leftLineLbl.translatesAutoresizingMaskIntoConstraints = false
        leftLineLbl.backgroundColor = borderColor
        headerView.addSubview(leftLineLbl)
        
        let rightLineLbl = UILabel(frame: CGRect.zero)
        rightLineLbl.translatesAutoresizingMaskIntoConstraints = false
        rightLineLbl.backgroundColor = borderColor
        headerView.addSubview(rightLineLbl)
        
        let iconUrl  =  brandingValues.header?.icon?.icon_url
            
        if arrayOfSectionsType[section] == StartConversationStr{
            headerView.backgroundColor = .white
            let headerSubView  = WelcomeVListHeaderView()
            let starterBox = welcomeScreenDic.starter_box
            headerSubView.configure(with: starterBox, iconStr: iconUrl)
            headerSubView.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(headerSubView)
            
            let views: [String: UIView] = ["topLineLbl": topLineLbl ,"leftLineLbl": leftLineLbl ,"rightLineLbl": rightLineLbl ,"headerSubView": headerSubView]
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerSubView]-5-|", options:[], metrics:nil, views:views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-1-[headerSubView]-1-|", options:[], metrics:nil, views:views))
            
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[topLineLbl]-0-|", options:[], metrics:nil, views:views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[topLineLbl(1)]", options:[], metrics:nil, views:views))
            
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[leftLineLbl(1)]", options:[], metrics:nil, views:views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[leftLineLbl]-0-|", options:[], metrics:nil, views:views))
            
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightLineLbl(1)]-0-|", options:[], metrics:nil, views:views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[rightLineLbl]-0-|", options:[], metrics:nil, views:views))
        }else{
            let headerTitleLbl = UILabel(frame: CGRect.zero)
            headerTitleLbl.textColor = .black
            if arrayOfSectionsType[section] == LinksStr{
                headerTitleLbl.text = "Links"
            }else if arrayOfSectionsType[section] == TransactionStr{
                headerTitleLbl.text = "Last 3 Transactions"
            }
           
            headerTitleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
            headerTitleLbl.numberOfLines = 0
            headerTitleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
            headerTitleLbl.isUserInteractionEnabled = true
            headerTitleLbl.contentMode = UIView.ContentMode.topLeft
            headerTitleLbl.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(headerTitleLbl)
            headerTitleLbl.adjustsFontSizeToFitWidth = true
            headerTitleLbl.backgroundColor = .clear
            headerTitleLbl.sizeToFit()
            let views: [String: UIView] = ["topLineLbl": topLineLbl ,"leftLineLbl": leftLineLbl ,"rightLineLbl": rightLineLbl ,"headerTitleLbl": headerTitleLbl]
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headerTitleLbl(30)]-10-|", options:[], metrics:nil, views:views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headerTitleLbl]-10-|", options:[], metrics:nil, views:views))
            
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[topLineLbl]-0-|", options:[], metrics:nil, views:views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[topLineLbl(1)]", options:[], metrics:nil, views:views))
            
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[leftLineLbl(1)]", options:[], metrics:nil, views:views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[leftLineLbl]-0-|", options:[], metrics:nil, views:views))
            
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightLineLbl(1)]-0-|", options:[], metrics:nil, views:views))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[rightLineLbl]-0-|", options:[], metrics:nil, views:views))
        }
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if arrayOfSectionsType[section] == StartConversationStr{
            if arrayOfHideTableSections[section] == true{
                return 70
            }
            return 0.0
        }else if arrayOfSectionsType[section] == BannersStr{
            return 0.0
        }else{
            if arrayOfHideTableSections[section] == true{
                return 10
            }
            return 0.0
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        if arrayOfSectionsType[section] == StartConversationStr{
            let StarterBoxDic = welcomeScreenDic.starter_box
            var btnBgColor = StarterBoxDic?.start_conv_button?.color
            let whiteColor = "#ffffff"
            var btnTextColor = "#ffffff"
            if useColorPaletteOnly{
                btnTextColor = genaralSecondary_textColor
                btnBgColor = genaralPrimaryColor
            }else{
                btnTextColor = StarterBoxDic?.start_conv_text?.color ?? btnTextColor
                btnBgColor = StarterBoxDic?.start_conv_button?.color
            }
            
            let footerSubView = UIView()
            footerSubView.backgroundColor = UIColor.white
            footerSubView.translatesAutoresizingMaskIntoConstraints = false
            footerView.addSubview(footerSubView)
            
            footerSubView.addBorder(edge: .bottom, color: borderColor, borderWidth: 1.0)
            footerSubView.addBorder(edge: .left, color: borderColor, borderWidth: 1.0)
            footerSubView.addBorder(edge: .right, color: borderColor, borderWidth: 1.0)
            footerSubView.layer.cornerRadius = 2.0
            footerSubView.clipsToBounds = true
            
            let inputType = StarterBoxDic?.quick_start_buttons?.input
            if inputType == "button"{
                let startBtn = UIButton(frame: CGRect.zero)
                startBtn.backgroundColor = UIColor(hexString: btnBgColor ?? defaultColor)
                startBtn.translatesAutoresizingMaskIntoConstraints = false
                startBtn.clipsToBounds = true
                startBtn.layer.cornerRadius = 5
                startBtn.setTitleColor(UIColor(hexString: btnTextColor ?? whiteColor), for: .normal)
                startBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
                footerView.addSubview(startBtn)
                startBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                startBtn.addTarget(self, action: #selector(self.startConversationBtnAction(_:)), for: .touchUpInside)
                startBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 10)
                if #available(iOS 13.0, *) {
                    //startBtn.setImage(UIImage(named: "downarrow", in: bundle, with: nil), for: .normal)
                }
                startBtn.setTitle("Start Conversation", for: .normal)
                startBtn.layer.borderWidth = 1
                startBtn.layer.borderColor = themeColor.cgColor
                let btnfont = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
                startBtn.titleLabel?.font = btnfont
                
                let arrowImg = UIImageView(frame: CGRect.zero)
                arrowImg.translatesAutoresizingMaskIntoConstraints = false
               
                let menuImage = UIImage(named: "leftarrow", in: bundle, compatibleWith: nil)
                let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
                arrowImg.image = tintedMenuImage
                arrowImg.tintColor = UIColor(hexString: btnTextColor )
                
                footerView.addSubview(arrowImg)

                let views: [String: UIView] = ["footerSubView":footerSubView, "startBtn": startBtn, "arrowImg": arrowImg]
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[footerSubView]-10-|", options:[], metrics:nil, views:views))
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerSubView]-0-|", options:[], metrics:nil, views:views))
                
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[startBtn(36)]", options:[], metrics:nil, views:views))
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[startBtn]-10-|", options:[], metrics:nil, views:views))
                
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-17-[arrowImg(15)]", options:[], metrics:nil, views:views))
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[arrowImg(15)]-25-|", options:[], metrics:nil, views:views))
            }else{
                let footerSearchView = UIView()
                footerSearchView.backgroundColor = UIColor.white
                footerSearchView.translatesAutoresizingMaskIntoConstraints = false
                footerSubView.addSubview(footerSearchView)
                footerSearchView.layer.cornerRadius = 5
                footerSearchView.layer.borderWidth = 1
                footerSearchView.layer.borderColor = borderColor.cgColor
                footerSearchView.clipsToBounds = true
                
                let sendBtn = UIButton(frame: CGRect.zero)
                sendBtn.backgroundColor = UIColor(hexString: btnBgColor ?? defaultColor)
                sendBtn.translatesAutoresizingMaskIntoConstraints = false
                sendBtn.clipsToBounds = true
                sendBtn.layer.cornerRadius = 5
                sendBtn.setTitleColor(UIColor(hexString: btnTextColor ?? whiteColor), for: .normal)
                sendBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
                sendBtn.setImage(UIImage(named: "SendW", in: bundle, compatibleWith: nil), for: .normal)
                sendBtn.addTarget(self, action: #selector(self.sendBtnAction(_:)), for: .touchUpInside)
                footerSubView.addSubview(sendBtn)
                
                let views: [String: UIView] = ["footerSubView":footerSubView, "footerSearchView": footerSearchView, "sendBtn": sendBtn]
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[footerSubView]-10-|", options:[], metrics:nil, views:views))
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerSubView]-0-|", options:[], metrics:nil, views:views))
                
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[footerSearchView(36)]", options:[], metrics:nil, views:views))
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[footerSearchView]-10-[sendBtn(36)]-10-|", options:[], metrics:nil, views:views))
                
                footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[sendBtn(36)]", options:[], metrics:nil, views:views))
                
                
                let searchImagv = UIImageView()
                searchImagv.translatesAutoresizingMaskIntoConstraints = false
                searchImagv.contentMode = .scaleAspectFit
                searchImagv.image = UIImage(named: "search", in: bundle, compatibleWith: nil)
                footerSearchView.addSubview(searchImagv)
                
                searchTf = UITextField()
                searchTf.backgroundColor = .clear
                searchTf.translatesAutoresizingMaskIntoConstraints = false
                searchTf.font = UIFont(name: "HelveticaNeue", size: 15.0)
                searchTf.tintColor = .black
                //searchTf.delegate = self
                searchTf.placeholder = "Search"
                searchTf.textColor = .black
                searchTf.delegate = self
                footerSearchView.addSubview(searchTf)
                
                let subviews: [String: UIView] = ["searchImagv":searchImagv, "searchTf": searchTf]
                footerSearchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[searchImagv(16)]", options:[], metrics:nil, views:subviews))
                footerSearchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[searchImagv(16)]-5-[searchTf]-10-|", options:[], metrics:nil, views:subviews))
                
                footerSearchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[searchTf]-5-|", options:[], metrics:nil, views:subviews))
            }
        }
        return footerView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrayOfSectionsType[indexPath.section] == StartConversationStr{
            if welcomeScreenDic.starter_box?.quick_start_buttons?.style != "slack"{
                let StarterBoxBtns = welcomeScreenDic.starter_box?.quick_start_buttons?.buttons
                let buttons =  StarterBoxBtns?[indexPath.row]
                if let title = buttons?.title{
                    if let action = buttons?.action, action.type == "postback"{
                        viewDelegate?.welcomeScreenBtnsAction(text: title, payload: action.value ?? title)
                        viewDelegate?.keyBoardShow()
                    }
                }
            }
        }else if arrayOfSectionsType[indexPath.section] == LinksStr{
            let links = staticLinksDic.links
            let linkDetails = links?[indexPath.row]
            if let linkAction = linkDetails?.action, linkAction.type == "url"{
                if let linkUrl = linkAction.value{
                    viewDelegate?.linkButtonTapAction(urlString: linkUrl)
                }
            }
        }else if arrayOfSectionsType[indexPath.section] == BannersStr{
            let promotios = BannersDic.promotions
            let promotiosDetails = promotios?[indexPath.row]
            if let linkAction = promotiosDetails?.action, linkAction.type == "url"{
                if let linkUrl = linkAction.value{
                    viewDelegate?.linkButtonTapAction(urlString: linkUrl)
                }
            }
        }
    }
    func optionsButtonAction(text: String, payload: String) {
        viewDelegate?.welcomeScreenBtnsAction(text: text, payload: payload)
    }
    @objc fileprivate func startConversationBtnAction(_ sender: AnyObject!) {
        viewDelegate?.hidewelcomeScreenView()
        viewDelegate?.keyBoardShow()
    }
    func linkButtonAction(urlString: String) {
        viewDelegate?.linkButtonTapAction(urlString: urlString)
    }
    @objc fileprivate func sendBtnAction(_ sender: AnyObject!) {
        var text =  searchTf.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let txt = text, text?.count ?? 0 > 0{
            searchTf.resignFirstResponder()
            viewDelegate?.welcomeScreenBtnsAction(text: txt, payload: txt)
        }
    }
}

extension UIView {

    func addBorder(edge: UIRectEdge, color: UIColor, borderWidth: CGFloat) {

        let seperator = UIView()
        self.addSubview(seperator)
        seperator.translatesAutoresizingMaskIntoConstraints = false

        seperator.backgroundColor = color

        if edge == .top || edge == .bottom
        {
            seperator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            seperator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            seperator.heightAnchor.constraint(equalToConstant: borderWidth).isActive = true

            if edge == .top
            {
                seperator.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            }
            else
            {
                seperator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            }
        }
        else if edge == .left || edge == .right
        {
            seperator.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            seperator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            seperator.widthAnchor.constraint(equalToConstant: borderWidth).isActive = true

            if edge == .left
            {
                seperator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            }
            else
            {
                seperator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            }
        }
    }

}

extension WelcomeScreenView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
