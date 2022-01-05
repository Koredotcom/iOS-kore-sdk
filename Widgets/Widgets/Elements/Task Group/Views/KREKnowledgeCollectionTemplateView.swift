//
//  KREKnowledgeCollectionTemplateView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 07/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import MarkdownKit

public class KREKnowledgeCollectionTemplateView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KREKnowledgeCollectionTemplateView.self)
  //  var markdownParser = TSMarkdownParser.standard()
    let markdownParser = MarkdownParser(font: UIFont.textFont(ofSize: 15, weight: .regular))

    public lazy var suggestedStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 7.0
        return stackView
    }()
    
    public lazy var suggestedLabel: UILabel = {
        let suggestedLabel = UILabel(frame: .zero)
        suggestedLabel.font = UIFont.textFont(ofSize: 11.0, weight: .semibold)
        suggestedLabel.numberOfLines = 0
        suggestedLabel.textAlignment = .left
        suggestedLabel.textColor = .squash
        let attributedText = NSMutableAttributedString(string: "SUGGESTED", attributes: [NSAttributedString.Key.font: UIFont.textFont(ofSize: 11.0, weight: .medium), .kern: 1.0])

        suggestedLabel.attributedText = attributedText
        suggestedLabel.translatesAutoresizingMaskIntoConstraints = false
        return suggestedLabel
    }()
    
    var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "suggested")
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .center
        return imageView
    }()
    
    
    public lazy var factsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 7.0
        return stackView
    }()
    
    public lazy var factSuggestedLabel: UILabel = {
        let suggestedLabel = UILabel(frame: .zero)
        suggestedLabel.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        suggestedLabel.numberOfLines = 0
        suggestedLabel.textAlignment = .left
        suggestedLabel.textColor = .battleshipGrey
        suggestedLabel.text = "More facts"
        suggestedLabel.translatesAutoresizingMaskIntoConstraints = false
        return suggestedLabel
    }()
    
    public lazy var matchLabel: UILabel = {
        let suggestedLabel = UILabel(frame: .zero)
        suggestedLabel.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        suggestedLabel.numberOfLines = 0
        suggestedLabel.textAlignment = .right
        suggestedLabel.textColor = .battleshipGrey
        suggestedLabel.text = "91% Match"
        suggestedLabel.translatesAutoresizingMaskIntoConstraints = false
        return suggestedLabel
    }()
    
    
    var factIconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "bullStackFooter")
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .center
        return imageView
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
        textView.contentMode = UIView.ContentMode.topLeft
        textView.linkTextAttributes = [.foregroundColor: UIColor.lightRoyalBlue, .underlineStyle: 1.0]
//        textView.textContainerInset = UIEdgeInsets(top: 0.0, left: -10.0, bottom: 0.0, right: 0.0)
        return textView
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
        let font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        let attributes = [NSAttributedString.Key.font: font]
        iconImageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        suggestedStackView.addArrangedSubview(iconImageView)
        suggestedStackView.addArrangedSubview(suggestedLabel)
        factIconImageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        factIconImageView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        factsStackView.addArrangedSubview(factIconImageView)
        factsStackView.addArrangedSubview(factSuggestedLabel)
        factsStackView.addArrangedSubview(matchLabel)
        stackView.addArrangedSubview(suggestedStackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        stackView.addArrangedSubview(factsStackView)
        addSubview(stackView)
        
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(7.0, after: titleLabel)
            stackView.setCustomSpacing(11.0, after: subTitleLabel)
        }
        
        let views = ["stackView": stackView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[stackView]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13-[stackView]-13-|", options: [], metrics: nil, views: views))
    }
    
    // MARK: -
   public func populateTemplateView(_ knowledgeCollectionItem: Decodable?) {
        guard let knowledgeCollectionItem = knowledgeCollectionItem as? KREKnowledgeCollectionElementData else {
            return
        }
        
        let titleText = NSMutableAttributedString(string: knowledgeCollectionItem.question ?? "", attributes: [NSAttributedString.Key.font: UIFont.textFont(ofSize: 17.0, weight: .medium), .kern: -0.07, NSAttributedString.Key.foregroundColor: UIColor.battleshipGrey])

        titleLabel.attributedText = titleText
        if let answerPayload = knowledgeCollectionItem.answerPayload?.first {
            if let answer = answerPayload.text?.removingPercentEncoding {
                    let htmlData = NSString(string: answer).data(using: String.Encoding.utf8.rawValue)
                    let font = UIFont.textFont(ofSize: 15.0, weight: .regular)
                    let attributes = [NSAttributedString.Key.font: font]
                    let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                    var attributedString = try! NSMutableAttributedString(data: htmlData!,
                    options: options,
                    documentAttributes: nil)
                attributedString.addAttributes(attributes, range: (attributedString.string as NSString).range(of: answer)) // some range
                subTitleLabel.attributedText = markdownParser.parse(answer)
            }
        }
        let attributedText = NSMutableAttributedString(string: knowledgeCollectionItem.name ?? "", attributes: [NSAttributedString.Key.font: UIFont.textFont(ofSize: 11.0, weight: .medium), .kern: 0.09])

        factSuggestedLabel.attributedText = attributedText
        if let score = knowledgeCollectionItem.score {
            let matchAttrtibuted = NSMutableAttributedString(string: "\(score)% Match" ?? "", attributes: [NSAttributedString.Key.font: UIFont.textFont(ofSize: 11.0, weight: .medium), .kern: 0.09])

            matchLabel.attributedText = matchAttrtibuted
        }
    }
}
