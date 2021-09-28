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
    var imageDataDic = NSDictionary()
    var initialViewingIndex: Int!
    var componentItems =  Componentss()
    var viewingIndex: Int! {
        didSet(newViewingIndex) {
            if (self.viewingIndex != newViewingIndex) {
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
            }
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var COMPONENT_PADDING: CGFloat = 0.0
    var INNER_PADDING: CGFloat = 10.0
    var IMAGE_COMPONENT_HEIGHT: CGFloat = 80.0
    var MAX_CELLS: Int = 5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.register(UINib.init(nibName: "ImageComponentCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "ImageComponentCollectionViewCell")
        self.viewingIndex = NSNotFound
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
    
    override var intrinsicContentSize : CGSize {
        
        return CGSize(width: BubbleViewMaxWidth, height: 200)
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
        return self.components.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ImageComponentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageComponentCollectionViewCell", for:indexPath) as! ImageComponentCollectionViewCell
         
        if  componentItems.videoUrl != nil {
            cell.videoPlayerView.isHidden = false
            let url = componentItems.videoUrl
            let playerURL = URL(string:url!)
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
            
            let url = URL(string: (componentItems.url!))
             if url != nil{
                cell.imageComponent.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
            }else{
                cell.imageComponent.image = UIImage(named: "placeholder_image")
            }
            
            if cell.playerViewController != nil{
                cell.videoPlayerView.willRemoveSubview(cell.playerViewController.view)
            }
            
            
        }
           
        
        //
        
       // cell.component = self.components.object(at: (indexPath as NSIndexPath).row) as! Component //kk
        //        cell.index = [indexPath.row]
        
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
            //            cell.isViewing = indexPath.row == MIN(_viewingIndex, MAX_CELLS - 1)
        }
        
        return cell
    }
    
   
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if ((self.didSelectComponentAtIndex) != nil) {
            self.didSelectComponentAtIndex((indexPath as NSIndexPath).row)
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
            let action1 = UIAlertAction(title: "Download", style: .default) { (action) in
                print("Download is pressed.....")
                self.loadFileAsync(url: URL(string: self.componentItems.videoUrl!)!) { (isSaved) in
                    if isSaved{
                        print("Video is saved!")
                        DispatchQueue.main.async {
                        let alert = UIAlertController(title: "BOT SDK", message: "Video is saved!", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // show the alert
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                print("Cancel is pressed......")
            }
            alertController.addAction(action1)
            alertController.addAction(action2)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)

        }
    
    
    
    
    /// Downloads a file asynchronously
    func loadFileAsync(url: URL, completion: @escaping (Bool) -> Void) {

        // create your document folder url
        let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        // your destination file url
        let destination = documentsUrl.appendingPathComponent(url.lastPathComponent)

        print("downloading file from URL: \(url.absoluteString)")
        if FileManager().fileExists(atPath: destination.path) {
            print("The file already exists at path, deleting and replacing with latest")

            if FileManager().isDeletableFile(atPath: destination.path){
                do{
                    try FileManager().removeItem(at: destination)
                    print("previous file deleted")
                    self.saveFile(url: url, destination: destination) { (complete) in
                        if complete{
                            completion(true)
                        }else{
                            completion(false)
                        }
                    }
                }catch{
                    print("current file could not be deleted")
                }
            }
        // download the data from your url
        }else{
            self.saveFile(url: url, destination: destination) { (complete) in
                if complete{
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
    }


    func saveFile(url: URL, destination: URL, completion: @escaping (Bool) -> Void){
        URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) in
            // after downloading your data you need to save it to your destination url
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let location = location, error == nil
                else { print("error with the url response"); completion(false); return}
            do {
                try FileManager.default.moveItem(at: location, to: destination)
                print("new file saved")
                completion(true)
            } catch {
                print("file could not be saved: \(error)")
                completion(false)
            }
        }).resume()
    }
    
    
    }



