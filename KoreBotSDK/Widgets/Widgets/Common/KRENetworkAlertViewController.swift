//
//  KRENetworkAlertViewController.swift
//  KoreApp
//
//  Created by Srinivas Vasadi on 16/11/18.
//  Copyright © 2018 Kore Inc. All rights reserved.
//

import UIKit

class KRENetworkAlertViewController: UIViewController {
    // MARK: - properties
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    
    var tryAgainHandler:(() -> Void)?
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = UIFont.systemFont(ofSize: 42.0, weight: .bold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let attributedString = NSMutableAttributedString(string: "No Internet Connection Found. Please Check Your Connection And Try Again.", attributes: [.font: UIFont.systemFont(ofSize: 16.0, weight: .medium), .foregroundColor: UIColor.black, .kern: 0.2, .paragraphStyle: paragraphStyle])
        informationLabel.attributedText = attributedString
        informationLabel.textAlignment = .center
        
        let buttonAttributedString = NSMutableAttributedString(string: "TRY AGAIN", attributes: [.font: UIFont.systemFont(ofSize: 17.0, weight: .bold), .foregroundColor: UIColor.white, .kern: 3.0])
        button.setAttributedTitle(buttonAttributedString, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: -
    @IBAction func buttonAction(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            self?.tryAgainHandler?()
        }
    }
}
