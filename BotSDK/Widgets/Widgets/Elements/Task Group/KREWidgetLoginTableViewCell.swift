//
//  KREWidgetNoDataTableViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 23/10/19.
//
import UIKit

class KREWidgetLoginTableViewCell: UITableViewCell {
    // MARK: - properties
    var widgetState: WidgetState = .none {
        didSet {
            loginView.widgetState = widgetState
        }
    }
    
    lazy var loginView: KREWidgetLoginView = {
        let loginView = KREWidgetLoginView(frame: .zero)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        return loginView
    }()
    
    public var loginButtonHandler:((KREWidgetLoginTableViewCell) -> Void)?

    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - init
    func initialize() {
        selectionStyle = .none
        contentView.addSubview(loginView)

        let views: [String: UIView] = [ "loginView": loginView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[loginView]-16-|", options:[], metrics:nil, views:views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[loginView]-|", options:[], metrics:nil, views:views))
        
        loginView.loginButton.addTarget(self, action: #selector(loginButtonAction(_:)), for: .touchUpInside)
    }
   
    @objc func loginButtonAction(_ sender: UIButton) {
        loginButtonHandler?(self)
    }

    // MARK:- deinit
    deinit {
        
    }
}
