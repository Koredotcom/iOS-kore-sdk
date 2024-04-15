//
//  KREWidgetNoDataTableViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 23/10/19.
//
import UIKit

class KREWidgetNoDataTableViewCell: UITableViewCell {
    
    lazy var noDataView: KRENoDataView = {
        let noDataView = KRENoDataView(frame: .zero)
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        return noDataView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: properties with observers
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        selectionStyle = .none
        clipsToBounds = true
        
        noDataView.layer.shadowColor = UIColor(red: 72/255, green: 82/255, blue: 96/255, alpha: 0.2).cgColor
        noDataView.layer.borderColor = UIColor.veryLightBlue.cgColor
        noDataView.layer.cornerRadius = 8.0
        noDataView.layer.shadowRadius = 7.0
        noDataView.layer.masksToBounds = false
        noDataView.layer.borderWidth = 0.5
        noDataView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        noDataView.layer.shadowOpacity = 0.1
        contentView.addSubview(noDataView)
        // Setting Constraints
        let views: [String: UIView] = [ "noDataView": noDataView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[noDataView]-16-|", options:[], metrics:nil, views:views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[noDataView(200)]-|", options:[], metrics:nil, views:views))
        
    }
    // MARK:- deinit
    deinit {
        
    }
}
