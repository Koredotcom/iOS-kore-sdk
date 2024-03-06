//
//  KREChartView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import DGCharts

public class KREBarChartView: UIView {
    // MARK: - properties
    public lazy var horizontalBarChartView: HorizontalBarChartView = {
        let hbcView = HorizontalBarChartView(frame: .zero)
        hbcView.translatesAutoresizingMaskIntoConstraints = false
        return hbcView
    }()
    
    public lazy var barChartView: BarChartView = {
        let barChartView = BarChartView(frame: .zero)
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        return barChartView
    }()
    
    public lazy var bcView = barChartView

    var xAxisValues = [String]()
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

    }
    
    // MARK: initialize chart views
    func intializeBarChartView(_ direction: String) {
        if direction == "horizontal" {
            bcView = horizontalBarChartView
        }
        
        bcView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bcView)
        
        let views: [String: UIView] = ["bcView": bcView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[bcView]-15-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[bcView]-15-|", options: [], metrics: nil, views: views))
        
        bcView.chartDescription.enabled = false
        if direction == "horizontal" {
            bcView.leftAxis.enabled = false
        } else {
            bcView.leftAxis.enabled = true
        }
        bcView.leftAxis.drawAxisLineEnabled = true
        bcView.leftAxis.drawGridLinesEnabled = false
        bcView.leftAxis.labelTextColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        bcView.rightAxis.enabled = false
        
        bcView.xAxis.labelPosition = .bottom
        bcView.xAxis.labelTextColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        bcView.xAxis.drawAxisLineEnabled = true
        bcView.xAxis.drawGridLinesEnabled = false
        bcView.xAxis.granularity = 1.0
        //bcView.xAxis.valueFormatter = self
        
        bcView.drawGridBackgroundEnabled = false
        bcView.drawBordersEnabled = false
        bcView.dragEnabled = true
        bcView.pinchZoomEnabled = true
        
        let legend: Legend = bcView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = true
        legend.formSize = 12.0
        legend.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        legend.font = UIFont(name: mediumCustomFont, size: 12.0) ?? UIFont.systemFont(ofSize: 12.0)
        
        let marker = BalloonMarker(color: UIColor.white.withAlphaComponent(0.9), font: UIFont(name: boldCustomFont, size: 12.0) ?? UIFont.systemFont(ofSize: 12.0), textColor: .black, insets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 20.0, right: 8.0))
        bcView.marker = marker
    }
    
    func colorsPalet() -> [NSUIColor]{
        var colors: Array<UIColor> = Array<UIColor>()
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
    func populateBarChart(_ chartData: KREBarChartData) {
        let stacked = chartData.stacked ?? false
        let headers = chartData.xAxis ?? []
        
        var dataValues: Array<[BarChartDataEntry]> = Array<[BarChartDataEntry]>()
        var titles: Array<String> = Array<String>()
        for element in chartData.elements ?? [] {
            let title: String = element.title ?? ""
            titles.append(title)
            
            let values = element.values ?? []
            var subDataValues: [BarChartDataEntry] = [BarChartDataEntry]()
            for j in 0..<values.count {
                subDataValues.append(BarChartDataEntry(x: Double(j), y: values[j]))
            }
            dataValues.append(subDataValues)
        }
                
        let colors = colorsPalet()
        var dataSets: Array<BarChartDataSet> = Array<BarChartDataSet>()
        for i in 0..<titles.count {
            let dataSet = BarChartDataSet(entries: dataValues[i], label: titles[i])
            dataSet.setColor(colors[i])
            dataSets.append(dataSet)
        }
        
        let barChartData = BarChartData(dataSets: dataSets)
        barChartData.setValueTextColor(UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1))
        barChartData.setValueFont(UIFont(name: mediumCustomFont, size: 8.0) ?? UIFont.systemFont(ofSize: 8.0, weight: .medium))
        barChartData.setDrawValues(false)
        //barChartData.setValueFormatter(self)
        
        let groupSpace = 0.30
        let barSpace = 0.01
        let barWidth = ((1.0 - groupSpace)/Double(dataSets.count)) - barSpace
        barChartData.barWidth = barWidth
        if !stacked {
            barChartData.groupBars(fromX: -0.5, groupSpace: groupSpace, barSpace: barSpace)
        }
        
        xAxisValues = headers
        bcView.fitBars = true
        bcView.data = barChartData
        
        bcView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        bcView.setVisibleXRangeMaximum(Double(headers.count))
    }
    
    func populatStackedBarChart(_ chartData: KREBarChartData) {
        let stacked = chartData.stacked ?? false
        let headers = chartData.xAxis ?? []
        var valuesArray: Array<[Double]> = Array<[Double]>()
        
        var titles: Array<String> = Array<String>()
        for element in chartData.elements ?? [] {
            let title = element.title ?? ""
            titles.append(title)
            
            let values = element.values ?? []
            valuesArray.append(values)
        }
        
        var subDataValues: Array<BarChartDataEntry> = Array<BarChartDataEntry>()
        for j in 0..<headers.count {
            var values = [Double]();
            for i in 0..<valuesArray.count {
                values.append(valuesArray[i][j])
            }
            subDataValues.append(BarChartDataEntry(x: Double(j), yValues: values))
        }
                
        let colors = colorsPalet()
        var dataSets: Array<BarChartDataSet> = Array<BarChartDataSet>()
        for _ in 0..<1 {
            let dataSet = BarChartDataSet(entries: subDataValues, label:"")
            dataSet.stackLabels = titles
            let n = titles.count
            let colorsArr:[NSUIColor] = Array(colors.prefix(n))
            dataSet.colors = colorsArr
            dataSets.append(dataSet)
        }
        
        let barChartData = BarChartData(dataSets: dataSets)
        barChartData.setValueTextColor(UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1))
        barChartData.setValueFont(UIFont(name: mediumCustomFont, size: 8.0) ?? UIFont.systemFont(ofSize: 8.0, weight: .medium))
        barChartData.setDrawValues(false)
        //barChartData.setValueFormatter(self)

        let groupSpace = 0.30
        let barSpace = 0.01
        let barWidth = ((1.0 - groupSpace)/Double(dataSets.count)) - barSpace
        barChartData.barWidth = barWidth
        if !stacked {
            barChartData.groupBars(fromX: -0.5, groupSpace: groupSpace, barSpace: barSpace)
        }
        
        xAxisValues = headers
        bcView.fitBars = true
        bcView.data = barChartData
        
        bcView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        bcView.setVisibleXRangeMaximum(Double(headers.count))
    }
    
    func populateChartData(_ chartData: KREBarChartData) {
        let stacked = chartData.stacked ?? false
        let direction = chartData.direction ?? "horizontal"
        intializeBarChartView(direction)

        if !stacked {
            populateBarChart(chartData)
        } else {
            populatStackedBarChart(chartData)
        }
    }
    
    // MARK: -
    func prepareForReuse() {
        bcView.removeFromSuperview()
        xAxisValues.removeAll()
    }
}

// MARK: - IAxisValueFormatter, IValueFormatter
extension KREBarChartView {
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
