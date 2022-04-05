//
//  PopularSearchView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 25/02/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit
protocol PopularSearchViewDelegate {
    func optionsButtonTapAction(text:String)
    func optionsButtonTapNewAction(text:String, payload:String)
}

class PopularSearchView: UIView {

    var iconImagV: UIImageView!
    var tileBgv: UIView!
    var textLabel: KREAttributedLabel!
    var tableView: UITableView!
    fileprivate let popularSearchCellIdentifier = "PopularLiveSearchCell"
    var popularSearchArray:NSArray = []
    var kaBotClient = KABotClient()
    var viewDelegate: PopularSearchViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = .white
        
        self.iconImagV = UIImageView(frame: CGRect.zero)
        self.iconImagV.translatesAutoresizingMaskIntoConstraints = false
        self.iconImagV.image = UIImage.init(named: "findly")
        self.addSubview(self.iconImagV)
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 5.0
        self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.tileBgv.clipsToBounds = true
        self.tileBgv.layer.borderWidth = 1.0
        self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.tileBgv.backgroundColor = UIColor.init(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
        self.addSubview(self.tileBgv)
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.isScrollEnabled = true
        self.tableView.register(UINib(nibName: popularSearchCellIdentifier, bundle: nil), forCellReuseIdentifier: popularSearchCellIdentifier)
        
        let views: [String: UIView] = ["iconImagV": iconImagV, "tileBgv":tileBgv, "tableView": tableView]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-45-[iconImagV(30)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[tileBgv(70)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-110-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[iconImagV(30)]-15-[tileBgv]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[tableView]-10-|", options: [], metrics: nil, views: views))
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x484848)
        self.textLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIView.ContentMode.topLeft
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.text = "Hi, Kindly type in your query or choose from our list of popular search queries"
        self.tileBgv.addSubview(textLabel)
        
        let subView: [String: UIView] = ["textLabel": textLabel]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[textLabel(>=31)]-5-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel]-10-|", options: [], metrics: nil, views: subView))
        
        callingPopularSearchApi() 
    }
    func callingPopularSearchApi(){
        kaBotClient.getPopularSearchResults(success: { [weak self] (arrayOfResults) in
            self?.popularSearchArray = arrayOfResults
            self?.tableView.reloadData()
            
            }, failure: { (error) in
                print(error)
                self.tableView.reloadData()
                
        })
    }

}
extension PopularSearchView: UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  popularSearchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PopularLiveSearchCell = self.tableView.dequeueReusableCell(withIdentifier: popularSearchCellIdentifier) as! PopularLiveSearchCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.text = ((popularSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "query") as! String)
        cell.titleLabel.textColor = .black
        cell.closeButton.setImage(UIImage.init(named: "searchPopular"), for: .normal)
        let width = 30.0
        cell.closeButtonWidthConstraint.constant = CGFloat(width)
        cell.subView.layer.cornerRadius = 5
        cell.subView.layer.borderColor = UIColor.lightGray.cgColor
        cell.subView.layer.borderWidth = 1.0
        cell.subView.clipsToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewDelegate?.optionsButtonTapAction(text: ((popularSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "query") as! String))
    }
    
}
