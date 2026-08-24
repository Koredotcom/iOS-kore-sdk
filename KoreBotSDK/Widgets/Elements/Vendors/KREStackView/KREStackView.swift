//
//  KREStackView.swift.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public protocol KRETappable {
    func didTapView()
}

// MARK: - KREStackView
public class KREStackView: UIView {
    // MARK: - properties
    public var axis: NSLayoutConstraint.Axis {
        get {
            return stackView.axis
        }
        set {
            stackView.axis = newValue
            updateStackViewAxisConstraint()
            for case let cell as KREStackViewCell in stackView.arrangedSubviews {
                cell.separatorAxis = newValue == .horizontal ? .vertical : .horizontal
            }
        }
    }
    
    public var rowBackgroundColor = UIColor.clear
    public var rowHighlightColor = KREStackView.defaultRowHighlightColor
    public var rowInset = UIEdgeInsets.zero
    public var spacing: CGFloat = 0.0 {
        didSet {
            stackView.spacing = spacing
        }
    }
    
    // MARK: -
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = spacing
        return stackView
    }()
    
    private var stackViewAxisConstraint: NSLayoutConstraint?
    
    private static let defaultRowHighlightColor: UIColor = UIColor(red: 217 / 255, green: 217 / 255, blue: 217 / 255, alpha: 1)
    private static let defaultSeparatorColor: UIColor = UITableView().separatorColor ?? .clear
    private static let defaultSeparatorInset = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 10.0)
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpViews()
        setUpConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: -
    public func addRow(_ row: UIView, animated: Bool = false) {
        insertCell(withContentView: row, atIndex: stackView.arrangedSubviews.count, animated: animated)
    }
    
    public func addRows(_ rows: [UIView], animated: Bool = false) {
        rows.forEach { addRow($0, animated: animated) }
    }
    
    public func prependRow(_ row: UIView, animated: Bool = false) {
        insertCell(withContentView: row, atIndex: 0, animated: animated)
    }
    
    public func prependRows(_ rows: [UIView], animated: Bool = false) {
        rows.reversed().forEach { prependRow($0, animated: animated) }
    }
    
    public func insertRow(_ row: UIView, before beforeRow: UIView, animated: Bool = false) {
        #if swift(>=5.0)
        guard
            let cell = beforeRow.superview as? KREStackViewCell,
            let index = stackView.arrangedSubviews.firstIndex(of: cell) else { return }
        #else
        guard
            let cell = beforeRow.superview as? KREStackViewCell,
            let index = stackView.arrangedSubviews.index(of: cell) else { return }
        #endif
        insertCell(withContentView: row, atIndex: index, animated: animated)
    }
    
    public func insertRows(_ rows: [UIView], before beforeRow: UIView, animated: Bool = false) {
        rows.forEach { insertRow($0, before: beforeRow, animated: animated) }
    }
    
    public func insertRow(_ row: UIView, after afterRow: UIView, animated: Bool = false) {
        #if swift(>=5.0)
        guard
            let cell = afterRow.superview as? KREStackViewCell,
            let index = stackView.arrangedSubviews.firstIndex(of: cell) else { return }
        #else
        guard
            let cell = afterRow.superview as? KREStackViewCell,
            let index = stackView.arrangedSubviews.index(of: cell) else { return }
        #endif
        insertCell(withContentView: row, atIndex: index + 1, animated: animated)
    }
    
    public func insertRows(_ rows: [UIView], after afterRow: UIView, animated: Bool = false) {
        _ = rows.reduce(afterRow) { currentAfterRow, row in
            insertRow(row, after: currentAfterRow, animated: animated)
            return row
        }
    }
    
    public func removeRow(_ row: UIView, animated: Bool = false) {
        if let cell = row.superview as? KREStackViewCell {
            removeCell(cell, animated: animated)
        }
    }
    
    public func removeRows(_ rows: [UIView], animated: Bool = false) {
        rows.forEach { removeRow($0, animated: animated) }
    }
    
    public func removeAllRows(animated: Bool = false) {
        stackView.arrangedSubviews.forEach { view in
            if let cell = view as? KREStackViewCell {
                removeRow(cell.contentView, animated: animated)
            }
        }
    }
    
    // MARK: -
    public var firstRow: UIView? {
        return (stackView.arrangedSubviews.first as? KREStackViewCell)?.contentView
    }
    
    public var lastRow: UIView? {
        return (stackView.arrangedSubviews.last as? KREStackViewCell)?.contentView
    }
    
    public func getAllRows() -> [UIView] {
        var rows: [UIView] = []
        stackView.arrangedSubviews.forEach { cell in
            if let cell = cell as? KREStackViewCell {
                rows.append(cell.contentView)
            }
        }
        return rows
    }
    
    public func containsRow(_ row: UIView) -> Bool {
        guard let cell = row.superview as? KREStackViewCell else { return false }
        return stackView.arrangedSubviews.contains(cell)
    }
    
    public func hideRow(_ row: UIView, animated: Bool = false) {
        setRowHidden(row, isHidden: true, animated: animated)
    }
    
    public func hideRows(_ rows: [UIView], animated: Bool = false) {
        rows.forEach { hideRow($0, animated: animated) }
    }
    
    public func showRow(_ row: UIView, animated: Bool = false) {
        setRowHidden(row, isHidden: false, animated: animated)
    }
    
    public func showRows(_ rows: [UIView], animated: Bool = false) {
        rows.forEach { showRow($0, animated: animated) }
    }
    
    public func setRowHidden(_ row: UIView, isHidden: Bool, animated: Bool = false) {
        guard let cell = row.superview as? KREStackViewCell, cell.isHidden != isHidden else { return }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                cell.isHidden = isHidden
                cell.layoutIfNeeded()
            }
        } else {
            cell.isHidden = isHidden
        }
    }
    
    public func setRowsHidden(_ rows: [UIView], isHidden: Bool, animated: Bool = false) {
        rows.forEach { setRowHidden($0, isHidden: isHidden, animated: animated) }
    }
    
    public func isRowHidden(_ row: UIView) -> Bool {
        return (row.superview as? KREStackViewCell)?.isHidden ?? false
    }
    
    public func setTapHandler<RowView: UIView>(forRow row: RowView, handler: ((RowView) -> Void)?) {
        guard let cell = row.superview as? KREStackViewCell else {
            return
        }
        
        if let handler = handler {
            cell.tapHandler = { contentView in
                guard let contentView = contentView as? RowView else { return }
                handler(contentView)
            }
        } else {
            cell.tapHandler = nil
        }
    }
    
    
    public func setBackgroundColor(forRow row: UIView, color: UIColor) {
        (row.superview as? KREStackViewCell)?.rowBackgroundColor = color
    }
    
    public func setBackgroundColor(forRows rows: [UIView], color: UIColor) {
        rows.forEach { setBackgroundColor(forRow: $0, color: color) }
    }
    
    
    public func setInset(forRow row: UIView, inset: UIEdgeInsets) {
        (row.superview as? KREStackViewCell)?.rowInset = inset
    }
    
    public func setInset(forRows rows: [UIView], inset: UIEdgeInsets) {
        rows.forEach { setInset(forRow: $0, inset: inset) }
    }
    
    public var separatorColor = KREStackView.defaultSeparatorColor {
        didSet {
            for case let cell as KREStackViewCell in stackView.arrangedSubviews {
                cell.separatorColor = separatorColor
            }
        }
    }
    
    public var separatorWidth: CGFloat = 1 / UIScreen.main.scale {
        didSet {
            for case let cell as KREStackViewCell in stackView.arrangedSubviews {
                cell.separatorWidth = separatorWidth
            }
        }
    }
    
    public var separatorHeight: CGFloat {
        get { return separatorWidth }
        set { separatorWidth = newValue }
    }
    
    public var separatorInset: UIEdgeInsets = KREStackView.defaultSeparatorInset
    
    public func setSeparatorInset(forRow row: UIView, inset: UIEdgeInsets) {
        (row.superview as? KREStackViewCell)?.separatorInset = inset
    }
    
    public func setSeparatorInset(forRows rows: [UIView], inset: UIEdgeInsets) {
        rows.forEach { setSeparatorInset(forRow: $0, inset: inset) }
    }
    
    public var hidesSeparatorsByDefault = false
    
    public func hideSeparator(forRow row: UIView) {
        if let cell = row.superview as? KREStackViewCell {
            cell.shouldHideSeparator = true
            updateSeparatorVisibility(forCell: cell)
        }
    }
    
    public func hideSeparators(forRows rows: [UIView]) {
        rows.forEach { hideSeparator(forRow: $0) }
    }
    
    public func showSeparator(forRow row: UIView) {
        if let cell = row.superview as? KREStackViewCell {
            cell.shouldHideSeparator = false
            updateSeparatorVisibility(forCell: cell)
        }
    }
    
    public func showSeparators(forRows rows: [UIView]) {
        rows.forEach { showSeparator(forRow: $0) }
    }
    
    public var automaticallyHidesLastSeparator = false {
        didSet {
            if let cell = stackView.arrangedSubviews.last as? KREStackViewCell {
                updateSeparatorVisibility(forCell: cell)
            }
        }
    }
    
    public func cellForRow(_ row: UIView) -> KREStackViewCell {
        return KREStackViewCell(contentView: row)
    }
    
    public func configureCell(_ cell: KREStackViewCell) { }
    
    private func setUpViews() {
        backgroundColor = UIColor.white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        addSubview(stackView)
    }
    
    private func setUpConstraints() {
        setUpStackViewConstraints()
        updateStackViewAxisConstraint()
    }
    
    private func setUpStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func updateStackViewAxisConstraint() {
        stackViewAxisConstraint?.isActive = false
        if stackView.axis == .vertical {
            stackViewAxisConstraint = stackView.widthAnchor.constraint(equalTo: widthAnchor)
        } else {
            stackViewAxisConstraint = stackView.heightAnchor.constraint(equalTo: heightAnchor)
        }
        stackViewAxisConstraint?.isActive = true
    }
    
    private func createCell(withContentView contentView: UIView) -> KREStackViewCell {
        let cell = cellForRow(contentView)
        
        cell.rowBackgroundColor = rowBackgroundColor
        cell.rowHighlightColor = rowHighlightColor
        cell.rowInset = rowInset
        cell.separatorAxis = axis == .horizontal ? .vertical : .horizontal
        cell.separatorColor = separatorColor
        cell.separatorHeight = separatorHeight
        cell.separatorInset = separatorInset
        cell.shouldHideSeparator = hidesSeparatorsByDefault
        
        configureCell(cell)
        
        return cell
    }
    
    private func insertCell(withContentView contentView: UIView, atIndex index: Int, animated: Bool) {
        let cellToRemove = containsRow(contentView) ? contentView.superview : nil
        
        let cell = createCell(withContentView: contentView)
        stackView.insertArrangedSubview(cell, at: index)
        
        if let cellToRemove = cellToRemove as? KREStackViewCell {
            removeCell(cellToRemove, animated: false)
        }
        
        updateSeparatorVisibility(forCell: cell)
        
        if let cellAbove = cellAbove(cell: cell) {
            updateSeparatorVisibility(forCell: cellAbove)
        }
        
        if animated {
            cell.alpha = 0
            layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 1
            }
        }
    }
    
    private func removeCell(_ cell: KREStackViewCell, animated: Bool) {
        let aboveCell = cellAbove(cell: cell)
        
        let completion: (Bool) -> Void = { [weak self] _ in
            guard let `self` = self else { return }
            cell.removeFromSuperview()
            
            if let aboveCell = aboveCell {
                self.updateSeparatorVisibility(forCell: aboveCell)
            }
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    cell.isHidden = true
            },
                completion: completion)
        } else {
            completion(true)
        }
    }
    
    private func updateSeparatorVisibility(forCell cell: KREStackViewCell) {
        let isLastCellAndHidingIsEnabled = automaticallyHidesLastSeparator &&
            cell === stackView.arrangedSubviews.last
        let cellConformsToSeparatorHiding = cell.contentView
        
        cell.isSeparatorHidden =
            isLastCellAndHidingIsEnabled ||
            cell.shouldHideSeparator
    }
    
    private func cellAbove(cell: KREStackViewCell) -> KREStackViewCell? {
        #if swift(>=5.0)
        guard let index = stackView.arrangedSubviews.firstIndex(of: cell), index > 0 else { return nil }
        #else
        guard let index = stackView.arrangedSubviews.index(of: cell), index > 0 else { return nil }
        #endif
        return stackView.arrangedSubviews[index - 1] as? KREStackViewCell
    }
}
