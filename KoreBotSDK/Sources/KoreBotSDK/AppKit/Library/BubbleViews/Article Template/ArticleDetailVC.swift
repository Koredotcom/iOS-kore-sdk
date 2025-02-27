//
//  ArticleDetailVC.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 25/02/25.
//

import UIKit
import SafariServices
protocol ArticleViewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
}

class ArticleDetailVC: UIViewController {
    let bundle = Bundle.sdkModule
    @IBOutlet weak var headingLebel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    fileprivate let listCellIdentifier = "ArticleCell"
    var dataString: String!
    var arrayOfElements = [ComponentElements]()
    var jsonData : Componentss?
    var viewDelegate: ArticleViewDelegate?
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "ArticleDetailVC", bundle: .sdkModule)
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
        self.tableview.register(Bundle.xib(named: listCellIdentifier), forCellReuseIdentifier: listCellIdentifier)
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
    
    @objc fileprivate func showArticleBtnAction (_ sender: UIButton!) {
        let elements = arrayOfElements[sender.tag]
        if elements.elementButton?.type != nil {
            if elements.elementButton?.type == "postback"{
                self.dismiss(animated: true, completion: nil)
                self.viewDelegate?.optionsButtonTapNewAction(text: (elements.elementButton?.title) ?? "", payload: (elements.elementButton?.payload) ?? (elements.elementButton?.title) ?? "")
            }else{
                if elements.elementButton?.url != nil {
                   self.movetoWebViewController(urlString: (elements.elementButton?.url)!)
                }
            }
        }
    }
   
}

extension ArticleDetailVC: UITableViewDelegate,UITableViewDataSource{
    
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
        let cell : ArticleCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! ArticleCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.bgView.backgroundColor = .white
        cell.bgView.layer.cornerRadius = 2.0
        cell.bgView.layer.borderWidth = 1.0
        cell.bgView.layer.borderColor = UIColor.lightGray.cgColor
        cell.bgView.clipsToBounds = true
        
        let elements = arrayOfElements[indexPath.row]
        cell.titleLbl.text = elements.title
        cell.descLbl.text = elements.descr
        cell.descLbl.numberOfLines = 0
        cell.createdLbl.text = elements.createdOn
        cell.updatedLbl.text = elements.updatedOn
        if let iconImg = elements.iconStr{
            if iconImg.contains("base64") || iconImg.contains("data:image"){
                let image = Utilities.base64ToImage(base64String: iconImg)
                cell.imageV.image = image
            }else{
                if let url = URL(string: iconImg){
                    cell.imageV.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                }
            }
        }
        
        cell.showArticleBtn.setTitle(elements.elementButton?.title, for: .normal)
        cell.showArticleBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        cell.showArticleBtn.setTitleColor(themeColor, for: .normal)
        cell.showArticleBtn.addTarget(self, action: #selector(self.showArticleBtnAction(_:)), for: .touchUpInside)
        cell.showArticleBtn.tag = indexPath.row
        
        let article = UIImage(named: "article", in: bundle, compatibleWith: nil)
        let tintedarticleImage = article?.withRenderingMode(.alwaysTemplate)
        cell.showArticleBtn.setImage(tintedarticleImage, for: .normal)
        cell.showArticleBtn.tintColor = themeColor
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let elements = arrayOfElements[indexPath.row]
//        if elements.elementButton?.type != nil {
//            if elements.elementButton?.type == "postback"{
//                self.dismiss(animated: true, completion: nil)
//                self.viewDelegate?.optionsButtonTapNewAction(text: (elements.elementButton?.title) ?? "", payload: (elements.elementButton?.payload) ?? (elements.elementButton?.title) ?? "")
//            }else{
//                if elements.elementButton?.url != nil {
//                   self.movetoWebViewController(urlString: (elements.elementButton?.url)!)
//                }
//            }
//        }
    }
    func movetoWebViewController(urlString:String){
        if (urlString.count > 0) {
           let url: URL = URL(string: urlString)!
           let webViewController = SFSafariViewController(url: url)
           present(webViewController, animated: true, completion:nil)
        }
    }
}

