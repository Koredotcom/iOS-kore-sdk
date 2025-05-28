//
//  ServerConfigs.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 10/25/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

import UIKit
import Foundation

var startSpeakingNotification = "StartSpeakingNowNotificationName"
var stopSpeakingNotification = "StopSpeakingNowNotificationName"
var showTableTemplateNotification = "ShowTableTemplateNotificationName"
var reloadTableNotification = "reloadTableNotification"
var updateUserImageNotification = "updateUserImageNotification"
var showListViewTemplateNotification = "ListViewTemplateNotificationName"
var showArticleTemplateNotification = "ArticleTemplateNotificationName"
var showListWidgetViewTemplateNotification = "ListWidgetViewTemplateNotificationName"
var advancedMultiSelectTemplateNotification = "AdvancedMultiSelectTemplateNotification"
var showAttachmentSendButtonNotification = "ShowAttachmentSendButton"
var dropDownTemplateNotification = "DropDownTemplateNotificationName"
var showCustomTableTemplateNotification = "ShowCustomTableTemplateNotificationName"
var pdfcTemplateViewNotification = "pdfShowViewNotification"
var pdfcTemplateViewErrorNotification = "pdfShowErrorNotification"
var reloadVideoCellNotification = "ReloadVideoCellNotification"
var callFromAgentNotification = "callFromAgentNotification"
var tokenExipryNotification = "TokenExpiryNotification"

var isSpeakingEnabled = false

let userColor: UIColor = UIColor(red: 38 / 255.0, green: 52 / 255.0, blue: 74 / 255.0, alpha: 1)
let botColor: UIColor = UIColor(red: 237 / 255.0, green: 238 / 255.0, blue: 241 / 255.0, alpha: 1)

var themeColor: UIColor = UIColor.init(hexString: "#2881DF")
var isAgentConnect = false

var isTryConnect = true
var isInternetAvailable = true
var isBotConnectSucessFully = false

var AcccesssTokenn:String?
var attachmentKeybord = false
var jwtToken:String?
var botHistoryIcon:String?
var lastMessageID:String?
var isIntialiseFileUpload = false
var history = true
var isShowWelcomeMsg = true
var calenderCloseTag = true

var isShowComposeMenuBtn = false
var isShowComposeAttachmentBtn = true

var regularCustomFont = "HelveticaNeue"
var mediumCustomFont = "HelveticaNeue-Medium"
var boldCustomFont = "HelveticaNeue-Bold"
var semiBoldCustomFont = "HelveticaNeue-Semibold"
var italicCustomFont =  "HelveticaNeue-Italic"

//SDKV3
var brandingValues = BrandingModel()
var brandingBodyDic = Body()
var btnBgActiveColor = "#4B4EDE"
var btnActiveTextColor = "#FFFFFF"
var btnBoarderColor = "#4B4EDE"
var templateBoarderColor = "#E4E5E7"

var genaralPrimaryColor = "#D38A17"
var genaralSecondaryColor = "#101828"
var genaralPrimary_textColor = "#C1EDB9"
var genaralSecondary_textColor = "#000000"
var useColorPaletteOnly = false
var headerTxt = SDKConfiguration.botConfig.chatBotName

var arrayOfViews = [BubbleView.Type]()
var arrayOfTemplateTypes = [String]()
var quickRepliesIsHorizontal = false
var feedBackTemplateSelectedValue = ""
var isShowQuickRepliesBottom = true
var arrayOfSelectedBtnIndex:NSMutableArray = NSMutableArray()

var notDeliverdMsgsArray = [String]()
var historyLimit = 0
var RemovedTemplateCount = 0
var isCallingHistoryApi = true
var close_AgentChat_EventName = "close_agent_chat"
var close_Button_EventName = "close_button_event"
var minimize_Button_EventName = "minimize_button_event"
var isZenDesk_Event = false


var isOTPValidationTemplate = false
var OTPValidationRemoveCount = 0
var otpValidationTemplateNotification = "OTPvalidationTemplateNotificationName"
var resetpinTemplateNotification = "ResetPinTemplateNotificationName"

var connectModeString:String? = nil
var loadReconnectionHistory = false
var isNetworkOnResumeCallingHistory = true
var statusBarBackgroundColor:UIColor? = nil
var statusBarBottomBackgroundColor:UIColor? = nil

var overRideBrandingTheme:BrandingModel? = nil

var emojiDic = [String : Any]()
var isEmojiDispaly = false
var recentHistoryBatchSize = 10
var isPaginatedScrollEnable = SDKConfiguration.botConfig.isShowChatHistory
var paginatedScrollBatchSize = 10

open class Common : NSObject {
    public static func UIColorRGB(_ rgb: Int) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
    
    public static func UIColorRGBA(_ rgb: Int, a: CGFloat) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: a)
    }
}

