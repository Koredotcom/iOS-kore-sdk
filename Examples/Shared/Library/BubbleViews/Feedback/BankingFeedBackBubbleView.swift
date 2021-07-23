//
//  BankingFeedBackBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 12/07/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class BankingFeedBackBubbleView: BubbleView, UITextViewDelegate {
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var experienceTableView: UITableView!
    var feedbackTableView: UITableView!
    fileprivate let listCellIdentifier = "MultiSelectCell"
    var experienceFeebackArray = [ExperienceFeedback]()
    var feebackListArray = [FeedbackList]()
    var buttonsArray = [ComponentItemAction]()
    var experienceCheckArray = NSMutableArray()
    var feedbackCheckArray = NSMutableArray()
    
     var selectedExperienceArray = [ExperienceFeedback]()
     var selectedFeedbackArray = [FeedbackList]()
    
    var maskview: UIView!
    var titleLbl: UILabel!
    var optionTitleLbl: UILabel!
    var topUnderLineLbl: UILabel!
    var descLbl: UILabel!
    var descriptionPlaceholderLbl: UILabel!
    var bottomUnderLineLbl: UILabel!
    var descriptionTxtV: UITextView!
    var buttonsCollectionV: UICollectionView!
    var expTabVHeightConstraint: NSLayoutConstraint!
    var feedbackTabVHeightConstraint: NSLayoutConstraint!
    var buttonsCollVHeightConstraint: NSLayoutConstraint!
     var descLblHeightConstraint: NSLayoutConstraint!
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
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
        // UserDefaults.standard.set(false, forKey: "SliderKey")
        intializeCardLayout()
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
        self.titleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.titleLbl)
        self.titleLbl.adjustsFontSizeToFitWidth = true
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.layer.cornerRadius = 6.0
        self.titleLbl.clipsToBounds = true
        self.titleLbl.sizeToFit()
        
        experienceTableView = UITableView(frame: CGRect.zero,style:.plain)
        experienceTableView.translatesAutoresizingMaskIntoConstraints = false
        experienceTableView.dataSource = self
        experienceTableView.delegate = self
        experienceTableView.layer.cornerRadius = 5.0
        experienceTableView.backgroundColor = .white
        experienceTableView.showsHorizontalScrollIndicator = false
        experienceTableView.showsVerticalScrollIndicator = false
        experienceTableView.bounces = false
        experienceTableView.separatorStyle = .none
        self.cardView.addSubview(self.experienceTableView)
        experienceTableView.isScrollEnabled = false
        self.experienceTableView.register(UINib(nibName: listCellIdentifier, bundle: nil), forCellReuseIdentifier: listCellIdentifier)
        
        topUnderLineLbl = UILabel(frame: CGRect.zero)
        topUnderLineLbl.textColor = Common.UIColorRGB(0x484848)
        topUnderLineLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        topUnderLineLbl.numberOfLines = 0
        topUnderLineLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        topUnderLineLbl.isUserInteractionEnabled = true
        topUnderLineLbl.contentMode = UIView.ContentMode.topLeft
        topUnderLineLbl.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(self.topUnderLineLbl)
        topUnderLineLbl.adjustsFontSizeToFitWidth = true
        topUnderLineLbl.backgroundColor = .lightGray
        topUnderLineLbl.layer.cornerRadius = 6.0
        topUnderLineLbl.clipsToBounds = true
        topUnderLineLbl.sizeToFit()
        
        self.descLbl = UILabel(frame: CGRect.zero)
        self.descLbl.textColor = BubbleViewBotChatTextColor
        self.descLbl.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.descLbl.numberOfLines = 0
        self.descLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.descLbl.isUserInteractionEnabled = true
        self.descLbl.contentMode = UIView.ContentMode.topLeft
        self.descLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.descLbl)
        self.descLbl.adjustsFontSizeToFitWidth = true
        self.descLbl.backgroundColor = .clear
        self.descLbl.layer.cornerRadius = 6.0
        self.descLbl.clipsToBounds = true
        self.descLbl.sizeToFit()
        
        bottomUnderLineLbl = UILabel(frame: CGRect.zero)
        bottomUnderLineLbl.textColor = Common.UIColorRGB(0x484848)
        bottomUnderLineLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        bottomUnderLineLbl.numberOfLines = 0
        bottomUnderLineLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        bottomUnderLineLbl.isUserInteractionEnabled = true
        bottomUnderLineLbl.contentMode = UIView.ContentMode.topLeft
        bottomUnderLineLbl.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(self.bottomUnderLineLbl)
        bottomUnderLineLbl.adjustsFontSizeToFitWidth = true
        bottomUnderLineLbl.backgroundColor = .lightGray
        bottomUnderLineLbl.layer.cornerRadius = 6.0
        bottomUnderLineLbl.clipsToBounds = true
        bottomUnderLineLbl.sizeToFit()
        
        
        feedbackTableView = UITableView(frame: CGRect.zero,style:.plain)
        feedbackTableView.translatesAutoresizingMaskIntoConstraints = false
        feedbackTableView.dataSource = self
        feedbackTableView.delegate = self
        feedbackTableView.layer.cornerRadius = 5.0
        feedbackTableView.backgroundColor = .white
        feedbackTableView.showsHorizontalScrollIndicator = false
        feedbackTableView.showsVerticalScrollIndicator = false
        feedbackTableView.bounces = false
        feedbackTableView.separatorStyle = .none
        self.cardView.addSubview(self.feedbackTableView)
        feedbackTableView.isScrollEnabled = false
        self.feedbackTableView.register(UINib(nibName: listCellIdentifier, bundle: nil), forCellReuseIdentifier: listCellIdentifier)
        
        self.optionTitleLbl = UILabel(frame: CGRect.zero)
        self.optionTitleLbl.textColor = Common.UIColorRGB(0x484848)
        self.optionTitleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        self.optionTitleLbl.numberOfLines = 0
        self.optionTitleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.optionTitleLbl.isUserInteractionEnabled = true
        self.optionTitleLbl.contentMode = UIView.ContentMode.topLeft
        self.optionTitleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.optionTitleLbl)
        self.optionTitleLbl.adjustsFontSizeToFitWidth = true
        self.optionTitleLbl.backgroundColor = .clear
        self.optionTitleLbl.layer.cornerRadius = 6.0
        self.optionTitleLbl.clipsToBounds = true
        self.optionTitleLbl.sizeToFit()
        
        self.descriptionTxtV = UITextView(frame: CGRect.zero)
        self.descriptionTxtV.delegate = self
        self.descriptionTxtV.textColor = Common.UIColorRGB(0x484848)
        self.descriptionTxtV.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        self.descriptionTxtV.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionTxtV.backgroundColor = .white
        self.descriptionTxtV.layer.cornerRadius = 6.0
        self.descriptionTxtV.layer.borderWidth = 1.0
        self.descriptionTxtV.layer.borderColor = UIColor.lightGray.cgColor
        self.descriptionTxtV.clipsToBounds = true
        self.cardView.addSubview(self.descriptionTxtV)
        
        self.descriptionPlaceholderLbl = UILabel(frame: CGRect.zero)
        self.descriptionPlaceholderLbl.text = "Add Suggestions"
        self.descriptionPlaceholderLbl.textColor = .lightGray
        self.descriptionPlaceholderLbl.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        self.descriptionPlaceholderLbl.numberOfLines = 0
        self.descriptionPlaceholderLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.descriptionPlaceholderLbl.isUserInteractionEnabled = true
        self.descriptionPlaceholderLbl.contentMode = UIView.ContentMode.topLeft
        self.descriptionPlaceholderLbl.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.descriptionPlaceholderLbl)
        self.descriptionPlaceholderLbl.adjustsFontSizeToFitWidth = true
        self.descriptionPlaceholderLbl.backgroundColor = .clear
        self.descriptionPlaceholderLbl.layer.cornerRadius = 6.0
        self.descriptionPlaceholderLbl.clipsToBounds = true
        self.descriptionPlaceholderLbl.sizeToFit()
        
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 1.0, height: 1.0)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 0.0)
        
        // collectionView initialization
        buttonsCollectionV = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        buttonsCollectionV.translatesAutoresizingMaskIntoConstraints = false
        buttonsCollectionV.backgroundColor = UIColor.clear
        buttonsCollectionV.bounces = true
        buttonsCollectionV.alwaysBounceHorizontal = true
        buttonsCollectionV.clipsToBounds = false
        buttonsCollectionV.showsHorizontalScrollIndicator = false
        buttonsCollectionV.showsVerticalScrollIndicator = false
        buttonsCollectionV.dataSource = self
        buttonsCollectionV.delegate = self
        self.cardView.addSubview(buttonsCollectionV)
        self.buttonsCollectionV.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil),
        forCellWithReuseIdentifier: "CustomCollectionViewCell")
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        
        
        let views: [String: UIView] = ["titleLbl": titleLbl, "experienceTableView" : experienceTableView, "topUnderLineLbl":topUnderLineLbl, "descLbl": descLbl, "bottomUnderLineLbl": bottomUnderLineLbl, "feedbackTableView": feedbackTableView, "optionTitleLbl": optionTitleLbl, "descriptionTxtV": descriptionTxtV, "descriptionPlaceholderLbl": descriptionPlaceholderLbl, "buttonsCollectionV": buttonsCollectionV, "maskview": maskview]
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[titleLbl(>=31)]-5-[experienceTableView]-5-[topUnderLineLbl(1)]-5-[descLbl]-5-[bottomUnderLineLbl(1)]-5-[optionTitleLbl(>=31)]-5-[feedbackTableView]-5-[descriptionTxtV(80)]-5-[buttonsCollectionV]", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[feedbackTableView]-10-[descriptionPlaceholderLbl]", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[experienceTableView]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[topUnderLineLbl]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[descLbl]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[bottomUnderLineLbl]-10-|", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[optionTitleLbl]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[feedbackTableView]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[descriptionTxtV]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[buttonsCollectionV]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[descriptionPlaceholderLbl]-10-|", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        
        self.expTabVHeightConstraint = NSLayoutConstraint.init(item: experienceTableView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(self.expTabVHeightConstraint)
        
        self.feedbackTabVHeightConstraint = NSLayoutConstraint.init(item: feedbackTableView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(self.feedbackTabVHeightConstraint)
        
        self.buttonsCollVHeightConstraint = NSLayoutConstraint.init(item: buttonsCollectionV as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
               self.cardView.addConstraint(self.buttonsCollVHeightConstraint)
        
        self.descLblHeightConstraint = NSLayoutConstraint.init(item: descLbl as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(self.descLblHeightConstraint)
    }
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.backgroundColor = BubbleViewLeftTint
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        
    }
    
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
                self.titleLbl.text = allItems.heading ?? ""
                self.optionTitleLbl.text = allItems.feedbackListHeading ?? ""
                experienceFeebackArray = allItems.experienceFeedback ?? []
                feebackListArray = allItems.feedbackList ?? []
                buttonsArray = allItems.buttons ?? []
                experienceCheckArray = []
                selectedExperienceArray = []
                for i in 0 ..< experienceFeebackArray.count{
                    if i == 0{
                        self.descLbl.text = experienceFeebackArray[0].empathyMessage
                        selectedExperienceArray.append(experienceFeebackArray[0])
                        experienceCheckArray.add("check")
                    }else{
                        experienceCheckArray.add("uncheck")
                    }
                }
                experienceTableView.reloadData()
                feedbackCheckArray = []
                for _ in 0 ..< feebackListArray.count{
                    feedbackCheckArray.add("uncheck")
                }
                feedbackTableView.reloadData()
                buttonsCollectionV.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        
        var optionTextSize: CGSize = self.optionTitleLbl.sizeThatFits(limitingSize)
        if optionTextSize.height < self.optionTitleLbl.font.pointSize {
            optionTextSize.height = self.optionTitleLbl.font.pointSize
        }
        
        var descTextSize: CGSize = self.descLbl.sizeThatFits(limitingSize)
        if descTextSize.height < self.descLbl.font.pointSize {
            descTextSize.height = self.descLbl.font.pointSize
        }
        descLblHeightConstraint.constant = descTextSize.height
        
        var expCellHeight = 0
        for _ in 0 ..< experienceFeebackArray.count{
            expCellHeight += 44
        }
        expTabVHeightConstraint.constant = CGFloat(expCellHeight)
        
        var feedbackCellHeight = 0
        for _ in 0 ..< feebackListArray.count{
            feedbackCellHeight += 44
        }
        feedbackTabVHeightConstraint.constant = CGFloat(feedbackCellHeight)
        
        let buttonsHeight = buttonsArray.count > 0 ? 40 : 0
        buttonsCollVHeightConstraint.constant = CGFloat(buttonsHeight)
        
        return CGSize(width: 0.0, height: textSize.height + descTextSize.height + optionTextSize.height + CGFloat(expCellHeight) + CGFloat(feedbackCellHeight) + 125 + CGFloat(buttonsHeight) + 40)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLbl.isHidden = !textView.text.isEmpty
    }
    
}

