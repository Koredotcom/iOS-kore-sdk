//
//  StackedCarouselBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 03/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class StackedCarouselBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var cardView: UIView!
    var maskview: UIView!
    var collectionView: UICollectionView!
    let customCellIdentifier = "StackedCarouselCell"
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth
    let kMinTextWidth: CGFloat = 20.0
    var arrayOfCarousels = [ComponentElements]()
    
    //public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    //public var linkAction: ((_ text: String?) -> Void)!
    
    let xLoop = 50
    
    var btnsHeight = 40.0
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        createCollectionView()
    }
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor.clear.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.clear
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
    }
    
    func createCollectionView(){

        let wiidth = UIScreen.main.bounds.size.width
        let withOutBtnsHeight = 175.0
        let layout = ZoomAndSnapFlowLayout(itemSize: CGSize(width: wiidth / 1.8, height: withOutBtnsHeight + btnsHeight))
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.cardView.addSubview(self.collectionView)
        
        if let xib = Bundle.xib(named: "StackedCarouselCell") {
            self.collectionView.register(xib, forCellWithReuseIdentifier: customCellIdentifier)
        }
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["collectionView": collectionView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[collectionView]-2-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                      let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                self.arrayOfCarousels = allItems.elements ?? []
                var arrayBtnsCount = [Int]()
                for i in 0..<arrayOfCarousels.count{
                    let btns = arrayOfCarousels[i]
                    arrayBtnsCount.append(btns.buttons?.count ?? 0)
                }
                let maxNofBtns = arrayBtnsCount.max()
                btnsHeight = CGFloat(maxNofBtns ?? 0) * 40.0
                self.collectionView.reloadData()
                if self.arrayOfCarousels.count > 1{
                    self.collectionView.scrollToItem(at: NSIndexPath.init(item: 1, section: 0) as IndexPath, at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        let withOutBtnsHeight = 250.0
        return CGSize(width: 0.0, height: withOutBtnsHeight + btnsHeight)
    }
    
   
}
extension StackedCarouselBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCarousels.count*xLoop
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! StackedCarouselCell
        cell.layer.cornerRadius = 5.0
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.lightGray.cgColor
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

        return cell
    }
    func arrayIndexForRow(_ row : Int)-> Int {
        return row % arrayOfCarousels.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 15.0, bottom: 5.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func scrollToMiddle(atIndex: Int, animated: Bool = true) {
        let middleIndex = atIndex + xLoop*arrayOfCarousels.count/2
        collectionView.scrollToItem(at: IndexPath(item: middleIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
}

extension StackedCarouselBubbleView : StackedCarouselCellDelegate{
    func stackedButtonActionText(text: String, payload: String) {
        self.optionsAction?(text, payload)
    }
    func stackedButtonActionUrl(text: String) {
        self.linkAction?(text)
    }
}
