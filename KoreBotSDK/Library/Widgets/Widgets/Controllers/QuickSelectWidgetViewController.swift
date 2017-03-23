//
//  QuickSelectWidgetViewController.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class QuickSelectWidgetViewController: UITableViewController {
    var quickReplyView: KREQuickSelectView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Quick Select"
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuickReplyWidgetTableViewCell")
        self.tableView.separatorColor = UIColor.clear
        
        quickReplyView = KREQuickSelectView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height:44))
        quickReplyView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = quickReplyView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        self.tableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[quickReplyView]|", options:[], metrics:nil, views:["quickReplyView":quickReplyView]))
//        self.tableView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[quickReplyView(80)]|", options:[], metrics:nil, views:["quickReplyView":quickReplyView]))
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuickReplyWidgetTableViewCell", for: indexPath)
        return cell
    }
}