extension BankingFeedBackBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == experienceTableView{
            return experienceFeebackArray.count
        }
        return feebackListArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == experienceTableView{
            let cell : MultiSelectCell = self.experienceTableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! MultiSelectCell
            cell.backgroundColor = UIColor.clear
            let expFeedback = experienceFeebackArray[indexPath.row]
            cell.titleLabel.text = expFeedback.id
            if experienceCheckArray[indexPath.row] as! String == "uncheck" {
                cell.checkImage.image = UIImage.init(named: "circle")
            }else{
                cell.checkImage.image = UIImage.init(named: "dot-circle")
            }
            cell.selectionStyle = .none
            return cell
        }else{
            let cell : MultiSelectCell = self.feedbackTableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! MultiSelectCell
            cell.backgroundColor = UIColor.clear
            let feedback = feebackListArray[indexPath.row]
            cell.titleLabel.text = feedback.id
            if feedbackCheckArray[indexPath.row] as! String == "uncheck" {
                cell.checkImage.image = UIImage.init(named: "uncheck")
            }else{
                cell.checkImage.image = UIImage.init(named: "check")
            }
            cell.selectionStyle = .none
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        descriptionTxtV.resignFirstResponder()
        
        if tableView == experienceTableView{
            self.descLbl.text = experienceFeebackArray[indexPath.row].empathyMessage
            selectedExperienceArray = []
            for i in 0 ..< experienceFeebackArray.count{
                if indexPath.row == i{
                    selectedExperienceArray.append(experienceFeebackArray[indexPath.row])
                    experienceCheckArray.replaceObject(at: indexPath.row, with: "check")
                }else{
                    experienceCheckArray.replaceObject(at: i, with: "uncheck")
                }
            }
            experienceTableView.reloadData()
        }else{
            if feedbackCheckArray[indexPath.row] as! String == "uncheck"{
                feedbackCheckArray.replaceObject(at: indexPath.row, with: "check")
                selectedFeedbackArray.append(feebackListArray[indexPath.row])
            }else{
                feedbackCheckArray.replaceObject(at: indexPath.row, with: "uncheck")
                var matchIndex:Int?
                for i in 0 ..< selectedFeedbackArray.count{
                    if feebackListArray[indexPath.row].id ==  selectedFeedbackArray[i].id {
                        matchIndex = i
                    }
                }
                
                if matchIndex != nil {
                    selectedFeedbackArray.remove(at: matchIndex!)
                }
            }
            feedbackTableView.reloadData()
        }
    }
}

