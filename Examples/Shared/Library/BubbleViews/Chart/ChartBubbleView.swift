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
    var cardView : UIView!
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
        if xAxisValues.count > index {
            return xAxisValues[index]
        }
        return "\(value)"
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if let dictionary = entry.data as? NSDictionary, let keys = dictionary.allKeys as? [String] {
            for i in 0..<keys.count {
                if keys[i] == "displayValue", let value = dictionary["displayValue"] as? String {
                    return value
                }
            }
        }
        return "\(value)"
    }
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor(red: 232/255, green: 232/255, blue: 230/255, alpha: 1).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.white
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
    }
    
    // MARK: initialize chart views
    func intializePieChartView(_ pieType: String){
        intializeCardLayout()
        
        self.pcView = PieChartView()
        self.pcView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.pcView)
        
        let views: [String: UIView] = ["pcView": pcView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[pcView]-15-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[pcView]-15-|", options: [], metrics: nil, views: views))
        
        let l: Legend = self.pcView.legend
        if(pieType == "regular"){
            l.horizontalAlignment = .right
            l.verticalAlignment = .top
            l.orientation = .vertical
            l.drawInside = false
            l.formSize = 12.0
            l.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
            l.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
            l.form = .circle
            
            self.pcView.chartDescription?.enabled = false
            self.pcView.drawHoleEnabled = false
            self.pcView.drawEntryLabelsEnabled = false
            self.pcView.extraRightOffset = 0.0
            self.pcView.rotationEnabled = false
        }
        if(pieType == "donut"){
            l.horizontalAlignment = .right
            l.verticalAlignment = .top
            l.orientation = .vertical
            l.drawInside = false
            l.formSize = 12.0
            l.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
            l.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
            
            self.pcView.chartDescription?.enabled = false
            self.pcView.drawHoleEnabled = true
            self.pcView.drawEntryLabelsEnabled = false
            self.pcView.extraRightOffset = 0.0
            self.pcView.rotationEnabled = false
//            self.pcView.legend.enabled = false
        }
        if(pieType == "donut_legend"){
            l.horizontalAlignment = .right
            l.verticalAlignment = .center
            l.orientation = .vertical
            l.drawInside = false
            l.formSize = 12.0
            l.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
            l.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
            l.form = .circle
            
            self.pcView.chartDescription?.enabled = false
            self.pcView.drawHoleEnabled = true
            self.pcView.drawEntryLabelsEnabled = false
            self.pcView.extraRightOffset = 5.0
            self.pcView.rotationEnabled = false
            
        }
    }
    
    func intializeLineChartView(){
        intializeCardLayout()
        self.lcView = LineChartView()
        self.lcView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.lcView)
        
        let views: [String: UIView] = ["lcView": lcView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[lcView]-15-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[lcView]-15-|", options: [], metrics: nil, views: views))
        
        self.lcView.chartDescription?.enabled = false
        self.lcView.isUserInteractionEnabled = false
        
        self.lcView.leftAxis.enabled = true
        self.lcView.leftAxis.drawAxisLineEnabled = true
        self.lcView.leftAxis.drawGridLinesEnabled = false
        self.lcView.leftAxis.labelTextColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        self.lcView.rightAxis.enabled = false
        
        self.lcView.xAxis.labelPosition = .bottom
        self.lcView.xAxis.labelTextColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        self.lcView.xAxis.drawAxisLineEnabled = true
        self.lcView.xAxis.drawGridLinesEnabled = false
        self.lcView.xAxis.granularity = 1.0
        self.lcView.xAxis.valueFormatter = self
        self.lcView.xAxis.avoidFirstLastClippingEnabled = true
        
        self.lcView.drawGridBackgroundEnabled = false
        self.lcView.drawBordersEnabled = false
        self.lcView.dragEnabled = true
        self.lcView.pinchZoomEnabled = true
        
        let l: Legend = self.lcView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = true
        l.formSize = 12.0
        l.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        l.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
        l.form = .circle
    }
    
    func intializeBarChartView(_ direction:String){
        
       intializeCardLayout()
        
        if(direction == "horizontal"){
            self.bcView = HorizontalBarChartView()
        }else{
            self.bcView = BarChartView()
        }
        
        self.bcView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.bcView)
        
        let views: [String: UIView] = ["bcView": bcView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[bcView]-15-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[bcView]-15-|", options: [], metrics: nil, views: views))
        
        self.bcView.chartDescription?.enabled = false
        if(direction == "horizontal"){
            self.bcView.leftAxis.enabled = false
        }else{
           self.bcView.leftAxis.enabled = true
        }
        self.bcView.leftAxis.drawAxisLineEnabled = true
        self.bcView.leftAxis.drawGridLinesEnabled = false
        self.bcView.leftAxis.labelTextColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        self.bcView.rightAxis.enabled = false
        
        self.bcView.xAxis.labelPosition = .bottom
        self.bcView.xAxis.labelTextColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        self.bcView.xAxis.drawAxisLineEnabled = true
        self.bcView.xAxis.drawGridLinesEnabled = false
        self.bcView.xAxis.granularity = 1.0
        self.bcView.xAxis.valueFormatter = self
        
        self.bcView.drawGridBackgroundEnabled = false
        self.bcView.drawBordersEnabled = false
        self.bcView.dragEnabled = true
        self.bcView.pinchZoomEnabled = true
        
        let l: Legend = self.bcView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = true
        l.formSize = 12.0
        l.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        l.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
        
        let marker = BalloonMarker(color: UIColor.white.withAlphaComponent(0.9), font: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, textColor: .black, insets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 20.0, right: 8.0))
        self.bcView.marker = marker
    }
    
    override func borderColor() -> UIColor {
        return UIColor.clear
    }
    
    func colorsPalet() -> [NSUIColor]{
        var colors: Array<UIColor> = Array<UIColor>()
//        colors.append(Common.UIColorRGB(0x5F6BF7))
//        colors.append(Common.UIColorRGB(0xF78083))
//        colors.append(Common.UIColorRGB(0x41C5D3))
//        colors.append(Common.UIColorRGB(0xC4AFF0))
//        colors.append(Common.UIColorRGB(0x2ecc71))
//        colors.append(Common.UIColorRGB(0x1abc9c))
        colors.append( UIColor(red: 95/255, green: 107/255, blue: 247/255, alpha: 1))
        colors.append( UIColor(red: 153/255, green: 237/255, blue: 158/255, alpha: 1))
        colors.append( UIColor(red: 247/255, green: 128/255, blue: 131/255, alpha: 1))
        colors.append( UIColor(red: 247/255, green: 128/255, blue: 131/255, alpha: 1))
        colors.append( UIColor(red: 253/255, green: 226/255, blue: 150/255, alpha: 1))
        colors.append( UIColor(red: 117/255, green: 176/255, blue: 254/255, alpha: 1))
        colors.append( UIColor(red: 38/255,  green: 52/255, blue: 74/255, alpha: 1))
        colors.append( UIColor(red: 153/255, green: 161/255, blue: 253/255, alpha: 1))
        colors.append( UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1))
        colors.append( UIColor(red: 156/255, green: 235/255, blue: 249/255, alpha: 1))
        colors.append( UIColor(red: 247/255, green: 199/255, blue: 244/255, alpha: 1))


        colors.append(contentsOf: ChartColorTemplates.colorful())
        colors.append(contentsOf: ChartColorTemplates.joyful())
        colors.append(contentsOf: ChartColorTemplates.liberty())
        colors.append(contentsOf: ChartColorTemplates.material())
        colors.append(contentsOf: ChartColorTemplates.pastel())
        colors.append(contentsOf: ChartColorTemplates.vordiplom())
        return colors
    }
    
    // MARK: Setting Data
    func setDataForPieChart(_ jsonObject: NSDictionary,_ pietype: String){
        let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
        let elementsCount: Int = elements.count
        var values: Array<PieChartDataEntry> = Array<PieChartDataEntry>()
        var rightOffset: CGFloat = 0.0
        for i in 0..<elementsCount {
            let dictionary = elements[i]
            let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
            let value: String = dictionary["value"] != nil ? dictionary["value"] as! String : ""
            var pieChartDataEntry = PieChartDataEntry(value: (value as NSString).doubleValue, label: title , data: dictionary as AnyObject)
            if(pietype == "donut_legend"){
                pieChartDataEntry = PieChartDataEntry(value: (value as NSString).doubleValue, label: title + "  " + value, data: dictionary as AnyObject)
            }
            values.append(pieChartDataEntry)
            
            rightOffset = CGFloat.maximum(rightOffset, (title as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Medium", size: 12.0)!]).width)
        }
        let pieChartDataSet = PieChartDataSet(values: values, label: "")
        pieChartDataSet.colors = colorsPalet()
        pieChartDataSet.sliceSpace = 2.0
        
        if(pietype == "regular"){
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            pieChartData.setValueFormatter(self)
            pieChartData.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0, weight: .medium))
//            pieChartData.setValueTextColor(UIColor.white)
            pieChartDataSet.yValuePosition = .outsideSlice
            pieChartDataSet.valueLinePart1OffsetPercentage = 0.8
            pieChartDataSet.valueLinePart1Length = 0.4
            pieChartDataSet.valueLinePart2Length = 0.4
            pieChartDataSet.valueLineColor = UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1)
            pieChartData.setValueFormatter(self)
            pieChartData.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0, weight: .medium))
            pieChartData.setValueTextColor(UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1))
            pieChartData.setDrawValues(true)
            self.pcView.extraRightOffset = rightOffset
            self.pcView.data = pieChartData
            self.pcView.highlightValues(nil)
            self.pcView.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInOutBack)
        }
        else if(pietype == "donut"){
            pieChartDataSet.selectionShift = 7
            pieChartDataSet.yValuePosition = .outsideSlice
            pieChartDataSet.valueLinePart1OffsetPercentage = 0.8
            pieChartDataSet.valueLinePart1Length = 0.4
            pieChartDataSet.valueLinePart2Length = 0.4
            pieChartDataSet.valueLineColor = UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1)
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            pieChartData.setValueFormatter(self)
            pieChartData.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0, weight: .medium))
            pieChartData.setValueTextColor(UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1))
            pieChartData.setDrawValues(true)
            self.pcView.extraRightOffset = rightOffset
            self.pcView.data = pieChartData
            self.pcView.highlightValues(nil)
            self.pcView.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInOutBack)
        }
        else if(pietype == "donut_legend"){
            pieChartDataSet.selectionShift = 7
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            pieChartData.setDrawValues(false)
             pieChartData.setValueFormatter(self)
            self.pcView.extraRightOffset = rightOffset
            self.pcView.data = pieChartData
            self.pcView.highlightValues(nil)
            
            self.pcView.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInOutBack)
            
        }
        

       
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
        let headers: Array<String> = jsonObject["X_axis"] != nil ? jsonObject["X_axis"] as! Array<String> : []
        let elementsCount: Int = elements.count
        
        var dataValues: Array<Array<ChartDataEntry>> = Array<Array<ChartDataEntry>>()
        var titles: Array<String> = Array<String>()
        for i in 0..<elementsCount {
            let dictionary = elements[i]
            let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
            titles.append(title)
            
            var values: Array<NSNumber> = dictionary["values"] != nil ? dictionary["values"] as! Array<NSNumber> : []
            if(values.count<headers.count){
                for _ in 0..<headers.count-values.count {
                    values.append(0)
                }
            }
            var subDataValues: Array<ChartDataEntry> = Array<ChartDataEntry>()
            for j in 0..<headers.count {
                subDataValues.append(ChartDataEntry(x: Double(j), y: values[j].doubleValue))
            }
            dataValues.append(subDataValues)
        }
        
        var colors = colorsPalet()

        var dataSets: Array<LineChartDataSet> = Array<LineChartDataSet>()
        for i in 0..<titles.count {
            let dataSet = LineChartDataSet(values: dataValues[i], label: titles[i])
            dataSet.mode = .cubicBezier
            dataSet.lineWidth = 2.0
            dataSet.setColor(colors[i])
            dataSet.drawCirclesEnabled = false
            dataSet.drawValuesEnabled = false
            dataSets.append(dataSet)
        }

        let lineChartData = LineChartData(dataSets: dataSets)
        lineChartData.setValueFormatter(self)


        self.xAxisValues = headers
        self.lcView.data = lineChartData
        self.lcView.xAxis.labelCount = headers.count
        lcView.animate(xAxisDuration: 1.0, easingOption: ChartEasingOption.easeInElastic)
    }
    func setDataForBarChart(_ jsonObject: NSDictionary){
        let stacked = jsonObject["stacked"] != nil ? jsonObject["stacked"] as! Bool : false
        let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
        let headers: Array<String> = jsonObject["X_axis"] != nil ? jsonObject["X_axis"] as! Array<String> : []
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
                subDataValues.append(BarChartDataEntry(x: Double(j), y: values[j].doubleValue))
            }
            dataValues.append(subDataValues)
        }
        
        //        dataValues = transpose(input: dataValues)
        
        var colors = colorsPalet()
        
        var dataSets: Array<BarChartDataSet> = Array<BarChartDataSet>()
        for i in 0..<titles.count {
            let dataSet = BarChartDataSet(values: dataValues[i], label: titles[i])
            dataSet.setColor(colors[i])
            dataSets.append(dataSet)
        }
        
        let barChartData = BarChartData(dataSets: dataSets)
        barChartData.setValueTextColor(UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1))
        barChartData.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: 8.0) ?? UIFont.systemFont(ofSize: 8.0, weight: .medium))
        barChartData.setDrawValues(false)
        barChartData.setValueFormatter(self)
        
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        let groupSpace = 0.30
        let barSpace = 0.01
        let barWidth = ((1.0 - groupSpace)/Double(dataSets.count)) - barSpace
        barChartData.barWidth = barWidth
        if(!stacked){
            barChartData.groupBars(fromX: -0.5, groupSpace: groupSpace, barSpace: barSpace)
        }
        
        self.xAxisValues = headers
        bcView.fitBars = true
        self.bcView.data = barChartData
        
        self.bcView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        self.bcView.setVisibleXRangeMaximum(Double(headers.count))
    }
    
    func setDataForStackedBarChart(_ jsonObject: NSDictionary){
        let stacked = jsonObject["stacked"] != nil ? jsonObject["stacked"] as! Bool : false
        let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
        let headers: Array<String> = jsonObject["X_axis"] != nil ? jsonObject["X_axis"] as! Array<String> : []
        var valuesArray: Array<Array<NSNumber>> = Array<Array<NSNumber>>()
        let elementsCount: Int = elements.count
        
        var titles: Array<String> = Array<String>()
        for i in 0..<elementsCount {
            let dictionary = elements[i]
            let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
            titles.append(title)

            let values: Array<NSNumber> = dictionary["values"] != nil ? dictionary["values"] as! Array<NSNumber> : []
            valuesArray.append(values)
        }
        
        var subDataValues: Array<BarChartDataEntry> = Array<BarChartDataEntry>()
        for j in 0..<headers.count {
            var values = [Double]();
            for i in 0..<valuesArray.count {
                values.append(valuesArray[i][j].doubleValue)
            }
            subDataValues.append(BarChartDataEntry(x: Double(j), yValues: values))
        }
      


        let colors = colorsPalet()
//        var colorsArray:  Array<UIColor> =  Array<UIColor>()
//        colorsArray.append(colors[0])

        var dataSets: Array<BarChartDataSet> = Array<BarChartDataSet>()
        for _ in 0..<1 {
            let dataSet = BarChartDataSet(values: subDataValues, label:"")
            dataSet.stackLabels = titles
            let n = titles.count
            let colorsArr:[NSUIColor] = Array(colors.prefix(n))
            dataSet.colors = colorsArr
            dataSets.append(dataSet)
        }

        let barChartData = BarChartData(dataSets: dataSets)
        barChartData.setValueTextColor(UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1))
        barChartData.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: 8.0) ?? UIFont.systemFont(ofSize: 8.0, weight: .medium))
        barChartData.setDrawValues(false)
        barChartData.setValueFormatter(self)
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        let groupSpace = 0.30
        let barSpace = 0.01
        let barWidth = ((1.0 - groupSpace)/Double(dataSets.count)) - barSpace
        barChartData.barWidth = barWidth
        if(!stacked){
            barChartData.groupBars(fromX: -0.5, groupSpace: groupSpace, barSpace: barSpace)
        }
        
        self.xAxisValues = headers
        bcView.fitBars = true
        self.bcView.data = barChartData
       
        self.bcView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        self.bcView.setVisibleXRangeMaximum(Double(headers.count))
    }
    
    func initializeViewForType(_ type: String, jsonObject: NSDictionary){
        if type == "piechart" {
            let pieType = jsonObject["pie_type"] != nil ? jsonObject["pie_type"] as! String : "regular"
            intializePieChartView(pieType)
        }else if type == "linechart" {
            intializeLineChartView()
        }else if type == "barchart" {
             let direction = jsonObject["direction"] != nil ? jsonObject["direction"] as! String : "horizontal"
            intializeBarChartView(direction)
        }
    }
    
    func setDataForType(_ type: String, jsonObject: NSDictionary){
        if type == "piechart" {
            let pieType = jsonObject["pie_type"] != nil ? jsonObject["pie_type"] as! String : "regular"
            setDataForPieChart(jsonObject,pieType)
        }else if type == "linechart" {
            setDataForLineChart(jsonObject)
        }else if type == "barchart" {
            let stacked = jsonObject["stacked"] != nil ? jsonObject["stacked"] as! Bool : false
            if(!stacked){
                setDataForBarChart(jsonObject)
            }
            else{
                setDataForStackedBarChart(jsonObject)
            }
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
                self.initializeViewForType(chartType,jsonObject: jsonObject)
                self.setDataForType(chartType, jsonObject: jsonObject)
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0.0, height: 280)
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
