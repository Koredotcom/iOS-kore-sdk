//
//  File.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 27/11/24.
//

import Foundation
import UIKit
open class KoreCustomHeaderView: UIView {
    let bundle = Bundle.sdkModule
    public var koreHeaderBackBtnAction: (() -> Void)?
    public var koreCloseChatWindow: (() -> Void)?
    public var koreMinimiseChatWindow: (() -> Void)?
    public var koreHeaderViewBranding: ((_ dic: HeaderModel?) -> Void)?
    public var startNewSession: (() -> Void)?
    public var koreAgentIsConnected: (() -> Bool)?
    public var sendAgentChatCloseEvent: (() -> Void)?
    public var callBackFromKoreSDK: ((_ isAgentConnected: Bool?) -> Void)?
    // MARK: init
    public init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    open func initialize() {
        
    }
    
//    @objc func backButtonActionHandler(_ sender: AnyObject) {
//        koreHeaderBackBtnAction?()
//    }
}
