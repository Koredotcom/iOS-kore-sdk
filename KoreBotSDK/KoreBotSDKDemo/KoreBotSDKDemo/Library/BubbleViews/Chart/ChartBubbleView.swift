//
//  ChartBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 04/11/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import Charts

class ChartBubbleView: BubbleView, IAxisValueFormatter, IValueFormatter {
    var pcView: PieChartView!
    var lcView: LineChartView!
    var bcView: BarChartView!
    var xAxisValues: Array<String>!
    
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
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        if xAxisValues.count >= index {
            return xAxisValues[index-1]
        }
        return "\(value)"
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return entry.data!["displayValue"] != nil ? entry.data!["displayValue"] as! String : "\(value)"
    }
    
    // MARK: initialize chart views
    func intializePieChartView(){
        self.pcView = PieChartView()
        self.pcView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.pcView)
        
        let views: [String: UIView] = ["pcView": pcView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pcView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pcView]|", options: [], metrics: nil, views: views))
        
        let l: Legend = self.pcView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.drawInside = false
        l.formSize = 12.0
        l.textColor = .white
        l.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
        
        self.pcView.chartDescription?.enabled = false
        self.pcView.drawHoleEnabled = false
        self.pcView.drawEntryLabelsEnabled = false
    }
    
    func intializeLineChartView(){
        self.lcView = LineChartView()
        self.lcView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.lcView)
        
        let views: [String: UIView] = ["lcView": lcView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lcView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lcView]|", options: [], metrics: nil, views: views))
        
        self.lcView.chartDescription?.enabled = false
        self.lcView.isUserInteractionEnabled = false
        
        self.lcView.leftAxis.enabled = true
        self.lcView.leftAxis.drawAxisLineEnabled = true
        self.lcView.leftAxis.drawGridLinesEnabled = false
        self.lcView.leftAxis.labelTextColor = UIColor.white
        self.lcView.rightAxis.enabled = false
        
        self.lcView.xAxis.labelPosition = .bottom
        self.lcView.xAxis.labelTextColor = UIColor.white
        self.lcView.xAxis.drawAxisLineEnabled = true
        self.lcView.xAxis.drawGridLinesEnabled = false
        self.lcView.xAxis.granularity = 1.0
        self.lcView.xAxis.valueFormatter = self
        
        self.lcView.drawGridBackgroundEnabled = false
        self.lcView.drawBordersEnabled = false
        self.lcView.dragEnabled = true
        self.lcView.pinchZoomEnabled = false
        
        let l: Legend = self.lcView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = true
        l.formSize = 12.0
        l.textColor = .white
        l.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
    }
    
    func intializeBarChartView(){
        self.bcView = BarChartView()
        self.bcView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bcView)
        
        let views: [String: UIView] = ["bcView": bcView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bcView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bcView]|", options: [], metrics: nil, views: views))
        
        self.bcView.chartDescription?.enabled = false
        
        self.bcView.leftAxis.enabled = true
        self.bcView.leftAxis.drawAxisLineEnabled = true
        self.bcView.leftAxis.drawGridLinesEnabled = false
        self.bcView.leftAxis.labelTextColor = UIColor.white
        self.bcView.rightAxis.enabled = false
        
        self.bcView.xAxis.labelPosition = .bottom
        self.bcView.xAxis.labelTextColor = UIColor.white
        self.bcView.xAxis.drawAxisLineEnabled = true
        self.bcView.xAxis.drawGridLinesEnabled = false
        self.bcView.xAxis.granularity = 1.0
        self.bcView.xAxis.valueFormatter = self
        
        self.bcView.drawGridBackgroundEnabled = false
        self.bcView.drawBordersEnabled = false
        self.bcView.dragEnabled = true
        self.bcView.pinchZoomEnabled = false
        
        let l: Legend = self.bcView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = true
        l.formSize = 12.0
        l.textColor = .white
        l.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
        
        let marker = BalloonMarker(color: UIColor.white.withAlphaComponent(0.9), font: UIFont(name: "HelveticaNeue-Bold", size: 13.0)!, textColor: .black, insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        self.bcView.marker = marker
    }
    
    override func borderColor() -> UIColor {
        return UIColor.clear
    }
    
    func colorsPalet() -> [NSUIColor]{
        var colors: Array<UIColor> = Array<UIColor>()
        colors.append(Common.UIColorRGB(0x5F6BF7))
        colors.append(Common.UIColorRGB(0xF78083))
        colors.append(Common.UIColorRGB(0x41C5D3))
        colors.append(Common.UIColorRGB(0xC4AFF0))
        colors.append(Common.UIColorRGB(0x2ecc71))
        colors.append(Common.UIColorRGB(0x1abc9c))
        colors.append(contentsOf: ChartColorTemplates.colorful())
        colors.append(contentsOf: ChartColorTemplates.joyful())
        colors.append(contentsOf: ChartColorTemplates.liberty())
        colors.append(contentsOf: ChartColorTemplates.material())
        colors.append(contentsOf: ChartColorTemplates.pastel())
        colors.append(contentsOf: ChartColorTemplates.vordiplom())
        return colors
    }
    
    // MARK: Setting Data
    func setDataForPieChart(_ jsonObject: NSDictionary){
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
        pieChartDataSet.colors = colorsPalet()
        pieChartDataSet.sliceSpace = 2.0
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.setValueFormatter(self)
        pieChartData.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0))
        pieChartData.setValueTextColor(UIColor.white)
        
        self.pcView.data = pieChartData
        self.pcView.highlightValues(nil)
        self.pcView.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInOutBack)
    }
    
    public func transpose<T>(input: [[T]]) -> [[T]] {
        if input.isEmpty { return [[T]]() }
        let count = input[0].count
        var out = [[T]](repeating: [T](), count: count)
        for outer in input {
            for (index, inner) in outer.enumerated() {
                out[index].append(inner)
            }
        }
        return out
    }
    
    func setDataForLineChart(_ jsonObject: NSDictionary){
        let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
        let headers: Array<String> = jsonObject["headers"] != nil ? jsonObject["headers"] as! Array<String> : []
        let elementsCount: Int = elements.count
        
        var dataValues: Array<Array<ChartDataEntry>> = Array<Array<ChartDataEntry>>()
        var titles: Array<String> = Array<String>()
        for i in 0..<elementsCount {
            let dictionary = elements[i]
            let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
            titles.append(title)
            
            let values: Array<NSNumber> = dictionary["values"] != nil ? dictionary["values"] as! Array<NSNumber> : []
            var subDataValues: Array<ChartDataEntry> = Array<ChartDataEntry>()
            for j in 0..<values.count {
                subDataValues.append(ChartDataEntry(x: Double(i + 1), y: values[j].doubleValue))
            }
            dataValues.append(subDataValues)
        }
        
        dataValues = transpose(input: dataValues)
        
        var colors = colorsPalet()
        
        var dataSets: Array<LineChartDataSet> = Array<LineChartDataSet>()
        for i in 0..<dataValues.count {
            let dataSet = LineChartDataSet(values: dataValues[i], label: headers[i+1])
            dataSet.mode = .cubicBezier
            dataSet.lineWidth = 2.0
            dataSet.setColor(colors[i])
            dataSet.drawCirclesEnabled = false
            dataSet.drawValuesEnabled = false
            dataSets.append(dataSet)
        }
        
        let lineChartData = LineChartData(dataSets: dataSets)
        
        self.xAxisValues = titles
        self.lcView.data = lineChartData
        self.lcView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    func setDataForBarChart(_ jsonObject: NSDictionary){
        let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
        let headers: Array<String> = jsonObject["headers"] != nil ? jsonObject["headers"] as! Array<String> : []
        let elementsCount: Int = elements.count
        
        var dataValues: Array<Array<BarChartDataEntry>> = Array<Array<BarChartDataEntry>>()
        var titles: Array<String> = Array<String>()
        for i in 0..<elementsCount {
            let dictionary = elements[i]
            let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
            titles.append(title)

            let values: Array<NSNumber> = dictionary["values"] != nil ? dictionary["values"] as! Array<NSNumber> : []
            var subDataValues: Array<BarChartDataEntry> = Array<BarChartDataEntry>()
            for j in 0..<values.count {
                subDataValues.append(BarChartDataEntry(x: Double(i + 1), y: values[j].doubleValue))
            }
            dataValues.append(subDataValues)
        }

        dataValues = transpose(input: dataValues)

        var colors = colorsPalet()

        var dataSets: Array<BarChartDataSet> = Array<BarChartDataSet>()
        for i in 0..<dataValues.count {
            let dataSet = BarChartDataSet(values: dataValues[i], label: headers[i+1])
            dataSet.setColor(colors[i])
            dataSets.append(dataSet)
        }

        let barChartData = BarChartData(dataSets: dataSets)
        barChartData.setValueTextColor(.white)
        barChartData.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: 8.0))
        barChartData.setDrawValues(false)
        
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        let groupSpace = 0.30
        let barSpace = 0.01
        let barWidth = ((1.0 - groupSpace)/Double(dataSets.count)) - barSpace
        barChartData.barWidth = barWidth
        barChartData.groupBars(fromX: 0.5, groupSpace: groupSpace, barSpace: barSpace)
        
        self.xAxisValues = titles
        self.bcView.data = barChartData
        self.bcView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    func initializeViewForType(_ type: String){
        if type == "piechart" {
            intializePieChartView()
        }else if type == "linechart" {
            intializeLineChartView()
        }else if type == "barchart" {
            intializeBarChartView()
        }
    }
    
    func setDataForType(_ type: String, jsonObject: NSDictionary){
        if type == "piechart" {
            setDataForPieChart(jsonObject)
        }else if type == "linechart" {
            setDataForLineChart(jsonObject)
        }else if type == "barchart" {
            setDataForBarChart(jsonObject)
        }
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let chartType = jsonObject["template_type"] != nil ? jsonObject["template_type"] as! String : "piechart"
                
                self.initializeViewForType(chartType)
                self.setDataForType(chartType, jsonObject: jsonObject)
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0.0, height: 320)
    }
    
    override func prepareForReuse() {
        if self.pcView != nil {
            self.pcView.removeFromSuperview()
            self.pcView = nil
        }
        if self.lcView != nil {
            self.lcView.removeFromSuperview()
            self.lcView = nil
        }
        if self.bcView != nil {
            self.bcView.removeFromSuperview()
            self.bcView = nil
        }
        self.xAxisValues = Array<String>()
    }
}