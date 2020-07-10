//
//  KREPieChartData.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREPieChartData: NSObject, Decodable {
    // MARK: - properties
    public var title: String?
    public var subTitle: String?
    public var pieType: String?
     public var templateType: String?
    public var buttons: [KREButtonTemplate]?
    public var elements: [KREPieChartDataEntry]?
    public var headerOptions: KREHeaderOptions?
    public var buttonsLayout: KREButtonsLayout?
    
    public enum ChartDataKeys: String, CodingKey {
        case title = "title"
        case subTitle = "sub-title"
        case pieType = "pie_type"
        case templateType = "templateType"
        case elements = "elements"
        case buttons = "buttons"
        case headerOptions = "headerOptions"
        case buttonsLayout = "buttonsLayout"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: ChartDataKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subTitle = try? container.decode(String.self, forKey: .subTitle)
        pieType = try? container.decode(String.self, forKey: .pieType)
        templateType = try? container.decode(String.self, forKey: .templateType)
        buttons = try? container.decode([KREButtonTemplate].self, forKey: .buttons)
        elements = try? container.decode([KREPieChartDataEntry].self, forKey: .elements)
        headerOptions = try? container.decode(KREHeaderOptions.self, forKey: .headerOptions)
        buttonsLayout = try? container.decode(KREButtonsLayout.self, forKey: .buttonsLayout)
    }
}

public class KREPieChartDataEntry: NSObject, Decodable {
    public var title: String?
    public var subTitle: String?
    public var value: String?
    public var displayValue: String?

    public enum ButtonKeys: String, CodingKey {
        case title = "title"
        case value = "value"
        case subTitle = "subTitle"
        case displayValue = "displayValue"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ButtonKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subTitle = try? container.decode(String.self, forKey: .subTitle)
        value = try? container.decode(String.self, forKey: .value) //Double 
        displayValue = try? container.decode(String.self, forKey: .displayValue)
    }
}
