//
//  ListWidgetDetailsViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 9/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

protocol ListWidgetViewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}

class ListWidgetDetailsViewController: UIViewController {

    @IBOutlet weak var headingLebel: UILabel!
    @IBOutlet weak var headingDescLebel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var subView: UIView!
   
    var arrayOfElements = [KREListItem]()
    let listItemViewCellIdentifier = "KREListItemViewCell"
    
    var dataString: String!
    var jsonData : Componentss?
    var viewDelegate: ListWidgetViewDelegate?
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "ListWidgetDetailsViewController", bundle: .sdkModule)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        subView.layer.masksToBounds = false
        subView?.layer.shadowColor = UIColor.lightGray.cgColor
        subView?.layer.shadowOffset =  CGSize.zero
        subView?.layer.shadowOpacity = 0.5
        subView?.layer.shadowRadius = 4
        
        getData()
        tableview.tableFooterView = UIView(frame:.zero)
        tableview.register(KREListItemViewCell.self, forCellReuseIdentifier: listItemViewCellIdentifier)
    }
    
    // MARK: -
    func updateSubviews() {
        tableview.beginUpdates()
        tableview.endUpdates()
    }
    
    func getData(){
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonDecoder = JSONDecoder()
        guard let jsonData1 = try? JSONSerialization.data(withJSONObject: jsonObject["elements"] as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode([KREListItem].self, from: jsonData1) else {
                return
        }
        headingLebel.text = jsonObject["title"] as? String
        headingDescLebel.text = jsonObject["description"] as? String
        arrayOfElements = allItems
        tableview.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tapsOnCloseBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
}
extension ListWidgetDetailsViewController: UITableViewDelegate,UITableViewDataSource{
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfElements.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = listItemViewCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? KREListItemViewCell, let listItem = arrayOfElements[indexPath.row] as? KREListItem {
            let listView = cell.templateView
            listView.populateListItemView(listItem)
            listView.buttonActionHandler = { [weak self] (action) in
                if let title = action?.title{
                    self?.viewDelegate?.optionsButtonTapNewAction(text: title , payload: action?.payload ?? title )
                    self?.dismiss(animated: true, completion: nil)
                }
                
            }
//            listView.menuActionHandler = { [weak self] (actions) in
//               // self?.delegate?.populateActions(actions, in: self?.widget, in: self?.panelItem)
//            }

            listView.revealActionHandler = { [weak self] in
                self?.updateSubviews()
            }
        }
        return cell
    }
   
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let listItem = arrayOfElements[indexPath.row] as? KREListItem else {
            return
        }
        if let action = listItem.defaultAction {
            if action.payload != nil{
                self.viewDelegate?.optionsButtonTapNewAction(text: action.title ?? action.payload! , payload:(action.payload!) )
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

