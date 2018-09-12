//
//  SessionEndView.swift
//  AFNetworking
//
//  Created by Sowmya Ponangi on 11/09/18.
//

import UIKit

public class SessionEndView: UIView {
    
    public var blueLineLbl: UILabel!
    public var convLbl: UILabel!
    public var chatBtn: UIButton!
    public var sendSessionAction: ((_ value: Bool?) -> Void)!
    var btnTitle: String = "Chat with an expert"
    
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
        
        
    }
    
    // MARK:- setup collectionView
    func setup() {
        
        blueLineLbl = UILabel(frame: .zero)
        blueLineLbl.translatesAutoresizingMaskIntoConstraints = false
        blueLineLbl.backgroundColor = UIColor(red: 43/255, green: 134/255, blue: 179/255, alpha: 1)
        self.addSubview(blueLineLbl)
        
        convLbl = UILabel(frame: .zero)
        convLbl.translatesAutoresizingMaskIntoConstraints = false
        convLbl.textAlignment = .center
        convLbl.numberOfLines = 2
//        convLbl.font = UIFont(name: "Lato-Regular", size: 16.0)
        convLbl.textColor =  UIColor(red: 43/255, green: 134/255, blue: 179/255, alpha: 1)
        convLbl.text = "This conversation thread has been marked as closed. If you wish to make other queries, tap below."
        self.addSubview(convLbl)
        
        chatBtn = UIButton.init(type: .custom)
        chatBtn.translatesAutoresizingMaskIntoConstraints = false
        //        doneBtn.titleLabel?.font = UIFont(name: "System-Bold", size: 12.0)
        let btnColor : UIColor =  UIColor(red: 43/255, green: 134/255, blue: 179/255, alpha: 1)
        chatBtn.titleLabel?.textAlignment = .center
        chatBtn.titleLabel?.textColor = UIColor.white
        chatBtn.backgroundColor = btnColor
        chatBtn.setTitle(btnTitle, for: .normal)
        chatBtn.setTitleColor( UIColor.white, for: .normal)
        chatBtn.addTarget(self, action: #selector(chatBtnAction(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(chatBtn)
        
        let views: [String: UIView] = ["blueLineLbl": blueLineLbl, "convLbl": convLbl, "chatBtn": chatBtn ]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[blueLineLbl]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[convLbl]-12-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[chatBtn]-14-|", options:[], metrics:nil, views:views))

        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blueLineLbl(1)]-15-[convLbl(48)]-18-[chatBtn(49)]-20-|", options:[], metrics:nil, views:views))
    }
    public func setValues(values:Array<String>) {
        btnTitle = values.first!
        setNeedsLayout()
    }
    @objc func chatBtnAction(_ sender: UIButton){
        if(self.sendSessionAction != nil){
            self.sendSessionAction(false)
        }
        
    }
}
