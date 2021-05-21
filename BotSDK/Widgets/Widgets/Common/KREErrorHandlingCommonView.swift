//
//  KREErrorHandlingCommonView.swift
//  KoreApp-QA
//
//  Created by Sukhmeet Singh on 25/02/20.
//  Copyright © 2020 Kore Inc. All rights reserved.
//

import UIKit

public class KREErrorHandlingCommonView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KREErrorHandlingCommonView.self)

    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.darkGreyBlue
        let noDataAvail = NSLocalizedString("No Data Available", comment: "No Data Available")
        titleLabel.text = noDataAvail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    public lazy var subTitleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 12.0, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.blueyGrey
        titleLabel.text = "Looks like there is no transaction data availble to show it to you."
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    public lazy var refreshButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = .tealBlue
        var image = UIImage(named: "refreshAlert")
        button.imageView?.tintColor = .whiteTwo
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 5)
        button.setImage(image, for: .normal)
        let refreshActionTitle = NSLocalizedString("Refresh", comment: "Refresh")
        button.setTitle(refreshActionTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    public lazy var cancelButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = .iceBlue
        let cancelActionTitle = NSLocalizedString("Cancel", comment: "Cancel")
        button.setTitle(cancelActionTitle, for: .normal)
        button.setTitleColor(.tealBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    public lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10.0
        return stackView
    }()
    
    // MARK: - init
    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        self.layer.cornerRadius = 4.0
        self.layer.shadowColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 0.58).cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset =  CGSize.zero
        self.layer.shadowRadius = 3.0
        self.layer.shouldRasterize = true

        let image = UIImage(named: "nodataMiniTable", in: bundle, compatibleWith: nil)
        imageView.image = image
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        horizontalStackView.addArrangedSubview(refreshButton)
        horizontalStackView.addArrangedSubview(cancelButton)
        addSubview(horizontalStackView)
        addSubview(imageView)
        
        let views = ["titleLabel": titleLabel, "subTitleLabel": subTitleLabel, "refreshButton": refreshButton, "cancelButton": cancelButton, "imageView": imageView, "horizontalStackView": horizontalStackView]
        //
        imageView.widthAnchor.constraint(equalToConstant: 176).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 67).isActive = true
        refreshButton.layer.cornerRadius = 4.0
        refreshButton.widthAnchor.constraint(equalToConstant: 98).isActive = true
        refreshButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 98).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        cancelButton.layer.cornerRadius = 4.0
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        horizontalStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        refreshButton.titleLabel?.font = UIFont.textFont(ofSize: 12, weight: .medium)
        cancelButton.titleLabel?.font = UIFont.textFont(ofSize: 12, weight: .medium)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[titleLabel]-40-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[subTitleLabel]-40-|", options: [], metrics: nil, views: views))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[imageView]-12-[titleLabel]-15-[subTitleLabel]-20-[horizontalStackView]-20-|", options: [], metrics: nil, views: views))
    }
    
}
