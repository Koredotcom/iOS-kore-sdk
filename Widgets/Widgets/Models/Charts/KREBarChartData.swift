//
//  KREBarChartData.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREBarChartData: NSObject, Decodable {
    // MARK: - properties
    public var title: String?
    public var subTitle: String?
    public var buttons: [KREAction]?
    public var elements: [KRELineChartDataEntry]?
    public var xAxis: [String]?
    public var autoAdjustXAxis: Bool?
    public var direction: String?
    public var stacked: Bool?
    
    public enum ChartDataKeys: String, CodingKey {
        case title = "title"
        case subTitle = "sub-title"
        case xAxis = "X_axis"
        case autoAdjustXAxis = "Auto_adjust_X_axis"
        case direction = "direction"
        case stacked = "stacked"
        case elements = "elements"
        case buttons = "buttons"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: ChartDataKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subTitle = try? container.decode(String.self, forKey: .subTitle)
        xAxis = try? container.decode([String].self, forKey: .xAxis)
        autoAdjustXAxis = try? container.decode(Bool.self, forKey: .autoAdjustXAxis)
        stacked = try? container.decode(Bool.self, forKey: .stacked)
        direction = try? container.decode(String.self, forKey: .direction)
        buttons = try? container.decode([KREAction].self, forKey: .buttons)
        elements = try? container.decode([KRELineChartDataEntry].self, forKey: .elements)
    }
}

public class KREBarChartDataEntry: NSObject, Decodable {
    public var title: String?
    public var values: [Double]?
    public var displayValues: [String]?

    public enum ButtonKeys: String, CodingKey {
        case title = "title"
        case values = "values"
        case displayValues = "displayValues"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ButtonKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        values = try? container.decode([Double].self, forKey: .values)
        displayValues = try? container.decode([String].self, forKey: .displayValues)
    }
}
