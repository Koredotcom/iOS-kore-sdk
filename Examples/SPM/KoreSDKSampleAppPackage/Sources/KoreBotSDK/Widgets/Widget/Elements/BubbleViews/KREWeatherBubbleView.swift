//
//  KREWeatherBubbleView.swift
//  AFNetworking
//
//  Created by Sukhmeet Singh on 08/03/19.
//

import UIKit
import AlamofireImage

public class KREWeatherBubbleView: KREBubbleView {
    // MARK: - properties
    private let MAX_ELEMENTS = 3
    var actionHandler: ((KREAction) -> Void)?
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorColor = .clear
        tableView.backgroundColor = .white
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    // MARK: - initialize
    override public func initialize() {
        super.initialize()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(KREWeatherHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "KREWeatherHeaderFooterView")
        tableView.register(KREWidgetSummaryCell.self, forCellReuseIdentifier: "KREWidgetSummaryCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        addSubview(tableView)
        
        let views: [String: UIView] = ["tableView": tableView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tableView]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tableView]-|", options: [], metrics: nil, views: views))
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: getExpectedHeight())
    }
    
    // MARK: -
    open override func populateBubbleView() {
        let widgetState = widget?.widgetState ?? .refreshing
        switch widgetState {
        case .refreshing, .loading:
            tableView.reloadData()
        case .loaded:
            tableView.reloadData()
            invalidateIntrinsicContentSize()
        case .refreshed:
            tableView.reloadData()
            invalidateIntrinsicContentSize()
        case .noData:
            break
        case .requestFailed:
            break
        case .noNetwork:
            break
        case .none:
            break
        }
    }
    
    public func getExpectedHeight() -> CGFloat {
        var height: CGFloat = 0.0
        for section in 0..<tableView.numberOfSections {
            var fittingSize = UIView.layoutFittingCompressedSize
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: section))
                let size = cell.systemLayoutSizeFitting(fittingSize)
                height += size.height
            }
            if let headerView = tableView(tableView, viewForHeaderInSection: section) {
                let size = headerView.systemLayoutSizeFitting(fittingSize)
                height += size.height
            }
        }
        return height + 16.0
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KREWeatherBubbleView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32.0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let widgetFilter = widget?.filters?.first
        if let elements = widgetFilter?.component?.elements {
            return elements.count
        } else {
            return MAX_ELEMENTS
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let widgetFilter = widget?.filters?.first
        let cellIdentifier = "KREWidgetSummaryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let summaryCell = cell as? KREWidgetSummaryCell {
            if let elements = widgetFilter?.component?.elements,
                let element = elements[indexPath.row] as? KREAction {
                summaryCell.iconView.backgroundColor = UIColor.clear
                summaryCell.messageLabel.backgroundColor = UIColor.clear
                
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
                
                summaryCell.iconLabel.text = unicode
                summaryCell.iconLabel.textColor = .white
                summaryCell.iconLabel.backgroundColor = color
                summaryCell.iconView.backgroundColor = color
                
                summaryCell.messageLabel.text = element.title
                summaryCell.messageLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
                summaryCell.messageLabel.textColor = UIColor.gunmetal
            } else {
                summaryCell.iconView.backgroundColor = UIColor.paleGrey
                summaryCell.messageLabel.backgroundColor = UIColor.paleGrey
            }
        }
        cell.layoutSubviews()
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let widget = widget else {
            return UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
        }
        
        switch widget.type {
        case "List":
            let widgetFilter = widget.filters?.first
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "KREWeatherHeaderFooterView")
            if let headerView = headerView as? KREWeatherHeaderFooterView {
                if let header = widgetFilter?.component?.header {
                    headerView.header = header
                } else {
                    headerView.titleLabel.backgroundColor = UIColor.paleGrey
                    headerView.descLabel.backgroundColor = UIColor.paleGrey
                }
            }
            
            headerView?.contentView.backgroundColor = .white
            return headerView
        default:
            return UIView(frame: .zero)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let widgetFilter = widget?.filters?.first
        guard let elements = widgetFilter?.component?.elements,
            let element = elements[indexPath.row] as? KREAction else {
                return
        }
        
        actionHandler?(element)
    }
}


