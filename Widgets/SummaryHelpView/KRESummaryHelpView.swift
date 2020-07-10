//
//  SummaryHelpView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 10/09/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

open class KRESummaryHelpView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KRESummaryHelpView.self)
    let cellIdentifier = "KRESummaryHelpViewViewCell"
    let kMaxRowHeight: CGFloat = 44.0
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    public var actions: [KREAction]? {
        didSet {
            tableView.reloadData()
        }
    }
    public var optionsButtonAction:((_ title: String?, _ payload: String?) -> Void)?
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 19.0, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.dark
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = .zero
        tableView.separatorColor = .clear
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        return tableView
    }()
    public var summaryHelpAction:((KREAction?) -> Void)?

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
        tableView.register(KRESummaryHelpActionCell.self, forCellReuseIdentifier: cellIdentifier)
        addSubview(tableView)
        addSubview(titleLabel)
        
        let views = ["tableView": tableView, "titleLabel": titleLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]-2-[tableView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics: nil, views: views))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    override open var intrinsicContentSize: CGSize {
        let kBubbleViewMaxWidth = BubbleViewMaxWidth
        let height = getExpectedHeight(width: kBubbleViewMaxWidth)
        let viewSize = CGSize(width: kBubbleViewMaxWidth, height: height)
        return viewSize
    }
    
    public func getExpectedHeight(width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        let limitingSize: CGSize  = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        if let _ = title {
            var textSize: CGSize = titleLabel.sizeThatFits(limitingSize)
            if textSize.height < titleLabel.font.pointSize {
                textSize.height = titleLabel.font.pointSize
            }
            height += (textSize.height + 2.0)
        }
        
        let count = actions?.count ?? 0
        for index in 0..<count {
            guard let action = actions?[index] else {
                continue
            }
            
            let cell = tableView(tableView, cellForRowAt: IndexPath(row: index, section: 0))
            var fittingSize = UIView.layoutFittingCompressedSize
            fittingSize.width = width
            let size = cell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: UILayoutPriority(rawValue: 1000), verticalFittingPriority: UILayoutPriority(rawValue: 250))
            height += size.height
        }
        return height
    }
    
    // MARK: -
    @objc func buttonAction(_ sender: UIButton) {
        let center = sender.center
        guard let rootViewPoint = sender.superview?.convert(center, to: tableView),
            let indexPath = tableView.indexPathForRow(at: rootViewPoint) else {
            return
        }

        if let action = actions?[indexPath.row] {
            summaryHelpAction?(action)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension KRESummaryHelpView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let actionCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = actionCell as? KRESummaryHelpActionCell, let action = actions?[indexPath.row] {
            cell.selectionStyle = .none
            cell.title = action.title
            cell.button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        }
        return actionCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return kMaxRowHeight
    }
}

// MARK: - KRESummaryHelpViewViewCell
public class KRESummaryHelpActionCell: UITableViewCell {
    var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.lightRoyalBlue, for: .normal)
        button.titleLabel?.font = UIFont.textFont(ofSize: 15.0, weight: .medium)
        button.backgroundColor = UIColor.paleLilacTwo
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = false
        button.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 13.0, bottom: 12.0, right: 12.0)
        return button
    }()
    
    // MARK:- init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        contentView.addSubview(button)
        
        let views = ["button": button]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[button]-6-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]", options: [], metrics: nil, views: views))
    }
}
