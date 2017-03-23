//
//  ListViewWidgetViewController.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class ListViewWidgetViewController: UITableViewController {
    
    fileprivate let cellIdentifier = "KREImagesViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.backgroundColor = UIColor.white
        tableView.register(KREImagesViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorColor = UIColor.clear
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KREImagesViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! KREImagesViewCell

        return cell
    }
}
