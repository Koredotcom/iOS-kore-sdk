//
//  KRESnackBarViewController.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 20/04/20.
//

import UIKit

public class KASnackBarContainerView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KASnackBarContainerView.self)
    lazy var contentView: UIView = {
        let contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.paleLilacThree.cgColor
        contentView.layer.cornerRadius = 11.0
        contentView.layer.shadowColor = UIColor.charcoalGrey.withAlphaComponent(0.16).cgColor
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        contentView.layer.shadowRadius = 7 / 2
        contentView.layer.shadowPath = nil
        return contentView
    }()
    

    let metrics: [String: CGFloat] = ["left": 15.0, "right": 16.0, "top": 8.0, "bottom": 8.0]
    let titleContainerViewMetrics: [String: CGFloat] = ["left": 0.0, "right": 0.0, "top": 8.0, "bottom": 8.0]
    let contentViewMetrics: [String: CGFloat] = ["left": 14.0, "right": 14.0, "top": 8.0, "bottom": 20.0]
    
    lazy var titleContainerView: UIView = {
        let titleContainerView = UIView(frame: .zero)
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleContainerView.backgroundColor = .clear
        return titleContainerView
    }()


    lazy var closeButton: UIButton = {
        var closeButton = UIButton(frame: .zero)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.backgroundColor = UIColor.clear
        let normalImage = UIImage(named: "close", in: bundle, compatibleWith: nil)
        closeButton.setImage(normalImage, for: .normal)
        return closeButton
    }()
        
   public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.textFont(ofSize: 17.0, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.dark
     //   titleLabel.text = NSLocalizedString("Pinned Successfully.", comment: "Pinned Successfully.")
        return titleLabel
    }()
    
    public lazy var leftImage: UIImageView = {
         let leftImage = UIImageView(frame: .zero)
         leftImage.translatesAutoresizingMaskIntoConstraints = false
         leftImage.backgroundColor = UIColor.algaeGreen
         leftImage.image = UIImage(named: "checkMark")?.withRenderingMode(.alwaysTemplate)
        leftImage.tintColor = .white
         return leftImage
     }()

    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 90.0)
    }
    
    public var dismissAction:(() -> Void)?

    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - setup
    func setup() {
        addSubview(contentView)

        let views: [String: Any] = ["contentView": contentView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[contentView]-(right)-|", options: [], metrics: contentViewMetrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[contentView]-(bottom)-|", options: [], metrics: contentViewMetrics, views: views))

        contentView.addSubview(titleContainerView)
        
        // titleContainerView
        titleContainerView.addSubview(titleLabel)
        titleContainerView.addSubview(leftImage)

        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        closeButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        titleContainerView.addSubview(closeButton)
       leftImage.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor).isActive = true
        leftImage.heightAnchor.constraint(equalToConstant: 54.0).isActive = true
        let titleContainerViews = ["titleLabel": titleLabel, "closeButton": closeButton, "leftImage": leftImage]
        
            leftImage.layer.cornerRadius = 27
            leftImage.contentMode = .center
        titleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[leftImage(54)]-[titleLabel]-[closeButton]-(right)-|", options: [], metrics: titleContainerViewMetrics, views: titleContainerViews))
        titleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[titleLabel]-(bottom)-|", options: [], metrics: titleContainerViewMetrics, views: titleContainerViews))
        

        closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        
        let contentViews: [String: Any] = ["titleContainerView": titleContainerView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[titleContainerView]-(right)-|", options: [], metrics: metrics, views: contentViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[titleContainerView]-(bottom)-|", options: [], metrics: metrics, views: contentViews))
        
    }
    
    // MARK: -
    @objc func closeButtonAction(_ sender: UIButton?) {
        dismissAction?()
    }
    
    // MARK: - deinit
    deinit {
        
    }
}

//
//  KAKoraFeedbackViewController.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 09/03/20.
//  Copyright © 2020 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRESnackBarViewController: UIViewController {
    public var destinationView = [UIView]()
    var dismissTimer:Timer?
    // MARK: - Public Properties
    public lazy var feedbackContainerView: KASnackBarContainerView = {
        let feedbackContainerView = KASnackBarContainerView(frame: .zero)
        feedbackContainerView.translatesAutoresizingMaskIntoConstraints = false
        feedbackContainerView.backgroundColor = .clear
        return feedbackContainerView
    }()

    public var inputViewHeight: CGFloat = 0.0
    
    public var dismissAction:(() -> Void)?

    // MARK: - init
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: -
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        view.addSubview(feedbackContainerView)
        
        feedbackContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        feedbackContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        feedbackContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inputViewHeight - 8.0).isActive = true
        
        feedbackContainerView.dismissAction = { [weak self] in
            if self?.dismissTimer != nil {
                self?.dismissTimer?.invalidate()
                self?.dismissTimer = nil
            }
            self?.dismissAction?()
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGestureRecognizer(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func dismissWithAnimation() {
            self.dismiss(animated: false, completion: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false, block: { (timer) in
            DispatchQueue.main.async {
                self.dismissWithAnimation()
            }
        })
    }
        
    // MARK: -
    @objc func handleGestureRecognizer(_ sender: Any?) {
        self.dismiss(animated: false, completion: nil)
        if self.dismissTimer != nil {
            self.dismissTimer?.invalidate()
            self.dismissTimer = nil
        }
    }
}
