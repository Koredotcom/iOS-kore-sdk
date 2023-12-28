//
//  KAGDriveListViewController.swift
//  KoraSDK
//
//  Created by Sukhmeet Singh on 14/02/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import UIKit
import Foundation

public class KREDriveListViewController: UIViewController {
    let bundle = Bundle(for: KREDriveListViewController.self)
    var urlString: String?
    public var widgetComponent: KREWidgetComponent?
    var isScrolling: Bool = false
    var needLoadMore: Bool = true
    var requestInProgress: Bool = false
    let fetchLimit: Int = 10
    public var objects: [Decodable]? {
        didSet {
            tableView.reloadData()
        }
    }
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorColor = UIColor.lightGreyBlue
        tableView.backgroundColor = .white
        tableView.bounces = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationItems()
        
        tableView.tableFooterView = UIView(frame:.zero)
        objects = widgetComponent?.elements ?? []
        let driveManager = KREDriveListManager()
        let parameters = ["offSet": "\(objects?.count ?? 0)", "limit": NSNumber(value: 10)] as [String : Any]
        if let urlString = urlString {
            driveManager.getDrive(urlString: urlString ?? "", parameters: parameters, with: { [weak self] (status, elements) in
                if let weakSelf = self, let componentElements = elements as? [Decodable] {
                    DispatchQueue.main.async {
                        weakSelf.objects?.append(contentsOf: componentElements)
                    }
                }
            })
        }
    }
    
    func setupNavigationItems() {
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        let driveImage = UIImage(named: "drive", in: bundle, compatibleWith: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: driveImage, style: .plain, target: self, action: #selector(driveButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.gunmetal
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(KREDocumentInformationCell.self, forCellReuseIdentifier: "KREDocumentInformationCell")
        view.addSubview(tableView)
        let views: [String: UIView] = ["tableView": tableView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: -
    @objc func closeButtonAction() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func driveButtonAction() {
        openFileUrl(urlString: "googledrive://")
    }
    
    func getDrive() {
        tableView.showLoadingFooter()
        if let hasMore = widgetComponent?.hasMore, hasMore == true {
            let driveManager = KREDriveListManager()
            let parameters = ["offSet": "\(objects?.count ?? 0)", "limit": NSNumber(value: 10)] as [String : Any]
            urlString = (widgetComponent?.buttons?.first as? KREButtonTemplate)?.api
            driveManager.getDrive(urlString: urlString ?? "", parameters: parameters, with: { [weak self] (status, elements) in
                if let weakSelf = self, let componentElements = elements as? [Decodable] {
                    DispatchQueue.main.async {
                        if componentElements.count < 10 { // less than limit
                            self?.needLoadMore = false
                        }
                        self?.objects?.append(contentsOf: componentElements)
                        self?.requestInProgress = false
                        self?.tableView.hideLoadingFooter()
                    }
                }
            })
        } else {
            objects = widgetComponent?.elements ?? []
            tableView.hideLoadingFooter()
        }
    }
    
    // MARK: scrollView delegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidFinishScrolling(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidFinishScrolling(scrollView)
        }
    }
    
    public func scrollViewDidFinishScrolling(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentOffset.y + scrollView.frame.size.height
        if isScrolling && !requestInProgress && needLoadMore && contentHeight >= scrollView.contentSize.height {
            
            requestInProgress = true
            getDrive()
        }
        
        isScrolling = false
    }
}

extension KREDriveListViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "KREDocumentInformationCell", for: indexPath)
        if let cell = tableViewCell as? KREDocumentInformationCell {
            let dataFileInfo = objects?[indexPath.row] as! KREDriveFileInfo
            cell.cardView.driveFileObject = dataFileInfo
            cell.cardView.configure(with: dataFileInfo)
            cell.cardView.setNeedsLayout()
            cell.selectionStyle = .none
            cell.setNeedsLayout()
        }
        return tableViewCell
    }
    
    // MARK: - table view delegate methods
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = objects?[indexPath.row]
        guard let fileData = object as? KREDriveFileInfo,
            let urlAction = fileData.defaultAction?.url else {
                return
        }
        
        openDriveUrl(urlString: urlAction, fileType: fileData.fileType ?? "")
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func getDriveListData() {
        
    }
}

// MARK: - Drive Utilites
public extension UIViewController {
    
    public func openMailApp(urlString: String, messageId: String) -> Bool {
        guard let escapedString = messageId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return false }
        var deepLinkUrl = "message://\(escapedString)"
        guard let url = URL(string: urlString), let driveUrl = URL(string: deepLinkUrl) else {
            return false
        }
        guard UIApplication.shared.canOpenURL(driveUrl) else {
            return false
        }
        UIApplication.shared.open(driveUrl, options: [:]) { (success) in
        }
        return true
    }
    
    public func openExternalUrl(url: URL) {
        let safariViewController = KRESafariViewController(url: url)
        safariViewController.modalPresentationStyle = .fullScreen
        present(safariViewController, animated: true, completion: nil)
    }
    
    public func openDriveUrl(urlString: String, fileType: String) {
        var deepLinkUrl = ""
        if fileType == "ppt" {
            deepLinkUrl = "googleslides://\(urlString)"
        } else if fileType == "gslide" {
            deepLinkUrl = "googleslides://\(urlString)"
        } else if fileType == "gdoc" {
            deepLinkUrl = "googledocs://\(urlString)"
        } else if fileType == "gsheet" {
            deepLinkUrl = "googlesheets://\(urlString)"
        } else {
            deepLinkUrl = "googledrive://\(urlString)"
        }
        guard let url = URL(string: urlString), let driveUrl = URL(string: deepLinkUrl) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(driveUrl) {
            UIApplication.shared.open(driveUrl, options: [:]) { (success) in
            }
        } else {
            deepLinkUrl = "googledrive://\(urlString)"
            guard let deepLinkDriveUrl = URL(string: deepLinkUrl) else {
                return
            }
            if UIApplication.shared.canOpenURL(deepLinkDriveUrl) {
                UIApplication.shared.open(deepLinkDriveUrl, options: [:]) { (success) in
                }
            } else {
                openGoogleDrive(url: url)
            }
        }
    }
    
    public func openFileUrl(urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { (success) in
                
            }
        } else {
            let alertController = UIAlertController(title: nil, message: "Google Drive application is not installed", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                
            })
            alertController.addAction(cancelAction)
            
            let installAction = UIAlertAction(title: "Ok, install", style: .default, handler: { (action) in
                let urlString = "itms://itunes.apple.com/us/app/google-drive/id507874739?mt=8"
                if #available(iOS 10.0, *), let url = URL(string: urlString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else if let url = URL(string: urlString) {
                    UIApplication.shared.openURL(url)
                }
            })
            alertController.addAction(installAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: -
    public func openGoogleDrive(url: URL?) {
        let alertController = UIAlertController(title: nil, message: "Google Drive application is not installed ", preferredStyle: .alert)
        let openAction = UIAlertAction(title: "Open in web", style: .default, handler: { [weak self] (action) in
            if let url = url {
                let safariViewController = KRESafariViewController(url: url)
                safariViewController.modalPresentationStyle = .fullScreen
                self?.present(safariViewController, animated: true, completion: nil)
            }
        })
        alertController.addAction(openAction)
        
        let installAction = UIAlertAction(title: "Install Google Drive", style: .default, handler: { (action) in
            let urlString = "itms://itunes.apple.com/us/app/google-drive/id507874739?mt=8"
            if #available(iOS 10.0, *), let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let url = URL(string: urlString) {
                UIApplication.shared.openURL(url)
            }
        })
        alertController.addAction(installAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
