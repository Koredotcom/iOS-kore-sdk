//
//  ListViewDetailsViewController.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 14/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import SafariServices

protocol NewListViewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}

class ListViewDetailsViewController: UIViewController {

    @IBOutlet weak var headingLebel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    fileprivate let listCellIdentifier = "NewListTableViewCell"
    var dataString: String!
    var arrayOfElements = [ComponentElements]()
    var jsonData : Componentss?
    var viewDelegate: NewListViewDelegate?
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "ListViewDetailsViewController", bundle: nil)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getData()
        self.tableview.tableFooterView = UIView(frame:.zero)
        self.tableview.register(UINib(nibName: listCellIdentifier, bundle: nil), forCellReuseIdentifier: listCellIdentifier)
    }
    func getData(){
       let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
            let jsonDecoder = JSONDecoder()
            guard let jsonData1 = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData1) else {
                        return
                }
                jsonData = allItems
            arrayOfElements = jsonData?.elements ?? []
            headingLebel.text = jsonData?.text ?? ""
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
extension ListViewDetailsViewController: UITableViewDelegate,UITableViewDataSource{
    
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
        
        return arrayOfElements.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : NewListTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! NewListTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        let elements = arrayOfElements[indexPath.row] as ComponentElements
       if elements.imageURL == nil{
            cell.imageViewWidthConstraint.constant = 0.0
        }else{
            cell.imageViewWidthConstraint.constant = 50.0
            let url = URL(string: elements.imageURL!)
            cell.imgView.af.setImage(withURL: url!, placeholderImage: UIImage(named: "placeholder_image"))
        }
        cell.titleLabel.text = elements.title
        cell.subTitleLabel.text = elements.subtitle
        cell.priceLbl.text = elements.value
        
       return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfElements[indexPath.row]
        if elements.action?.type != nil {
            if elements.action?.type == "postback"{
                self.dismiss(animated: true, completion: nil)
                self.viewDelegate?.optionsButtonTapNewAction(text: (elements.action?.title) ?? "", payload: (elements.action?.payload) ?? (elements.action?.title) ?? "")
            }else{
                if elements.action?.fallback_url != nil {
                   self.movetoWebViewController(urlString: (elements.action?.fallback_url)!)
                }
            }
        }
    }
    func movetoWebViewController(urlString:String){
        if (urlString.count > 0) {
           let url: URL = URL(string: urlString)!
           let webViewController = SFSafariViewController(url: url)
           present(webViewController, animated: true, completion:nil)
        }
    }
}

