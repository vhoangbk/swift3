/**
 * DateTimeUtils
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */


import UIKit

class DateTimeUtils: NSObject {
    
    class func getCurrentSecond()->Int64{
        return Int64(NSDate().timeIntervalSince1970);
    }
    
    class func getCurrentDateTimeToString() -> String{
        let strResult = convertLongTimeToDateTimeString(longTime: Int(Int64(NSDate().timeIntervalSince1970)));
        return strResult;
    }
    
    class func convertLongTimeToDateTimeString(longTime : Int) -> String{
        let date = NSDate(timeIntervalSince1970: TimeInterval(longTime));
        return convertDateToString(date: date as Date, formatterDate: StringUtilities.getLocalizedString("date_full", comment: "yyyy/MM/dd"));
    }
    
    class func convertLongTimeToDateTimeString2(longTime : Int) -> String{
        let date = NSDate(timeIntervalSince1970: TimeInterval(longTime));
        return convertDateToString(date: date as Date, formatterDate: StringUtilities.getLocalizedString("date_full_2", comment: "yyyy/MM/dd (E)"));
    }

    class func convertDateToString(date : Date) -> String{
        let formatter = DateFormatter();
        formatter.dateFormat = StringUtilities.getLocalizedString("date_full", comment: "yyyy/MM/dd");
        let someDateTime = formatter.string(from: date);
        return someDateTime;
    }
    
    class func convertDateToString(date : Date, formatterDate : String) -> String{
        let formatter = DateFormatter();
        formatter.dateFormat = formatterDate;
        let someDateTime = formatter.string(from: date);
        return someDateTime;
    }
    
    class func convertStringToDate(strDate : String, formatterDate : String) -> Date{
        let formatter = DateFormatter();
        formatter.dateFormat = formatterDate;
        let someDateTime = formatter.date(from: strDate);
        return someDateTime!;
    }
    
    class func convertStringToDate(strDate : String) -> Date{
        let formatter = DateFormatter();
        formatter.dateFormat = StringUtilities.getLocalizedString("date_full", comment: "yyyy/MM/dd");
        let someDateTime = formatter.date(from: strDate);
        return someDateTime!;
    }
    
    class func getSecondFromDate(date : Date) -> Double{
        return date.timeIntervalSince1970;
    }
    
    class func getDateNotificationTime(second : Int) -> String{
        var strResult = "";
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy/MM/dd HH:mm";
        let curentTime = getCurrentSecond();
        let exptime = curentTime - second;
        if (exptime < 60) {
            strResult = StringUtilities.getLocalizedString("one_minute_format", comment: "");
        } else if (exptime < 3600) {
            strResult = String(format: StringUtilities.getLocalizedString("one_hour_format", comment: ""), exptime / 60);
        } else if (exptime < 86400) {
            let hour = exptime / 3600;
            let minute = (exptime % 3600) / 60;
            strResult = String(format: StringUtilities.getLocalizedString("one_day_format", comment: ""), hour, minute);
        } else {
            strResult = convertLongTimeToDateTimeString(longTime: second);
        }
        return strResult;
    }
    
    class func getDateDiffCurrentTime(longTime : Int) -> Double{
        let currentTime = getCurrentSecond();
        return Double(longTime) - Double(currentTime);
    }
    
    class func currentTimeYearMonthDayLessDateInput(dateInput : Date) -> Bool{
        let currentTime = getCurrentSecond();
        let currentTimeString = convertLongTimeToDateTimeString(longTime: Int(currentTime));
        print("currentTimeString:" + currentTimeString);
        let currentTimeDateFormat = convertStringToDate(strDate: currentTimeString);
        let dateAdd = convertDateToString(date: dateInput);
        print("dateAdd:" + dateAdd);
        let dateAddFormat = convertStringToDate(strDate: dateAdd)
        print(currentTimeDateFormat <= dateAddFormat)
        return currentTimeDateFormat <= dateAddFormat;
    }
    
    class func getDateFromLimitDatePiker(dateInput : Date) -> String{
        let dateAdd = convertDateToString(date: dateInput);
        let longTimeCurrent = getCurrentSecond();
        let longTimeCurrentAddOneDay = longTimeCurrent + 86400;
        if(dateAdd == getCurrentDateTimeToString()){
            return StringUtilities.getLocalizedString("activity_post_today", comment: "");
        } else if(dateAdd == convertLongTimeToDateTimeString(longTime: Int(longTimeCurrentAddOneDay))) {
            return StringUtilities.getLocalizedString("activity_post_tomorrow", comment: "");
        }
        return dateAdd;
    }
    
    class func getDateTabHomeAndHistory(second : Int) -> String{
         var strResult = "";
        // Sub time 1 day server
        let secondSubOneDay = second - 86400;
        let curentTime = getCurrentSecond();
        // Current time
        let strDateCurrent = convertLongTimeToDateTimeString(longTime: Int(curentTime));
        // Current time sub 1 day
        let strDateCurrentSub1Day = convertLongTimeToDateTimeString(longTime: Int(curentTime - 86400));
        // Current time add 1 day
        let strDateCurrentAdd1Day = convertLongTimeToDateTimeString(longTime: Int(curentTime + 86400));
        // Date time input
        let strDateInput = convertLongTimeToDateTimeString(longTime: secondSubOneDay);
        // Check
        if(strDateCurrentSub1Day == strDateInput){
            // if yesterday
            strResult = StringUtilities.getLocalizedString("activity_history_post_yesterday", comment: "");
        } else if(strDateCurrent == strDateInput){
            // if today
            strResult = StringUtilities.getLocalizedString("activity_post_today", comment: "");
        } else if (strDateCurrentAdd1Day == strDateInput) {
            // if tomorrow
            strResult = StringUtilities.getLocalizedString("activity_post_tomorrow", comment: "");
        } else {
            // if time
            strResult = convertLongTimeToDateTimeString(longTime: secondSubOneDay);
        }
        return strResult;
    }
}
