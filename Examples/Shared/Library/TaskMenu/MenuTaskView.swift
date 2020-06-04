//
//  MenuTaskView.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 01/06/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol TaskMenuDelegate {
    func optionsButtonTapAction(text:String)
}
class MenuTaskView: UIView, UITableViewDelegate, UITableViewDataSource {

    fileprivate let taskMenuCellIdentifier = "TaskMenuTablViewCell"
    var viewDelegate: TaskMenuDelegate?
    var tableView: UITableView!
    var arrayOftasks = [Task]()
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
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.isScrollEnabled = true
         self.tableView.register(UINib(nibName: taskMenuCellIdentifier, bundle: nil), forCellReuseIdentifier: taskMenuCellIdentifier)
        
        let views: [String: UIView] = ["tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tableView]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[tableView]-15-|", options: [], metrics: nil, views: views))
        getData()
    }
    func getData(){
        if let path = Bundle.main.path(forResource: "TaskMenu", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    // do stuff
                    let jsonData = try DictionaryDecoder().decode(TaskMenu.self, from: jsonResult as [String : Any])
                    self.arrayOftasks = jsonData.tasks
                    self.tableView.reloadData()
                }
            } catch {
                // handle error
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
        
        return  self.arrayOftasks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : TaskMenuTablViewCell = self.tableView.dequeueReusableCell(withIdentifier: taskMenuCellIdentifier) as! TaskMenuTablViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let tasks =  self.arrayOftasks[indexPath.row]
        cell.titleLabel.text = tasks.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOftasks[indexPath.row]
        self.viewDelegate?.optionsButtonTapAction(text: (elements.postback.title))
    }
    deinit {
        self.tableView = nil
    }

}
