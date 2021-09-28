//
//  KAPanelCollectionView.swift
//  KoraSDK
//
//  Created by Sukhmeet Singh on 14/10/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import KoreBotSDK
import Alamofire

public enum KAPanelState {
    case loading
    case loaded
    case refreshed
    case refreshing
    case networkError
    case noData
    case requestFailed
    case none
}

public class KAPanelCollectionView: UIView {
    // MARK: - properties
    let imageUrl = SDKConfiguration.serverConfig.JWT_SERVER
    let maxElements: Int = Int(UIScreen.main.bounds.width / 64.0)
    let bundle = Bundle(for: KAPanelCollectionView.self)
    var showLabelsBelowPanelIcons = true
    var gesture: UIPanGestureRecognizer?
    var timerCount = 0
    var timerState = false
    var scaleStateFlag = false
    var collectionViewLeadingConstraint: NSLayoutConstraint!
    var collectionViewTrailingConstraint: NSLayoutConstraint!
    var isSelected: Bool = false
    var selectedIndexPath = IndexPath(row: -1, section: -1)
    var collectionView: UICollectionView!
    var prototypeCell = KAPanelCollectionViewCell()
    var collectionViewHeightConstraint: NSLayoutConstraint!
    let maxHeight: CGFloat = 44.0
    let cellHeight: CGFloat = 32.0
    let cellWidth: CGFloat = 70.0
    var scaledHeight = 0.0
    var scaledWidth = 0.0
    let maxPanelItems = 10
    var previousNetworkState: Int = -1
   
    lazy var errorView: UIButton = {
        let errorView = UIButton(frame: .zero)
        errorView.backgroundColor = UIColor.init(red: 224.0 / 255.0, green: 225.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0)
        errorView.translatesAutoresizingMaskIntoConstraints = false
       errorView.titleLabel?.font = UIFont.textFont(ofSize: 14.0, weight: .bold)
        //errorView.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
        errorView.titleLabel?.textAlignment = .center
        errorView.titleLabel?.lineBreakMode = .byWordWrapping
        errorView.titleLabel?.numberOfLines = 0
        errorView.setTitleColor(.black, for: .normal)
        errorView.setImage(UIImage(named: "refresh"), for: .normal)
        errorView.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: (bounds.width - 28.0), bottom: 8.0, right: 8.0)
        errorView.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 28.0)
        return errorView
    }()
    var panelState: KAPanelState = .none {
        didSet {
            updatePanelState()
        }
    }
    lazy var panelBarInputView: UIView = {
        let panelBarInputView = UIView(frame: .zero)
        panelBarInputView.translatesAutoresizingMaskIntoConstraints = false
        return panelBarInputView
    }()
    
    public var panelScaleAnimationTriggered:((Bool?) -> Void)?
    public var panelItemHandler:((KREPanelItem?, (()->Void)?) -> Void)?
    public var onPanelItemClickAction: ((KREPanelItem?) -> Void)?
    public var retryAction: (() -> Void)?
    public var keyboardSwipeGestureHandler: ((UISwipeGestureRecognizer) -> Void)?
    public var keyboardEditingEndsHandler: (() -> Void)?
    public var keyboardEditingBeginsHandler: (() -> Void)?
    
    public var scaleState = false
    
    public var items: [KREPanelItem]? {
        didSet {
            collectionView.reloadData()
        }
    }

    //public weak var inputBarAccessoryView: InputBarAccessoryView?
    public weak var timer: Timer?
    
    // MARK:- init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience public init() {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - removing refernces to elements
    public func prepareForReuse() {
        
    }
    
    // MARK:- setup collectionView
    func setup() {
        scaledWidth = Double(50)
        scaledHeight = Double(50)
        backgroundColor = UIColor.init(red: 224.0 / 255.0, green: 225.0 / 255.0, blue: 233.0 / 255.0, alpha: 1.0)
        
        // configure layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 1.0, height: 1.0)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 0.0)
        
        // collectionView initialization
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)

        for n in 0..<maxPanelItems {
            collectionView.register(KAPanelCollectionViewCell.self, forCellWithReuseIdentifier: "KAPanelCollectionViewCell_\(n)")
        }
        collectionView.register(KAPanelCollectionViewCell.self, forCellWithReuseIdentifier: "KAPanelCollectionViewCell")
        let views: [String: Any] = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[collectionView]", options:[], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(-2)-[collectionView]-5-|", options:[], metrics: nil, views: views))
        collectionViewLeadingConstraint = NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: -5.0)
        addConstraint(collectionViewLeadingConstraint)
        collectionViewLeadingConstraint.isActive = true
        
        collectionViewTrailingConstraint = NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        addConstraint(collectionViewTrailingConstraint)

        collectionViewTrailingConstraint.isActive = true
        
