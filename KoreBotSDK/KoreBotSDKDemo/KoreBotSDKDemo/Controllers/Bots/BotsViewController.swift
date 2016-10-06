//
//  BotsViewController.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking
import KoreBotSDK

class BotsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: properties
    @IBOutlet weak var tableView: UITableView!
    var streams: NSArray! = nil
    
    var accessToken: String!
    var userId: String!

    // MARK: init
    init(userId: String!, accessToken: String!) {
        super.init(nibName: "BotsViewController", bundle: nil)
        self.accessToken = accessToken
        self.userId = userId
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "BotsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: viewcontroller life-cycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Bots"
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BotCell")
        if (accessToken != nil && userId != nil) {
            self.getStreams(userId, accessToken: accessToken)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: button actions
    func composeMessage(_ sender: UIBarButtonItem) {

    }
    
    // MARK: tableView dataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.streams != nil && self.streams.count > 0) {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0:
            return 1
        default:
            if (self.streams.count > 0) {
                return self.streams.count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "Auto Bots"
        default:
            return "Configured Bots"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "BotCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel!.textAlignment = .left
        
        switch ((indexPath as NSIndexPath).section) {
        case 0:
            cell.textLabel!.text = "Kora"
            break
        default:
            let stream: NSDictionary = self.streams[(indexPath as NSIndexPath).row] as! NSDictionary
            if(stream["name"] != nil) {
                cell.textLabel!.text = stream["name"] as? String
            }
            break
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatMessagesViewController: ChatMessagesViewController = ChatMessagesViewController(nibName: "ChatMessagesViewController", bundle: nil
        )
        
        switch ((indexPath as NSIndexPath).section) {
        case 0:
            if(self.accessToken.characters.count > 0) {
                let parameters = ["botInfo":["chatBot":"Kora"], "authorization": self.accessToken] as [String : Any]
                chatMessagesViewController.botInfoParameters = parameters as NSDictionary!
                self.navigationController?.pushViewController(chatMessagesViewController, animated: true)
            }

            break
        default:
            let stream: NSDictionary = self.streams[(indexPath as NSIndexPath).row] as! NSDictionary
            let botInfoObject: NSMutableDictionary = NSMutableDictionary()
            if(stream["name"] != nil) {
                botInfoObject.setObject(stream["name"] as! String, forKey: "chatBot" as NSCopying)
            }
            
            if(stream["_id"] != nil) {
                botInfoObject.setObject(stream["_id"] as! String, forKey: "taskBotId" as NSCopying)
            }
            
            if(self.accessToken.characters.count > 0) {
                let parameters = ["botInfo":botInfoObject, "authorization": self.accessToken] as [String : Any]
                chatMessagesViewController.botInfoParameters = parameters as NSDictionary!
                self.navigationController?.pushViewController(chatMessagesViewController, animated: true)
            }
        }
    }
    
    // MARK: get all streams
    func getStreams(_ userId: String!, accessToken: String!) {
        let urlString: String = ServerConfigs.getAllStreamsURL(userId)
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let accessToken: String = String(format: "%@", accessToken!)
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        
        let parameters: NSDictionary = [:]
        
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: URL.init(string: ServerConfigs.KORE_SERVER))
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.get(urlString, parameters: parameters, success: { (operation, responseObject) in
            if (responseObject is NSArray) {
                self.streams = NSArray(array: responseObject as! NSArray)
                self.tableView.reloadData()
            }
            print(operation?.responseObject)
        }) { (operation, error) in
//            print(operation.responseObject)
        }
    }
}
