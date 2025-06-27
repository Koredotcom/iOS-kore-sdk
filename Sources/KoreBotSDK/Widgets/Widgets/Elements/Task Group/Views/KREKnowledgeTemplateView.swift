//
//  KREKnowledgeTemplateView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 06/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
#if SWIFT_PACKAGE
import ObjcSupport
#endif
//import MarkdownKit

public class DescriptionImageView : UIImageView {
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 60.0, height: 60.0)
    }
}

public class KREKnowledgeTemplateView: UIView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    var widthConstraint:NSLayoutConstraint?
    var markdownParser = TSMarkdownParser.standard()
    //let markdownParser = MarkdownParser(font: UIFont.textFont(ofSize: 15, weight: .regular))

    public lazy var dateLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 12.0, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = .charcoalGrey
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 19.0, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.textColor = .dark
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
//    public lazy var subTitleLabel: UILabel = {
//        let titleLabel = UILabel(frame: .zero)
//        titleLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
//        titleLabel.numberOfLines = 2
//        titleLabel.textAlignment = .left
//        titleLabel.textColor = .dark
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.sizeToFit()
//        return titleLabel
//    }()
    
        public lazy var subTitleLabel: UITextView = {
            let textView = UITextView(frame: .zero)
            textView.textContainer.maximumNumberOfLines = 2
            textView.textContainer.lineBreakMode = .byTruncatingTail
            textView.isScrollEnabled = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.textColor = UIColor.dark
            textView.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            textView.dataDetectorTypes = .all
            textView.isUserInteractionEnabled = true
            textView.isSelectable = true
            textView.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
            textView.contentMode = UIView.ContentMode.topLeft
            textView.linkTextAttributes = [.foregroundColor: UIColor.lightRoyalBlue, .underlineStyle: 1.0]

    //        textView.textContainerInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 11.0)
            return textView
        }()

    public lazy var commentImagePlaceholder: UILabel = {
        let commentImagePlaceholder = UILabel(frame: .zero)
        commentImagePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        commentImagePlaceholder.text = "\u{e941}"
        commentImagePlaceholder.textColor = UIColor(hex: 0xA7A9BE)
        commentImagePlaceholder.font = UIFont.systemSymbolFont(ofSize: 17)
        commentImagePlaceholder.backgroundColor = .white
        commentImagePlaceholder.tintColor = UIColor(hex: 0xA7A9BE)
        commentImagePlaceholder.clipsToBounds = true
        commentImagePlaceholder.isUserInteractionEnabled = true
        return commentImagePlaceholder
    }()
    
    public lazy var commentCountLabel: UILabel = {
        let commentCountLabel = UILabel(frame: .zero)
        commentCountLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        commentCountLabel.textColor = UIColor(hex: 0x333D4D)
        commentCountLabel.isUserInteractionEnabled = true
        commentCountLabel.textAlignment = .left
        commentCountLabel.translatesAutoresizingMaskIntoConstraints = false
        return commentCountLabel
    }()
    
    public lazy var spectatorImagePlaceholder: UIImageView = {
        let viewImage = UIImage(named: "viewImage", in: bundle, compatibleWith: nil)
        let viewTemplateImage = viewImage?.withRenderingMode(.alwaysTemplate)
        let spectatorImagePlaceholder = UIImageView(frame: .zero)
        spectatorImagePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        spectatorImagePlaceholder.contentMode = .scaleAspectFit
        spectatorImagePlaceholder.tintColor = UIColor(hex: 0xA7A9BE)
        spectatorImagePlaceholder.image = viewTemplateImage
        spectatorImagePlaceholder.backgroundColor = .white
        spectatorImagePlaceholder.clipsToBounds = true
        spectatorImagePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        spectatorImagePlaceholder.isUserInteractionEnabled = true
        return spectatorImagePlaceholder
    }()
    
    public lazy var spectatorCountLabel: UILabel = {
        let spectatorCountLabel = UILabel(frame: .zero)
        spectatorCountLabel.translatesAutoresizingMaskIntoConstraints = false
        spectatorCountLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        spectatorCountLabel.textColor = UIColor(hex: 0x333D4D)
        spectatorCountLabel.isUserInteractionEnabled = true
        spectatorCountLabel.textAlignment = .left
        return spectatorCountLabel
    }()
    
    public lazy var likeImagePlaceholder: UIImageView = {
        let favouriteImage = UIImage(named: "upvote", in: bundle, compatibleWith: nil)
        let favouriteTemplateImage = favouriteImage?.withRenderingMode(.alwaysTemplate)
        let likeImagePlaceholder = UIImageView(frame: .zero)
        likeImagePlaceholder.contentMode = .scaleAspectFit
        likeImagePlaceholder.image = favouriteTemplateImage
        likeImagePlaceholder.tintColor = UIColor(hex: 0xA7A9BE)
        likeImagePlaceholder.backgroundColor = .white
        likeImagePlaceholder.clipsToBounds = true
        likeImagePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        likeImagePlaceholder.isUserInteractionEnabled = true
        return likeImagePlaceholder
    }()
    
    public lazy var likeCountLabel: UILabel = {
        let likeCountLabel = UILabel(frame: .zero)
        likeCountLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        likeCountLabel.textColor = UIColor(hex: 0x333D4D)
        likeCountLabel.sizeToFit()
        likeCountLabel.isUserInteractionEnabled = true
        likeCountLabel.textAlignment = .left
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        return likeCountLabel
    }()
    
    public lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 32.0
        return stackView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()
    
    public lazy var descriptionImage: DescriptionImageView = {
        let favouriteImage = UIImage(named: "actions", in: bundle, compatibleWith: nil)
        let favouriteTemplateImage = favouriteImage?.withRenderingMode(.alwaysTemplate)
        let likeImagePlaceholder = DescriptionImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        likeImagePlaceholder.contentMode = .scaleAspectFit
        likeImagePlaceholder.backgroundColor = .white
        likeImagePlaceholder.clipsToBounds = true
        likeImagePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        return likeImagePlaceholder
    }()

    lazy var topLevelStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 0.0
        return stackView
    }()
    
    public lazy var dislikeImagePlaceholder: UIImageView = {
        let dislikeImage = UIImage(named: "no", in: bundle, compatibleWith: nil)
        let dislikeTemplateImage = dislikeImage?.withRenderingMode(.alwaysTemplate)
        let dislikeImagePlaceholder = UIImageView(frame: .zero)
        dislikeImagePlaceholder.contentMode = .scaleAspectFit
        dislikeImagePlaceholder.image = dislikeTemplateImage
        dislikeImagePlaceholder.tintColor = UIColor(hex: 0xA7A9BE)
        dislikeImagePlaceholder.backgroundColor = .white
        dislikeImagePlaceholder.clipsToBounds = true
        dislikeImagePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        dislikeImagePlaceholder.isUserInteractionEnabled = true
        return dislikeImagePlaceholder
    }()
    
    public lazy var dislikeCountLabel: UILabel = {
        let dislikeCountLabel = UILabel(frame: .zero)
        dislikeCountLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        dislikeCountLabel.textColor = UIColor(hex: 0x333D4D)
        dislikeCountLabel.sizeToFit()
        dislikeCountLabel.isUserInteractionEnabled = true
        dislikeCountLabel.textAlignment = .left
        dislikeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        return dislikeCountLabel
    }()

    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    public func setup() {
        addSpectatorContainerView()
        addCommentsContainerView()
        addLikesContainerView()
        addDislikesContainerView()

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(subTitleLabel)
        stackView.addArrangedSubview(horizontalStackView)
        topLevelStackView.addArrangedSubview(stackView)
        topLevelStackView.addArrangedSubview(descriptionImage)
        addSubview(topLevelStackView)

        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(5.0, after: titleLabel)
            stackView.setCustomSpacing(8.0, after: dateLabel)
            stackView.setCustomSpacing(12.0, after: subTitleLabel)
            stackView.setCustomSpacing(12.0, after: horizontalStackView)
        }
        
        let views = ["topLevelStackView": topLevelStackView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[topLevelStackView]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13-[topLevelStackView]-13-|", options: [], metrics: nil, views: views))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]-60-|", options: [], metrics: nil, views: views))
        widthConstraint = stackView.rightAnchor.constraint(equalTo: topLevelStackView.rightAnchor, constant: -60)
        widthConstraint?.isActive = true
    }
    
    // MARK: -
    func loadDescriptionImage(_ imageURL:String?) {
        if imageURL == nil {
            self.descriptionImage.isHidden = true
            widthConstraint?.constant = 0
            return
        }
        if let urlStr = imageURL {
            if urlStr == "" {
                self.descriptionImage.isHidden = true
                widthConstraint?.constant = 0
                return
            }
            if let url = URL(string: urlStr) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            let image = UIImage(data: data)
                            self.descriptionImage.image = image
                            self.descriptionImage.isHidden = false
                            self.widthConstraint?.constant = -60
                        }
                    }
                }
            }
            else {
                self.descriptionImage.isHidden = true
                widthConstraint?.constant = 0
            }
        }
        topLevelStackView.layoutIfNeeded()
    }

    func addSpectatorContainerView() {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(spectatorImagePlaceholder)
        container.addSubview(spectatorCountLabel)
        
        let views = ["spectatorImagePlaceholder": spectatorImagePlaceholder, "spectatorCountLabel": spectatorCountLabel]
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[spectatorImagePlaceholder]-6-[spectatorCountLabel]|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[spectatorImagePlaceholder]|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[spectatorCountLabel]|", options: [], metrics: nil, views: views))
        spectatorImagePlaceholder.widthAnchor.constraint(equalToConstant: 19.0).isActive = true
        horizontalStackView.addArrangedSubview(container)
    }
    
    func addCommentsContainerView() {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(commentImagePlaceholder)
        container.addSubview(commentCountLabel)
        
        let views = ["commentCountLabel": commentCountLabel, "commentImagePlaceholder": commentImagePlaceholder]
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[commentImagePlaceholder]-6-[commentCountLabel]|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[commentImagePlaceholder]|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[commentImagePlaceholder]|", options: [], metrics: nil, views: views))
        commentImagePlaceholder.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
        horizontalStackView.addArrangedSubview(container)
    }
    
    func addLikesContainerView() {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(likeImagePlaceholder)
        container.addSubview(likeCountLabel)
        
        let views = ["likeCountLabel": likeCountLabel, "likeImagePlaceholder": likeImagePlaceholder]
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[likeImagePlaceholder]-6-[likeCountLabel]|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[likeImagePlaceholder]|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[likeCountLabel]|", options: [], metrics: nil, views: views))
        likeImagePlaceholder.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
        horizontalStackView.addArrangedSubview(container)
    }
    
    func addDislikesContainerView() {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dislikeImagePlaceholder)
        container.addSubview(dislikeCountLabel)
        
        let views = ["dislikeCountLabel": dislikeCountLabel, "dislikeImagePlaceholder": dislikeImagePlaceholder]
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dislikeImagePlaceholder]-6-[dislikeCountLabel]|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dislikeImagePlaceholder]|", options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dislikeCountLabel]|", options: [], metrics: nil, views: views))
        dislikeImagePlaceholder.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
        horizontalStackView.addArrangedSubview(container)
    }

    public func prepareForReuse() {
        descriptionImage.isHidden = true
        descriptionImage.image = nil
        widthConstraint?.constant = 0
        titleLabel.text = nil
        subTitleLabel.text = nil
        dateLabel.text = nil
        horizontalStackView.isHidden = true
    }

    // MARK: -
    public func loadingDataState() {
        titleLabel.text = ""
        subTitleLabel.text = ""
        dateLabel.text = ""
        titleLabel.textColor = .paleGrey
        titleLabel.backgroundColor = .paleGrey
        subTitleLabel.textColor = .paleGrey
        subTitleLabel.backgroundColor = .paleGrey
        dateLabel.textColor = .paleGrey
        dateLabel.backgroundColor = .paleGrey
        horizontalStackView.isHidden = true
    }
    
    public func loadedDataState() {
        titleLabel.textColor = .dark
        titleLabel.backgroundColor = .clear
        subTitleLabel.textColor = .dark
        subTitleLabel.backgroundColor = .clear
        dateLabel.textColor = .charcoalGrey
        dateLabel.backgroundColor = .clear
        horizontalStackView.isHidden = false
    }
    
    func populateTemplateView(_ knowledgeItem: Decodable?) {
        guard let knowledgeItem = knowledgeItem as? KREKnowledgeItem else {
            return
        }
        
        loadedDataState()
        titleLabel.text = knowledgeItem.title
       // subTitleLabel.text = knowledgeItem.desc
        if let desc = knowledgeItem.desc {
                let htmlData = NSString(string: desc).data(using: String.Encoding.utf8.rawValue)
                let font = UIFont.textFont(ofSize: 15.0, weight: .regular)
                let attributes = [NSAttributedString.Key.font: font]
                let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                var attributedString = try! NSMutableAttributedString(data: htmlData!,
                options: options,
                documentAttributes: nil)
            attributedString.addAttributes(attributes, range: (attributedString.string as NSString).range(of: desc)) // some range
            //subTitleLabel.attributedText = markdownParser.parse(desc)
            subTitleLabel.attributedText = attributedString
        }

        if let sharedOn = knowledgeItem.sharedOn {
            let sharedOnInSeconds = Double(truncating: NSNumber(value: sharedOn)) / 1000
            let sharedOnDate = Date(timeIntervalSince1970: sharedOnInSeconds)
            let dateTimeString = sharedOnDate.formatAsDayShort(using: sharedOnDate)
            dateLabel.text = "Modified: " + dateTimeString
        } else if let createdOn = knowledgeItem.createdOn {
            let createdOnInSeconds = Double(truncating: NSNumber(value: createdOn)) / 1000
            let createdOnDate = Date(timeIntervalSince1970: createdOnInSeconds)
            let dateString = createdOnDate.formatAsDayShort(using: createdOnDate)
            dateLabel.text = "Created: " + dateString
        }
        
        if let comments = knowledgeItem.nComments {
            commentCountLabel.text = "\(comments)"
        }
        if let votes = knowledgeItem.nUpVotes {
            likeCountLabel.text = "\(votes)"
        }
        if let downVotes = knowledgeItem.nDownVotes {
            dislikeCountLabel.text = "\(downVotes)"
        }
        if let views = knowledgeItem.nViews {
            spectatorCountLabel.text = "\(views)"
        }
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    func getHTMLString(_ color:UIColor, _ font:UIFont) -> NSAttributedString? {
        do {
            var attribStr =  try NSMutableAttributedString(data: data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
            if attribStr.length <= 0 {
                return nil
            }
            var attribs = attribStr.attributes(at: 0, effectiveRange: nil)
            attribs[NSAttributedString.Key.font] = font
            attribs[NSAttributedString.Key.foregroundColor] = color
            attribStr.setAttributes(attribs, range: NSRange(location: 0, length: attribStr.length))
            return attribStr
        } catch {
            print("error: ", error)
            return nil
        }
    }
}
