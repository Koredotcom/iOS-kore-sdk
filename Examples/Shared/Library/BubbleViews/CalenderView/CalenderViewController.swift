//
//  CalenderViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/13/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol calenderSelectDelegate {
    func optionsButtonTapAction(text:String)
}
class CalenderViewController: UIViewController {

    var dataString: String!
    var messageId: String!
    var kreMessage: KREMessage!
    var selectedFromDate : String?
    var selectedToDate : String?
    var comp = NSDateComponents()
    var viewDelegate: calenderSelectDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var fromYearLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var fromDateButton: UIButton!
    @IBOutlet weak var dateViewHorzontalConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var toDateView: UIView!
    @IBOutlet weak var toYearLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var toDateButton: UIButton!
    var templateType : String?
    var startdateString : String?
    var endDateString : String?
    let dateFormatter = DateFormatter()
    
    // MARK: init
       init(dataString: String, chatId: String, kreMessage: KREMessage) {
           super.init(nibName: "CalenderViewController", bundle: nil)
           self.dataString = dataString
           self.messageId = chatId
           self.kreMessage = kreMessage
       }
    
    required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        datePicker.addTarget(self, action: #selector(CalenderViewController.datePickerChanged(datePicker:)), for: UIControl.Event.valueChanged)
        getData()
    }

    @IBAction func clickOnCloseButton(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    func getData(){
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                                        return
            }
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let todayDate = dateFormatter.string(from: Date())
        
        headingLabel.text = allItems.text ?? "Please Choose"
        endDateString = allItems.endDate ?? todayDate
        templateType = allItems.template_type ?? ""
        startdateString = allItems.startDate ?? todayDate
        endDateString = allItems.endDate ?? todayDate

        let startDate = dateFormatter.date(from: startdateString!)
        let endDate = dateFormatter.date(from: endDateString!)
        print(startDate as Any)
        
        if templateType == "daterange" {
            datePickerOfMinimumMaximum(minimumdate: endDate ?? Date(), maximumDate: endDate ?? Date())
            clickOnFromDateButton(fromDateButton as Any)
        }else{
            datePickerOfMinimumMaximum(minimumdate: startDate ?? Date(), maximumDate: startDate ?? Date())
            toDateView.isHidden = true
            fromDateButton.isUserInteractionEnabled = false
            fromYearLabel.textAlignment = .left
            fromDateLabel.textAlignment = .left
        }
       
    }
    
    @objc func datePickerChanged(datePicker:UIDatePicker){
       selectDate(datePicker: datePicker)
    }
    func selectDate(datePicker:UIDatePicker){
        let dayOfweek = datePicker.date.dayOfWeek()! as String
        let year = datePicker.date.year()! as String
        let day = datePicker.date.day()! as String
        let monthName = datePicker.date.monthName()! as String
        
        if templateType == "daterange" {
            dateViewHorzontalConstrain.constant = -80
            if fromDateButton.isSelected {
                fromYearLabel.text = year
                fromDateLabel.text = "\(dayOfweek), \(monthName) \(day)"
                selectedFromDate = datePicker.date.currentDate()! as Any as? String
            }else{
                toYearLabel.text = year
                toDateLabel.text = "\(dayOfweek), \(monthName) \(day)"
                selectedToDate = datePicker.date.currentDate()! as Any as? String
            }
            
        }else{
            fromYearLabel.text = year
            fromDateLabel.text = "\(dayOfweek), \(monthName) \(day)"
            selectedFromDate = datePicker.date.currentDate()! as Any as? String
            dateViewHorzontalConstrain.constant = 0
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
    @IBAction func clickOnFromDateButton(_ sender: Any) {
        fromDateButton.isSelected = true
        toDateButton.isSelected = false
        fromDateButton.backgroundColor = UIColor.init(red: 171/255.0, green: 171/255.0, blue: 171/255.0, alpha: 0.5)
        toDateButton.backgroundColor = .clear
    
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let startDate = dateFormatter.date(from: (endDateString!))
        print(startDate as Any)
        datePickerOfMinimumMaximum(minimumdate: startDate ?? Date(), maximumDate: startDate ?? Date())
    }
    
    @IBAction func clickOnToDateButton(_ sender: Any) {
        fromDateButton.isSelected = false
        toDateButton.isSelected = true
        toDateButton.backgroundColor = UIColor.init(red: 171/255.0, green: 171/255.0, blue: 171/255.0, alpha: 0.5)
        fromDateButton.backgroundColor = .clear
        
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let startDate = dateFormatter.date(from: selectedFromDate!)
        let endDate = dateFormatter.date(from: endDateString!)
        print(startDate as Any)
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: 0, to: startDate!)
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to:endDate!)
        datePicker.setDate(Date(), animated: true)
        selectDate(datePicker: datePicker)
    }
    @IBAction func clickConfirmBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if templateType == "daterange" {
            let selectedDates = ("\(selectedFromDate!) to \(selectedToDate!)")
            self.viewDelegate?.optionsButtonTapAction(text: selectedDates)
        }else{
            self.viewDelegate?.optionsButtonTapAction(text: selectedFromDate!)
        }
    }
    func datePickerOfMinimumMaximum(minimumdate: Date, maximumDate: Date){
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: minimumdate)
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: maximumDate)
        datePicker.setDate(Date(), animated: true)
        selectDate(datePicker: datePicker)
    }
}
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter.string(from: self).capitalized
    }
    func year() -> String? {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy"
           return dateFormatter.string(from: self).capitalized
       }
    func day() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self).capitalized
    }
    func monthName() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self).capitalized
    }
    func currentDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: self).capitalized
    }
}
