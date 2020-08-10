//
//  ServerConfigs.swift
//  KoraApp
//
//  Created by Srinivas Vasadi on 06/12/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//

import UIKit
import Foundation
import KoreBotSDK

// MARK: - Kora Notifications
@objc public class KoraNotification: NSObject {
    public enum EnforcementType: Int {        
        case none = 0
        case userSessionDidBecomeInvalid = 1
        case accessTokenDidBecomeInvalid = 2
        case accountLicenseChanged = 3
        case adminUsagePolicyChanaged = 4
        case accountPermissionsChanged = 5
        case adminAccountDeleted = 6
        case passwordExpired = 7
        case adminPasswordReset = 8
        case managedByEnterprise = 9
        case licenseChanged = 10
        case adminSSOEnabled = 11
        case adminSSODisabled = 12
        case adminAccountSuspend = 13
        case adminKilledSession = 14
        case usagePolicyChanged = 15
        case passwordPolicyChanged = 16
        case resetOnboarding = 17
    }
    @objc public class var UserLoggedIn: String {
        return "UserLoggedInNotification"
    }
    @objc public class var UserLoggedInFinished: String {
        return "UserLoggedInFinishedNotification"
    }
    @objc public class var AccountManagerAddedUser: String {
        return "AccountManagerAddedUser"
    }
    @objc public class var AccountManagerDefaultAccountChanged: String {
        return "AccountManagerDefaultAccountChanged"
    }
    @objc public class var ConnectPersistentConnection: String {
        return "ConnectPersistentConnection"
    }
    @objc public class var DisconnectPersistentConnection: String {
        return "DisconnectPersistentConnection"
    }
    @objc public class var PersistentConnectionConnected: String {
        return "PersistentConnectionConnected"
    }
    @objc public class var UpdateApplicationBadgeCount: String {
        return "UpdateApplicationBadgeCountNotification"
    }
    @objc public class var PersistentConnectionStatusDidChange: String {
        return "PersistentConnectionStatusDidChangeNotification"
    }
    @objc public class var UserProfile: String {
        return "UserProfileNotification"
    }
    @objc public class var LogInProgressBegin: String {
        return "LogInProgressBeginNotification"
    }
    @objc public class var LogInProgressEnded: String {
        return "LogInProgressEndedNotification"
    }
    @objc public class var AccountManagerUserSignedOut: String {
        return "AccountManagerUserSignedOut"
    }
    @objc public class var AccountGot: String {
        return "AccountGotNotification"
    }
    @objc public class var EnforcementNotification: String {
        return "EnforcementNotification"
    }
    @objc public class var AccountSignOut: String {
        return "AccountSignOut"
    }
    @objc public class var NetworkNotReachable: String {
        return "NetworkNotReachable"
    }
    
    public enum ProfileEvent: Int {
        case pictureChange, colorChange
        
        public var description: String {
            switch self {
            case .pictureChange:
                return "ProfilePictureChange"
            case .colorChange:
                return "ProfileColorChange"
            }
        }
        
        public var notification: NSNotification.Name {
            switch self {
            case .pictureChange:
                return NSNotification.Name(rawValue: ProfileEvent.pictureChange.description)
            case .colorChange:
                return NSNotification.Name(rawValue: ProfileEvent.colorChange.description)
            }
        }
    }
    
    public enum Event: Int {
        case respondToMeeting, followUpMeeting, scheduleMeeting, trySkill, tryout, systemAlert, feedback
        
        public var description: String {
            switch self {
            case .trySkill:
                return "TrySkill"
            case .respondToMeeting:
                return "RespondToMeeting"
            case .followUpMeeting:
                return "FollowUpMeeting"
            case .scheduleMeeting:
                return "ScheduleMeeting"
            case .tryout:
                return "TryOut"
            case .systemAlert:
                return "Alert"
            case .feedback:
                return "Feedback"
            }
        }
        static let allCases = [respondToMeeting.description, trySkill.description, followUpMeeting.description, scheduleMeeting.description, tryout.description, systemAlert.description, feedback.description]
    }
    
    public enum Widget: Int {
        case update, event
        
