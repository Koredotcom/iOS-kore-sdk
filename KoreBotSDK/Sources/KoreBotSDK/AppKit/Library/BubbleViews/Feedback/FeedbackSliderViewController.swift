//
//  FeedbackSliderViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 9/1/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol feedbackViewDelegate {
    func optionsButtonTapAction(text:String)
}
class FeedbackSliderViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
    @IBOutlet weak var textViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var subViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    let placeholderText = "Add Suggestions"
    
    let customCellIdentifier = "FeedbackCell"
    let arrayOfEmojis = ["rating_1","rating_2","rating_3","rating_4","rating_5"]
    var selectedEmojiIndex = 10
    var arrayOfSmiley = [SmileyArraysAction]()
    var dataString: String!
    var viewDelegate: feedbackViewDelegate?
    var messageToDisplay:String?
    var selectedValue : Int!
    var selectedDescription : String!
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "FeedbackSliderViewController", bundle: .sdkModule)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        descriptionLabel.isHidden = true
        descriptionTextView.isHidden = true
        submitButton.isHidden = true
        subViewHeightConstraint.constant = 110
        
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.cornerRadius = 5.0
        descriptionTextView.text = placeholderText
        descriptionTextView.textColor = UIColor.lightGray
        
        floatRatingView.backgroundColor = .clear
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        floatRatingView.type = .wholeRatings
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        self.collectionView.collectionViewLayout = layout
        
        self.collectionView.register(Bundle.xib(named: customCellIdentifier),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        getData()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        
        var keyboardHeight = keyboardFrameEnd.size.height;
        if #available(iOS 11.0, *) {
            keyboardHeight -= self.view.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
        };
        self.bottomConstraint.constant = -keyboardHeight
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = UIColor.lightGray
        }else{
            textView.textColor = UIColor.black
        }
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func getData(){
        
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                return
        }
        self.headingLabel.text = allItems.text ?? ""
        messageToDisplay = allItems.messageTodisplay ?? ""
        
        if allItems.feedbackView! == "emojis"{
            collectionView.isHidden = false
            floatRatingView.isHidden = true
            arrayOfSmiley = allItems.smileyArrays ?? []
        }else{
            collectionView.isHidden = true
            floatRatingView.isHidden = false
            arrayOfSmiley = allItems.starArrays?.reversed() ?? []
        }
        collectionView.reloadData()
    }
    
    @IBAction func tapsOnCloseBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapsOnSubmitButtonAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        descriptionTextView.resignFirstResponder()
        if selectedValue != 5{
            if descriptionTextView.text == placeholderText {
                descriptionTextView.text = ""
                selectedDescription = descriptionTextView.text
            }else{
                selectedDescription = descriptionTextView.text
            }
        }
        viewDelegate?.optionsButtonTapAction(text: "\(selectedValue!): \(selectedDescription ?? "")")
    }
}

extension FeedbackSliderViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfSmiley.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! FeedbackCell
        cell.backgroundColor = .clear
        if indexPath.item == selectedEmojiIndex{
            let jeremyGif = UIImage.gifImageWithName("ratingselect_\(indexPath.item+1)")
            cell.imageView.image = jeremyGif
        }else{
            cell.imageView.image = UIImage(named: "rating_\(indexPath.item+1)")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let elements = arrayOfSmiley[indexPath.item]
        selectedValue = elements.value!
        
        if elements.smileyId! == 5{
            subViewHeightConstraint.constant = 200
            textViewHeightContraint.constant = 0
            descriptionLabel.isHidden = false
            descriptionTextView.isHidden = true
            submitButton.isHidden = false
            descriptionLabel.text = messageToDisplay
            selectedDescription = messageToDisplay
            
        }else{
            subViewHeightConstraint.constant = 260
            textViewHeightContraint.constant = 60
            descriptionLabel.isHidden = false
            descriptionTextView.isHidden = false
            submitButton.isHidden = false
            descriptionLabel.text = "What can be improved?"
        }
        
        selectedEmojiIndex = indexPath.item
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
}

extension FeedbackSliderViewController: FloatRatingViewDelegate {
    
    // MARK: FloatRatingViewDelegate
    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Double) {
        
    }
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        
        //selectedValue = Int(floatRatingView.rating)
        let index = Int(floatRatingView.rating) - 1
        let elements = arrayOfSmiley[index]
        selectedValue = elements.value!
        
        if selectedValue == 5{
            subViewHeightConstraint.constant = 200
            textViewHeightContraint.constant = 0
            descriptionLabel.isHidden = false
            descriptionTextView.isHidden = true
            submitButton.isHidden = false
            descriptionLabel.text = messageToDisplay
            selectedDescription = messageToDisplay
        }else{
            subViewHeightConstraint.constant = 260
            textViewHeightContraint.constant = 60
            descriptionLabel.isHidden = false
            descriptionTextView.isHidden = false
            submitButton.isHidden = false
            descriptionLabel.text = "What can be improved?"
        }
    }
}
