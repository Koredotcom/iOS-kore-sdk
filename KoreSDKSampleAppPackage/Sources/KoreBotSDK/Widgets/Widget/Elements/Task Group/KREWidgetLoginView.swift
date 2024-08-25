//
//  KREWidgetLoginView.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 31/12/19.
//

import UIKit

public class KREWidgetLoginView: UIView {
    // MARK: - properties
    let LOADER_WIDTH: CGFloat = 20.0
    var widgetState: WidgetState = .none {
        didSet {
            updateWidgetState()
        }
    }

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.battleshipGrey
        let attributedString = NSAttributedString(string: "You’d need to login to view the content", attributes: [.font: UIFont.textFont(ofSize: 13.0, weight: .medium), .foregroundColor: UIColor.battleshipGrey, .kern: 0.2])
        titleLabel.attributedText = attributedString
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    lazy var iconImageView : UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.image = UIImage(named: "someThingIsNotRight")
        imageView.contentMode = .center
        return imageView
    }()
    
    lazy var loginButton: UIButton = {
        var loginButton = UIButton(frame: .zero)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = UIColor.lightRoyalBlue
        let attributedString = NSAttributedString(string: "Login", attributes: [.font: UIFont.textFont(ofSize: 15.0, weight: .semibold), .foregroundColor: UIColor.paleGrey, .kern: 0.39])
        loginButton.setAttributedTitle(attributedString, for: .normal)
        return loginButton
    }()
    
    public var loginButtonHandler:(() -> Void)?
    
    // MARK: - init
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    func setup() {
        addSubview(titleLabel)
        addSubview(iconImageView)
        addSubview(loginButton)
        
        let views = ["titleLabel": titleLabel, "iconImageView": iconImageView, "loginButton": loginButton]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLabel]-10-[iconImageView]-15-[loginButton]-30-|", options: [], metrics: nil, views: views))
        
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 118).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                
        loginButton.addTarget(self, action: #selector(loginButtonAction(_:)), for: .touchUpInside)
    }
    
    @objc func loginButtonAction(_ sender: UIButton) {
        loginButtonHandler?()
    }

    func updateWidgetState() {
        switch widgetState {
        case .refreshing, .loading:
            loginButton.isHidden = true
        default:
            loginButton.isHidden = false
        }
    }
}
