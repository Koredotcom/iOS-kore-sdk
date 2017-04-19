//
//  AppLaunchViewController.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class KWAppLaunchViewController: UITableViewController {
    var widgets: Array<String>!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Widgets"

        self.widgets = ["Buttons", "Choice", "Quick Reply", "List View"]

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WidgetTableViewCell")
        self.tableView.separatorColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.widgets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WidgetTableViewCell", for: indexPath)
        
        cell.textLabel?.text = self.widgets[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let buttonWidgetViewController: ButtonWidgetViewController = ButtonWidgetViewController()
            self.navigationController?.pushViewController(buttonWidgetViewController, animated: true)
            break
        case 1:
            let quickSelectWidgetViewController: QuickSelectWidgetViewController = QuickSelectWidgetViewController()
            self.navigationController?.pushViewController(quickSelectWidgetViewController, animated: true)
            break
        case 2:
            let quickSelectWidgetViewController: QuickSelectWidgetViewController = QuickSelectWidgetViewController()
            self.navigationController?.pushViewController(quickSelectWidgetViewController, animated: true)
            break
        case 3:            
            let listViewWidgetViewController: ListViewWidgetViewController = ListViewWidgetViewController(style: .plain)
            self.navigationController?.pushViewController(listViewWidgetViewController, animated: true)

            break
        default:
            break
        }
    }
}

