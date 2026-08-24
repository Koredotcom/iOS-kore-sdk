//
//  MiniTableHorizontalCell.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 28/03/25.
//

import UIKit

class MiniTableHorizontalCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - properties
    var tableView: UITableView!
    let customCellIdentifier = "CustomCellIdentifier"
    var data: MiniTableData = MiniTableData()
    let rowsDataLimit = 6
    var align0:NSTextAlignment = .left
    var align1:NSTextAlignment = .left
    
    var dataHeaders: Array<Header> = Array<Header>()
    var dataRows: Array<Array<String>> = Array<Array<String>>()
    var dataElements:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var sectionIndex = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
       
    }
    func collecvData(data:MiniTableData, dataHeaders: Array<Header>, sectionIndex: Int){
        self.data = data
        self.dataHeaders = dataHeaders
        self.sectionIndex = sectionIndex
        self.tableView.reloadData()
    }
    
    func initialize() {
        self.clipsToBounds = true
        self.tableView = UITableView(frame: CGRect.zero,style:.grouped)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .white
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.contentView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        tableView.register(MiniTableViewCell.self, forCellReuseIdentifier: customCellIdentifier)
        
        let views: [String: UIView] = ["tableView": tableView]
         self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options:[], metrics:nil, views:views))
       
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.rows.count > 0{
            return data.rows[sectionIndex].count/2
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : MiniTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: customCellIdentifier) as! MiniTableViewCell
        let rows = data.rows[sectionIndex]
        if (rows.count > (indexPath.row * 2)){
            cell.headerLabel.text = rows[indexPath.row*2]
            cell.headerLabel.numberOfLines = 0
            cell.headerLabel.font = UIFont(name: regularCustomFont, size: 15.0)
            cell.headerLabel.font = cell.headerLabel.font.withSize(15.0)
            cell.headerLabel.textColor = BubbleViewBotChatTextColor
        }
        if (rows.count > (indexPath.row * 2+1)){
            cell.secondLbl.text = rows[indexPath.row*2+1]
            cell.secondLbl.textAlignment = .right
            cell.secondLbl.font = UIFont(name: regularCustomFont, size: 15.0)
            cell.secondLbl.font = cell.headerLabel.font.withSize(15.0)
            
            cell.secondLbl.textColor = BubbleViewBotChatTextColor
            
            let fullText = rows[indexPath.row*2+1]
            let attributedString = NSMutableAttributedString(string: fullText)
            // Find the range of the word "Swift"
            var wordToColor = "."
            if let range = fullText.range(of: wordToColor) {
                // Convert String range to NSRange the right way
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.clear, range: nsRange)
            }
             wordToColor = ","
            if let range = fullText.range(of: wordToColor) {
                // Convert String range to NSRange the right way
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.clear, range: nsRange)
            }
            cell.secondLbl.attributedText = attributedString
        }
        
        if indexPath.row % 2 == 0{
            cell.backgroundColor = BubbleViewLeftTint
        }else{
            cell.backgroundColor = .white
        }
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: boldCustomFont, size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)
        
        headerLabel.textColor = BubbleViewBotChatTextColor
        headerLabel.text =  data.headers[sectionIndex*2].title
        view.addSubview(headerLabel)
        
        let secondLbl = UILabel(frame: .zero)
        secondLbl.translatesAutoresizingMaskIntoConstraints = false
        secondLbl.textAlignment = .right
        secondLbl.font = UIFont(name: boldCustomFont, size: 15.0)
        secondLbl.font = secondLbl.font.withSize(15.0)
        secondLbl.textColor = BubbleViewBotChatTextColor
        secondLbl.text =  data.headers[sectionIndex*2+1].title
        view.addSubview(secondLbl)
        
        let underLineLbl = UILabel(frame: .zero)
        underLineLbl.translatesAutoresizingMaskIntoConstraints = false
        underLineLbl.backgroundColor = BubbleViewLeftTint
        view.addSubview(underLineLbl)
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "secondLbl":secondLbl, "underLineLbl": underLineLbl]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headerLabel]-[secondLbl]-15-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[underLineLbl]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[headerLabel]-15-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[secondLbl]-15-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[underLineLbl(1)]-0-|", options:[], metrics:nil, views:views))
        
        return view
    }
    
    // MARK:- deinit
    deinit {
      
    }
}