//        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(_:)), name: NSNotification.Name.AFNetworkingReachabilityDidChange, object: nil)
        
    }

    public override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height = maxHeight
        return contentSize
    }
    
    // MARK: -
    private func updatePanelState() {
        switch panelState {
        case .loading:
            collectionView.isUserInteractionEnabled = false
            collectionView.isScrollEnabled = false
            collectionView.bounces = false
        case .requestFailed, .networkError:
            showErrorView()
            fallthrough
        default:
            collectionView.isUserInteractionEnabled = true
            collectionView.isScrollEnabled = true
            collectionView.bounces = true
        }
    }
    
    private func showErrorView() {
        var error = KALocalized("Oops! Something went wrong. Please try again after a while.")
        if panelState == .networkError {
            error = KALocalized("You are offline. Tap to retry...")
        }

        errorView.setTitle(error, for: .normal)
        errorView.addTarget(self, action: #selector(retryAction(_:)), for: .touchUpInside)
        addSubview(errorView)

        if let window = UIApplication.shared.windows.first {
            if errorView.isDescendant(of: window) {
                errorView.translatesAutoresizingMaskIntoConstraints = false
                errorView.leftAnchor.constraint(equalTo: window.leftAnchor, constant: 0.0).isActive = true
                errorView.rightAnchor.constraint(equalTo: window.rightAnchor, constant: 0.0).isActive = true
                errorView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
                errorView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
            }
            else {
                let errorViews: [String: Any] = ["errorView": errorView]
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[errorView]|", options:[], metrics: nil, views: errorViews))
                addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[errorView]|", options:[], metrics: nil, views: errorViews))
            }
        }

        UIView.animate(withDuration: 0.2, animations:{
            self.errorView.heightAnchor.constraint(equalToConstant: self.maxHeight).isActive = false
        })
    }
    
    @objc func retryAction(_ sender: UIButton) {
        retry()
    }
    
    func retry() {
        retryAction?()
        updatePanelState()
        removeErrorView()
    }
    
    @objc func networkChanged(_ notification: Notification) {
        if let key = notification.userInfo?["NetworkingReachabilityNotificationStatusItem"] as? NetworkReachabilityManager.NetworkReachabilityStatus {
            switch key {
            case .unknown:
                previousNetworkState = -1
                break
            case .notReachable:
                if previousNetworkState != 0 {
                    retry()
                }
                previousNetworkState = 0
                break
            case .reachable(.cellular):
                if self.errorView.superview != nil {
                    removeErrorView()
                }
                retryAction?()
                updatePanelState()
                previousNetworkState = 1
                break
            case .reachable(.ethernetOrWiFi):
                if self.errorView.superview != nil {
                    removeErrorView()
                }
                retryAction?()
                updatePanelState()
                previousNetworkState = 2
                break
            default:
                break
            }
        }
    }

    
    private func removeErrorView() {
        UIView.animate(withDuration: 0.2, animations:{
            self.errorView.heightAnchor.constraint(equalToConstant: 0.0).isActive = false
        }, completion: { (finished) in
            self.errorView.removeFromSuperview()
        })
    }
    
    func showLabelsBelowPanelIcons(_ show:Bool) {
        showLabelsBelowPanelIcons = show
        let numSecs = collectionView.numberOfSections
        for i in 0..<numSecs {
            let cellsInsec = collectionView.numberOfItems(inSection: i)
            for j in 0..<cellsInsec {
                let indexpath = IndexPath(item: j, section: i)
                if let cell = collectionView.cellForItem(at: indexpath) as? KAPanelCollectionViewCell {
                    cell.bottomConstraint.constant = 0.0
                    if show {
                        cell.heightContraint.constant = 13.0
                    }
                    else {
                        cell.heightContraint.constant = 0.0
                    }
                }
            }
        }
    }
    
    func panelIconMask(_ forView:UIView) {
        let path = UIBezierPath.init(roundedRect: forView.bounds, cornerRadius: forView.bounds.height/2)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        forView.layer.mask = shapeLayer
    }
    
    
    // MARK: - populate cells
    private func populateCell(for indexPath: IndexPath, in collectionViewCell: KAPanelCollectionViewCell) {
        collectionViewCell.iconImageView.image = nil
        let item = items?[indexPath.row]
                        
        let identity = iconIdentity(for: item)
        collectionViewCell.iconImageView.setProfileImage(for: identity, initials: true)
        
        if let name = item?.name {
            collectionViewCell.titleLabel.text = name
        }

        if selectedIndexPath == indexPath {
            collectionViewCell.shapeLayer.isHidden = false
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = 0.25
            collectionViewCell.shapeLayer.add(animation, forKey: "strokeEnd")
        } else {
            collectionViewCell.shapeLayer.removeAllAnimations()
            collectionViewCell.shapeLayer.isHidden = true
            collectionViewCell.layer.borderColor = UIColor.clear.cgColor
            collectionViewCell.layer.borderWidth = 0.0
        }
        if scaleStateFlag {
            collectionViewCell.bottomConstraint.constant = 0.0
            collectionViewCell.heightContraint.constant = 13.0
        }
        else {
            collectionViewCell.bottomConstraint.constant = 0.0
            if showLabelsBelowPanelIcons {
                collectionViewCell.heightContraint.constant = 13.0
            }
            else {
                collectionViewCell.heightContraint.constant = 0.0
            }
        }
    }
    
    private func populateDefaultCell(for indexPath: IndexPath, in collectionViewCell: KAPanelCollectionViewCell) {
        collectionViewCell.iconImageView.image = nil
        
        collectionViewCell.iconImageView.backgroundColor = .lightGreyBlue
    }
    
    // MARK: -
    func iconIdentity(for item: KREPanelItem?) -> KREIdentity {
        var unicode = "\u{2d}"
        var imageUrlString: String?
        var image: UIImage?
        var contentMode = UIImageView.ContentMode.scaleAspectFit
        
        switch item?.iconId {
        case "meetings", "home", "files", "announcement", "knowledge", "tasks":
            if let iconId = item?.iconId {
                let panelImage = UIImage(named: iconId + "Panel", in: bundle, compatibleWith: nil)
                image = panelImage
                contentMode = .center
            }
        case "koreTeam":
            unicode = "\u{e996}"
        case "koreChat":
            unicode = "\u{e995}"
        default:
            if let urlString = item?.icon, urlString != "url" {
                imageUrlString =  urlString
                contentMode = .scaleAspectFill
            }
        }
        
        let identity = KREIdentity()
        identity.color = item?.theme ?? UIColor.lightGreyBlue.hex
        identity.initials = unicode
        identity.imageUrl = imageUrlString
        identity.font = UIFont.systemSymbolFont(ofSize: 20.0)
        identity.image = image
        identity.contentMode = contentMode
        identity.placeHolderImage = UIImage(named: "genericSkillIcon", in: bundle, compatibleWith: nil)
        return identity
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource methods
extension KAPanelCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch panelState {
        case .loading:
            return maxElements
        case .loaded, .refreshed, .refreshing:
            return items?.count ?? 0
        default:
            //return 0
            return items?.count ?? 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: KAPanelCollectionViewCell? = nil
        if indexPath.row < maxPanelItems {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KAPanelCollectionViewCell_\(indexPath.row)", for: indexPath) as? KAPanelCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KAPanelCollectionViewCell", for: indexPath) as? KAPanelCollectionViewCell
        }
        
        if let collectionViewCell = cell {
            if let _ = items?[indexPath.row]  {
                populateCell(for: indexPath, in: collectionViewCell)
            } else {
                populateDefaultCell(for: indexPath, in: collectionViewCell)
            }
            collectionViewCell.layoutIfNeeded()
        }
        if cell != nil {
            return cell!
        } else {
            return (collectionView.dequeueReusableCell(withReuseIdentifier: "KAPanelCollectionViewCell", for: indexPath) as? KAPanelCollectionViewCell)!
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items?[indexPath.row] else {
            return
        }
        
        panelScaleAnimationTriggered?(false)
        transform = CGAffineTransform.identity
        collectionViewLeadingConstraint.constant = -5
        collectionViewTrailingConstraint.constant = 0
        scaleState = false
        scaleStateFlag = false
        
        if selectedIndexPath != indexPath {
            if selectedIndexPath.row >= 0 {
                if let prev = items?[selectedIndexPath.row] {
                    prev.selectionState = false
                }
            }
            item.selectionState = true
        }
        
        selectedIndexPath = indexPath
        onPanelItemClickAction?(item) //, self
        panelItemHandler?(item, nil)
        collectionView.reloadData()
        stopTimer()
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if scaleStateFlag {
            return CGSize(width: scaledWidth+20.0, height: scaledHeight-9)
        } else {
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scaleState = true
        startTimer()
        if scaleState {
            collectionView.reloadData()
            self.clipsToBounds = false
            scaleStateFlag = true
            self.collectionViewLeadingConstraint.constant = 55
            self.collectionViewTrailingConstraint.constant = -60
            panelScaleAnimationTriggered?(true)
            self.transform =  CGAffineTransform(scaleX: 1.4, y: 1.4)
            scaleState = false
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        timerCount = 0
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func startTimer() {
        timer?.invalidate()
        timerCount = 0
        // just in case you had existing `Timer`, `invalidate` it before we lose our reference to it
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // do something here
            self?.timerCount += 1
            if self?.timerCount ?? 0 >= 2 {
                self?.resetPanelAnimation()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timerCount = 0
    }
    
    func resetPanelAnimation() {
        panelScaleAnimationTriggered?(false)
        transform = CGAffineTransform.identity
        collectionViewLeadingConstraint.constant = -5
        collectionViewTrailingConstraint.constant = 0
        scaleState = false
        scaleStateFlag = false
        collectionView.reloadData()
        stopTimer()
    }
    
    // MARK: -
    func startAnimating() {
        if let _ = items {
            panelState = .refreshing
        } else {
            panelState = .loading
        }
    }
    
    func stopAnimating(_ error: Error?) {
        switch panelState {
        case .loading, .refreshing:
            guard let error = error as NSError? else {
                panelState = (panelState == .loading) ? .loaded : .refreshed
                return
            }
            
            let errorCode = error.code
            switch errorCode {
            case -1009, -1001:
                panelState = .networkError
            default:
                panelState = .requestFailed
            }
        case .requestFailed, .networkError, .loaded, .refreshed:
            break
        case .noData, .none:
            break
        }
    }
}



// MARK: - KAPanelItemImageView
class KAPanelItemImageView: UIImageView {
    
    var newBackgroundColor: UIColor?
    
    override var bounds: CGRect {
        didSet {
            self.clipsToBounds = true
            updateOverlay()
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            newBackgroundColor = backgroundColor
            updateOverlay()
        }
    }
    
    func updateOverlay() {
        let xOffset = self.bounds.size.width * 0.5
        let yOffset = self.bounds.size.height * 0.5
        let smallestSide = yOffset > xOffset ? xOffset : yOffset
        let view = createOverlay(frame: self.frame, xOffset: xOffset, yOffset: yOffset, radius: smallestSide)
        if self.subviews.count > 0 {
            for allSubview in self.subviews {
                allSubview.removeFromSuperview()
            }
        }
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    func createOverlay(frame: CGRect,
                       xOffset: CGFloat,
                       yOffset: CGFloat,
                       radius: CGFloat) -> UIView {
        let overlayView = UIView(frame: frame)
        if newBackgroundColor != nil {
            overlayView.backgroundColor =  newBackgroundColor   //UIColor.black.withAlphaComponent(0.6)
        }
        else {
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.size.height/2.0)
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
        return overlayView
    }
}

// MARK: - KAPanelCollectionViewCell
public class KAPanelCollectionViewCell: UICollectionViewCell {
    // MARK: -
    public var panelClickAction: ((IndexPath) -> Void)?
    public var panelAnimateAction: ((IndexPath) -> Void)?
    let shapeLayer = CAShapeLayer()
    var bottomConstraint: NSLayoutConstraint!
    var heightContraint: NSLayoutConstraint!
    override public var backgroundColor: UIColor?{
        didSet {
            iconImageView.backgroundColor = backgroundColor
        }
    }
    
    var iconImageView: KREIdentityImageView = {
        let imageView = KREIdentityImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 9.0, weight: .regular)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.lightGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    public lazy var iconTitleStackView: UIStackView = {
        let iconTitleStackView = UIStackView()
        iconTitleStackView.axis = .vertical
        iconTitleStackView.distribution = UIStackView.Distribution.fill
        iconTitleStackView.alignment = UIStackView.Alignment.center
        iconTitleStackView.spacing = 2.0
        iconTitleStackView.translatesAutoresizingMaskIntoConstraints = false
        return iconTitleStackView
    }()

    
    public override func prepareForReuse() {
        iconImageView.image = nil
        super.prepareForReuse()
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: -
    func setup() {
        backgroundColor = .clear
        layer.cornerRadius = 16.0

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        iconImageView.layer.cornerRadius = 16.0
        
        let views = ["iconImageView": iconImageView, "titleLabel": titleLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[iconImageView(50)]-10-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[iconImageView(32)][titleLabel]", options: [], metrics: nil, views: views))
        
        bottomConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0)
        contentView.addConstraint(self.bottomConstraint)
        bottomConstraint.isActive = true
        heightContraint = NSLayoutConstraint.init(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        contentView.addConstraint(self.heightContraint)
        heightContraint.isActive = true
       
        let circlePath = UIBezierPath(roundedRect: CGRect(x: 10, y: 0, width: 50, height: 32), cornerRadius: 16)
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.lightGreyBlue.cgColor
        shapeLayer.lineWidth = 3.0
        layer.addSublayer(shapeLayer)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - KAPanelInputView
public class KAPanelInputView: UIView {
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .paleLilacFour
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .paleLilacFour
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            if view == self {
                return nil
            }
            return view
        }
        return nil
    }
}
