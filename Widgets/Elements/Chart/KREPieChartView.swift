//
//  KREChartView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Charts

public class KREPieChartView: UIView {
    // MARK: - properties
    public lazy var pieChartView: PieChartView = {
        let pieChartView = PieChartView(frame: .zero)
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        return pieChartView
    }()

    public var optionsAction: ((String?) -> Void)?
    public var linkAction: ((String?) -> Void)?

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
        addSubview(pieChartView)
        
        let views: [String: UIView] = ["pieChartView": pieChartView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pieChartView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pieChartView]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - initialize chart views
    func intializePieChartView(_ pieType: String?) {
        let legend = pieChartView.legend
        switch pieType {
        case "regular":
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .top
            legend.orientation = .vertical
            legend.drawInside = false
            legend.formSize = 12.0
            legend.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
            legend.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
            legend.form = .circle
            
            pieChartView.chartDescription?.enabled = false
            pieChartView.drawHoleEnabled = false
            pieChartView.drawEntryLabelsEnabled = false
            pieChartView.extraRightOffset = 0.0
            pieChartView.rotationEnabled = false
        case "donut":
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .top
            legend.orientation = .vertical
            legend.drawInside = false
            legend.formSize = 12.0
            legend.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
            legend.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
            
            pieChartView.chartDescription?.enabled = false
            pieChartView.drawHoleEnabled = true
            pieChartView.drawEntryLabelsEnabled = false
            pieChartView.extraRightOffset = 0.0
            pieChartView.rotationEnabled = false
            pieChartView.usePercentValuesEnabled = true
        case "donut_legend":
            legend.horizontalAlignment = .right
            legend.verticalAlignment = .center
            legend.orientation = .vertical
            legend.drawInside = false
            legend.formSize = 12.0
            legend.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
            legend.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
            legend.form = .circle
            
            pieChartView.chartDescription?.enabled = false
            pieChartView.drawHoleEnabled = true
            pieChartView.drawEntryLabelsEnabled = false
            pieChartView.extraRightOffset = 5.0
            pieChartView.rotationEnabled = false
        default:
            break
        }
        invalidateIntrinsicContentSize()
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
    
    // MARK: - populate pie chart data
    func populatePieChartData(_ chartData: KREPieChartData) {
        intializePieChartView(chartData.pieType)
        var values: [PieChartDataEntry] = [PieChartDataEntry]()
        var rightOffset: CGFloat = 0.0
        for element in chartData.elements ?? []  {
            let title = element.title ?? ""
            let value = element.value ?? "0.0"
            let displayValue = element.displayValue ?? ""
            switch chartData.pieType {
            case "donut_legend", "donut":
                let pieChartDataEntry = PieChartDataEntry(value: (value as NSString).doubleValue, label: title + "  " + displayValue, data: chartData)
                values.append(pieChartDataEntry)
            default:
                let pieChartDataEntry = PieChartDataEntry(value: (value as NSString).doubleValue, label: title, data: chartData)
                values.append(pieChartDataEntry)
            }
            rightOffset = CGFloat.maximum(rightOffset, (title as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.textFont(ofSize: 14.0, weight: .medium)]).width)
        }
        
        let pieChartDataSet = PieChartDataSet(values: values, label: "")
        pieChartDataSet.colors = colorsPalet()
        pieChartDataSet.sliceSpace = 2.0
        
        switch chartData.pieType {
        case "regular":
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            pieChartData.setValueFont(UIFont.textFont(ofSize: 14.0, weight: .medium))
            pieChartDataSet.yValuePosition = .outsideSlice
            pieChartDataSet.valueLinePart1OffsetPercentage = 0.8
            pieChartDataSet.valueLinePart1Length = 0.4
            pieChartDataSet.valueLinePart2Length = 0.4
            pieChartDataSet.valueLineColor = UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1)
            pieChartData.setValueFont(UIFont.textFont(ofSize: 14.0, weight: .medium))
            pieChartData.setValueTextColor(UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1))
            pieChartData.setDrawValues(true)
            pieChartView.extraRightOffset = rightOffset
            pieChartView.data = pieChartData
            pieChartView.highlightValues(nil)
            pieChartView.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInOutBack)
        case "donut":
            pieChartDataSet.selectionShift = 7            
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            pieChartData.setValueFont(UIFont.textFont(ofSize: 12.0, weight: .medium))
            pieChartData.setValueTextColor(UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1))
            pieChartData.setDrawValues(true)
            pieChartView.extraRightOffset = rightOffset
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .percent
            pFormatter.maximumFractionDigits = 1
            pFormatter.multiplier = 1
            pFormatter.percentSymbol = " %"
            
            pieChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            pieChartView.data = pieChartData
            pieChartView.highlightValues(nil)
            pieChartView.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInOutBack)
        case "donut_legend":
            pieChartDataSet.selectionShift = 7
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            pieChartData.setDrawValues(false)
            pieChartView.extraRightOffset = rightOffset
            pieChartView.data = pieChartData
            pieChartView.highlightValues(nil)
            
            pieChartView.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInOutBack)
        default:
            break
        }
    }
    
    func prepareForReuse() {
        pieChartView.removeFromSuperview()
    }
}