open class Utilities: NSObject {
    // MARK:-
    public static func stringFromJSONObject(object: Any) -> String? {
        var jsonString: String? = nil
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            jsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        } catch {
            print(error.localizedDescription)
        }
        return jsonString
    }
    
    public static func jsonObjectFromString(jsonString: String) -> Any? {
        var jsonObject: Any?
        do {
            let data: Data = jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as Data
            jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return jsonObject!
        } catch {
            print(error.localizedDescription)
        }
        return jsonObject
    }
    
    public static func getKREActionFromDictionary(dictionary: Dictionary<String, Any>) -> KREAction? {
        let actionInfo:Dictionary<String,Any> = dictionary
        let actionType: String = actionInfo["type"] != nil ? actionInfo["type"] as! String : ""
        let title: String = actionInfo["title"] != nil ? actionInfo["title"] as! String : ""
        switch (actionType.lowercased()) {
        case "web_url", "iframe_web_url", "url":
            let url: String = actionInfo["url"] != nil ? actionInfo["url"] as! String : ""
            return KREAction(actionType: .webURL, title: title, payload: url)
        case "postback":
            let payload: String = (actionInfo["payload"] != nil ? actionInfo["payload"] as? String : "") ?? String(actionInfo["payload"] as! Int) 
            return KREAction(actionType: .postback, title: title, payload: payload)
        case "postback_disp_payload":
            let payload: String = actionInfo["payload"] != nil ? actionInfo["payload"] as! String : ""
            return KREAction(actionType: .postback_disp_payload, title: payload, payload: payload)
        default:
            break
        }
        return nil
    }
    
    public static func base64ToImage(base64String: String?) -> UIImage{
        if (base64String?.isEmpty)! {
            return #imageLiteral(resourceName: "no_image_found")
        }else {
            // Separation part is optional, depends on your Base64String !
            let tempImage = base64String?.components(separatedBy: ",")
            let dataDecoded : Data = Data(base64Encoded: tempImage![1], options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            let pngImage = UIImage(named: "faceIcon", in: Bundle.sdkModule, compatibleWith: nil)
            return decodedimage ?? UIImage(data: (pngImage?.pngData())!)!
        }
    }
    
    public static func isValidJson(check jsonString:String) -> Bool{
        if let jsonDataToVerify = jsonString.data(using: .utf8)
        {
            do {
                _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)
                print("JSON is valid.")
                return true
            } catch {
                //print("Error deserializing JSON: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }
    
    public static func getTimeformater(sentOn: Date) -> String{
        var time = ""
        let today = Date()
        let yesterday = Date().yesterday
        let dateFormt = DateFormatter()
        dateFormt.dateFormat = "MMM dd yyyy"
        
        var todayOrYesterDay = Date()
        var is12or24Format = false
        if dateFormt.string(from: sentOn) == dateFormt.string(from: today){
            todayOrYesterDay = today
            is12or24Format = true
        }else if dateFormt.string(from: sentOn) == dateFormt.string(from: yesterday){
            todayOrYesterDay = yesterday
            is12or24Format = true
        }else{
            is12or24Format = false
            let dateFormatter = DateFormatter()
            
            var formatterStr = "\(brandingBodyDic.time_stamp?.date_format ?? "")"
            if "dd/mm/yyyy" == formatterStr.lowercased(){
                formatterStr = "dd/MM/yyyy"
            }else if "mm/dd/yyyy" == formatterStr.lowercased(){
                formatterStr = "MM/dd/yyyy"
            }else if "mmm/dd/yyyy" == formatterStr.lowercased(){
                formatterStr = "MMM/dd/yyyy"
            }
            
            var formte = ""
            formte = formatterStr.replacingOccurrences(of: "D", with: "d")
            formte = formte.replacingOccurrences(of: "Y", with: "y")
            dateFormatter.dateFormat = formte
            let timeFormatter = DateFormatter()
            if brandingBodyDic.time_stamp?.timeformat == "24"{
                timeFormatter.dateFormat = "HH:mm"
            }else{
                timeFormatter.dateFormat = "h:mm a"
            }
            let date = dateFormatter.string(from: sentOn)
            let timee = timeFormatter.string(from: sentOn)
            time = "\(timee), \(date)"
        }
        
        if is12or24Format{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
            
            if let time_format = brandingBodyDic.time_stamp?.timeformat, time_format == "24"{
                let timeFormatter24 = DateFormatter()
                timeFormatter24.dateFormat = "HH:mm"
                time = "\(timeFormatter24.string(from: sentOn)), \(dateFormatter.string(from: todayOrYesterDay))"
                
            }else if let time_format = brandingBodyDic.time_stamp?.timeformat, time_format == "12"{
                let timeFormatter12 = DateFormatter()
                timeFormatter12.dateFormat = "h:mm a"
                
                time = "\(timeFormatter12.string(from: sentOn)), \(dateFormatter.string(from: todayOrYesterDay))"
                
            }
        }
        
        return time
    }
    
    public static func getDateformater(sentOn: Date) -> String{
        var time = ""
        let today = Date()
        let yesterday = Date().yesterday
        let dateFormt = DateFormatter()
        dateFormt.dateFormat = "MMM dd yyyy"
        
        var todayOrYesterDay = Date()
        var is12or24Format = false
        if dateFormt.string(from: sentOn) == dateFormt.string(from: today){
            todayOrYesterDay = today
            is12or24Format = true
        }else if dateFormt.string(from: sentOn) == dateFormt.string(from: yesterday){
            todayOrYesterDay = yesterday
            is12or24Format = true
        }else{
            is12or24Format = false
            let dateFormatter = DateFormatter()
            
            var formatterStr = "\(brandingBodyDic.time_stamp?.date_format ?? "")"
            if "dd/mm/yyyy" == formatterStr.lowercased(){
                formatterStr = "dd/MM/yyyy"
            }else if "mm/dd/yyyy" == formatterStr.lowercased(){
                formatterStr = "MM/dd/yyyy"
            }else if "mmm/dd/yyyy" == formatterStr.lowercased(){
                formatterStr = "MMM/dd/yyyy"
            }
            
            var formte = ""
            formte = formatterStr.replacingOccurrences(of: "D", with: "d")
            formte = formte.replacingOccurrences(of: "Y", with: "y")
            dateFormatter.dateFormat = formte
            let timeFormatter = DateFormatter()
            if brandingBodyDic.time_stamp?.timeformat == "24"{
                timeFormatter.dateFormat = "HH:mm"
            }else{
                timeFormatter.dateFormat = "h:mm a"
            }
            let date = dateFormatter.string(from: sentOn)
            let timee = timeFormatter.string(from: sentOn)
            time = "\(date)"
        }
        
        if is12or24Format{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
            
            if let time_format = brandingBodyDic.time_stamp?.timeformat, time_format == "24"{
                let timeFormatter24 = DateFormatter()
                timeFormatter24.dateFormat = "HH:mm"
                time = "\(timeFormatter24.string(from: sentOn)), \(dateFormatter.string(from: todayOrYesterDay))"
                
            }else if let time_format = brandingBodyDic.time_stamp?.timeformat, time_format == "12"{
                let timeFormatter12 = DateFormatter()
                timeFormatter12.dateFormat = "h:mm a"
                
                time = "\(dateFormatter.string(from: todayOrYesterDay))"
                
            }
        }
        
        return time
    }
    public static func isValidJsonString(check jsonString:String) -> Bool{
        if let jsonDataToVerify = jsonString.data(using: .utf8)
        {
            do {
                _ = try JSONSerialization.jsonObject(with: jsonDataToVerify)
                //print("JSON is valid.")
                return true
            } catch {
                //print("Error deserializing JSON: \(error.localizedDescription)")
                return false
            }
        }
        return false
    }
    
    public static func getComponentTypes(_ templateType: String,_ tabledesign:String) -> ComponentType {
        if (templateType == "quick_replies") {
            return .quickReply
        } else if (templateType == "buttonn") {
            return .options
        }else if (templateType == "list") {
            return .list
        }else if (templateType == "carousel") {
            return .carousel
        }else if (templateType == "piechart" || templateType == "linechart" || templateType == "barchart") {
            return .chart
        }else if (templateType == "table"  && tabledesign == "regular") {
            return .table
        }
        else if (templateType == "table"  && tabledesign == "responsive") {
            return .responsiveTable
        }
        else if (templateType == "mini_table") {
            return .minitable
        }
        else if (templateType == "mini_table_horizontal") {
            return .minitable_Horizontal
        }
        else if (templateType == "menu") {
            return .menu
        }
        else if (templateType == "listView") {
            return .newList
        }
        else if (templateType == "tableList") {
            return .tableList
        }
        else if (templateType == "daterange" || templateType == "dateTemplate" || templateType == "clockTemplate") {
            return .calendarView
        }
        else if (templateType == "quick_replies_welcome" || templateType == "button"){
            return .quick_replies_welcome
        }
        else if (templateType == "Notification") {
            return .notification
        }
        else if (templateType == "multi_select") {
            return .multiSelect
        }
        else if (templateType == "listWidget") {
            return .list_widget
        }
        else if (templateType == "feedbackTemplate") {
            return .feedbackTemplate
        }
        else if (templateType == "form_template") {
            return .inlineForm
        }
        else if (templateType == "dropdown_template") {
            return .dropdown_template
        }else if (templateType == "custom_table")
        {
            return .custom_table
        }else if (templateType == "advancedListTemplate"){
            return .advancedListTemplate
        }else if (templateType == "cardTemplate"){
            return .cardTemplate
        }else if (templateType == "stacked"){
            return .stackedCarousel
        }else if templateType == "advanced_multi_select"{
            return .advanced_multi_select
        }else if templateType == "radioOptionTemplate"{
            return .radioOptionTemplate
        }else if templateType == "quick_replies_top"{
            return .quick_replies_top
        }else if templateType == "articleTemplate"{
            return .articleTemplate
        }else if templateType == "answerTemplate"{
            return .answerTemplate
        }else if templateType == "otpValidationTemplate" || templateType == "resetPinTemplate"{
            return .OtpOrResetTemplate
        }else if templateType == "text"{
            return .text
        }
        return .noTemplate
    }
}
