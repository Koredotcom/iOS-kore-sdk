//
//  QuickReplyCollectionViewFlowLayout.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/20/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import Foundation
import UIKit

class Row {
    var attributes = [UICollectionViewLayoutAttributes]()
    var spacing: CGFloat = 0

    init(spacing: CGFloat) {
        self.spacing = spacing
    }

    func add(attribute: UICollectionViewLayoutAttributes) {
        attributes.append(attribute)
    }

    func tagLayout(collectionViewWidth: CGFloat, isRTL: Bool) {
        let padding = 10
        if isRTL {
            var offset = Int(collectionViewWidth) - padding
            for attribute in attributes {
                offset -= Int(attribute.frame.width)
                attribute.frame.origin.x = CGFloat(offset)
                offset -= Int(spacing)
            }
        } else {
            var offset = padding
            for attribute in attributes {
                attribute.frame.origin.x = CGFloat(offset)
                offset += Int(attribute.frame.width + spacing)
            }
        }
    }
}

class TagFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        var rows = [Row]()
        var currentRowY: CGFloat = -1

        for attribute in attributes {
            if currentRowY != attribute.frame.origin.y {
                currentRowY = attribute.frame.origin.y
                rows.append(Row(spacing: 10))
            }
            rows.last?.add(attribute: attribute)
        }

        // Follow this collection view's direction, not the global SDK flag, so
        // screens that keep LTR content (e.g. welcome grid) stay left-aligned.
        let isRTL = collectionView?.effectiveUserInterfaceLayoutDirection == .rightToLeft
        rows.forEach {
            $0.tagLayout(
                collectionViewWidth: collectionView?.frame.width ?? 0,
                isRTL: isRTL
            )
        }
        return rows.flatMap { $0.attributes }
    }
}
