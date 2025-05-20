//
//  MultiImageBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class MultiImageBubbleView : BubbleView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let bundle = Bundle.sdkModule
    var imageDataDic = NSDictionary()
    var initialViewingIndex: Int!
    var componentItems =  Componentss()
    var viewingIndex: Int! {
        didSet(newViewingIndex) {
            if (self.viewingIndex != newViewingIndex) {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
            }
        }
    }
    override var components:NSArray! {
        didSet {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                componentItems = allItems
                imageDataDic = jsonObject
                textLblHeightConstarint.constant = 0.0
                 if let text = imageDataDic["text"] as? String {
                    textLblHeightConstarint.constant = 30.0
                    textlabel.text = text
                    self.collectionView.frame = CGRect.init(x: self.bounds.origin.x, y: self.bounds.origin.y+30, width: self.bounds.size.width, height: self.bounds.size.height)
                }else{
                    self.collectionView.frame = self.bounds
                    textlabel.text = ""
                }
            }
            textlabel.textColor = BubbleViewBotChatTextColor
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
    @IBOutlet weak var textLblHeightConstarint: NSLayoutConstraint!
    
    @IBOutlet weak var downLoadBtn: UIButton!
    
    @IBOutlet weak var downloadBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var downloadBtnTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var downloadBtnBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var textlabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var COMPONENT_PADDING: CGFloat = 0.0
    var INNER_PADDING: CGFloat = 10.0
    var IMAGE_COMPONENT_HEIGHT: CGFloat = 80.0
    var MAX_CELLS: Int = 5
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       // self.collectionView.register(UINib.init(nibName: "ImageComponentCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "ImageComponentCollectionViewCell")
        if let xib = Bundle.xib(named: "ImageComponentCollectionViewCell") {
            self.collectionView.register(xib, forCellWithReuseIdentifier: "ImageComponentCollectionViewCell")
                }
        self.viewingIndex = NSNotFound
        NotificationCenter.default.addObserver(self, selector: #selector(reloadVideoAct), name: NSNotification.Name(rawValue: reloadVideoCellNotification), object: nil)
        
        downLoadBtn.layer.cornerRadius = 5.0
        downLoadBtn.setTitleColor(BubbleViewRightTint, for: .normal)
        downLoadBtn.titleLabel?.font = UIFont.init(name: regularCustomFont, size: 14.0)
        downLoadBtn.clipsToBounds = true
       
        self.layer.borderColor = BubbleViewLeftTint.cgColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
    }
    
    @objc func reloadVideoAct(notification:Notification){
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
       // self.collectionView.frame = self.bounds
    }
    
    @IBAction func tapsOnDownloadBtnAction(_ sender: Any) {
        if let payload = imageDataDic["payload"] as? [String: Any]{
            if let imageurlStr = payload["url"] as? String, let url = URL(string:imageurlStr){
                funcDownloadFile(url:url)
            }
        }else{
            if let urlStr = imageDataDic["url"] as? String{
                if let url = URL(string: urlStr){
                    funcDownloadFile(url:url)
                }
            }
        }
        
    }
    
    func funcDownloadFile(url:URL){
        toastMessageStr = fileDownloadingToastMsg
        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Download error:", error?.localizedDescription ?? "Unknown error")
                toastMessageStr = vileDownloadFailedToastMsg
                NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                return
            }

            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    downloadImage = image
                    NotificationCenter.default.post(name: Notification.Name(activityViewControllerNotification), object: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.linkAction?(url.absoluteString)
                    print("Failed to convert data to UIImage")
                }
            }
        }

        task.resume()
    }
        
    override var intrinsicContentSize : CGSize {
        self.downloadBtnTopConstraint.constant = 10.0
        self.downloadBtnBottomConstraint.constant = 10.0
        self.downloadBtnHeightConstraint.constant = 35.0
        
        if imageDataDic["videoUrl"] as? String != nil{
            self.downloadBtnTopConstraint.constant = 0.0
            self.downloadBtnBottomConstraint.constant = 0.0
            self.downloadBtnHeightConstraint.constant = 0.0
            return CGSize(width: BubbleViewMaxWidth, height: 200)
        }else{
            if let gifImageUrl = imageDataDic["url"] as? String, gifImageUrl.contains(".gif"){
                self.downloadBtnTopConstraint.constant = 0.0
                self.downloadBtnBottomConstraint.constant = 0.0
                self.downloadBtnHeightConstraint.constant = 0.0
                return CGSize(width: BubbleViewMaxWidth, height: 200)
            }
            return CGSize(width: BubbleViewMaxWidth, height: 255)
        }
    }
    
    func visibleCells() -> NSArray {
        let indexPaths: NSArray = self.collectionView.indexPathsForVisibleItems as NSArray
        let cells: NSMutableArray = NSMutableArray()

        for indexPath in indexPaths {
            cells.add(self.collectionView.cellForItem(at: indexPath as! IndexPath)!)
        }
        cells.sort (comparator: { (object1, object2) -> ComparisonResult in
            let cell1: ImageComponentCollectionViewCell = object1 as! ImageComponentCollectionViewCell
            let cell2: ImageComponentCollectionViewCell = object2 as! ImageComponentCollectionViewCell
            return cell1.index.compare(cell2.index)
        })

        return NSArray(array: cells)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.components.count > MAX_CELLS) {
            return MAX_CELLS
        }
        return 1 //self.components.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ImageComponentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageComponentCollectionViewCell", for:indexPath) as! ImageComponentCollectionViewCell
         
        cell.menuBtn.setImage(UIImage(named: "more", in: bundle, compatibleWith: nil), for: .normal)
        if  imageDataDic["type"] as? String == "video" { //componentItems.videoUrl
            cell.videoPlayerView.isHidden = false
            if let payload = imageDataDic["payload"] as? [String: Any]{
                let url = payload["url"] as? String//componentItems.videoUrl
                let escapedString = url?.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
                let playerURL = URL(string: escapedString!)
                cell.player = AVPlayer(url: playerURL!)
            }
           
            cell.playerViewController = AVPlayerViewController()
            cell.playerViewController.player = cell.player
            cell.playerViewController.view.frame = cell.videoPlayerView.frame
            cell.playerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cell.playerViewController.player?.pause()
            cell.videoPlayerView.addSubview(cell.playerViewController.view)
            cell.playerViewController.view.backgroundColor = .black
        
            cell.menuBtn.tag = indexPath.item
            cell.menuBtn.addTarget(self, action: #selector(self.menuButtonAction(_:)), for: .touchUpInside)
            cell.menuBtn.isUserInteractionEnabled = true
            cell.videoPlayerView.addSubview(cell.menuBtn)
            cell.videoPlayerView.bringSubviewToFront(cell.menuBtn)
            
        }else{

            if imageDataDic["videoUrl"] as? String != nil{ //componentItems.videoUrl
                cell.videoPlayerView.isHidden = false
                
                    let url = imageDataDic["videoUrl"] as? String
                let escapedString = url?.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
                    let playerURL = URL(string: escapedString ?? "")
                    cell.player = AVPlayer(url: playerURL!)
              
                
                cell.playerViewController = AVPlayerViewController()
                cell.playerViewController.player = cell.player
                cell.playerViewController.view.frame = cell.videoPlayerView.frame
                cell.playerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill
                cell.playerViewController.player?.pause()
                cell.videoPlayerView.addSubview(cell.playerViewController.view)
                cell.playerViewController.view.backgroundColor = .black
                
                cell.menuBtn.tag = indexPath.item
                cell.menuBtn.addTarget(self, action: #selector(self.menuButtonAction(_:)), for: .touchUpInside)
                cell.menuBtn.isUserInteractionEnabled = true
                cell.videoPlayerView.addSubview(cell.menuBtn)
                cell.videoPlayerView.bringSubviewToFront(cell.menuBtn)
            }else{
                cell.videoPlayerView.isHidden = true
                if let payload = imageDataDic["payload"] as? [String: Any]{
                    if let imageurlStr = payload["url"] as? String, let url = URL(string:imageurlStr){
                        //cell.imageComponent.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            guard let data = data, error == nil else {
                                print("Download error:", error?.localizedDescription ?? "Unknown error")
                                return
                            }

                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    cell.imageComponent.image = image
                                }
                            } else {
                                DispatchQueue.main.async {
                                    cell.imageComponent.image = UIImage(named: "placeholder_image", in: self.bundle, compatibleWith: nil)
                                }
                                
                            }
                        }

                        task.resume()
                    }else{
                        cell.imageComponent.image = UIImage(named: "placeholder_image", in: bundle, compatibleWith: nil)
                    }
                }else{
                    if let imageurlStr = imageDataDic["url"] as? String, let url = URL(string:imageurlStr){
                            //cell.imageComponent.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                        
                        
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            guard let data = data, error == nil else {
                                print("Download error:", error?.localizedDescription ?? "Unknown error")
                                return
                            }

                            if let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    cell.imageComponent.image = image
                                }
                            } else {
                                DispatchQueue.main.async {
                                    cell.imageComponent.image = UIImage(named: "placeholder_image", in: self.bundle, compatibleWith: nil)
                                }
                                
                            }
                        }

                        task.resume()
                    }else{
                            cell.imageComponent.image = UIImage(named: "placeholder_image", in: bundle, compatibleWith: nil)
                    }
                }
                
                if let gifImageUrl = imageDataDic["url"] as? String, gifImageUrl.contains(".gif"){
                    UIImage.gifImageWithURL(gifImageUrl, completion: { gifImage in
                        DispatchQueue.main.async {
                            cell.imageComponent.image = gifImage
                            cell.imageComponent.contentMode = .scaleAspectFill
                        }
                        
                    })
                    
                }
                
                if cell.playerViewController != nil{
                    cell.videoPlayerView.willRemoveSubview(cell.playerViewController.view)
                }
            }
        }
           
        if (((indexPath as NSIndexPath).row == 4) && (self.components.count > MAX_CELLS)) {
            cell.plusCountLabel.isHidden = false
            //            cell.plusCountLabel.text = [NSString stringWithFormat:@"+%lu", (long)self.components.count - MAX_CELLS]
            cell.dimmingView.isHidden = false
        } else {
            cell.plusCountLabel.isHidden = true
            cell.dimmingView.isHidden = true
        }
        
        if (self.viewingIndex == NSNotFound) {
            cell.isViewing = false
        } else {
        
        }
        
        return cell
    }
    
   
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if ((self.didSelectComponentAtIndex) != nil) {
            self.didSelectComponentAtIndex((indexPath as NSIndexPath).row)
        }
        
        if  imageDataDic["type"] as? String != "video" {
            if let imageurlStr = imageDataDic["url"] as? String{
                if !imageurlStr.contains(".gif"){
                    print(imageurlStr)
                }
            }
        }
    }
    
    /// MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfComponents = self.components.count
        
        switch (numberOfComponents) {
        case 1:
            return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        case 2:
            return CGSize(width: collectionView.bounds.size.width / 2, height: collectionView.bounds.size.height)
        case 3:
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height / 2)
                
            default:
                return CGSize(width: collectionView.bounds.size.width / 2, height: collectionView.bounds.size.height / 2)
            }
        case 4:
            return CGSize(width: collectionView.bounds.size.width / 2, height: collectionView.bounds.size.height / 2)
            
        default:
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                return CGSize(width: collectionView.bounds.size.width / 2.0, height: collectionView.bounds.size.height / 3.0 * 2.0)
            case 1:
                return CGSize(width: collectionView.bounds.size.width / 2.0, height: collectionView.bounds.size.height / 3.0 * 2.0)
            default:
                return CGSize(width: collectionView.bounds.size.width / 3.0 , height: collectionView.bounds.size.height / 3.0)
            }
        }
    }
}
extension MultiImageBubbleView{
    @objc fileprivate func menuButtonAction(_ sender: UIButton!) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: videoDownloadAlertTitle, style: .default) { (action) in
                if let urlStr = self.componentItems.videoUrl as? String{
                    if let url = URL(string: urlStr){
                        toastMessageStr = fileDownloadingToastMsg
                        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                        let date: Date = Date()
                        let timeStamp: Int?
                        timeStamp = Int(date.timeIntervalSince1970)
                        let fileName = "\(timeStamp ?? 0)\(url.lastPathComponent)"
                        self.downloadVideo(from: urlStr, fileName: fileName) { savedURL in
                            if let savedURL = savedURL {
                                print("Video saved at: \(savedURL.path)")
                                DispatchQueue.main.async {
                                    toastMessageStr = fileSavedSuccessfullyToastMsg
                                    NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                                }
                            } else {
                                print("Failed to save video.")
                                toastMessageStr = vileDownloadFailedToastMsg
                                NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                            }
                        }
                    }
                }
            }
            let action2 = UIAlertAction(title: videoDownloadAlertCancelTitle, style: .cancel) { (action) in
                print("Cancel is pressed......")
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            guard let parentVC = self.parentViewController() else {
               print("No parent view controller found")
               return
            }
        parentVC.present(alertController, animated: true)

        }
    
    
}
extension MultiImageBubbleView{
    func downloadVideo(from urlString: String, fileName: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
            if let error = error {
                print("Download error: \(error)")
                completion(nil)
                return
            }
            
            guard let tempLocalUrl = tempLocalUrl else {
                print("No file URL.")
                completion(nil)
                return
            }
            
            // Get Documents folder
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent(fileName)
            
            // Remove existing file if needed
            if fileManager.fileExists(atPath: destinationURL.path) {
                try? fileManager.removeItem(at: destinationURL)
            }
            
            do {
                try fileManager.moveItem(at: tempLocalUrl, to: destinationURL)
                print("File saved to: \(destinationURL)")
                completion(destinationURL)
            } catch {
                print("Error saving file: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
}
extension UIView {
    func parentViewController() -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}


