//
//  TaskMenuViewController.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 29/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol TaskMenuNewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}
class TaskMenuViewController: UIViewController {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    var arrayOftasks = [Task]()
    fileprivate let taskMenuCellIdentifier = "TaskMenuTablViewCell"
    var viewDelegate: TaskMenuNewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // Do any additional setup after loading the view.
        subView.backgroundColor = UIColor.init(hexString: (brandingShared.brandingInfoModel?.widgetBodyColor) ?? "#FFFFFF")
        titleLabel.textColor = UIColor.init(hexString: (brandingShared.brandingInfoModel?.widgetTextColor)!)
        subView.layer.masksToBounds = false
        subView?.layer.shadowColor = UIColor.lightGray.cgColor
        subView?.layer.shadowOffset =  CGSize.zero
        getData()
        self.tableview.register(UINib(nibName: taskMenuCellIdentifier, bundle: frameworkBundle), forCellReuseIdentifier: taskMenuCellIdentifier)
    }

    func getData(){
    
        let jsonDic = brandingShared.hamburgerOptions
        if let jsonResult = jsonDic as Dictionary<String, AnyObject>? {
            // do stuff
            let jsonData = try? DictionaryDecoder().decode(TaskMenu.self, from: jsonResult as [String : Any])
            self.arrayOftasks = jsonData!.tasks
            titleLabel.text = jsonData!.heading 
            self.tableview.reloadData()
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
    
    public init() {
        super.init(nibName: "TaskMenuViewController", bundle: Bundle(for: TaskMenuViewController.self))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
           let image = base64ToImage(base64String: tasks.icon)
           cell.imgView.image = image
          cell.bgView.backgroundColor = UIColor.init(hexString: (brandingShared.brandingInfoModel?.widgetBodyColor)!)
          cell.titleLabel.textColor = UIColor.init(hexString: (brandingShared.brandingInfoModel?.widgetTextColor)!)
           return cell
       }
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let elements = arrayOftasks[indexPath.row]
           self.viewDelegate?.optionsButtonTapNewAction(text: (elements.postback.title), payload: (elements.postback.value))
           self.dismiss(animated: true, completion: nil)
    }
       
       func base64ToImage(base64String: String?) -> UIImage{
           if (base64String?.isEmpty)! {
               return #imageLiteral(resourceName: "no_image_found")
           }else {
               // Separation part is optional, depends on your Base64String !
               let tempImage = base64String?.components(separatedBy: ",")
               let dataDecoded : Data = Data(base64Encoded: tempImage![1], options: .ignoreUnknownCharacters)!
               let decodedimage = UIImage(data: dataDecoded)
               return decodedimage!
           }
       }
   
}
