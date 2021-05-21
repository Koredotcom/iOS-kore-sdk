//
//  SectionedThread.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import UIKit

class SectionedThread : NSObject {
    
    var thread: Thread! = nil
    var sections: Array<ThreadSection>!
    
    static func sectionedThread(_ thread: Thread) -> SectionedThread {
        let sectionThread: SectionedThread = SectionedThread(thread: thread)
        sectionThread.thread = thread
        return sectionThread
    }
    
    init(thread:Thread) {
        super.init()
    }
}


class ThreadSection : NSObject {
    
    var groups: NSMutableArray!
    var maxSectionWidth: CGFloat! = 0.0
    override init() {
        super.init()
        self.groups = NSMutableArray()
    }
}
