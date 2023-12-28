//
//  KREDocumentInformationCellTableViewCell.swift
//  Pods
//
//  Created by Sukhmeet Singh on 13/03/19.
//

import UIKit

class KREDocumentInformationCell: UITableViewCell {
    // MARK: - properties
    lazy var cardView: KREDriveFileView = {
        let cardView = KREDriveFileView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    var titleLabel = UILabel(frame: .zero)
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var sizeLabel = UILabel(frame: .zero)
    var sizeOfFile: String? {
        didSet {
            sizeLabel.text = sizeOfFile
        }
    }
    
    var lastModificationLabel = UILabel(frame: .zero)
    var lastModification: String? {
        didSet {
            lastModificationLabel.text = lastModification
        }
    }
    
    // MARK: -
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // title label
        contentView.addSubview(cardView)
        let views: [String: UIView] = ["cardView": cardView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: [], metrics: nil, views: views))
    }
    
    func loadingDataState() {
        cardView.titleLabel.text = "Test"
        cardView.sizeLabel.text = "Test"
        cardView.titleLabel.textColor = UIColor.paleGrey
        cardView.titleLabel.backgroundColor = .paleGrey
        cardView.sizeLabel.textColor = UIColor.paleGrey
        cardView.sizeLabel.backgroundColor = .paleGrey
    }
    
    func loadedDataState() {
        cardView.titleLabel.textColor = UIColor(hex: 0x485260)
        cardView.titleLabel.backgroundColor = .clear
        cardView.sizeLabel.textColor = UIColor(hex: 0xa7b0be)
        cardView.sizeLabel.backgroundColor = .clear
    }

    // MARK: -
    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.prepareForReuse()
    }
}

