//
//  KREChartView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Charts

public class KRELineChartView: UIView {
    // MARK: - properties
    public lazy var lineChartView: LineChartView = {
        let lineChartView = LineChartView()
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        return lineChartView
    }()
    
    var xAxisValues: Array<String>!
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 280.0)
    }

    // MARK: - setup
    func setup() {
        addSubview(lineChartView)
        
        let views: [String: UIView] = ["lineChartView": lineChartView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[lineChartView]-15-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[lineChartView]-15-|", options: [], metrics: nil, views: views))
    }
    
    // MARK: initialize line chart view
    func intializeLineChartView() {
        lineChartView.chartDescription?.enabled = false
        lineChartView.isUserInteractionEnabled = false
        
        lineChartView.leftAxis.enabled = true
        lineChartView.leftAxis.drawAxisLineEnabled = true
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.labelTextColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        lineChartView.rightAxis.enabled = false
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        lineChartView.xAxis.drawAxisLineEnabled = true
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.granularity = 1.0
        lineChartView.xAxis.valueFormatter = self
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.drawBordersEnabled = false
        lineChartView.dragEnabled = true
        lineChartView.pinchZoomEnabled = true
        
        let legend: Legend = lineChartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = true
        legend.formSize = 12.0
        legend.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        legend.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)!
        legend.form = .circle
    }
    
    func colorsPalet() -> [NSUIColor]{
        var colors: Array<UIColor> = Array<UIColor>()
        colors.append(UIColor(red: 95/255, green: 107/255, blue: 247/255, alpha: 1))
        colors.append(UIColor(red: 153/255, green: 237/255, blue: 158/255, alpha: 1))
        colors.append(UIColor(red: 247/255, green: 128/255, blue: 131/255, alpha: 1))
        colors.append(UIColor(red: 247/255, green: 128/255, blue: 131/255, alpha: 1))
        colors.append(UIColor(red: 253/255, green: 226/255, blue: 150/255, alpha: 1))
        colors.append(UIColor(red: 117/255, green: 176/255, blue: 254/255, alpha: 1))
        colors.append(UIColor(red: 38/255,  green: 52/255, blue: 74/255, alpha: 1))
        colors.append(UIColor(red: 153/255, green: 161/255, blue: 253/255, alpha: 1))
        colors.append(UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1))
        colors.append(UIColor(red: 156/255, green: 235/255, blue: 249/255, alpha: 1))
        colors.append(UIColor(red: 247/255, green: 199/255, blue: 244/255, alpha: 1))
        
        colors.append(contentsOf: ChartColorTemplates.colorful())
        colors.append(contentsOf: ChartColorTemplates.joyful())
        colors.append(contentsOf: ChartColorTemplates.liberty())
        colors.append(contentsOf: ChartColorTemplates.material())
        colors.append(contentsOf: ChartColorTemplates.pastel())
        colors.append(contentsOf: ChartColorTemplates.vordiplom())
        return colors
    }
    
    // MARK: - populate line chart
    func populateLineChart(_ chartData: KRELineChartData) {
        intializeLineChartView()
        let headers: [String] = chartData.xAxis ?? []
        
        var dataValues: Array<[ChartDataEntry]> = Array<[ChartDataEntry]>()
        var titles: [String] = [String]()
        for element in chartData.elements ?? [] {
            let title: String = element.title ?? ""
            titles.append(title)
            
            var values = element.values ?? []
            if values.count < headers.count {
                for _ in 0..<headers.count - values.count {
                    values.append(0)
                }
            }
            var subDataValues: Array<ChartDataEntry> = Array<ChartDataEntry>()
            for j in 0..<headers.count {
                subDataValues.append(ChartDataEntry(x: Double(j), y: values[j]))
            }
            dataValues.append(subDataValues)
        }
        
        let colors = colorsPalet()
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
        
        xAxisValues = headers
        lineChartView.data = lineChartData
        lineChartView.xAxis.labelCount = headers.count
        lineChartView.animate(xAxisDuration: 1.0, easingOption: ChartEasingOption.easeInElastic)
    }
    
    // MARK: -
    func prepareForReuse() {
        lineChartView.removeFromSuperview()
        xAxisValues = Array<String>()
    }
}

// MARK: -
extension KRELineChartView: IAxisValueFormatter, IValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        if xAxisValues.count > index {
            return xAxisValues[index]
        }
        return "\(value)"
    }
    
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if let dictionary = entry.data as? NSDictionary, let keys = dictionary.allKeys as? [String] {
            for i in 0..<keys.count {
                if keys[i] == "displayValue", let value = dictionary["displayValue"] as? String {
                    return value
                }
            }
        }
        return "\(value)"
    }
}
