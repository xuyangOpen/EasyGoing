//
//  PDCalendarAttribute.swift
//  Bluedaquiri
//
//  Created by bluedaquiri on 16/10/26.
//  Copyright © 2016年 blue. All rights reserved.
//

import UIKit

class PDCalendarAttribute: NSObject {
    var calendarFont: UIFont?                       // 1.字体大小
    var calendarMonthYearFont: UIFont?              // 2.年月字体大小
    var calendarBeforeDayColor: UIColor?            // 3.今天之前字体颜色
    var calendarAfterDayColor: UIColor?             // 4.今天之后字体颜色
    var calendarSelectdayColor: UIColor?            // 5.选中字体颜色
    var calendarTodayColor: UIColor?                // 6.今日字体颜色
    
    
    
    override init() {
        super.init()
        calendarFont = UIFont.systemFontOfSize(15)
        calendarMonthYearFont = UIFont.systemFontOfSize(18)
        calendarBeforeDayColor = UIColor.hexChangeFloat("7f7f7f")
        calendarAfterDayColor = UIColor.blackColor()
        calendarTodayColor = UIColor.redColor()
        calendarSelectdayColor = UIColor.whiteColor()
    }
    
    // Mark: - Date Method 
    class func lastMothDate(date: NSDate) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.month = -1
        let newDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: date, options: NSCalendarOptions.init(rawValue: 0))
        return newDate!
    }
    
    class func nextMothDate(date: NSDate) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.month = +1
        let newDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: date, options: NSCalendarOptions.init(rawValue: 0))
        return newDate!
    }
    
    class func totalDaysInMonth(date: NSDate) -> Int {
        let daysInMonth = NSCalendar.currentCalendar().rangeOfUnit(.Day, inUnit:.Month, forDate: date)
        return daysInMonth.length
    }
    
    class func weekForMonthFistDay(date: NSDate) -> Int {
        //1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
        let calendar = NSCalendar.currentCalendar()
        let coms = calendar.components([.Year, .Month, .Day], fromDate: date)
        coms.day = 1
        let firstDayOfDate = calendar.dateFromComponents(coms)
        let firstWeekDay = calendar.ordinalityOfUnit(.Weekday, inUnit: .WeekOfMonth, forDate: firstDayOfDate!)
        return firstWeekDay
    }
    
    class func day(date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: date)
        return components.day
    }
    
    class func month(date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: date)
        return components.month
    }
    
    class func year(date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: date)
        return components.year
    }
}
