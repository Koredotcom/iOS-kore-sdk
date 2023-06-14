//
//  ViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 08/06/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK
let botconnect = BotConnect()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
           // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func connectBtn(_ sender: Any) {
        botconnect.show()
    }
    
}
