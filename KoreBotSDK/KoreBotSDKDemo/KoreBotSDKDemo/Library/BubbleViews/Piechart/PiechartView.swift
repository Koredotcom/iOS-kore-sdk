//
//  PiechartView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 08/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import Charts

class PiechartView: BubbleView {
    var pcView: PieChartView!
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor =  UIColor.clear
        }
    }
    
    override func initialize() {
        super.initialize()
        
        self.pcView = PieChartView()
        self.pcView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.pcView)
        
        let views: [String: UIView] = ["pcView": pcView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pcView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pcView]|", options: [], metrics: nil, views: views))
        
//        self.carouselView.optionsAction = {[weak self] (text) in
//            if((self?.optionsAction) != nil){
//                self?.optionsAction(text)
//            }
//        }
//        self.carouselView.linkAction = {[weak self] (text) in
//            if(self?.linkAction != nil){
//                self?.linkAction(text)
//            }
//        }
    }
    
    override func borderColor() -> UIColor {
        return UIColor.clear
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
                let elementsCount: Int = elements.count
                var values: Array<PieChartDataEntry> = Array<PieChartDataEntry>()
                for i in 0..<elementsCount {
                    let dictionary = elements[i]
                    let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
                    let value: NSNumber = dictionary["value"] != nil ? dictionary["value"] as! NSNumber : 0
                    
                    let pieChartDataEntry = PieChartDataEntry(value: value.doubleValue, label: title, data: dictionary as AnyObject)
                    values.append(pieChartDataEntry)
                }
                let pieChartDataSet = PieChartDataSet(values: values, label: "")
                
                var colors: Array<UIColor> = Array<UIColor>()
                colors.append(contentsOf: ChartColorTemplates.vordiplom())
                colors.append(contentsOf: ChartColorTemplates.joyful())
                colors.append(contentsOf: ChartColorTemplates.colorful())
                colors.append(contentsOf: ChartColorTemplates.liberty())
                colors.append(contentsOf: ChartColorTemplates.pastel())
                
                pieChartDataSet.colors = colors
                
                let pieChartData = PieChartData(dataSet: pieChartDataSet)
                self.pcView.data = pieChartData
                self.pcView.highlightValues(nil)
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0.0, height: 300)
    }
    
    override func prepareForReuse() {
//        self.carouselView.prepareForReuse()
    }
}
