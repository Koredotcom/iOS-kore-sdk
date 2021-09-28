//
//  KREWidgetContainerView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 12/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Alamofire

public class KREWidgetContainerView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KREWidgetContainerView.self)
    var collectionViewIdentifier = "KRESegmentButtonsCollectionViewCell"
    let buttonMaxHeight: CGFloat = 42.0
    let titleHeight: CGFloat = 23.0
    let titleContainerHeight: CGFloat = 40.0
    let pinOrUnpinButtonHeight: CGFloat = 28.0
    var themeColor: UIColor?
    public var delegate: KREWidgetViewDelegate? {
        didSet {
            widgetView.viewDelegate = delegate
        }
    }
    public var widget: KREWidget? {
        didSet {
            filters = widget?.filters
            widget?.dataSource = self
        }
    }
    public var filters: [KREWidgetFilter]? {
        didSet {
            populateFilters()
        }
    }
    public var bubbleContainerView: UIStackView = {
        let bubbleContainerView = UIStackView(frame: .zero)
        bubbleContainerView.backgroundColor = UIColor.clear
        bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainerView.axis = .vertical
        return bubbleContainerView
    }()

    public lazy var lineContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .paleLilacFour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    public var showPinOrUnPinButton: Bool = true {
        didSet {
            pinOrUnpinButton.isHidden = true
        }
    }
    var didSelectComponentAtIndex:((Int) -> Void)?
    let prototypeCell = KRESegmentButtonsCollectionViewCell()

    lazy var buttonTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.lightRoyalBlue, .kern: 1.87]
    }()

    lazy var filterSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(frame: .zero)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.apportionsSegmentWidthsByContent = false
        segmentedControl.layer.cornerRadius = 15.0
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.layer.masksToBounds = true
        segmentedControl.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        segmentedControl.addTarget(self, action: #selector(filterDidChange(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 20.0, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.contentMode = .topLeft
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    lazy var noDataView: KRENoDataView = {
        let noDataView = KRENoDataView(frame: .zero)
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.noDataImageView.isHidden = true
        noDataView.noDataLabel.isHidden = true
        return noDataView
    }()
    lazy var buttonsContainerView: UIView = {
        let buttonsContainerView = UIView(frame: .zero)
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        return buttonsContainerView
    }()
    lazy var titleContainerView: UIView = {
        let titleContainerView = UIView(frame: .zero)
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        return titleContainerView
    }()
    lazy var progressBar: KRELinearProgressBar = {
        let progressBar = KRELinearProgressBar(frame: CGRect(x: 0, y: 0, width: 320, height: 2))
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.backgroundColor = UIColor.silver
        progressBar.clipsToBounds = true
        return progressBar
    }()
    lazy var pinOrUnpinButton: UIButton = {
        let pinOrUnpinButton = UIButton(frame: .zero)
        pinOrUnpinButton.translatesAutoresizingMaskIntoConstraints = false
        pinOrUnpinButton.backgroundColor = UIColor.paleLilacTwo
        pinOrUnpinButton.contentMode = .scaleAspectFit
        pinOrUnpinButton.addTarget(self, action: #selector(pinOrUnpinButtonAction(_:)), for: .touchUpInside)
        
        let unPinWidgetImage = UIImage(named: "unPinWidget", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        pinOrUnpinButton.setImage(unPinWidgetImage, for: .selected)
        
        let pinWidgetImage = UIImage(named: "pinWidget", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        pinOrUnpinButton.setImage(pinWidgetImage, for: .normal)

        return pinOrUnpinButton
    }()

    lazy var plusButton: UIButton = {
        let button = UIButton(frame: .zero)
        let image = UIImage(named: "addPanel"
            )
        button.isHidden = true
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.paleGreyTwo
        button.addTarget(self, action: #selector(addKnowledgeAction(_:)), for: .touchUpInside)
        return button
    }()

    lazy var loginView: KREWidgetLoginView = {
        let loginView = KREWidgetLoginView(frame: .zero)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        return loginView
    }()
    
    public var loginButtonHandler:((KREWidgetLoginView) -> Void)?
    public var updateSubviews:(() -> Void)?
    public var widgetView: KREWidgetView

    // MARK: - init
    public init(view: KREWidgetView) {
        widgetView = view
        super.init(frame: .zero)
        setup()
//        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(_:)), name: NSNotification.Name.AFNetworkingReachabilityDidChange, object: nil)
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        widgetView = KREWidgetView(frame: .zero)
        super.init(coder: coder)
        setup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: -
    func setup() {
        clipsToBounds = true
        backgroundColor = UIColor.paleGrey
        
        addSubview(titleContainerView)

        bubbleContainerView.backgroundColor = UIColor.clear
        bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleContainerView)
        
        // lineContainerView
        lineContainerView.addSubview(lineView)
        
        let lineContainerViews: [String: UIView] = ["lineView": lineView]
        lineContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView]|", options:[], metrics: nil, views: lineContainerViews))
        lineContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[lineView]-10-|", options: [], metrics: nil, views: lineContainerViews))
        
        // setting bubbleContainerView constraints
        let views: [String: UIView] = ["bubbleContainerView": bubbleContainerView, "titleContainerView": titleContainerView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleContainerView][bubbleContainerView]|", options:[], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleContainerView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleContainerView]|", options: [], metrics: nil, views: views))

        bubbleContainerView.addArrangedSubview(lineContainerView)
        bubbleContainerView.addArrangedSubview(progressBar)
        bubbleContainerView.addArrangedSubview(buttonsContainerView)
        bubbleContainerView.addArrangedSubview(widgetView)
        bubbleContainerView.addArrangedSubview(noDataView)
        bubbleContainerView.addArrangedSubview(loginView)
        
        titleContainerView.backgroundColor = UIColor.white
        titleContainerView.addSubview(pinOrUnpinButton)
        titleContainerView.addSubview(titleLabel)
        titleContainerView.addSubview(plusButton)

        let titleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.textFont(ofSize: 15.0, weight: .medium)
        ]
        filterSegmentedControl.setTitleTextAttributes(titleAttributes, for: .selected)
        
        let normalTitleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.textFont(ofSize: 15.0, weight: .medium)
        ]
        filterSegmentedControl.setTitleTextAttributes(normalTitleAttributes, for: .normal)
        
        filterSegmentedControl.backgroundColor = .paleGrey
        filterSegmentedControl.layer.cornerRadius = 6.0
        filterSegmentedControl.layer.cornerRadius = 6.0
        filterSegmentedControl.layer.masksToBounds = false
        filterSegmentedControl.layer.borderWidth = 0.5
        buttonsContainerView.addSubview(filterSegmentedControl)

        filterSegmentedControl.heightAnchor.constraint(equalToConstant: buttonMaxHeight).isActive = true
        titleContainerView.heightAnchor.constraint(equalToConstant: titleContainerHeight).isActive = true
        noDataView.heightAnchor.constraint(equalToConstant: 200.0).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        plusButton.layer.cornerRadius = 15
        plusButton.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor).isActive = true

        pinOrUnpinButton.widthAnchor.constraint(equalToConstant: pinOrUnpinButtonHeight).isActive = true
        pinOrUnpinButton.heightAnchor.constraint(equalToConstant: pinOrUnpinButtonHeight).isActive = true
        pinOrUnpinButton.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor).isActive = true

        progressBar.heightAnchor.constraint(equalToConstant: 2.0).isActive = true

        // setting buttonsContainerView constraints
        let buttonsContainerViews: [String: UIView] = ["filterSegmentedControl": filterSegmentedControl]
        buttonsContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[filterSegmentedControl]-4-|", options: [], metrics: nil, views: buttonsContainerViews))
        buttonsContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[filterSegmentedControl]-10-|", options: [], metrics: nil, views: buttonsContainerViews))
        
        // setting titleContainerView constraints
        let titleContainerViews: [String: UIView] = ["titleLabel": titleLabel, "pinOrUnpinButton": pinOrUnpinButton, "plusButton": plusButton]
        titleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]|", options: [], metrics: nil, views: titleContainerViews))
        titleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel][plusButton]-[pinOrUnpinButton]-10-|", options: [], metrics: nil, views: titleContainerViews))
        
        progressBar.isLoading = true
        progressBar.isHidden = true
        buttonsContainerView.isHidden = true
        
        loginView.loginButtonHandler = { [weak self]  in
            let selectedFilters = self?.widget?.filters?.filter { $0.isSelected == true}
            guard let widgetFilter = selectedFilters?.first,
                let widgetComponent = widgetFilter.component else {
                    return
            }

            self?.delegate?.elementAction(for: widgetComponent.login, in: self?.widget)
        }
        
        lineContainerView.isHidden = true
        lineContainerView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    // MARK: - populate bubbleView
    public func populateBubbleView() {
        guard let widget = widget as? KREWidget else {
            startShimmering()
            return
        }
        
        stopShimmering()
        backgroundColor = UIColor.white
        
        if let title = widget.title {
            let attributedString = NSMutableAttributedString(string: title, attributes: [.font: UIFont.textFont(ofSize: 17.0, weight: .semibold), .foregroundColor: UIColor.dark, .kern: 1.0])
            titleLabel.attributedText = attributedString
        }
        if let color = widget.themeColor {
            themeColor = UIColor(hexString: color)
            progressBar.progressBarColor = UIColor(hexString: color)
        }
        lineContainerView.isHidden = true
        switch widget.templateType {
        case "headLines":
            populateWidgetView()
        default:
            if let widgetFilters = widget.filters {
                if widgetFilters.count > 1 {
                    filters = widgetFilters
                    buttonsContainerView.isHidden = false
                } else {
                    buttonsContainerView.isHidden = true
                    lineContainerView.isHidden = false
                }
                
                if let widgetFilter = widgetFilters.first {
                    let isLoading = widgetFilter.isLoading
                    progressBar.isLoading = isLoading
                    progressBar.isHidden = !isLoading
                } else {
                    let isLoading = false
                    progressBar.isLoading = isLoading
                    progressBar.isHidden = !isLoading
                }
                populateBubbleContainerView()
            }
        }
    }
    
    func populateFilters() {
        guard let filters = filters else {
            return
        }

        filterSegmentedControl.layer.borderColor = UIColor.veryLightBlue.cgColor
        if #available(iOS 13.0, *) {
           filterSegmentedControl.selectedSegmentTintColor = themeColor ?? UIColor.coralPink
        } else {
           filterSegmentedControl.tintColor = themeColor ?? UIColor.coralPink
        }
        
        filterSegmentedControl.removeAllSegments()
        
        for index in 0..<filters.count {
            let filter = filters[index]
            filterSegmentedControl.insertSegment(withTitle: filter.title, at: index, animated: false)
            if filter.isSelected {
                filterSegmentedControl.selectedSegmentIndex = index
            }
        }
    }
    
    func populateWidgetView() {
        loginView.isHidden = true
    
        guard let widget = widget else {
            return
        }
        pinButtonChanges()
        switch widget.widgetState {
        case .noNetwork:
            noDataView.setHiddenState(false)
        case .loaded, .refreshed, .refreshing:
            let elements = widget.elements
            if widget.widgetState == .loaded || widget.widgetState == .refreshed {
                let isLoading = false
                progressBar.isLoading = isLoading
                progressBar.isHidden = !isLoading
            }
            if elements?.count ?? 0 > 0 {
                widgetView.isHidden = false
                widgetView.widget = widget
                noDataView.setHiddenState(true)
            } else if (elements?.count ?? 0) == 0 {
                widgetView.isHidden = true
                noDataView.setHiddenState(false)
            }
        default:
            break
        }
        
        layoutIfNeeded()
        invalidateIntrinsicContentSize()
    }
    
    func populateBubbleContainerView() {
        loginView.isHidden = true
        guard let widget = widget as? KREWidget, let filters = widget.filters else {
            return
        }
        
        let selectedFilters = filters.filter { $0.isSelected == true}
        if let widgetFilter = selectedFilters.first {
            if let widgetComponent = widgetFilter.component  {
                if let _ = widgetComponent.login {
                    loginView.isHidden = false
                    noDataView.isHidden = true
                    loginView.widgetState = widget.widgetState
                    layoutIfNeeded()
                    invalidateIntrinsicContentSize()
                    return
                }
            }
        }
        pinButtonChanges()
        switch widget.widgetState {
        case .noNetwork:
            let isLoading = false
            progressBar.isLoading = isLoading
            progressBar.isHidden = !isLoading
            noDataView.setHiddenState(false)
        case .loaded, .refreshed, .refreshing:
            if widget.widgetState == .loaded || widget.widgetState == .refreshed {
                let isLoading = false
                progressBar.isLoading = isLoading
                progressBar.isHidden = !isLoading
            }
            if let widgetFilter = selectedFilters.first {
                if let widgetComponent = widgetFilter.component  {
                    let elements = widgetComponent.elements
                    if elements?.count ?? 0 > 0 {
                        widgetView.isHidden = false
                        widgetView.widget = widget
                        widgetView.widgetComponent = widgetComponent
                        noDataView.setHiddenState(true)
                    } else if (elements?.count ?? 0) == 0 {
                        widgetView.isHidden = true
                        noDataView.setHiddenState(false)

                        let placeholder = widgetComponent.placeholder ?? ""
                        noDataView.noDataLabel.text = placeholder
                    }
                }
            }
        case .requestFailed:
            let widgetFilter = selectedFilters.first
            let widgetComponent = widgetFilter?.component
            let elements = widgetComponent?.elements
            if elements?.count ?? 0 == 0 {
                widgetView.isHidden = true
                noDataView.setHiddenState(false)

                let isLoading = false
                progressBar.isLoading = isLoading
                progressBar.isHidden = !isLoading

                noDataView.noDataLabel.text = NSLocalizedString("Request failed", comment: "Request failed")
            }
        case .noData:
            let widgetFilter = selectedFilters.first
            let widgetComponent = widgetFilter?.component
            let elements = widgetComponent?.elements
            if elements?.count ?? 0 == 0 {
                widgetView.isHidden = true
                noDataView.setHiddenState(false)

                let isLoading = false
                progressBar.isLoading = isLoading
                progressBar.isHidden = !isLoading

                let placeholder = widgetComponent?.placeholder ?? ""
                noDataView.noDataLabel.text = placeholder
            }
        case .loading:
            let isLoading = true
            progressBar.isLoading = isLoading
            progressBar.isHidden = !isLoading
            
            noDataView.noDataLabel.text = nil
        case .none:
            break
        }
        
        invalidateIntrinsicContentSize()
    }
    
    func pinButtonChanges() {
        guard let widget = widget else {
            return
        }
        
        pinOrUnpinButton.layer.cornerRadius = pinOrUnpinButtonHeight / 2
        pinOrUnpinButton.tintColor = UIColor.black
        pinOrUnpinButton.isSelected = widget.pinned ?? false
    }
    
    @objc func pinOrUnpinButtonAction(_ sender: UIButton) {
        delegate?.pinOrUnpinAction(for: widget, completion: { [weak self] (status, mWidget) in
            guard mWidget?.widgetId == self?.widget?.widgetId else {
                return
            }
            var success = ""
            if mWidget?.pinned ?? false {
               success = "This widget is now pinned in the home panel"
            } else {
               success = "This widget is now unpinned from the home panel"
            }
            self?.delegate?.addSnackBar(text: success)
            self?.pinButtonChanges()
        })
    }

    @objc func addKnowledgeAction(_ sender: UIButton) {
        if let widget = widget {
            delegate?.addWidgetElement(in: widget)
        }
    }
    
    @objc func networkChanged(_ notification:Notification) {
        if let key = notification.userInfo?["NetworkingReachabilityNotificationStatusItem"] as? NetworkReachabilityManager.NetworkReachabilityStatus {
            switch key {
            case .unknown:
                break
            case .notReachable:
                break
            case .reachable(.cellular):
                populateBubbleView()
                break
            case .reachable(.cellular):
                populateBubbleView()
                break
            default:
                debugPrint("Network Changed")
                break
            }
        }
    }
    // MARK: - Method to be overridden
    public func prepareForReuse() {
        progressBar.isLoading = false
        progressBar.isHidden = true
        buttonsContainerView.isHidden = true
        widgetView.prepareForReuse()
        widgetView.isHidden = false
        pinOrUnpinButton.isSelected = false
        invalidateIntrinsicContentSize()
        filters = nil
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    @objc func filterDidChange(_ segmentedControl: UISegmentedControl) {
        filterSegmentedControl.layer.borderColor = UIColor.veryLightBlue.cgColor
        filterSegmentedControl.layer.cornerRadius = 6.0
        filterSegmentedControl.layer.masksToBounds = false
        filterSegmentedControl.layer.borderWidth = 0.5

        if let filters = widget?.filters {
            let selectedIndex = segmentedControl.selectedSegmentIndex
            let filter = filters[selectedIndex]
            
            let manager = KREWidgetManager.shared
            manager.updateSelectedWidgetFilter(filter, in: widget)
            
            populateBubbleView()
            didSelectComponentAtIndex?(selectedIndex)
            layoutSubviews()
            invalidateIntrinsicContentSize()
            updateSubviews?()
        }
    }
    
    // MARK: -
    func startShimmering() {
        widgetView.backgroundColor = UIColor.paleGrey
    }
    
    func stopShimmering() {
        widgetView.backgroundColor = UIColor.clear
    }
}

// MARK: - KREWidgetViewDataSource
extension KREWidgetContainerView: KREWidgetViewDataSource {
    public func willUpdateWidget(_ widget: KREWidget) {
        
    }
    
    public func didUpdateWidget(_ widget: KREWidget) {
        DispatchQueue.main.async {
            self.populateBubbleView()
        }
    }
}
