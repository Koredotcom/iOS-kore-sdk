//
//  KREIdentityImageView.swift
//  KoreApp
//
//  Created by Srinivas Vasadi on 27/08/18.
//  Copyright © 2018 Kore Inc. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import ChatBotObjc

public class KREIdentity: NSObject {
    // MARK: -
    public var initials: String?
    public var color: String?
    public var placeholder: Bool = true
    public var imageUrl: String?
    public var server: String?
    public var userId: String?
    public var image: UIImage?
    public var icon: String?
    public var font: UIFont?
    public var placeHolderImage: UIImage?
    public var contentMode: UIImageView.ContentMode = .scaleAspectFit
}

@objc protocol KREIdentityImageViewDelegate: class {
    func profileImageView(_ profileImageView: KREIdentityImageView, profileImage: UIImage?)
    func profileImageClicked(_ profileImageView: KREIdentityImageView)
}

public class KREIdentityImageView: UIImageView {
    // MARK: - properties
    let bundle = Bundle(for: KREIdentityImageView.self)
    weak var profileImageDelegate: KREIdentityImageViewDelegate?
    public lazy var userInitial: UILabel = {
        let label = UILabel(frame: .zero)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()
    public lazy var overlayImageView: UIImageView = {
        let overlayImageView = UIImageView(frame: .zero)
        overlayImageView.backgroundColor = UIColor.clear
        overlayImageView.layer.masksToBounds = true
        overlayImageView.contentMode = .center
        return overlayImageView
    }()
    public lazy var previewButton: UIButton = {
        let previewButton = UIButton(frame: .zero)
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        return previewButton
    }()
    
    private var identity: KREIdentity?
    private var userInitialString: String?
    public var font: UIFont?

    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    private func initialize() {
        previewButton.addTarget(self, action: #selector(previewButtonClick(_:)), for: .touchUpInside)
        addSubview(previewButton)
        
        addSubview(userInitial)

        bringSubviewToFront(userInitial)
        bringSubviewToFront(previewButton)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let fontSize = bounds.size.width / 2
        if let font = identity?.font {
            userInitial.font = font
        } else {
            userInitial.font = UIFont.textFont(ofSize: fontSize, weight: UIFont.Weight.light)
        }

        userInitial.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        
        layer.cornerRadius = bounds.size.height / 2
        layer.masksToBounds = true
        contentMode = .scaleAspectFill

        // calculate size of the overlay image
        // It is a percentage of a rectangle inscribed inside the circle
        let width: CGFloat = bounds.size.width
        
        let a: CGFloat = width / 2
        let b: CGFloat = width / 2
        let c: CGFloat = sqrt(a * a + b * b) * 0.9 // 90% size of a full inscribed rectangle
        
        let x: CGFloat = (width / 2) - (c / 2)
        let y: CGFloat = (width / 2) - (c / 2)
        
        overlayImageView.frame = CGRect(x: x, y: y, width: c, height: c)
    }
    
    public func drawInitials(_ initials: String?, with color: Any?) {
        image = nil
        
        userInitialString = initials?.uppercased()
        userInitial.isHidden = false
        userInitial.text = userInitialString
        
        identity = nil
        
        if let color = color as? UIColor {
            backgroundColor = color
        } else if let color = color as? String {
            backgroundColor = UIColor(hexString: color)
        } else {
            backgroundColor = UIColor.contactGrey
        }

        setNeedsLayout()
    }
    
    public func clearOverlayImage() {
        overlayImageView.removeFromSuperview()
    }
    
    public func drawOverlayImage(_ image: UIImage, with color: Any?) {
        overlayImageView.isHidden = false
        overlayImageView.image = image
        
        userInitialString = nil
        userInitial.isHidden = true
        
        identity = nil
        
        if let color = color as? UIColor {
            backgroundColor = color
        } else if let color = color as? String {
            backgroundColor = UIColor(hexString: color)
        } else {
            backgroundColor = UIColor(hex: 0xADBFC3)
        }
    }
    
    @objc func previewButtonClick(_ sender: UIButton) {
        profileImageDelegate?.profileImageClicked(self)
    }
}

// MARK: - profile image loading
extension KREIdentityImageView {
    // MARK: - profile image loading
    public func setProfileImage(for identity: KREIdentity, initials: Bool) {
        if identity.placeholder {
            var placeholderImage:UIImage?
            if identity.placeHolderImage != nil {
                placeholderImage = identity.placeHolderImage
            }
            else {
                placeholderImage = UIImage(named: "profileImage", in: bundle, compatibleWith: nil)
            }
            setProfileImage(for: identity, initials: initials, rounded: true, placeholderImage: placeholderImage)
        } else {
            setProfileImage(for: identity, initials: initials, rounded: true, placeholderImage: nil)
        }
    }

    public func setProfileImage(for identity: KREIdentity, initials: Bool, rounded: Bool, placeholderImage: UIImage?, completion block: ((UIImage?) -> Void)? = nil) {
        
        resetProfileImage()
        
        self.image = nil
        setNeedsDisplay()
        backgroundColor = .clear

        let profileIcon = identity.icon ?? "no-avatar"
        switch profileIcon {
        case "profile.png":
            if let profileImage = identity.image {
                contentMode = identity.contentMode
                image = profileImage
            } else if let url = getImageUrl(for: identity) {
                contentMode = identity.contentMode
                af.setImage(withURL: url, placeholderImage: placeholderImage)
            }
        default:
            if let urlString = identity.imageUrl, let url = URL(string: urlString) {
                contentMode = identity.contentMode
                af.setImage(withURL: url, placeholderImage: placeholderImage)
            } else if let iconImage = identity.image {
                contentMode = identity.contentMode
                image = iconImage
            } else if let profileInitials = identity.initials as? String, initials, let profileColor = identity.color as? String  {
                drawInitials(profileInitials, with: profileColor)
            }
        }
        
        if rounded == true {
            layer.cornerRadius = bounds.size.height / 2
            layer.borderColor = UIColor.lightGray.cgColor
            layer.borderWidth = 0.5
            layer.masksToBounds = true
        } else {
            layer.cornerRadius = 0
            layer.masksToBounds = true
        }
        
        if let color = identity.color as? String {
            backgroundColor = UIColor(hexString: color)
        } else {
            backgroundColor = UIColor.clear
        }
        
        self.identity = identity
    }
        
    public func getImageUrl(for identity: KREIdentity) -> URL? {
        guard let userId = identity.userId, let server = identity.server as? String else {
            return nil
        }
        
        let PROFILE_IMAGE_SIZE_LARGE = 128
        let imageName = String(format: "d_%dx%d_profile.png", PROFILE_IMAGE_SIZE_LARGE, PROFILE_IMAGE_SIZE_LARGE)
        let urlString = String(format: "%@api/1.1/getMediaStream/profilePictures/%@/%@", server, userId, imageName)
        return URL(string: urlString)
    }
        
    public func resetProfileImage() {
        userInitial.text = nil
        userInitial.isHidden = true
//        cancelImageDownloadTask()
        image = nil
        backgroundColor = UIColor.clear
        clearOverlayImage()
    }
}
