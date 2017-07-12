//
//  KRECarouselView.swift
//  Widgets
//
//  Created by anoop on 24/05/17.
//
//

import UIKit

public class KRECarouselView: UIScrollView {
    
    static let cardPadding: CGFloat = 10.0
    static let cardLimit: Int = 10
    public var maxHeight: CGFloat = 0.0
    public var numberOfItems: Int = 0
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isPagingEnabled = true
        self.clipsToBounds = false
        self.backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.showsHorizontalScrollIndicator = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func initializeViewForElements(elements: Array<Any>, maxWidth: CGFloat) {
        let elementsCount: Int = min(elements.count, KRECarouselView.cardLimit)
        var maxHeight: CGFloat = 0.0
        for dictionary in elements  {
            let height = KRECardView.getExpectedHeight(data: dictionary as! NSDictionary, width: maxWidth - KRECarouselView.cardPadding)
            if(height > maxHeight){
                maxHeight = height
            }
        }
        self.maxHeight = maxHeight
        self.numberOfItems = elementsCount
        
        for i in 0..<elementsCount {
            let dictionary = elements[i]
            let frame: CGRect = CGRect(x: 0.0, y: 0.0, width: maxWidth - KRECarouselView.cardPadding, height: maxHeight)
            let view: KRECardView = KRECardView(frame: frame)
            view.setupView(data: dictionary as! NSDictionary, index: i)
            if(i == 0){
                view.isFirst = true
            }
            if(i == elementsCount-1){
                view.isLast = true
            }
            view.optionsAction = {[weak self] (text) in
                if((self?.optionsAction) != nil){
                    self?.optionsAction(text)
                }
            }
            view.linkAction = {[weak self] (text) in
                if(self?.linkAction != nil){
                    self?.linkAction(text)
                }
            }
            self.addCardView(view: view)
        }
    }
    
    func addCardView(view:UIView) {
        var frame = view.frame
        frame.origin.x = self.contentSize.width
        view.frame = frame
        self.addSubview(view)
        self.contentSize = CGSize(width: frame.maxX + KRECarouselView.cardPadding, height: frame.maxY)
    }
    
    public func prepareForReuse() {
        for view in self.subviews{
            view.removeFromSuperview()
        }
        self.contentSize = CGSize.zero
        self.maxHeight = 0.0
    }
}
