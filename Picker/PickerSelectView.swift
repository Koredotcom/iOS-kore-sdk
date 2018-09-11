//
//  PickerSelectView.swift
//  AFNetworking
//
//  Created by Sowmya Ponangi on 11/09/18.
//

import UIKit

public class PickerSelectView: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    public var picker: UIPickerView!
    public var toolbarView: UIView!
    public var data = ["one", "two", "three"]
    var titleList: [String]!
    public var sendPickerAction: ((_ text: String?) -> Void)!
    public var cancelAction: (() -> Void)!
    var doneBtn: UIButton!
    var cancelBtn: UIButton!
    var selectdValue: String?
    
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
        self.picker.delegate = nil
        self.picker.dataSource = nil
    }
    
    // MARK:- setup collectionView
    func setup() {
        titleList = [String]()
        
        toolbarView = UIView(frame: .zero)
        let backColor : UIColor =  UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        toolbarView.backgroundColor = backColor
        
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(toolbarView)
        
        doneBtn = UIButton.init(type: .custom)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
//        doneBtn.titleLabel?.font = UIFont(name: "System-Bold", size: 12.0)
        let btnColor : UIColor =  UIColor(red: 43/255, green: 134/255, blue: 179/255, alpha: 1)
        doneBtn.titleLabel?.textAlignment = .center
        doneBtn.titleLabel?.textColor = btnColor
        doneBtn.setTitle("Done", for: .normal)
        doneBtn.setTitleColor( btnColor, for: .normal)
        doneBtn.addTarget(self, action: #selector(doneBtnAction(_:)), for: UIControlEvents.touchUpInside)
        self.toolbarView.addSubview(doneBtn)
        
        cancelBtn = UIButton.init(type: .custom)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = true
//        cancelBtn.titleLabel?.font = UIFont(name: "System-Bold", size: 12.0)!
        cancelBtn.titleLabel?.textColor = UIColor.blue
        
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction(_:)), for: UIControlEvents.touchUpInside)
        self.toolbarView.addSubview(cancelBtn)
        
        picker = UIPickerView(frame: .zero)
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        
        //        picker.addTarget(self, action: #selector(pickerValChanged(_ : )), for: .valueChanged)
        self.addSubview(picker)
//        self.bringSubview(toFront: picker)
        let views: [String: UIView] = ["picker": picker, "toolbarView": toolbarView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[picker]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toolbarView]|", options:[], metrics:nil, views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[toolbarView(44)][picker]|", options:[], metrics:nil, views:views))
        
        let toolBarviews: [String: UIView] = ["cancelBtn": cancelBtn, "doneBtn": doneBtn ]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[cancelBtn]", options:[], metrics:nil, views:toolBarviews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cancelBtn]|", options:[], metrics:nil, views:toolBarviews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[doneBtn]-8-|", options:[], metrics:nil, views:toolBarviews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[doneBtn]|", options:[], metrics:nil, views:toolBarviews))
        self.toolbarView.bringSubview(toFront: doneBtn)
    }
    public func setValues(values:Array<String>) {
        self.titleList = values
        self.picker.reloadAllComponents()
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.titleList != nil {
            return self.titleList.count
        } else {
            return 0
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if titleList[row] != nil {
            selectdValue = titleList[row]
            return titleList[row]
        } else {
            return ""
        }
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectdValue = titleList[row]
    }
    @objc func cancelBtnAction(_ sender: UIButton){
        if(self.cancelAction != nil){
            self.cancelAction()
        }
    }
    @objc func doneBtnAction(_ sender: UIButton){
        if(self.sendPickerAction != nil){
            self.sendPickerAction(selectdValue)
        }
       
    }
}