        public var description: String {
            switch self {
            case .event:
                return "Event"
            case .update:
                return "Update"
            }
        }
        public var notification: NSNotification.Name {
            switch self {
            case .update:
                return NSNotification.Name(rawValue: Widget.update.description)
            case .event:
                return NSNotification.Name(rawValue: Widget.event.description)
            }
        }
    }
    public enum Panel: Int {
        case update, event
        
        public var description: String {
            switch self {
            case .event:
                return "Event"
            case .update:
                return "Update"
            }
        }
        public var notification: NSNotification.Name {
            switch self {
            case .update:
                return NSNotification.Name(rawValue: Widget.update.description)
            case .event:
                return NSNotification.Name(rawValue: Widget.event.description)
            }
        }
    }

    public enum Overlay: Int {
        case widgets, kora, activity
        public var description: String {
            switch self {
            case .widgets:
                return "DidLoadWidgets"
            case .kora:
                return "DidLoadKora"
            case .activity:
                return "DidLoadActivity"
            }
        }
        public var notification: NSNotification.Name {
            switch self {
            case .widgets:
                return NSNotification.Name(rawValue: Overlay.widgets.description)
            case .kora:
                return NSNotification.Name(rawValue: Overlay.kora.description)
            case .activity:
                return NSNotification.Name(rawValue: Overlay.activity.description)
            }
        }
    }
}

public enum BotSessionEvent: Int {
    case start, end, send
    
    public var notification: NSNotification.Name {
        switch self {
        case .start:
            return NSNotification.Name(rawValue: "startSession")
        case .end:
            return NSNotification.Name(rawValue: "SessionDidEnd")
        case .send:
            return NSNotification.Name(rawValue: "MessageDidSend")
        }
    }
}

public enum BotMessagesEvent: Int {
    case startLoading, stopLoading, error
    
    public static var notification: NSNotification.Name {
        return NSNotification.Name(rawValue: "BotMessagesEvent")
    }
    public static var name: String {
        return "BotMessagesEvent"
    }
    public var value: String {
        switch self {
        case .startLoading:
            return "StartLoading"
        case .stopLoading:
            return "StopLoading"
        case .error:
            return "MessagesError"
        }
    }
}

public enum BotSession: Int {
    case `default`, valid, invalid
    
    public var notification: NSNotification.Name {
        switch self {
        case .valid:
            return NSNotification.Name(rawValue: "ValidSession")
        case .invalid:
            return NSNotification.Name(rawValue: "InvalidSession")
        default:
            return NSNotification.Name(rawValue: "DefaultSession")
        }
    }
}

public enum KASaveOption: Int {
    case `default`, autosave
}

public enum KASaveMode: Int {
    case `default`, autosave
}

public enum KASiriShortcutType: Int {
    case none = 0, task = 1, meeting = 2, knowledge = 3, announcement = 4
}

enum KAPersistentConnectionStatus: NSInteger {
    case none = 0, disconnected = 1, connected = 2, connecting = 3
}

let kTermsOfUseTermsOfServiceURL = "https://kore.com/terms-of-service-app/"
let kTermsOfUsePrivacyPolicyURL = "https://kore.com/privacy-policy-app/"

let kreAcknowledgementString = "The following sets forth attribution notices for third party software that may be contained in portions of the Kore.ai mobile application. We thank the open source community for all of their contributions.<br/><br/><br/><font color='#69CDE1'><b>AFNetworking<br/><br/>APAddressBook<br/><br/>CocoaLumberjack<br/><br/>DTCoreText<br/><br/>DTFoundation<br/><br/>HMSegmentedControl<br/><br/>MBProgressHUD<br/><br/>Mantle<br/><br/>SocketRocket<br/><br/>UICKeyChainStore<br/><br/>US2FormValidator<br/><br/>libPhoneNumber-iOS<br/><br/>SocketIO.JSCore<br/><br/>uiimage-from-animated-gif<br/><br/>UIImage-Resize<br/><br/>NSDate-TimeAgo</font></b>"


var kaProfileInitials = "initials";
var kaProfileColor = "profileColor";
var kaProfileIdentity = "identity";
var kaProfileUserId = "userId";
var kaProfileDeviceId = "deviceId";
var kaProfileImageURL = "url";
var kaGetProfileImageEndPoint = "%@api/1.1/getMediaStream/profilePictures/%@/%@";
var kaProfilePlaceHolder = "placeHolder";
var kaIsProfileImage = "isProfileImage";
var kaIsTeam = "isTeam";

