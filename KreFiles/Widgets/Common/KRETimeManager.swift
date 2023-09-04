//
//  KRETimeManager.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 14/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Alamofire

class KRETimeManager: NSObject {
    var isTrustWorthy = false
    private var offset: TimeInterval = 0.0
    private var systemTime: Date?
    private var networkTime: Date?
    private var pollingTimer: Timer?
    private var active = false
    private var queue: DispatchQueue = DispatchQueue(label: "com.kora.networktime.queue")
    private var dateFormatter: DateFormatter = DateFormatter()
    private static var instance: KRETimeManager!
    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration)
    }()
    
    public static let sharedInstance: KRETimeManager = {
        if (instance == nil) {
            instance = KRETimeManager()
        }
        return instance
    }()
    
    // MARK: - init
    override init() {
        super.init()
        
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        if let anAbbreviation = NSTimeZone(abbreviation: "GMT") {
            dateFormatter.timeZone = anAbbreviation as TimeZone
        }
        
        isTrustWorthy = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.processSignificantTimeChange(_:)), name: UIApplication.significantTimeChangeNotification, object: nil)
    }
    
    // MARK: -
    func startNetworkClock() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        
        active = true
        pollingTimer = Timer(fireAt: Date(timeIntervalSinceNow: 1.0), interval: 5.0, target: self, selector: #selector(self.pollingTimerMethod(_:)), userInfo: nil, repeats: true)
        
        if let timer = pollingTimer {
            RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        }
        pollingTimerMethod(pollingTimer)
    }
    
    func stopNetworkClock() {
        systemTime = nil
        networkTime = nil
        pollingTimer?.invalidate()
        pollingTimer = nil
        active = false
        isTrustWorthy = false
    }
    
    func getTimeOffset() -> TimeInterval {
        return offset
    }
    
    func deviceDate() -> Date {
        var date = Date()
        date = date.addingTimeInterval(offset)
        return date
    }
    
    func getCorrectDate(with date: Date?) -> Date? {
        var cDate: Date? = nil
        cDate = date?.addingTimeInterval(-offset + 0.5)
        return cDate
    }
    
    @objc func pollingTimerMethod(_ timer: Timer?) {
        guard let KORE_SERVER = KREWidgetManager.shared.user?.server else {
            return
        }
        queue.async(execute: {  [weak self] in
            let urlString = KORE_SERVER
            var headers: HTTPHeaders = [
                "Keep-Alive": "Connection",
            ]

            let dataRequest = self?.sessionManager.request(urlString, method: .head)
            dataRequest?.validate().responseJSON { (response) in
                if let _ = response.error {
                    self?.isTrustWorthy = false
                    return
                }
                
//                if let response = response.value as? HTTPURLResponse, let dateString = response.allHeaderFields["Date"] as? String {
//                    var date = dateString
//                    date = date.replacingOccurrences(of: "GMT", with: "+0000")
//                    self.systemTime = Date()
//                    self.networkTime = self.dateFormatter.date(from: date)
//                    if let networkTime = self.networkTime, let systemTime = self.systemTime {
//                        self.offset = networkTime.timeIntervalSince(systemTime)
//                    }
//                    print("------Network Time: \(self.networkTime?.description ?? "")------")
//                    print("------Device time: \(self.systemTime?.description ?? "")------")
//                    print("------Network ahead by: \(self.offset)------")
//                    self.isTrustWorthy = true
//                }
            }
        })
    }
    
    func isNetworkClockActive() -> Bool {
        return active
    }
    
    @objc func processSignificantTimeChange(_ notification: Notification?) {
        stopNetworkClock()
        startNetworkClock()
    }
    
    // MARK: - deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        pollingTimer?.invalidate()
        pollingTimer = nil
        systemTime = nil
        networkTime = nil
    }
}

public extension Date {
    // MARK: -
    var SECOND: Double {
        return 1.0
    }
    var MINUTE: Double {
        return SECOND * 60.0
    }
    var HOUR : Double {
        return MINUTE * 60.0
    }
    var DAY: Double {
        return HOUR * 24.0
    }
    var WEEK: Double {
        return DAY * 7.0
    }
    var MONTH: Double {
        return DAY * 30.0
    }
    var YEAR: Double {
        return Double(DAY) * 365.24
    }
    var HOUR_IN_MINUTES: Double {
        return 60.0
    }
    var DAY_IN_MINUTES: Double {
        return 1440.0
    }
    var WEEK_IN_MINUTES: Double {
        return 10080.0
    }
    var MONTH_IN_MINUTES: Double {
        return 43800.0
    }
    var YEAR_IN_MINUTES: Double {
        return 525600.0
    }
    
