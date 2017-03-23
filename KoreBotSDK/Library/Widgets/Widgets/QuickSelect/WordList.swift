//
//  WordList.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class WordList: NSObject {
    var words = [String]()
    
    convenience override init() {
        self.init(fileName: "Words")
    }
    
    init(fileName: String) {
        super.init()
        words = self.importWordsFromFile(name: fileName)
    }
    
    func importWordsFromFile(name: String) -> [String] {
        var result = [String]()
        if let path = Bundle.main.path(forResource: name, ofType: "txt") {
            let contents = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
            if let s: String = contents {
                result = s.components(separatedBy: "\n")
            }
        }
        return ["Hi", "How are you", "test", "Hi", "How are you", "test", "Hi", "How are you", "test", "Hi", "How are you", "test"]
    }
}
