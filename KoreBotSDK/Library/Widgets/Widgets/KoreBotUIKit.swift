//
//  KoreBotUIKit.swift
//  Widgets
//
//  Created by Srinivas Vasadi on 06/09/18.
//  Copyright © 2018 Kore. All rights reserved.
//

import UIKit
import CoreData

open class KoreBotUIKit: NSObject {
    public struct User {
        public struct BubbleView {
            public static var textColor = UIColor.white
            public static var backgroundColor = UIColorRGB(0xEDEEF1)
            public static var contrastTint = UIColorRGB(0xBCBCBC)
        }
        public struct SendButton {
            public static var textColor = UIColorRGB(0xB0B0B0)
            public static var titleFont = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold)
            public static var backgroundColor = UIColor.white
        }

    }
    public struct Bot {
        public struct BubbleView {
            public static var textColor = UIColorRGB(0x212121)
            public static var backgroundColor = UIColorRGB(0x26344A)
            public static var contrastTint = UIColorRGB(0xFFFFFF)
        }
    }
    public struct Font {
        public static var sendButtonTextFont = UIFont.systemFont(ofSize: 16.0)
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    // MARK: - init datastore
    public func setupDataStoreManager(with botParameters: [String: Any]?, resetDatastore reset: Bool = false, completion block: ((_ thread: KREThread?) -> Void)?) {
        guard let botParameters = botParameters, let taskBotId = botParameters["taskBotId"] as? String, let _ = botParameters["chatBot"] as? String else {
            print("Bot parameters, botId, chat bot name should not be nil")
            return
        }
        
        let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
        let context: NSManagedObjectContext = dataStoreManager.coreDataManager.workerContext
        context.perform {
            dataStoreManager.deleteThreadIfRequired(with: taskBotId, resetDatastore: reset, completion: { (success) in
                let thread = dataStoreManager.insertOrUpdateThread(dictionary: botParameters, with: context)
                try? context.save()
                dataStoreManager.coreDataManager.saveChanges()
    
                block?(thread)
            })
        }
    }
}
