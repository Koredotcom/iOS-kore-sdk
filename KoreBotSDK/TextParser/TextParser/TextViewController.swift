//
//  TextViewController.swift
//  TextParser
//
//  Created by Srinivas Vasadi on 17/11/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    var textView: UITextView! = nil
    
    // MARK: - view controller life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Text Parser"
        
        textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.white
        self.view.addSubview(textView)
        
        let views: [String: UITextView] = ["textView": textView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[textView]-2-|", options:[], metrics:nil, views:views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[textView]-2-|", options:[], metrics:nil, views:views))
        
        let markdownParser: MarkdownParser = MarkdownParser()
        if let path = Bundle.main.path(forResource: "SampleText", ofType: "txt") {
            let contents = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
            textView.attributedText = markdownParser.attributedString(from: contents)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

