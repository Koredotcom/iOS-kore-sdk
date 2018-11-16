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
    var progressBar: DottedProgressBar!
    
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
        
        textLbl.font = UIFont(name: "Helvetica", size: 16.0)
        textLbl.textColor = UIColor(red: 20/255, green: 230/255, blue: 150/255, alpha: 1)
        contentView.addSubview(textLbl)
        setupProgressBar()
        
        let views: [String: UIView] = ["textLabel": textLbl, "progressBar": progressBar]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[textLabel]-14-|", options:[], metrics:nil, views:views))
         self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[progressBar]-100-|", options:[.alignAllCenterX], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[textLabel]-14-[progressBar]-14-|", options:[], metrics:nil, views:views))
        
    }
    func setupProgressBar(){
        progressBar = DottedProgressBar(frame:.zero)
        
        //appearance
        progressBar.progressAppearance = DottedProgressBar.DottedProgressAppearance(
            dotRadius: 8.0,
            dotsColor: UIColor(red: 20/255, green: 230/255, blue: 150/255, alpha: 0.4),
            dotsProgressColor: UIColor(red: 20/255, green: 230/255, blue: 150/255, alpha: 1),
            backColor: UIColor.clear
        )
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(progressBar)
        
        //set number of steps and current progress
        progressBar.setNumberOfDots(5, animated: false)
        progressBar.setProgress(5, animated: false)
        
        //customize animation
        progressBar.dotsNumberChangeAnimationDuration = 0.6
        progressBar.progressChangeAnimationDuration = 0.7
        progressBar.pauseBetweenConsecutiveAnimations = 1.0
        progressBar.zoomIncreaseValueOnProgressAnimation = 3
        
        
    
        
    }
//    MARK: perform animations
    func performAnimation(){
        var i = 1
        for  _ in 1..<100{
            i = i+1
            if(i > 5 ){
                i = 1
                progressBar.setProgress(i)
                progressBar.setNumberOfDots(5)
            }else{
                progressBar.setProgress(i)
                progressBar.setNumberOfDots(5)
            }
        }
    }
    
    
    // MARK:- deinit
    deinit {
        textLbl = nil
    }
}