extension BankingFeedBackBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        cell.backgroundColor = .clear
        let elements = buttonsArray[indexPath.row]
        cell.textLabel.text = elements.label
        cell.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)!
        cell.textLabel.textAlignment = .center
        cell.textLabel.textColor = bubbleViewBotChatButtonBgColor
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.backgroundColor = bubbleViewBotChatButtonTextColor
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 10.0
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.maskview.isHidden = false
        if buttonsArray[indexPath.row].label == "Cancel" {
            self.optionsAction(buttonsArray[indexPath.row].label, buttonsArray[indexPath.row].label)
        }else{
           
            let mainDic = NSMutableDictionary()
            let feedbackArry = NSMutableArray()
            let feedBackDic = NSMutableDictionary()
             
            for i in 0 ..< selectedFeedbackArray.count{
                feedBackDic.setValue(selectedFeedbackArray[i].id, forKey: "id")
                feedBackDic.setValue(selectedFeedbackArray[i].value, forKey: "value")
                feedbackArry.add(feedBackDic)
            }
            
            let expDic = NSMutableDictionary()
            for i in 0 ..< selectedExperienceArray.count{
                expDic.setValue(selectedExperienceArray[i].id, forKey: "id")
                expDic.setValue(selectedExperienceArray[i].value, forKey: "value")
                expDic.setValue(selectedExperienceArray[i].empathyMessage, forKey: "empathyMessage")
            }
            mainDic.setValue(feedbackArry, forKey: "selectedFeedback")
            mainDic.setValue(expDic, forKey: "selectedExperience")
            mainDic.setValue(descriptionTxtV.text ?? "", forKey: "userSuggestion")
            print(mainDic)
            
            if let theJSONData = try?  JSONSerialization.data(withJSONObject: mainDic, options: .prettyPrinted),
                let theJSONText = String(data: theJSONData,encoding: String.Encoding.ascii) {
                   // print("JSON string = \n\(theJSONText)")
                self.optionsAction("Feedback submitted", theJSONText)
            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let elements = buttonsArray[indexPath.row]
        let text = elements.label
        let indexPath = IndexPath(row: indexPath.item, section: indexPath.section)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        cell.textLabel.text = text
        cell.layer.cornerRadius = 5.0
        cell.layer.borderWidth = 1.5
        return CGSize(width: cell.textLabel.intrinsicContentSize.width + 25, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 0.0, bottom: 5.0, right: 0.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
}

