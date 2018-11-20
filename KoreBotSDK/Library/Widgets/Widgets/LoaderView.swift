//
//  LoaderView.swift
//  AFNetworking
//
//  Created by Sowmya Ponangi on 13/09/18.
//

import UIKit
import DottedProgressBar

public class LoaderView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    let cellReuseIdentifier = "LoaderViewCell"
    var lblText: String = ""
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
        tableView.register(LoaderViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
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
        let cell : LoaderViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! LoaderViewCell
        cell.textLbl.text = lblText
        cell.selectionStyle = .none
        if(lblText != ""){
            cell.performAnimation()
            
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    func setValues(textLblTitle:String){
        lblText = textLblTitle
        tableView.reloadData()
    }

}
class LoaderViewCell: UITableViewCell {
    // MARK: - properties
    
    var textLbl: UILabel!
    var progressBar: UIActivityIndicatorView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        textLbl.text = ""
    }
    
    func initialize() {
        self.selectionStyle = .default
        self.clipsToBounds = true
        
        textLbl = UILabel(frame: .zero)
        textLbl.translatesAutoresizingMaskIntoConstraints = false
        textLbl.textAlignment = .center
        textLbl.numberOfLines = 2
        
        textLbl.font = UIFont(name: "Roboto-Regular", size: 16.0)
        textLbl.textColor = UIColor(red: 189/255, green: 190/255, blue: 199/255, alpha: 1)
        contentView.addSubview(textLbl)
        setupProgressBar()
        
        let views: [String: UIView] = ["textLabel": textLbl, "progressBar": progressBar]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[textLabel]-14-|", options:[], metrics:nil, views:views))
         self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[progressBar]|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[textLabel]-8-[progressBar]-20-|", options:[], metrics:nil, views:views))
        
    }
    func setupProgressBar(){
        progressBar = UIActivityIndicatorView(frame:.zero)
        progressBar.activityIndicatorViewStyle = .whiteLarge
        progressBar.color = UIColor(red: 20/255, green: 50/255, blue: 255/255, alpha: 1)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(progressBar)
    }
//    MARK: perform animations
    func performAnimation(){
        self.progressBar.startAnimating()
    }
    
    
    // MARK:- deinit
    deinit {
        textLbl = nil
    }
}
