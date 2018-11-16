//
//  SessionEndView.swift
//  AFNetworking
//
//  Created by Sowmya Ponangi on 11/09/18.
//

import UIKit

public class SessionEndView: UIView, UITableViewDelegate, UITableViewDataSource, SessionEndCellDelegate  {
    var tableView: UITableView!
    let cellReuseIdentifier = "SessionEndCell"
    var lblText: String = ""
    var btnTitle: String = ""
    public var sendSessionAction: (() -> Void)!
    // MARK:- init
    override init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    //MARK:- removing refernces to elements
    public func prepareForDeinit(){
        
        
    }
    
    // MARK:- setup tableView
    func setup() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
        tableView.register(SessionEndCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        
        let views: [String: UIView] = ["tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options:[], metrics:nil, views:views))
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SessionEndCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! SessionEndCell
        cell.convLbl.text = lblText
        cell.chatBtn.setTitle(btnTitle, for: .normal)
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    public func setValues(titleArr: Array<String>?, text: String) {
        btnTitle = (titleArr?.first)!
        lblText = text
        tableView.reloadData()
    }
    func chatBtnClicked(_ sender: SessionEndCell) {
        if(sendSessionAction != nil){
            self.sendSessionAction()
        }
    }
    
}

class SessionEndCell: UITableViewCell {
    // MARK: - properties
    
    public var blueLineLbl: UILabel!
    public var convLbl: UILabel!
    public var chatBtn: UIButton!
    var btnTitle: String = ""
    var delegate: SessionEndCellDelegate!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        convLbl.text = ""
    }
    
    func initialize() {
        self.selectionStyle = .default
        self.clipsToBounds = true
        
        blueLineLbl = UILabel(frame: .zero)
        blueLineLbl.translatesAutoresizingMaskIntoConstraints = false
        blueLineLbl.backgroundColor = UIColor(red: 20/255, green: 230/255, blue: 150/255, alpha: 1)
        self.addSubview(blueLineLbl)
        
        convLbl = UILabel(frame: .zero)
        convLbl.translatesAutoresizingMaskIntoConstraints = false
        convLbl.textAlignment = .center
        convLbl.numberOfLines = 2
        convLbl.adjustsFontSizeToFitWidth = true
        convLbl.minimumScaleFactor=0.5;
        convLbl.font = UIFont(name: "Helvetica", size: 16.0)
        convLbl.textColor =  UIColor(red: 20/255, green: 230/255, blue: 150/255, alpha: 1)
//        convLbl.text = "This conversation thread has been marked as closed. If you wish to make other queries, tap below."
        self.addSubview(convLbl)
        
        chatBtn = UIButton.init(type: .custom)
        chatBtn.translatesAutoresizingMaskIntoConstraints = false
        //        doneBtn.titleLabel?.font = UIFont(name: "System-Bold", size: 12.0)
        let btnColor : UIColor =  UIColor(red: 20/255, green: 230/255, blue: 150/255, alpha: 1)
        chatBtn.titleLabel?.textAlignment = .center
        chatBtn.titleLabel?.textColor = UIColor.white
        chatBtn.backgroundColor = btnColor
        chatBtn.setTitle(btnTitle, for: .normal)
        chatBtn.setTitleColor( UIColor.white, for: .normal)
        chatBtn.addTarget(self, action: #selector(chatBtnAction(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(chatBtn)
        
        let views: [String: UIView] = ["blueLineLbl": blueLineLbl, "convLbl": convLbl, "chatBtn": chatBtn ]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[blueLineLbl]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[convLbl]-12-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[chatBtn]-14-|", options:[], metrics:nil, views:views))

        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blueLineLbl(1)]-15-[convLbl]-18-[chatBtn(49)]-20-|", options:[], metrics:nil, views:views))
    }
    
    @objc func chatBtnAction(_ sender: UIButton){
        delegate.chatBtnClicked(self)
    }
    
    // MARK:- deinit
    deinit {
        convLbl = nil
    }
}
protocol SessionEndCellDelegate : class {
    func chatBtnClicked(_ sender: SessionEndCell)
    
}


