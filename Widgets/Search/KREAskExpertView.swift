//
//  KREAskExpertView.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 30/03/20.
//

import UIKit

open class KREAskExpertView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    public lazy var stackView: KREStackView = {
        let stackView = KREStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.hidesSeparatorsByDefault = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 6.0
        return stackView
    }()
    
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.dark
        titleLabel.text = ""
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    public lazy var askExpertButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = UIFont.textFont(ofSize: 14, weight: .semibold)
        button.setTitle("", for: .normal)
        button.setTitleColor(UIColor.lightRoyalBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
//    var titleLabel: UITextView = {
//        let titleLabel = UITextView(frame: .zero)
//        titleLabel.isScrollEnabled = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        return titleLabel
//    }()
//
//
//
//    lazy var utteranceCollection: KREUtteranceCollectionView = {
//        let utteranceCollectionView = KREUtteranceCollectionView(frame: .zero)
//        utteranceCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        return utteranceCollectionView
//    }()
    
    
    
    // MARK: - init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
//        self.addSubview(stackView)
        addSubview(titleLabel)
        addSubview(askExpertButton)
        let views = ["titleLabel": titleLabel, "askExpertButton": askExpertButton]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]-120-|", options:[], metrics:nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[askExpertButton(100)]-|", options:[], metrics:nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]|", options:[], metrics:nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[askExpertButton]|", options:[], metrics:nil, views: views))
    }
    
}
