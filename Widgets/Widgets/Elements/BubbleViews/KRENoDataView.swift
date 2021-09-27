//
//  KRENoDataView.swift
//  Pods
//
//  Created by Sukhmeet Singh on 12/03/19.
//

import UIKit
import Alamofire

open class KRENoDataView: UIView {
    // MARK: -
    let bundle = Bundle(for: KRENoDataView.self)
    var requiredImageList = ["undrawNoData", "noNetwork"]
    lazy public  var noDataLabel: UILabel = {
        let noDataLabel = UILabel(frame: .zero)
        noDataLabel.textColor = UIColor.lightGreyBlue
        noDataLabel.textAlignment = .center
        noDataLabel.backgroundColor = .clear
        noDataLabel.font = UIFont.textFont(ofSize: 16.0, weight: .medium)
        noDataLabel.numberOfLines = 0
        noDataLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        noDataLabel.contentMode = .topLeft
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        return noDataLabel
    }()

    lazy public var noDataImageView: UIImageView = {
        let noDataImageView = UIImageView(frame: .zero)
        noDataImageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: requiredImageList[0], in: bundle, compatibleWith: nil)
        noDataImageView.image = image
        return noDataImageView
    }()
    
    // MARK: init
    override public init (frame: CGRect) {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public func initialize() {
        clipsToBounds = true
        addSubview(noDataImageView)
        addSubview(noDataLabel)
        let views = ["noDataImageView": noDataImageView,"noDataLabel": noDataLabel]
        let constraintCenter = NSLayoutConstraint(item: self,
                                                  attribute: .centerX,
                                                  relatedBy: .equal,
                                                  toItem: noDataImageView,
                                                  attribute: .centerX,
                                                  multiplier: 1.0,
                                                  constant: 0.0)
        addConstraint(constraintCenter)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[noDataImageView(115)]", options:[], metrics:nil, views: views))
        let widthConstraintImageView = NSLayoutConstraint.init(item: noDataImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 121)
        addConstraint(widthConstraintImageView)
        let constraintCenterNoDataLabel = NSLayoutConstraint(item: noDataImageView,
                                                  attribute: .centerX,
                                                  relatedBy: .equal,
                                                  toItem: noDataLabel,
                                                  attribute: .centerX,
                                                  multiplier: 1.0,
                                                  constant: 0.0)
        addConstraint(constraintCenterNoDataLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[noDataImageView(115)]-2-[noDataLabel]", options:[], metrics:nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[noDataLabel]-16-|", options:[], metrics:nil, views: views))
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(_:)), name: NSNotification.Name.AFNetworkingReachabilityDidChange, object: nil)
    }
    
    @objc func networkChanged(_ notification:Notification) {
        if let key = notification.userInfo?["NetworkingReachabilityNotificationStatusItem"] as? NetworkReachabilityManager.NetworkReachabilityStatus {
            switch key {
            case .unknown:
                setNoNetworkState()
                break
            case .notReachable:
                setNoNetworkState()
                break
            case .reachable(.ethernetOrWiFi):
                setNoDataState()
                break
            case .reachable(.cellular):
                setNoDataState()
                break
            default:
                NSLog("Network Changed")
                break
            }
        }
    }
    
    public func setNoNetworkState() {
        setHiddenState(false)
        let image = UIImage(named: requiredImageList[1], in: bundle, compatibleWith: nil)
        noDataImageView.image = image
    }
    public func setNoDataState() {
        let image = UIImage(named: requiredImageList[0], in: bundle, compatibleWith: nil)
        noDataImageView.image = image
    }
    
    public func setHiddenState(_ hide:Bool) {
        self.isHidden = hide
        noDataImageView.isHidden = hide
        noDataLabel.isHidden = hide
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK:- deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