    // Mysql Datetime Formatted As Time Ago, Takes in a mysql datetime string and returns the Time Ago date format
    static func mysqlDatetimeFormatted(asTimeAgo mysqlDatetime: String?) -> String? {
        // If this is not in UTC, we don't have any knowledge about which tz it is. MUST BE IN UTC.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date: Date? = formatter.date(from: mysqlDatetime ?? "")
        return date?.formattedAsTimeAgo()
    }
    func years(from date: Date) -> Int {
        if let year = Calendar.current.dateComponents([.year], from: date, to: self).year {
            return year
        }
        return 0
    }
    func months(from date: Date) -> Int {
        if let months = Calendar.current.dateComponents([.month], from: date, to: self).month {
            return months
        }
        return 0
    }
    func weeks(from date: Date) -> Int {
        if let weeks = Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth {
            return weeks
        }
        return 0
    }
    func days(from date: Date) -> Int {
        if let days = Calendar.current.dateComponents([.day], from: date, to: self).day {
            return days
        }
        return 0
    }
    func hours(from date: Date) -> Int {
        if let hours = Calendar.current.dateComponents([.hour], from: date, to: self).hour {
            return hours
        }
        return 0
    }
    func minutes(from date: Date) -> Int {
        if let minutes = Calendar.current.dateComponents([.minute], from: date, to: self).minute {
            return minutes
        }
        return 0
    }
    func seconds(from date: Date) -> Int {
        if let seconds = Calendar.current.dateComponents([.second], from: date, to: self).second {
            return seconds
        }
        return 0
    }
    func koraRequiredFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM dd, yyyy"
        let currentYear = dateFormatter.string(from: self)
        return currentYear
    }
    func formattedAsDayMonthDateYear() -> String? {
        if abs(years(from: Date())) > 0 {
            return koraRequiredFormat()
        }
        else {
            let mon = months(from: Date())
            if abs(months(from: Date())) > 0 {
                return koraRequiredFormat()
            }
            else {
                let week = weeks(from: Date())
                if abs(weeks(from: Date())) > 0 {
                    return koraRequiredFormat()
                }
                else {
                    let day = abs(days(from: Date()))
                    if day > 1 {
                        return koraRequiredFormat()
                    }
                    else if day == 1 {
                        return "Yesterday"
                    }
                    else {
                        return "Today"
                    }
                }
            }
        }
        return nil
    }
    
    func formattedAsTimeAgo() -> String? {
        //Now
        let now = KRETimeManager.sharedInstance.deviceDate()
        let secondsSince = TimeInterval(-Int(timeIntervalSince(now)))
        //Should never hit this but handle the future case
        if secondsSince < 0 {
            return "now"
        }
        // Future time
        // < 1 minute = "now"
        if secondsSince < 5 * MINUTE {
            return "now"
        }
        // < 1 hour = "__m"
        if secondsSince < HOUR {
            return String(format: "%dm", Int(secondsSince / MINUTE))
        }
        // < 24 hour = "__h"
        if secondsSince < DAY {
            return String(format: "%dh", Int(secondsSince / HOUR))
        }
        // < 7 days = "__d"
        if secondsSince < WEEK {
            return String(format: "%dd", Int(secondsSince / DAY))
        }
        // < 30 days = "__w"
        if secondsSince < MONTH {
            return String(format: "%dw", Int(secondsSince / WEEK))
        }
        // < 12 months = "__m"
        if secondsSince < YEAR {
            return String(format: "%dm", Int(secondsSince / MONTH))
        }
        // Anything else = "__y"
        return String(format: "%dy", Int(secondsSince / YEAR))
    }
    
    
    func formatMinutesAgo(_ secondsSince: TimeInterval) -> String? {
        //Convert to minutes
        let minutesSince = secondsSince / MINUTE
        //Create date formatter
        let dateFormatter = DateFormatter()
        //Format
        dateFormatter.dateFormat = "hh:mm a"
        if minutesSince >= 1 {
            return "\(dateFormatter.string(from: self))"
        } else {
            return "Just Now"
        }
    }
    
    // Today = "x hours ago"
    func format(asToday secondsSince: TimeInterval) -> String? {
        //Convert to hours
        //int hoursSince = (int)secondsSince / HOUR;
        //Create date formatter
        let dateFormatter = DateFormatter()
        //Format
        dateFormatter.dateFormat = "hh:mm a"
        return "\(dateFormatter.string(from: self))"
    }
    
    // Yesterday = "Yesterday at 1:28 PM"
    func formatAsYesterday() -> String? {
        return "Yesterday"
    }
    
    // < Last 7 days = "Friday at 1:48 AM"
    func formatAsLastWeek() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()
        //Format
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    // < Last 30 days = "March 30 at 1:14 PM"
    func formatAsLastMonth() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()
        //Format
        //[dateFormatter setDateFormat:@"MMMM d 'at' h:mm a"];
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: self)
    }
    
    func formatAsDayMonthAtTime() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()
        //Format
        //[dateFormatter setDateFormat:@"MMMM d 'at' h:mm a"];
        dateFormatter.dateFormat = "EEE, d MMM 'at' h:mm a"
        return dateFormatter.string(from: self)
    }

    func formatAsHourlyTime() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()
        //Format
        //[dateFormatter setDateFormat:@"MMMM d 'at' h:mm a"];
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self)
    }

    
    func formatAsLastYear() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()
        let currentDate = Date()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: currentDate)
        let timeStampYear = dateFormatter.string(from: self)
        if (currentYear == timeStampYear) {
            dateFormatter.dateFormat = "EEE, MMM d"
            return dateFormatter.string(from: self)
        } else {
            dateFormatter.dateFormat = "EEE, MMM d, yyyy"
            return dateFormatter.string(from: self)
        }
    }
    //MON, 15 OCT
    func formatAsLastYearWithDayDateMonth() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()
        let currentDate = Date()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: currentDate)
        let timeStampYear = dateFormatter.string(from: self)
        if (currentYear == timeStampYear) {
            dateFormatter.dateFormat = "EEE, d MMM"
            return dateFormatter.string(from: self)
        } else {
            dateFormatter.dateFormat = "EEE, d MMM, yyyy"
            return dateFormatter.string(from: self)
        }
    }
    
    // Anything else = "September 9, 2011"
    func formatAsOther() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: self)
    }
    
    func isSameDay(as comparisonDate: Date?) -> Bool {
        //Check by matching the date strings
        let dateComparisonFormatter = DateFormatter()
        dateComparisonFormatter.dateFormat = "yyyy-MM-dd"
        //Return true if they are the same
        if let aDate = comparisonDate {
            return dateComparisonFormatter.string(from: self) == dateComparisonFormatter.string(from: aDate)
        }
        return false
    }
    
    func isTomorow(as comparisonDate: Date?) -> Bool {
        //Check by matching the date strings
        if let dateCompare = comparisonDate {
            return Calendar.current.isDateInTomorrow(dateCompare)
        } else {
            return false
        }
    }

    
    // If the current date is yesterday relative to now, Pasing in now to be more accurate (time shift during execution) in the calculations
    func isYesterday(_ now: Date?) -> Bool {
        return isSameDay(as: now?.date(bySubtractingDays: 1.0))
    }
    
    func date(byAddingDays numDays: Double) -> Date {
        let aTimeInterval = TimeInterval(timeIntervalSinceReferenceDate + DAY * numDays)
        let newDate = Date(timeIntervalSinceReferenceDate: aTimeInterval)
        return newDate
    }
    
    func date(bySubtractingDays numDays: Double) -> Date {
        let aTimeInterval = TimeInterval(timeIntervalSinceReferenceDate + DAY * -numDays)
        let newDate = Date(timeIntervalSinceReferenceDate: aTimeInterval)
        return newDate
    }
    
    /*
     Is Last Week
     We want to know if the current date object is the first occurance of
     that day of the week (ie like the first friday before today
     - where we would colloquially say "last Friday")
     (within 6 of the last days)
     */
    func isLastWeek(_ secondsSince: TimeInterval) -> Bool {
        return secondsSince < WEEK
    }
    
    
    // Is Last Month: Previous 31 days?
    func isLastMonth(_ secondsSince: TimeInterval) -> Bool {
        return secondsSince < MONTH
    }
    
    func isLastYear(_ secondsSince: TimeInterval) -> Bool {
        return secondsSince < YEAR
    }
    
    func formattedAsDateTimeForMentions() -> String? {
        //Now
        let now = KRETimeManager.sharedInstance.deviceDate()
        let secondsSince = TimeInterval(-Int(timeIntervalSince(now)))
        //Should never hit this but handle the future case
        if secondsSince < 300 {
            return "Just Now"
        } else {
            return formatDateTime(forMentions: secondsSince)
        }
    }
    
    // Formatted As full DateTime String, Returns the date formatted as full Date Time(i.e. 21/05/2014 07:45 PM )
    func formattedAsFullDateTime() -> String? {
        //Now
        let now = KRETimeManager.sharedInstance.deviceDate()
        let secondsSince = TimeInterval(-Int(timeIntervalSince(now)))
        if (secondsSince < 0) { // Should never hit this but handle the future case
            return "In The Future";
        } else if secondsSince < MINUTE {
            return "Just Now"
        } else {
            return formatFullDateTime(secondsSince)?.uppercased()
        }
    }
    
    func formatDateTime(forMentions secondsSince: TimeInterval) -> String? {
        let minutesSince = secondsSince / MINUTE
        if minutesSince >= 5 && minutesSince < HOUR_IN_MINUTES {
            return String(format: "%im", minutesSince)
        } else if minutesSince >= HOUR_IN_MINUTES && minutesSince < DAY_IN_MINUTES {
            let hours: Int = Int(minutesSince / HOUR_IN_MINUTES)
            return String(format: "%ih", hours)
        } else if minutesSince >= DAY_IN_MINUTES && minutesSince < WEEK_IN_MINUTES {
            let days: Int = Int(minutesSince / DAY_IN_MINUTES)
            return String(format: "%id", days)
        } else if minutesSince >= WEEK_IN_MINUTES && minutesSince < MONTH_IN_MINUTES {
            let week: Int = Int(minutesSince / WEEK_IN_MINUTES)
            return String(format: "%iw", week)
        } else if minutesSince >= MONTH_IN_MINUTES && minutesSince < YEAR_IN_MINUTES {
            let month: Int = Int(minutesSince / MONTH_IN_MINUTES)
            return String(format: "%im", month)
        } else if minutesSince >= YEAR_IN_MINUTES {
            let year: Int = Int(minutesSince / YEAR_IN_MINUTES)
            return String(format: "%iy", year)
        } else {
            return "Just Now"
        }
    }
    
    // < 1 minute = "Just Now"
    // > 1 minute = "MM/dd/yyyy hh:mm a"
    func formatFullDateTime(_ secondsSince: TimeInterval) -> String? {
        // Convert to minutes
        let minutesSince = secondsSince / MINUTE
        // Create date formatter
        let dateFormatter = DateFormatter()
        // Format
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        // Handle Plural
        if minutesSince >= 1 {
            return "\(dateFormatter.string(from: self))"
        } else {
            return "Just Now"
        }
    }
    
    func formatDateTimeWithoutJustNow(withFormat format: String?) -> String? {
        // Create date formatter
        let dateFormatter = DateFormatter()
        // Format
        dateFormatter.dateFormat = format ?? ""
        // Handle Plural
        return dateFormatter.string(from: self)
    }
    
    func formatDateTime(withFormat format: String?) -> String? {
        let secondsSince = TimeInterval(-Int(timeIntervalSince(KRETimeManager.sharedInstance.deviceDate())))
        // Convert to minutes
        let minutesSince = secondsSince / MINUTE
        // Create date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        
        // Format
        dateFormatter.dateFormat = format ?? ""
        
        // Handle Plural
        if minutesSince >= 1 {
            return "\(dateFormatter.string(from: self))"
        } else {
            return "Just Now"
        }
    }
    
    func format(forConversationHeader forHeader: Bool) -> String? {
        // Now
        let now = KRETimeManager.sharedInstance.deviceDate()
        let secondsSince = TimeInterval(-Int(timeIntervalSince(now)))
        
        // Convert to minutes
        let minutesSince = secondsSince / MINUTE
        if minutesSince < 1 && !forHeader && secondsSince > MINUTE {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        // Today
        if isSameDay(as: now) {
            let currentDate = dateFormatter.string(from: now)
            let today = "Today, " + (currentDate)
            return today
        }
        
        // Yesterday
        if isYesterday(now) {
            let yesterDate = dateFormatter.string(from: now.date(bySubtractingDays: 1.0))
            let yesterday = "Yesterday, " + (yesterDate)
            return yesterday
        }
        return formatAsLastYear()
    }
    
    func format(forConversationHeaderinKora forHeader: Bool) -> String? {
        // Now
        let now = KRETimeManager.sharedInstance.deviceDate()
        let secondsSince = TimeInterval(-Int(timeIntervalSince(now)))
        
        // Convert to minutes
        let minutesSince = secondsSince / MINUTE
        if minutesSince < 1 && !forHeader && secondsSince > MINUTE {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        // Today
        if isSameDay(as: now) {
            let today = "TODAY"
            return today
        }
        
        // Yesterday
        if isYesterday(now) {
            let yesterday = "YESTERDAY"
            return yesterday
        }
        return formatAsLastYear()
    }

    func formatCalendarEventToReadableString(_ date:Date) -> String {

        let todayDateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        let startOfToday = Calendar.current.startOfDay(for:Date())

        let requiredDateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        let startOfRequiredDay = Calendar.current.startOfDay(for: date)

        let milliSecondsof_23_59_59 = 86399000 // 23:59:59

        if todayDateComponent.day == requiredDateComponent.day &&  todayDateComponent.month == requiredDateComponent.month && todayDateComponent.year == requiredDateComponent.year{
            return "TODAY"
        }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let yesterdayDateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: yesterday!)

        if yesterdayDateComponent.day == requiredDateComponent.day &&  yesterdayDateComponent.month == requiredDateComponent.month && yesterdayDateComponent.year == requiredDateComponent.year{
            return "YESTERDAY"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM, yyyy"
        return dateFormatter.string(from: date)
    }

    func formatCalenderEvent(forConversationHeaderinKora forHeader: Bool, _ cursor:Date? = nil) -> String? {
        // Now
        let today = "TODAY"
//        let now = KRETimeManager.sharedInstance.deviceDate()
        let now = Calendar.current.startOfDay(for: Date())
        
//        if isSameDay(as: now) {
//            return today
//        }

        switch now.compare(self) {
        case .orderedDescending:
            if let cStartDate = cursor {
                if cStartDate.isSameDay(as: now){
                    return today
                }
                else if self < cStartDate {
                    return cStartDate.formatAsLastYearWithDayDateMonth()
                }
                else {
                    return formatAsLastYearWithDayDateMonth()
                }
            }
            return today
        case .orderedSame:
            return today
        case .orderedAscending:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"
            return formatAsLastYearWithDayDateMonth()
        }
    }
    
    
    func format(asTodayYesterdayAndFormat format: String?) -> String? {
        // Now
        let now = KRETimeManager.sharedInstance.deviceDate()
        
        // Today
        if isSameDay(as: now) {
            return "Today"
        }
        
        // Yesterday
        if isYesterday(now) {
            return "Yesterday"
        } else {
            return formatDateTime(withFormat: format)
        }
    }
}


extension Date {
    
    func format(date: Date) -> String? {
        // Now
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }
        return formatAsDayShortDate(using: date)
    }
    
    public func formattedAsAgo()-> String {
        let calendar = Calendar.current
        let now = Date()
        let from = self
        let earliest = (now as NSDate).earlierDate(from)
        let latest = earliest == now ? from : now
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest)
        
        var result = ""
        
        if components.year! >= 2 {
            result = formatAsOther(using: from)
        } else if components.year! >= 1 {
            result = self.formatAsLastYear(using: from)
        } else if components.month! >= 2 {
            result = "\(components.month!) months ago"
        } else if components.month! >= 1 {
            result = formatAsLastMonth(using: from)
        } else if components.weekOfYear! >= 2 {
            result = "\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            result = formatAsLastWeek(using: from)
        } else if components.day! >= 2 {
            result = "\(components.day!) days ago"
        } else if components.day! >= 1 {
            result = self.formatAsYesterday(using: from)
        } else if components.hour! >= 2 {
            result = "\(components.hour!) hours ago"
        } else if components.hour! >= 1 {
            result = "An hour ago"
        } else if components.minute! >= 2 {
            result = "\(components.minute!) minutes ago"
        } else if components.minute! >= 1 {
            result = "A minute ago"
        } else {
            result = "Just now"
        }
        
        return result
    }
    
    public func formattedshortAsAgo()-> String {
        let calendar = Calendar.current
        let now = Date()
        let from = self
        let earliest = (now as NSDate).earlierDate(self)
        let latest = (earliest == now) ? self : now
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        
        var result = ""
        
        if components.year! >= 2 {
            result = formatAsOther(using: self)
        } else if components.year! >= 1 {
            result = self.formatAsLastYear(using: self)
        } else if components.month! >= 2 {
            result = "\(components.month!) months"
        } else if components.month! >= 1 {
            result = formatAsLastMonth(using: self)
        } else if components.day! >= 2 {
            result = "\(components.day!) days"
        } else if components.day! >= 1 {
            result = self.formatAsYesterday(using: self)
        } else if components.hour! >= 2 {
            result = "\(components.hour!) hrs"
        } else if components.hour! >= 1 {
            result = "1 hr"
        } else if components.minute! >= 2 {
            result = "\(components.minute!) mins"
        } else if components.minute! >= 1 {
            result = "1 min"
        } else {
            result = "now"
        }
        
        return result
    }
    
    
    // Yesterday = "Yesterday at 1:28 PM"
    func formatAsYesterday(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return "Yesterday at \(dateFormatter.string(from: date))"
    }
    
    // < Last 7 days = "Friday at 1:48 AM"
    func formatAsLastWeek(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE 'at' h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // < Last 30 days = "March 30 at 1:14 PM"
    func formatAsLastMonth(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d 'at' h:mm a"
        return dateFormatter.string(from: date)
    }
    
    // < 1 year = "September 15"
    func formatAsLastYear(using date: Date) -> String {
        //Create date formatter
        let dateFormatter = DateFormatter()
        //Format
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter.string(from: date)
    }
    
    // Anything else = "September 9, 2011"
    func formatAsOther(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    //Friday, March 30 2018
    public func formatAsDayDate(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, LLLL d yyyy"
        return dateFormatter.string(from: date)
    }
    //Fri, Mar 30 2018
    public func formatAsDayShortDate(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, LLL d, yyyy"
        return dateFormatter.string(from: date)
    }
    //Friday, Mar 30
    public func formatAsDay(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, LLL d"
        return dateFormatter.string(from: date)
    }
    //Fri, Mar 30
    public func formatAsDayShort(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, LLL d"
        return dateFormatter.string(from: date)
    }
    public func formatAsDateASMMDDYY(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date)
    }
    
    public func formatAsDateASDDMM(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        return dateFormatter.string(from: date)
    }
        
    public func formatAsTime(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        return dateFormatter.string(from: date)
    }
    
    public func formatAsTimewithHH(using date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        return dateFormatter.string(from: date)
    }

    public func formatAsDateASMMDDYYWithYesterday(using date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            return dateFormatter.string(from: date)
        }
    }
}

// MARK: - date functions
public extension NSNumber {
    public func UTCToDateHour() -> String {
        let timeInSeconds = Double(truncating: self) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        let dateString = dateTime.formatAsTime(using: dateTime)
        return dateString
    }
    
    public func UTCtoString() -> String {
        let timeInSeconds = Double(truncating: self) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        let dateStr = dateTime.formatAsDayDate(using: dateTime)
        return dateStr
    }
}

// MARK: -
public extension Date {
    public init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    /*
    Officially there is no support, Taken this hack from
     https://stackoverflow.com/questions/34955990/how-do-i-check-whether-a-phone-time-format-is-set-to-24-hours/34962428#34962428
     */

    public static func getDeviceTimeFormat()-> Int{
        let locale = NSLocale.current
        let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
        if formatter.contains("a") {
            return 12
        } else {
            return 24
        }
    }

    public static func convert12HrTo24Hr(_ dateString12Hr:String)->String{
        let dateAsString = dateString12Hr
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: dateAsString)

        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date!)
    }
    public static func convert24HrTo12Hr(_ dateString24Hr:String)->String{
        let dateAsString = dateString24Hr
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: dateAsString)

        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date!)
    }
}
