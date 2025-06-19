//
//  KreStackedCarouselBubbleView.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 05/05/25.
//


import UIKit

public class KreStackedCarousel: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    //var collectionView: UICollectionView!
    let customCellIdentifier = "StackedCarouselCell"
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth
    let kMinTextWidth: CGFloat = 20.0
    var arrayOfCarousels = [ComponentElements]()
    let xLoop = 50
    var btnsHeight = 40.0
    public var maxCardHeight: CGFloat = 0.0
    public var maxCardWidth: CGFloat = 0.0
    public var numberOfItems: Int = 0
    public var pageIndex = 0
    var shouldScrollInitially = true
    var isImageIsAvailable = true
    
    public var cards: [ComponentElements] = [ComponentElements]() {
        didSet {
            self.numberOfItems = min(cards.count, KRECarouselView.cardLimit)
            var maxHeight: CGFloat = 0.0
            self.arrayOfCarousels = cards ?? []
            var arrayBtnsCount = [Int]()
            for i in 0..<self.numberOfItems {
                let cardInfo = cards[i]
                let height = getExpectedHeight(cardInfo: cardInfo, width: maxCardWidth - KRECarouselView.cardPadding)
                if height > maxHeight {
                    maxHeight = height
                }
                arrayBtnsCount.append(cardInfo.buttons?.count ?? 0)
            }
            let maxNofBtns = arrayBtnsCount.max()
            btnsHeight = CGFloat(maxNofBtns ?? 0) * 40.0
            self.maxCardHeight = maxHeight + btnsHeight
            self.reloadData()
        }
    }
    
    public var optionsAction: ((_ title: String?, _ payload: String?) -> Void)?
    public var linkAction: ((_ text: String?) -> Void)?
   
    // MARK: - init
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience init () {
        let wiidth = UIScreen.main.bounds.size.width
        let withOutBtnsHeight = 175.0 + 40.0
        let layout = ZoomAndSnapFlowLayout(itemSize: CGSize(width: wiidth / 1.8, height: withOutBtnsHeight))
        layout.scrollDirection = .horizontal
        self.init(frame: CGRect.zero, collectionViewLayout: layout)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = .clear
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.bounces = false
        self.isScrollEnabled = true
        
        if let xib = Bundle.xib(named: "StackedCarouselCell") {
            self.register(xib, forCellWithReuseIdentifier: customCellIdentifier)
        }
    
    }
    
    func updateItemHeight(to newHeight: CGFloat) {
        let newWidth = UIScreen.main.bounds.size.width / 1.8

        if let layout = self.collectionViewLayout as? ZoomAndSnapFlowLayout {
            layout.itemSize = CGSize(width: newWidth, height: newHeight)
            layout.invalidateLayout()
            self.collectionViewLayout.invalidateLayout()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure it's only done once if needed
        if shouldScrollInitially {
            shouldScrollInitially = false
            if self.arrayOfCarousels.count > 1{
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: 1, section: 0)
                    self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    // MARK:- datasource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! StackedCarouselCell
        cell.layer.cornerRadius = 5.0
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = BubbleViewLeftTint.cgColor
        cell.clipsToBounds = true
        let arrayIndex = arrayIndexForRow(indexPath.row)
        let elements = arrayOfCarousels[arrayIndex]
        
        cell.titleLbl.text = elements.topSection?.title
        cell.descLbl.text = elements.middleSection?.descrip
        cell.bottomTitleLbl.text = elements.bottomSection?.title
        cell.bottomDescLbl.text = elements.bottomSection?.descrip
        cell.configure(with: elements.buttons ?? [])
        cell.viewDelegate = self
        
        cell.titleLbl.textColor = BubbleViewBotChatTextColor
        cell.descLbl.textColor = BubbleViewBotChatTextColor
        cell.bottomTitleLbl.textColor = BubbleViewBotChatTextColor
        cell.bottomDescLbl.textColor = BubbleViewBotChatTextColor
        if let urlstr = elements.topSection?.image_url, let url = URL(string: urlstr){
            cell.imageVHeightConstraint.constant = 90.0
            cell.imagV.af.setImage(withURL: url, placeholderImage:  UIImage(named: "placeholder_image", in: bundle, compatibleWith: nil))
        }else{
            cell.imageVHeightConstraint.constant = 10.0
            cell.imagV.image = nil
        }
        return cell
    }
    func arrayIndexForRow(_ row : Int)-> Int {
        return row % arrayOfCarousels.count
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 15.0, bottom: 5.0, right: 15.0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func scrollToMiddle(atIndex: Int, animated: Bool = true) {
        let middleIndex = atIndex + xLoop*arrayOfCarousels.count/2
        self.scrollToItem(at: IndexPath(item: middleIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
    public func prepareForReuse() {
        self.cards.removeAll()
        self.reloadData()
        self.pageIndex = 0
    }
    
    // MARK: - expected height of KRECard
    public func getExpectedHeight(cardInfo: ComponentElements, width: CGFloat) -> CGFloat {
        var height: CGFloat = 140.0
        var imageVHeight = 0.0
        if let urlstr = cardInfo.topSection?.image_url, let url = URL(string: urlstr){
            imageVHeight = 90.0
        }
        return height + imageVHeight
    }
}
extension KreStackedCarousel : StackedCarouselCellDelegate{
    func stackedButtonActionText(text: String, payload: String) {
        self.optionsAction?(text, payload)
    }
    func stackedButtonActionUrl(text: String) {
        self.linkAction?(text)
    }
}
