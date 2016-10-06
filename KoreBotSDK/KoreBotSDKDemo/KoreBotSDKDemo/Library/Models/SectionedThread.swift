//
//  SectionedThread.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation
import UIKit

class SectionedThread : NSObject {
    
    var thread: Thread! {
        didSet {
            self.sections = Array()
            
            var currentSegment: ThreadSection!
        
            // Loop through the messages
            for message in thread.messages {
                // loop through the grouped components
                for groupedComponents in message.groupedComponents {
                    
                    if (currentSegment == nil || currentSegment.isRelatedToComponentGroup(groupedComponents as! ComponentGroup) == false) {
                        currentSegment = ThreadSection()
                        self.sections.append(currentSegment)
                    }
                    
                    currentSegment.groups.add(groupedComponents)
                }
            }
        }
    }
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
    
    func isRelatedToComponentGroup(_ group: ComponentGroup) -> Bool {
        return false
    }
    
}
