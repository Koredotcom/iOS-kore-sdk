//
//  KREWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KREWidgetViewDelegate
public protocol KREWidgetViewDelegate: class {
    func addWidgetElement(in widget: KREWidget)
    func didLoadWidgetView(with widget: KREWidget)
    func didSelectElement(_ component: Decodable, in widget: KREWidget?)
    func elementAction(for component: Decodable, in widget: KREWidget?)
    func viewMoreElements(for component: KREWidgetComponent?, in widget: KREWidget?)
    func populateActions(_ actions: [KREAction]?, in widget: KREWidget?)
    func pinOrUnpinAction(for widget: KREWidget?, completion block:((Bool, KREWidget?) -> Void)?)
    func addSnackBar(text: String)
}

public protocol KREWidgetViewDataSource: class {
    func willUpdateWidget(_ widget: KREWidget)
    func didUpdateWidget(_ widget: KREWidget)
}

public enum KREWidgetViewType: Int {
    case trim, full
}

// MARK: - KREWidgetView
public class KREWidgetView: UIView {
    public var widget: KREWidget?
    public weak var viewDelegate: KREWidgetViewDelegate?
    public var widgetComponent: KREWidgetComponent?
    public var widgetViewType: KREWidgetViewType = .full
    
    public var requestInProgress: Bool = false
    public var needLoadMore: Bool = true
    public var selectedIndex = 0
    public var hasMore = false
    public var pagination = false
    
    public var MAX_ELEMENTS: Int {
        return 3
    }
    
    public var MAX_SECTIONS: Int {
        return 3
    }

    public func startShimmering() {

    }
    
    public func stopShimmering() {
        
    }
    
    public func prepareForReuse() {
        requestInProgress = false
    }
    
    // MARK: - widget pagination
    func paginateWidget(completion block:((Bool)->Void)?) {
        guard !requestInProgress else {
            block?(false)
            return
        }
        
        fetchWidgetElements(completion: block)
        requestInProgress = true
    }
    
    func fetchWidgetElements(completion block:((Bool)->Void)?) {
        guard let filters = widget?.filters?.filter ({ $0.isSelected == true }),
            let filter = filters.first else {
                requestInProgress = false
                block?(false)
                return
        }
        
        guard let widgetComponent = filter.component, widgetComponent.hasMore == true else {
            requestInProgress = false
            block?(false)
            return
        }
        
        let driveManager = KREDriveListManager()
        driveManager.paginationApiCall(hookParams: filter.hook) { [weak self] (success, responseObject) in
            self?.requestInProgress = false
            guard success, let dictionary = responseObject as? [String: Any] else {
                block?(success)
                return
            }
            
            let manager = KREWidgetManager.shared
            manager.insertOrUpdateWidgetComponent(for: filter, in: self?.widget, pagination: true, with: dictionary)
            
            // update elements
            let filters = self?.widget?.filters?.filter { $0.isSelected == true }
            if let widgetComponent = filters?.first?.component {
                self?.widgetComponent = widgetComponent
            }
            
            block?(success)
        }
    }
}
