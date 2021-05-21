//
//  ViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 04/05/21.
//  Copyright © 2021 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import KoreBotSDKFrameWork
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let botConnect = BotConnect()
        botConnect.show()
    }


}

