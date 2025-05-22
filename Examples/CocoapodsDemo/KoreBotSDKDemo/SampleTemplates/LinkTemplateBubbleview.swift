//
//  LinkTemplateBubbleview.swift
//  KoreBotSDKDemo
//
//  Created by Pagidimarri Kartheek on 22/05/25.
//  Copyright © 2025 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK
class LinkTemplateBubbleview: BubbleView {

    let bundle = Bundle.sdkModule
    public var maskview: UIView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = (UIScreen.main.bounds.size.width - 80.0)
    let cellIdentifier = "PdfDownloadCell"
    //public var linkAction: ((_ text: String?) -> Void)!
    var imageV: UIImageView!
    var downloadBtn: UIButton!
    var activityView: UIActivityIndicatorView!
    
    var pdfTitle = ""
    var pdfUrl = ""
    var tileBgv: UIView!
    var titleLbl: KREAttributedLabel!
    var fileExtension = ""
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init() {
        super.init()
    }
    
    @MainActor required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor.clear.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.layer.cornerRadius = 10.0
        cardView.backgroundColor =  .lightGray
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
    }
    public override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
        self.titleLbl.textColor = .black
        self.titleLbl.mentionTextColor = .white
        self.titleLbl.hashtagTextColor = .white
        self.titleLbl.linkTextColor = .white
        self.titleLbl.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.titleLbl)
        
        imageV = UIImageView(frame: CGRect.zero)
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.image = UIImage(named: "pdfICon", in: bundle, compatibleWith: nil)
        cardView.addSubview(self.imageV)
        
        downloadBtn = UIButton(frame: CGRect.zero)
        downloadBtn.backgroundColor = .clear
        downloadBtn.translatesAutoresizingMaskIntoConstraints = false
        downloadBtn.setTitleColor(.blue, for: .normal)
        downloadBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)

        cardView.addSubview(downloadBtn)
        downloadBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        downloadBtn.addTarget(self, action: #selector(self.downloadButtonAction(_:)), for: .touchUpInside)
        let downloadImage = UIImage(named: "download", in: bundle, compatibleWith: nil)
        let tintedImage = downloadImage?.withRenderingMode(.alwaysTemplate)
        downloadBtn.setImage(tintedImage, for: .normal)
        downloadBtn.tintColor = .black
        
        activityView = UIActivityIndicatorView(frame: CGRect.zero)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(activityView)
        activityView.isHidden = true
        activityView.color = .green
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        let listViews: [String: UIView] = ["imageV": imageV, "titleLbl": titleLbl,"downloadBtn": downloadBtn,"activityView": activityView ,"maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[titleLbl(>=21)]-10-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[downloadBtn(30)]-5-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[activityView(30)]-5-|", options: [], metrics: nil, views: listViews))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[imageV(35)]", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[imageV(35)]-5-[titleLbl]-16-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[downloadBtn(30)]-5-|", options: [], metrics: nil, views: listViews))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[activityView(30)]-5-|", options: [], metrics: nil, views: listViews))
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let titleStr = jsonObject["fileName"] as? NSString ?? ".pdf"
                fileExtension = jsonObject["format"] as? String ?? titleStr.pathExtension
                if fileExtension == ""{
                    fileExtension = "pdf"
                }
                self.titleLbl.setHTMLString(titleStr as String, withWidth: kMaxTextWidth)
                var url = jsonObject["url"] as? String ?? ""
                url = url.replacingOccurrences(of: " ", with: "")
                pdfUrl = url
                
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
        }
        
        return CGSize(width: 0.0, height:  CGFloat(50) + 32)
    }

    @objc fileprivate func downloadButtonAction(_ sender: AnyObject!) {
        let date: Date = Date()
        let timeStamp: Int?
        timeStamp = Int(date.timeIntervalSince1970)
        if let url = URL(string: pdfUrl){
            activityView.startAnimating()
            activityView.isHidden = false
            downloadBtn.isHidden = true
            let fileName = url.lastPathComponent as NSString
            let title = "\(fileName.deletingPathExtension)\(timeStamp ?? 0).\(fileExtension)"
            downloadAndShareTextFile(from: url, fileName: title)
        }
    }
    func downloadAndShareTextFile(from url: URL, fileName: String) {
            let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
                guard let localURL = localURL, error == nil else {
                    print("Download error: \(String(describing: error))")
                    DispatchQueue.main.async {
                        self.stopLoader()
                    }
                    return
                }
    
                // Move the file to a permanent location if needed
                let fileManager = FileManager.default
                let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destURL = docsURL.appendingPathComponent("\(fileName)")
    
                try? fileManager.removeItem(at: destURL) // Clean up if needed
                do {
                    try fileManager.moveItem(at: localURL, to: destURL)
    
                    DispatchQueue.main.async {
                        self.downloadBtn.isHidden = false
                        self.activityView.stopAnimating()
                        self.activityView.isHidden = true
                        NotificationCenter.default.post(name: Notification.Name("pdfToastNotification"), object: "File downloaded successfully under Files")
                    }
                } catch {
                    print("File move error: \(error)")
                    DispatchQueue.main.async {
                        self.stopLoader()
                    }
                }
            }
    
            task.resume()
        }
    
    func stopLoader(){
        downloadBtn.isHidden = false
        activityView.stopAnimating()
        activityView.isHidden = true
        NotificationCenter.default.post(name: Notification.Name("pdfToastNotification"), object: "File can not be downloaded!")
    }

}
