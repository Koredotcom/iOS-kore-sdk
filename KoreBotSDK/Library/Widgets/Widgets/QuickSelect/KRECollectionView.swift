//
//  KRECollectionView.swift
//  Widgets
//
//  Created by Srinivas Vasadi on 16/11/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

public class KRECollectionView: UICollectionView {


}

class KRECollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
