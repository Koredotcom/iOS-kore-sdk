//
//  ButtonWidgetViewController.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class ButtonWidgetViewController: UITableViewController {
    fileprivate let cellIdentifier = "KREOptionsView"
    var options: Array<KREOption> = Array<KREOption>()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Buttons"
        tableView.separatorColor = UIColor.clear
        
        tableView.register(KREOptionsViewCell.self, forCellReuseIdentifier: cellIdentifier)
        for index in 1...3 {
//            let option: KREOption = KREOption(name: "option" + String(index), index: index)
//            options.append(option)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        let cell: KREOptionsViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! KREOptionsViewCell
        cell.optionsView.options = options
        return cell
    }

}