// MARK: - KREWidgetSummaryCell
class KREWidgetSummaryCell: UITableViewCell {
    // MARK: - properties
    var messageLabel = UILabel(frame: .zero)
    var iconLabel = UILabel(frame: .zero)
    var iconView = UIView(frame: .zero)
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialize() {
        selectionStyle = .none
        clipsToBounds = true
        
        messageLabel.textColor = UIColor(hex: 0x4741fa)
        messageLabel.textAlignment = .left
        messageLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        
        iconLabel.font = UIFont.systemSymbolFont(ofSize: 15)
        iconLabel.textAlignment = .left
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconLabel.layer.cornerRadius = 9.0
        iconLabel.layer.masksToBounds = false
        
        iconView.layer.cornerRadius = 12.0
        iconView.layer.masksToBounds = false
        
        iconView.addSubview(iconLabel)
        contentView.addSubview(iconView)
        
        iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
        iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        
        let views = ["messageLabel": messageLabel, "iconView": iconView] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[iconView(22)]-12-[messageLabel]-4-|", options:[], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[iconView(22)]", options: [.alignAllLeft], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[messageLabel(>=28)]-2-|", options: [.alignAllLeft], metrics: nil, views: views))
    }
}

class KREWeatherHeaderFooterView: UITableViewHeaderFooterView {
    // MARK: - properties
    let constant: CGFloat = 76.0
    var toggleTemperature = false
    lazy var temperatureTextView: UILabel = {
        let temperatureTextView = UILabel(frame: .zero)
        temperatureTextView.textColor = UIColor.battleshipGrey
        temperatureTextView.textAlignment = .center
        temperatureTextView.backgroundColor = .clear
        temperatureTextView.font = UIFont.textFont(ofSize: 12.0, weight: .bold)
        temperatureTextView.translatesAutoresizingMaskIntoConstraints = false
        temperatureTextView.adjustsFontSizeToFitWidth = true
        temperatureTextView.isUserInteractionEnabled = false
        return temperatureTextView
    }()
        
    lazy var weatherImageView: UIImageView = {
        let weatherImageView = UIImageView(frame: .zero)
        weatherImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        weatherImageView.addGestureRecognizer(tapGestureRecognizer)
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        return weatherImageView
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = UIColor.dark
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 19.0, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.contentMode = .topLeft
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    lazy var descLabel: UILabel = {
        let descLabel = UILabel(frame: .zero)
        descLabel.textColor = UIColor.darkTwo
        descLabel.textAlignment = .left
        descLabel.backgroundColor = .clear
        descLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        descLabel.contentMode = .topLeft
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        return descLabel
    }()
    
    public var header: KREWeatherHeader? {
        didSet {
            titleLabel.text = header?.title
            descLabel.text = header?.message
            guard let weather = header?.weather else {
                return
            }
            
            if let value = weather.icon, let imageUrl = URL(string: value) {
                weatherImageView.af.setImage(withURL: imageUrl)
            }
            temperatureTextView.text = weather.temp
        }
    }
    
    // MARK: - init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
      
    // MARK: -
    func setup() {
        clipsToBounds = true
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(weatherImageView)
        contentView.addSubview(temperatureTextView)

        let views: [String: UIView] = ["weatherImageView": weatherImageView, "temperatureTextView": temperatureTextView, "titleLabel": titleLabel, "descLabel": descLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[weatherImageView]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[weatherImageView]-3-[temperatureTextView]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[titleLabel]-[weatherImageView]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[descLabel]-[weatherImageView]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[weatherImageView]-13-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel(>=16)]-[descLabel(>=16)]-30-[temperatureTextView]|", options: [], metrics: nil, views: views))
        temperatureTextView.centerXAnchor.constraint(equalTo: weatherImageView.centerXAnchor).isActive = true
        weatherImageView.widthAnchor.constraint(equalToConstant: constant).isActive = true
        weatherImageView.heightAnchor.constraint(equalToConstant: constant).isActive = true
    }
    
    // MARK: -
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        toggleTemperature = !toggleTemperature
        if let weather = header?.weather {
            if toggleTemperature {
                temperatureTextView.text = weather.desc
            } else {
                temperatureTextView.text = weather.temp
            }
        }
    }
}
