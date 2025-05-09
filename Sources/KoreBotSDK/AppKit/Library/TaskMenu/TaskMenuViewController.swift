//
//  TaskMenuViewController.swift
//  KoreBotSDKDemo
//
//  Created by Pagidimarri Kartheek on 29/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol TaskMenuNewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
    func linkButtonTapAction(urlString: String)
}
class TaskMenuViewController: UIViewController {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    var arrayOftasks = [Actions]()
    fileprivate let taskMenuCellIdentifier = "TaskMenuTablViewCell"
    var viewDelegate: TaskMenuNewDelegate?
    let bundle = Bundle.sdkModule
    // MARK: init
       init() {
           super.init(nibName: "TaskMenuViewController", bundle: .sdkModule)
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
        self.tableview.register(Bundle.xib(named: taskMenuCellIdentifier), forCellReuseIdentifier: taskMenuCellIdentifier)
    }

    func getData(){
        if let footerViewLeftMenu = brandingValues.footer?.buttons?.menu{
            
            self.arrayOftasks = footerViewLeftMenu.actions ?? []
        }else{
            if let path = Bundle.main.path(forResource: "TaskMenu", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                        let jsonData = try DictionaryDecoder().decode(TaskMenu.self, from: jsonResult as [String : Any])
                        self.tableview.reloadData()
                    }
                } catch {
                    // handle error
                }
            }
        }
        
    }
    @IBAction func tapsOnCloseBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TaskMenuViewController: UITableViewDelegate,UITableViewDataSource{
    
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
           let cell : TaskMenuTablViewCell = self.tableview.dequeueReusableCell(withIdentifier: taskMenuCellIdentifier) as! TaskMenuTablViewCell
           cell.backgroundColor = UIColor.clear
           cell.selectionStyle = .none
           let tasks =  self.arrayOftasks[indexPath.row]
           cell.titleLabel.text = tasks.title
           cell.titleLabel.font = UIFont.init(name: regularCustomFont, size: 15.0)
           cell.titleLabel.textColor = BubbleViewBotChatTextColor
           cell.imagVWidthConstarint.constant  = 25.0
           if let iconImg = tasks.icon{
               if iconImg.contains("base64"){
                   let image = Utilities.base64ToImage(base64String: tasks.icon)
                   cell.imgView.image = image.withRenderingMode(.alwaysTemplate)
               }else{
                   if let url = URL(string: iconImg){
                       cell.imgView.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                   }else{
                       cell.imagVWidthConstarint.constant  = 0.0
                       cell.titleLabel.textAlignment = .center
                   }
               }
           }
           return cell
       }
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           self.dismiss(animated: true, completion: nil)
           let elements = arrayOftasks[indexPath.row]
           if let type = elements.type, type == "postback"{
               if let titile = elements.title{
                   self.viewDelegate?.optionsButtonTapNewAction(text: titile, payload: (elements.value ?? titile))
               }
           }else if let type = elements.type, type == "url"{
               if let urlstr = elements.value{
                   self.viewDelegate?.linkButtonTapAction(urlString: urlstr)
               }
           }
           
    }
       
}
