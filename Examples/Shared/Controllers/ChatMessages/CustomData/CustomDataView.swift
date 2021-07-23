//
//  CustomDataView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 22/07/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit
protocol CustomDataViewDelegate {
    func oKButtonTapAction(text:String)
}

class CustomDataView: UIView, UITextViewDelegate {
    
    var customDataSubView: UIView!
    var descriptionTxtV: UITextView!
    var clearBtn: UIButton!
    var okBtn: UIButton!
    var descriptionPlaceholderLbl: UILabel!
    var viewDelegate: CustomDataViewDelegate?
    
    convenience init() {
           self.init(frame: CGRect.zero)
       }
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           self.setupViews()
       }
       
       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           self.setupViews()
       }
       
       fileprivate func setupViews() {
        
        botCustomData = [:]
        customDataSubView = UIView(frame:.zero)
        customDataSubView.translatesAutoresizingMaskIntoConstraints = false
        customDataSubView.layer.cornerRadius = 5
        customDataSubView.layer.shadowColor = UIColor.darkGray.cgColor
        customDataSubView.layer.shadowOffset = CGSize(width: 0, height: 0)
        customDataSubView.layer.shadowOpacity = 0.5
        customDataSubView.layer.shadowRadius = 2
        customDataSubView.clipsToBounds = false
        self.addSubview(self.customDataSubView)
        customDataSubView.backgroundColor =  UIColor.init(red: 248.0/255.0, green: 250.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        let cardViews: [String: UIView] = ["customDataSubView": customDataSubView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[customDataSubView(200)]", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[customDataSubView]-20-|", options: [], metrics: nil, views: cardViews))
        
        
        self.descriptionTxtV = UITextView(frame: CGRect.zero)
        //self.descriptionTxtV.text = "{\"userContext\" : \"test\"}"
        self.descriptionTxtV.delegate = self
        self.descriptionTxtV.textColor = .black
        self.descriptionTxtV.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        self.descriptionTxtV.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionTxtV.backgroundColor = .white
        self.descriptionTxtV.layer.cornerRadius = 5.0
        descriptionTxtV.layer.shadowColor = UIColor.darkGray.cgColor
        descriptionTxtV.layer.shadowOffset = CGSize(width: 0, height: 0)
        descriptionTxtV.layer.shadowOpacity = 0.5
        descriptionTxtV.layer.shadowRadius = 2
        self.descriptionTxtV.layer.borderColor = UIColor.lightGray.cgColor
        self.descriptionTxtV.clipsToBounds = false
        self.customDataSubView.addSubview(self.descriptionTxtV)
        
        clearBtn = UIButton(frame: CGRect.zero)
        clearBtn.backgroundColor = .white
        clearBtn.setTitle("Clear", for: .normal)
        clearBtn.translatesAutoresizingMaskIntoConstraints = false
        clearBtn.clipsToBounds = true
        clearBtn.layer.cornerRadius = 5
        clearBtn.layer.borderColor = UIColor.lightGray.cgColor
        clearBtn.layer.borderWidth = 1.0
        clearBtn.setTitleColor(.black, for: .normal)
        clearBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        clearBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        customDataSubView.addSubview(clearBtn)
        clearBtn.addTarget(self, action: #selector(self.clearBtnAction(_:)), for: .touchUpInside)
        
        okBtn = UIButton(frame: CGRect.zero)
        okBtn.backgroundColor = .blue
        okBtn.setTitle("Ok", for: .normal)
        okBtn.translatesAutoresizingMaskIntoConstraints = false
        okBtn.clipsToBounds = true
        okBtn.layer.cornerRadius = 5
        okBtn.setTitleColor(.white, for: .normal)
        okBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        okBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        customDataSubView.addSubview(okBtn)
        okBtn.addTarget(self, action: #selector(self.OkBtnAction(_:)), for: .touchUpInside)
        
        self.descriptionPlaceholderLbl = UILabel(frame: CGRect.zero)
        self.descriptionPlaceholderLbl.text = "Provide context object"
        self.descriptionPlaceholderLbl.textColor = .lightGray
        self.descriptionPlaceholderLbl.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)
        self.descriptionPlaceholderLbl.numberOfLines = 0
        self.descriptionPlaceholderLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.descriptionPlaceholderLbl.isUserInteractionEnabled = true
        self.descriptionPlaceholderLbl.contentMode = UIView.ContentMode.topLeft
        self.descriptionPlaceholderLbl.translatesAutoresizingMaskIntoConstraints = false
        self.customDataSubView.addSubview(self.descriptionPlaceholderLbl)
        self.descriptionPlaceholderLbl.adjustsFontSizeToFitWidth = true
        self.descriptionPlaceholderLbl.backgroundColor = .clear
        self.descriptionPlaceholderLbl.layer.cornerRadius = 6.0
        self.descriptionPlaceholderLbl.clipsToBounds = true
        self.descriptionPlaceholderLbl.sizeToFit()

        let autoViews: [String: UIView] = ["descriptionTxtV": descriptionTxtV, "clearBtn": clearBtn, "okBtn": okBtn, "descriptionPlaceholderLbl": descriptionPlaceholderLbl]
        self.customDataSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[descriptionTxtV(150)]-10-[clearBtn(30)]", options: [], metrics: nil, views: autoViews))
         self.customDataSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[descriptionTxtV(150)]-10-[okBtn(30)]", options: [], metrics: nil, views: autoViews))
         self.customDataSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[descriptionPlaceholderLbl(21)]", options: [], metrics: nil, views: autoViews))
        self.customDataSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[descriptionTxtV]-0-|", options: [], metrics: nil, views: autoViews))
        self.customDataSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[clearBtn(60)]-20-[okBtn(60)]-10-|", options: [], metrics: nil, views: autoViews))
        self.customDataSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[descriptionPlaceholderLbl]-10-|", options: [], metrics: nil, views: autoViews))
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLbl.isHidden = !textView.text.isEmpty
    }
    
    @objc fileprivate func clearBtnAction(_ sender: AnyObject!) {
        descriptionTxtV.text = ""
        descriptionPlaceholderLbl.isHidden = false
        botCustomData = [:]
    }
    
    @objc fileprivate func OkBtnAction(_ sender: AnyObject!) {
        let descTxt = descriptionTxtV.text!
        
        var jsonString = descTxt.replacingOccurrences(of: "”", with: "\"")
         jsonString = jsonString.replacingOccurrences(of: "“", with: "\"")
        
        let jsonData = jsonString.data(using: String.Encoding.utf8)
        if isValidJson(check: jsonData!){
            print("Valid Json")
            descriptionTxtV.resignFirstResponder()
            viewDelegate?.oKButtonTapAction(text: jsonString)
        }else{
            print("InValid Json")
             botCustomData = [:]
        }
        
        let string = jsonString
        let data = string.data(using: .utf8)!
        do {
            if let jsonData = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
            {
                 botCustomData = jsonData
               print(jsonData) // use the json here
            } else {
                print("bad json")
                 botCustomData = [:]
            }
        } catch let error as NSError {
            print(error)
            botCustomData = [:]
        }
    }
    
    func isValidJson(check data:Data) -> Bool
    {
        do{
        if let _ = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
           return true
        } else if let _ = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
            return true
        } else {
            return false
        }
        }
        catch let error as NSError {
            print(error)
            return false
        }

    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
