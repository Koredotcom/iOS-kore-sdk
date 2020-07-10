//
//  KAPanelHeaderView.swift
//  KoreApp-QA
//
//  Created by Sukhmeet Singh on 21/10/19.
//  Copyright © 2019 Kore Inc. All rights reserved.
//

import UIKit

public class KAPanelHeaderView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KAPanelHeaderView.self)
    public lazy var pullBarView: UIView = {
        let pullBarView = UIView(frame: .zero)
        pullBarView.translatesAutoresizingMaskIntoConstraints = false
        pullBarView.backgroundColor = .white
        pullBarView.layer.cornerRadius = 8.0
        return pullBarView
    }()
    public lazy var backdropView: UIView = {
        let backdropView = UIView(frame: .zero)
        backdropView.translatesAutoresizingMaskIntoConstraints = false
        backdropView.backgroundColor = .white
        return backdropView
    }()
    public lazy var contentView: UIView = {
        let contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        return contentView
    }()
    public lazy var handlerView: UIView = {
        let handlerView = UIView(frame: .zero)
        handlerView.translatesAutoresizingMaskIntoConstraints = false
        handlerView.backgroundColor = .lightGreyBlue
        handlerView.layer.cornerRadius = 3.0
        handlerView.layer.masksToBounds = true
        return handlerView
    }()
    public var handlerColor: UIColor = UIColor.lightGreyBlue {
        didSet {
            handlerView.backgroundColor = handlerColor
        }
    }
    public lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.image = UIImage(named: "tasksPanel")
        imageView.backgroundColor = UIColor.coralPink
        imageView.layer.cornerRadius = 16.0
        imageView.contentMode = .center
        return imageView
    }()
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 19.0, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.text = "Tasks"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    public lazy var closeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "panelHeaderClose"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public lazy var reoderButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "reorder"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public lazy var bottomLine: UIView = {
       let view = UIView(frame: .zero)
       view.backgroundColor = UIColor.paleLilacTwo
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()

    public var actionHandler:(() -> Void)?

    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - setup
    func setup() {
        backgroundColor = .clear
        addSubview(pullBarView)
        addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        contentView.addSubview(iconImageView)
        contentView.addSubview(bottomLine)
        contentView.addSubview(reoderButton)

        let contentViews = ["pullBarView": pullBarView, "contentView": contentView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pullBarView]|", options: [], metrics: nil, views: contentViews))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: contentViews))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pullBarView][contentView]|", options: [], metrics: nil, views: contentViews))

        pullBarView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true

        let views = ["pullBarView": pullBarView, "iconImageView": iconImageView, "closeButton": closeButton, "reoderButton": reoderButton ,"titleLabel": titleLabel, "bottomLine": bottomLine]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[iconImageView(50)]-7-[titleLabel]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLine]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[iconImageView]-[bottomLine(1)]|", options: [], metrics: nil, views: views))

        closeButton.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        
        reoderButton.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        reoderButton.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        reoderButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true

        iconImageView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[closeButton]-9-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[reoderButton]-12-[closeButton]-9-|", options: [], metrics: nil, views: views))

        titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        
        setUpPullBarView()
    }
    
    func setUpPullBarView() {
        pullBarView.addSubview(handlerView)
        pullBarView.addSubview(backdropView)

        let views = ["handlerView": handlerView, "backdropView": backdropView]
        pullBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backdropView]|", options: [], metrics: nil, views: views))
        pullBarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[handlerView][backdropView(9)]|", options: [], metrics: nil, views: views))
        
        handlerView.widthAnchor.constraint(equalToConstant: 64.0).isActive = true
        handlerView.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
        handlerView.centerXAnchor.constraint(equalTo: pullBarView.centerXAnchor).isActive = true
    }

    @objc func buttonAction(_ sender: UIButton) {
        actionHandler?()
    }
    
    // MARK: - deinit
    deinit {

    }
}
