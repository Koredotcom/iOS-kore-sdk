//
//  KREImportantUpdateBubbleView.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 26/01/20.
//

import UIKit

public class KREActivityWidgetView: KREWidgetView {
    // MARK: - properites
    public lazy var stackView: KREStackView = {
        let stackView = KREStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.hidesSeparatorsByDefault = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 6.0
        return stackView
    }()

    var elements: [KRESummaryElement]?
    let documentInformationCellIdentifier = "KREDocumentInformationCell"
    let widgetViewCellIdentifier = "KREWidgetViewCell"
    let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"

    lazy var titleStrikeThroughAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.blueyGrey]
    }()
    
    lazy var taskTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.gunmetal]
    }()
    
    public weak var widgetViewDelegate: KREWidgetViewDelegate?
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        addSubview(stackView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options:[], metrics: nil, views: ["stackView": stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options:[], metrics: nil, views: ["stackView": stackView]))
    }

    // MARK: - KREWidgetView methods
    override public var widget: KREWidget? {
        didSet {
            if let summaryElements = widget?.elements as? [KRESummaryElement] {
                elements = summaryElements
            } else {
                elements = nil
            }
            
            populateData()
            layoutIfNeeded()
        }
    }
    
    override public var widgetComponent: KREWidgetComponent? {
        didSet {
            
        }
    }
    
    override public func startShimmering() {
        
    }
    
    override public func stopShimmering() {
        
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        widgetComponent = nil
        widget = nil
        populateData()
    }

    func populateData() {
        stackView.removeAllRows()
        let elements = widget?.elements
        for element in elements ?? [] {
            let summaryView = KREWidgetSummaryView()
            
            summaryView.iconView.backgroundColor = UIColor.clear
            summaryView.messageLabel.backgroundColor = UIColor.clear
            
            var color = UIColor.white
            var unicode = "\u{2d}"
            
            switch element.iconId {
            case "meeting":
                unicode = "\u{2d}"
                color = UIColor.cornflower
            case "upcoming_tasks":
                unicode = "\u{e96c}"
                color = UIColor.coralPink
            case "overdue":
                unicode = "\u{e96c}"
                color = UIColor.coralPink
            case "email":
                unicode = "\u{e95d}"
                color = UIColor.greenblue
            case "form":
                unicode = "\u{e926}"
                color = UIColor.greenblue
            default:
                unicode = "\u{e943}"
                color = UIColor.yellowishOrange
            }
            
            summaryView.iconLabel.text = unicode
            summaryView.iconLabel.textColor = .white
            summaryView.iconLabel.backgroundColor = color
            summaryView.iconView.backgroundColor = color
            
            summaryView.messageLabel.text = element.title
            summaryView.messageLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
            summaryView.messageLabel.textColor = UIColor.gunmetal
            summaryView.layoutSubviews()
            stackView.addRow(summaryView)
            
            stackView.setTapHandler(forRow: summaryView) { [weak self] (summaryView) in
                self?.viewDelegate?.elementAction(for: element, in: self?.widget)
            }
        }
        layoutSubviews()
    }
}

// MARK: - KREWidgetSummaryView
public class KREWidgetSummaryView: UIView {
    // MARK: - properties
    public var messageLabel = UILabel(frame: .zero)
    public var iconLabel = UILabel(frame: .zero)
    public var iconView = UIView(frame: .zero)
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: properties with observers
    public func prepareForReuse() {

    }
        
    // MARK: - setup
    public func setup() {
        clipsToBounds = true
        
        messageLabel.textColor = UIColor(hex: 0x4741fa)
        messageLabel.textAlignment = .left
        messageLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)
        
        iconLabel.font = UIFont.systemSymbolFont(ofSize: 15)
        iconLabel.textAlignment = .left
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconLabel.layer.cornerRadius = 9.0
        iconLabel.layer.masksToBounds = false
        
        iconView.layer.cornerRadius = 12.0
        iconView.layer.masksToBounds = false
        
        iconView.addSubview(iconLabel)
        addSubview(iconView)
        
        iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
        iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        
        let views = ["messageLabel": messageLabel, "iconView": iconView] as [String : Any]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[iconView(22)]-12-[messageLabel]-4-|", options:[], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[iconView(22)]", options: [.alignAllLeft], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[messageLabel(>=28)]-2-|", options: [.alignAllLeft], metrics: nil, views: views))
    }
}
