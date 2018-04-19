//
//  KREShowFormView.swift
//  Widgets
//
//  Created by Srinivas Vasadi on 20/02/18.
//  Copyright © 2018 Kore. All rights reserved.
//

import UIKit

public struct KAInformation {
    public var title: String?
    public var hashtags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case title, hashtags
    }
}

extension KAInformation: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(hashtags, forKey: .hashtags)
    }
}

extension KAInformation: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        hashtags = try values.decode([String].self, forKey: .hashtags)
    }
}


public struct KAFormAction {
    public var title: String?
    public var type: String?
    public var name: String?
    public var information: KAInformation?
    enum CodingKeys: String, CodingKey {
        case title, type = "action_type", name = "form_name", information = "customData"
    }
}

extension KAFormAction: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(title, forKey: .title)
        } catch {
            print(error.localizedDescription)
        }
        do {
            try container.encode(type, forKey: .type)
        } catch {
            print(error.localizedDescription)
        }
        do {
            try container.encode(name, forKey: .name)
        } catch {
            print(error.localizedDescription)
        }
        do {
            try container.encode(information, forKey: .information)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func truncateString(_ string: String, count: Int) -> String{
        var tmpString = string
        if (tmpString.characters.count > count){
            tmpString = tmpString.substring(to: tmpString.index(tmpString.startIndex, offsetBy: count))
        }
        return tmpString
    }
}

extension KAFormAction: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            title = try values.decode(String.self, forKey: .title)
        } catch {
            print(error.localizedDescription)
        }
        do {
            type = try values.decode(String.self, forKey: .type)
        } catch {
            print(error.localizedDescription)
        }
        do {
            name = try values.decode(String.self, forKey: .name)
        } catch {
            print(error.localizedDescription)
        }
        do {
            information = try values.decode(KAInformation.self, forKey: .information)
        } catch {
            print(error.localizedDescription)
        }
    }
}
open class FormData {
    public var workingHrs : Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    public convenience init(_ data: NSDictionary){
        print(data)
        self.init()
        let formAction: Array<Dictionary<String, Any>> = data["form_actions"] != nil ? data["form_actions"] as! Array<Dictionary<String, Any>> : []
        print(formAction)
        let first = formAction.first
        let customData: Dictionary<String, Any> = first!["customData"] != nil ? first!["customData"] as! Dictionary<String, Any> : [:]
        print(customData)
        workingHrs = customData["working_hours"] != nil ?customData["working_hours"] as! Array<Dictionary<String, Any>> : []
        print(workingHrs)
    }
}

public class KAFormActionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var formActionList: [KAFormAction]!
    var collectionView: KRECollectionView! = nil
    var flowLayout:UICollectionViewFlowLayout! = nil
    var prototypeCell: KRETokenCollectionViewCell! = nil
    public var formActionHandler: ((_ formAction: KAFormAction?) -> Void)!
    
    let cellHeight: CGFloat = 40
    // MARK:- init
    override init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    //MARK:- removing refernces to elements
    public func prepareForDeinit(){
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
    }
    
    // MARK:- setup collectionView
    func setup() {
        self.backgroundColor = UIColor.clear
        formActionList = [KAFormAction]()
        prototypeCell = KRETokenCollectionViewCell()
        
        // configure layout
        flowLayout = KACenterAlignedCollectionViewFlowLayout()
        flowLayout.itemSize = CGSize.zero
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 8.0
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        
        // collectionView initialization
        collectionView = KRECollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        self.addSubview(collectionView)
        
        // register
        self.collectionView.register(KRETokenCollectionViewCell.self, forCellWithReuseIdentifier: "KRETokenCollectionViewCell")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let views = ["collectionView":collectionView!]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options:[], metrics:nil, views:views))
    }
    
    public func setFormActionsList(actions: Array<KAFormAction>) {
        self.formActionList = actions
        self.collectionView.reloadData()
    }
    
    // MARK:- datasource
    @nonobjc public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.formActionList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KRETokenCollectionViewCell", for: indexPath) as! KRETokenCollectionViewCell
        let formAction = formActionList[(indexPath as NSIndexPath).row]
        cell.labelText = formAction.title
        cell.krefocused = false
        cell.layoutIfNeeded()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: KRETokenCollectionViewCell = collectionView.cellForItem(at: indexPath) as! KRETokenCollectionViewCell
        if (self.formActionHandler != nil){
            let formAction = formActionList[(indexPath as NSIndexPath).row]
            self.formActionHandler(formAction)
        }
        cell.krefocused = false
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let formAction = formActionList[(indexPath as NSIndexPath).row]
        let widthForItem: CGFloat = self.prototypeCell.widthForCell(string: formAction.title!, withImage: false, height: cellHeight)
        return CGSize(width: min(self.maxContentWidth(), widthForItem), height: cellHeight)
    }
    
    func maxContentWidth() -> CGFloat {
        let collectionViewLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
        return self.frame.size.width - sectionInset.left - sectionInset.right;
    }
    
    deinit {
        self.formActionList = nil
        self.collectionView = nil
        self.flowLayout = nil
        self.prototypeCell = nil
    }
}

class KACenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
        
        let leftPadding: CGFloat = 8
        let interItemSpacing = minimumInteritemSpacing
        
        var leftMargin: CGFloat = leftPadding
        var maxY: CGFloat = -1.0
        var rowSizes: [[CGFloat]] = []
        var currentRow: Int = 0
        attributes.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = leftPadding
                if rowSizes.count == 0 {
                    rowSizes = [[leftMargin, 0]]
                } else {
                    rowSizes.append([leftMargin, 0])
                    currentRow += 1
                }
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
            rowSizes[currentRow][1] = leftMargin - interItemSpacing
        }
        
        leftMargin = leftPadding
        maxY = -1.0
        currentRow = 0
        attributes.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = leftPadding
                let rowWidth = rowSizes[currentRow][1] - rowSizes[currentRow][0] // last.x - first.x
                let appendedMargin = (collectionView!.frame.width - leftPadding  - rowWidth - leftPadding) / 2
                leftMargin += appendedMargin
                currentRow += 1
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + interItemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}

