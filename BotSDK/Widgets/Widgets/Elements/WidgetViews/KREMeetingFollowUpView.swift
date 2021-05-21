//
//  KREMeetingFollowUpView.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 16/06/20.
//

import UIKit

open class KREMeetingFollowUpView: UIView {
    let bundle = Bundle(for: KREMeetingFollowUpView.self)

    public lazy var verticalLineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    

   public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.textFont(ofSize: 14.8, weight: .medium)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .dark
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .left
        titleLabel.letterSpace = -0.07
        return titleLabel
    }()
    
    lazy var dateStackView: UIView = {
        let stackView = UIView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var clockImageView: UIImageView = {
        let typeImageView = UIImageView(frame: .zero)
        typeImageView.translatesAutoresizingMaskIntoConstraints = false
        typeImageView.contentMode = .scaleAspectFit
        return typeImageView
    }()
    
    public lazy var dateTimeLabel: UILabel = {
        let dateTimeLabel = UILabel(frame: .zero)
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.font = UIFont.textFont(ofSize: 12, weight: .medium)
        dateTimeLabel.lineBreakMode = .byWordWrapping
        dateTimeLabel.numberOfLines = 0
        dateTimeLabel.textColor = .dark
        dateTimeLabel.backgroundColor = .clear
        dateTimeLabel.textAlignment = .left
        dateTimeLabel.letterSpace = 0.28
        dateTimeLabel.sizeToFit()
        return dateTimeLabel
    }()
    
    lazy var noOfPeopleStackView: UIView = {
        let stackView = UIView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var noOFPeopleImageView: UIImageView = {
        let noOFPeopleImageView = UIImageView(frame: .zero)
        noOFPeopleImageView.contentMode = .scaleAspectFit
        noOFPeopleImageView.translatesAutoresizingMaskIntoConstraints = false
        return noOFPeopleImageView
    }()
    
    public lazy var noOFPeopleLabel: UILabel = {
        let noOFPeopleLabel = UILabel(frame: .zero)
        noOFPeopleLabel.translatesAutoresizingMaskIntoConstraints = false
        noOFPeopleLabel.font = UIFont.textFont(ofSize: 12, weight: .medium)
        noOFPeopleLabel.lineBreakMode = .byWordWrapping
        noOFPeopleLabel.numberOfLines = 1
        noOFPeopleLabel.textColor = .dark
        noOFPeopleLabel.backgroundColor = .clear
        noOFPeopleLabel.textAlignment = .left
        noOFPeopleLabel.letterSpace = 0.28
        return noOFPeopleLabel
    }()
    
    lazy var verticalStackView: UIView = {
        let stackView = UIView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        let dateAndTimeImage = UIImage(named: "followClock", in: bundle, compatibleWith: nil)
        clockImageView.image = dateAndTimeImage
        
        let assigneeImage = UIImage(named: "followPeople", in: bundle, compatibleWith: nil)
        noOFPeopleImageView.image = assigneeImage
        self.addSubview(verticalStackView)
        self.addSubview(verticalLineView)
        clockImageView.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        clockImageView.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        noOFPeopleImageView.widthAnchor.constraint(equalToConstant: 16.0).isActive = true
        noOFPeopleImageView.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
        let dateViews = ["clockImageView": clockImageView, "dateTimeLabel": dateTimeLabel]
        dateStackView.addSubview(clockImageView)
        dateStackView.addSubview(dateTimeLabel)
        clockImageView.contentMode = .scaleAspectFit
        dateStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[clockImageView]-12-[dateTimeLabel]-|", options: [], metrics: nil, views: dateViews))
        dateStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[clockImageView(20)]", options: [], metrics: nil, views: dateViews))
        dateStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dateTimeLabel]|", options: [], metrics: nil, views: dateViews))
        
        
        let peopleViews = ["noOFPeopleImageView": noOFPeopleImageView, "noOFPeopleLabel": noOFPeopleLabel]
        
        noOfPeopleStackView.addSubview(noOFPeopleImageView)
        noOfPeopleStackView.addSubview(noOFPeopleLabel)
        
        noOfPeopleStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noOFPeopleImageView]-12-[noOFPeopleLabel]-|", options: [], metrics: nil, views: peopleViews))
        noOfPeopleStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[noOFPeopleImageView]", options: [], metrics: nil, views: peopleViews))
        noOfPeopleStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[noOFPeopleLabel]|", options: [], metrics: nil, views: peopleViews))
        
        
        verticalStackView.addSubview(titleLabel)
        verticalStackView.addSubview(dateStackView)
        verticalStackView.addSubview(noOfPeopleStackView)
        verticalLineView.widthAnchor.constraint(equalToConstant: 2.0).isActive = true
        verticalLineView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        
        let views: [String: Any] = ["verticalStackView": verticalStackView, "verticalLineView": verticalLineView]
        
        let viewsVerticalStackView: [String: Any] = ["titleLabel": titleLabel, "dateStackView": dateStackView, "noOfPeopleStackView": noOfPeopleStackView]
        verticalStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]-|", options: [], metrics: nil, views: viewsVerticalStackView))
        verticalStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dateStackView]-|", options: [], metrics: nil, views: viewsVerticalStackView))
        verticalStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noOfPeopleStackView]-|", options: [], metrics: nil, views: viewsVerticalStackView))
        verticalStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]-8-[dateStackView]-3-[noOfPeopleStackView]-|", options: [], metrics: nil, views: viewsVerticalStackView))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[verticalLineView(2)]-10-[verticalStackView]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[verticalLineView]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[verticalStackView]-|", options: [], metrics: nil, views: views))

    }
    
    public func testData() {
        titleLabel.text = "Catch-Up"
        dateTimeLabel.text = "Oct 12, 9:30am - 10:00am"
      //  \nOct 12, 10:30am - 11:00am\nOct 12, 11:30am - 12:00pm"
        noOFPeopleLabel.text = "4 People Responded"
    }
    
//    override open var intrinsicContentSize: CGSize {
//        return CGSize(width: UIView.noIntrinsicMetric, height: 120)
//    }

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during aninmation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}


extension UILabel {

    @IBInspectable
    var letterSpace: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }

            attributedString.addAttribute(NSAttributedString.Key.kern,
                                           value: newValue,
                                           range: NSRange(location: 0, length: attributedString.length))

            attributedText = attributedString
        }

        get {
            if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            }
            else {
                return 0
            }
        }
    }
}