var showTableTemplateNotification = "ShowTableTemplateNotificationName"
var selectQuickSlotNotification = "selectQuickSlotNotification"
var slotLastMsgNotification = "slotLastMsgNotification"
var pickSlotLastMsgNotification = "pickSlotLastMsgNotification"
var taskLastMsgNotification = "taskLastMsgNotification"
var reloadTableNotification = "reloadTableNotification"
var resolveKnowledgeIds = "resolveKnowledgeIdsNotification"

public var KALOADER_WIDTH = 20.0

func KALocalized(_ string: String) -> String {
    return NSLocalizedString(string, comment: string)
}

public enum KANotificationType: Int {
    case actions = 0, updates = 1
}

enum KAInormationType: Int {
    case none = 0, knowledge = 1, announcement = 2
}

open class KACommon : NSObject {
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
    public static func UIColorwithName(name: String) -> UIColor {
        let colorStr: String
        if name.hasPrefix("0x") {
            colorStr = name
        } else {
            colorStr = name.replacingOccurrences(of: "#", with: "0x")
        }
        var result: UInt32 = 0
        let scanner = Scanner(string: colorStr)
        scanner.scanHexInt32(&result)
        return UIColorRGB(Int(result))
    }
    
    public static func backgroundColor() -> UIColor {
        return UIColor(hex: 0xF7F8F9)
    }
    
    public static func textColor() -> UIColor {
        return UIColor.blueyGrey
    }
    
    public static func themeColor() -> UIColor {
        return UIColor(hex: 0x6F88F0)
    }
    
    public static func textColor(alpha: CGFloat) -> UIColor {
        return UIColor(hex: 0x6168E7, alpha: alpha)
    }
}

open class Utilities: NSObject {
    // MARK:-
    
