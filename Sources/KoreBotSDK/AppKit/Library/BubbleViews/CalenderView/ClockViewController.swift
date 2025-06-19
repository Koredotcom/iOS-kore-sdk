//
//  ClockViewController.swift
//  KoreBotSDK
//
//  Created by Kartheek Pagidimarri on 25/04/24.
//

import UIKit

class ClockViewController: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    var dataString: String!
    let bundle = Bundle.sdkModule
    public var optionsButtonTapNewAction: ((_ text: String?, _ payload: String?) -> Void)?
    @IBOutlet weak var timerLbl: UILabel!
    var selectedTime = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 14, *) {
            timePicker.preferredDatePickerStyle = .wheels
            timePicker.backgroundColor = .white
            timePicker.sizeToFit()
        }
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        headingLabel.textColor =  BubbleViewBotChatTextColor
        headingLabel.text = ""
        confirmButton.backgroundColor = themeColor
        timePicker.addTarget(self, action: #selector(ClockViewController.timePickerChanged(timePicker:)), for: UIControl.Event.valueChanged)
        getTime(timePicker: timePicker)
        
        confirmButton.backgroundColor = bubbleViewBotChatButtonBgColor
        confirmButton.setTitleColor(bubbleViewBotChatButtonTextColor, for: .normal)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.layer.cornerRadius = 5.0
        confirmButton.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            self.bgView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
        }
    }
    @objc func timePickerChanged(timePicker:UIDatePicker){
        getTime(timePicker: timePicker)
    }
    
    func getTime(timePicker:UIDatePicker){
        let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short
            dateFormatter.timeZone = TimeZone.current
            let time = dateFormatter.string(from: timePicker.date)
            timerLbl.text = time
            selectedTime = time
    }

    // MARK: init
       init(dataString: String) {
           super.init(nibName: "ClockViewController", bundle: bundle)
           self.dataString = dataString
       }
    
    required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func clickOnCloseButton(_ sender: Any) {
        //calenderCloseTag = true
         self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapsOnConfirmBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        optionsButtonTapNewAction?(selectedTime, selectedTime)
    }
}