    public static func bezierArraw(_ args:[String:Any]) -> UIImage? {
        var angle:CGFloat = 30.0
        var length:CGFloat = 10.0
        guard let startPoint = args["startPoint"] as? CGPoint else {
            return nil
        }
        guard let endPoint = args["endPoint"] as? CGPoint else {
            return nil
        }
        guard let cPoint1 = args["controlPoint1"] as? CGPoint else {
            return nil
        }
        guard let cPoint2 = args["controlPoint2"] as? CGPoint else {
            return nil
        }
        guard let boundingBox = args["boundingBox"] as? CGRect else {
            return nil
        }
        if let ang = args["angleBetweenArrowEdges"] as? CGFloat {
            angle = ang
        }
        if let len = args["arrowLength"] as? CGFloat {
            length = len
        }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: boundingBox.width, height: boundingBox.height))
        let image = renderer.image { (context) in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.red.cgColor)
            ctx.saveGState()
            let path = UIBezierPath()
            // Start from the lower left corner
            let pattern:[CGFloat] = [5.0, 2.0]
            path.setLineDash(pattern, count: 2, phase: 0)
            path.move(to: startPoint)
            path.addCurve(to: endPoint, controlPoint1: cPoint1, controlPoint2: cPoint2)

            let slopeLine = CGPoint(x:cPoint2.x - endPoint.x, y:cPoint2.y - endPoint.y)
            var rotationAngle:CGFloat = angle * .pi/180.0
            let leftXPoint = slopeLine.x * cos(rotationAngle) + slopeLine.y * -sin(rotationAngle)
            let leftYPoint = slopeLine.x * sin(rotationAngle) + slopeLine.y * cos(rotationAngle)
            let left = CGPoint(x:leftXPoint*leftXPoint, y:leftYPoint*leftYPoint)
            let leftLength:CGFloat = CGFloat(sqrtf(Float(left.x + left.y)))
            var unitLeft = CGPoint(x:leftXPoint/leftLength, y:leftYPoint/leftLength)
            
            rotationAngle = -angle * .pi/180.0
            let rightXPoint = slopeLine.x * cos(rotationAngle) + slopeLine.y * -sin(rotationAngle)
            let rightYPoint = slopeLine.x * sin(rotationAngle) + slopeLine.y * cos(rotationAngle)
            let right = CGPoint(x:rightXPoint*rightXPoint, y:rightYPoint*rightYPoint)
            let rightLength = CGFloat(sqrtf(Float(right.x + right.y)))
            var unitRight = CGPoint(x:rightXPoint/rightLength, y:rightYPoint/rightLength)
            
            unitLeft.x *= length
            unitLeft.y *= length
            unitLeft.x += endPoint.x
            unitLeft.y += endPoint.y
            
            unitRight.x *= length
            unitRight.y *= length
            unitRight.x += endPoint.x
            unitRight.y += endPoint.y

            path.move(to: endPoint)
            path.addLine(to: unitLeft)
            path.move(to: endPoint)
            path.addLine(to: unitRight)
            path.stroke()
            ctx.restoreGState()
        }

        return image
    }
    
    
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
        case "web_url", "iframe_web_url":
            let url: String = actionInfo["url"] != nil ? actionInfo["url"] as! String : ""
            return KREAction(actionType: .webURL, title: title, payload: url)
        case "postback":
            let payload: String = actionInfo["payload"] != nil ? actionInfo["payload"] as! String : ""
            return KREAction(actionType: .postback, title: title, payload: payload)
        case "postback_disp_payload":
            let payload: String = actionInfo["payload"] != nil ? actionInfo["payload"] as! String : ""
            return KREAction(actionType: .postback_disp_payload, title: payload, payload: payload)
        case "USERINTENT".lowercased():
            var customData: [String: Any] = [:]
            if (actionInfo["customData"] != nil) {
                customData = actionInfo["customData"] as! [String: Any]
            }
            let action: KREAction = KREAction(actionType: .user_intent, title: title, customData: customData)
            if (actionInfo["action"] != nil) {
                action.action = actionInfo["action"] as? String
            }
            return action
        case "help_resource":
            let action = KREAction(actionType: .user_intent, title: actionType, customData: dictionary)
            action.action = actionType
            return action
        default:
            break
        }
        return nil
    }
    
    // MARK: -
    public class func profileIdentity(for contact: KAContact?, server: String?) -> KREIdentity {
        let identity = KREIdentity()
        identity.icon = contact?.icon
        identity.userId = contact?.contactId
        identity.color = contact?.profileColor
        identity.initials = contact?.initials
        identity.server = server
        return identity
    }
    
    public class func profileIdentity(for contact: KREContacts?, server: String?) -> KREIdentity {
        let identity = KREIdentity()
        identity.icon = contact?.icon
        identity.userId = contact?.id
        identity.color = contact?.color
        identity.initials = contact?.initials
        identity.server = server
        return identity
    }
    
    public class func profileIdentity(for contact: NotesAttendees?, server: String?) -> KREIdentity {
        let identity = KREIdentity()
        identity.icon = contact?.icon
        identity.userId = contact?.contactId
        identity.color = contact?.color
        identity.initials = contact?.initials
        identity.server = server
        return identity
    }
}

// Sample text styles
extension UIFont {
    class var header: UIFont {
        return UIFont.textFont(ofSize: 24.0, weight: .regular)
    }
}

extension Date {
    func UTCFromLocalDate() -> Int {
        let currentDate = self
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
}

extension String {
    func toUTC() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, LLLL d yyyy - h:mm a"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let date = dateFormatter.date(from: self)
        
        let timeInSeconds = date?.UTCFromLocalDate()
        return timeInSeconds!
    }
}

// MARK: - phone number validation
extension String {
    public var isValidPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    public var isValidEmail: Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension NSAttributedString {
    convenience init(with string: String?, tracking: CGFloat, font: UIFont?) {
        let fontSize: CGFloat? = font?.pointSize
        let characterSpacing: CGFloat = tracking * (fontSize ?? 0.0) / 1000
        var attributes: [NSAttributedString.Key : Any]? = nil
        if let aFont = font {
            attributes = [NSAttributedString.Key.font: aFont as Any, NSAttributedString.Key.kern: CGFloat(characterSpacing)]
        }
        self.init(string: string ?? "", attributes: attributes)
    }
}
