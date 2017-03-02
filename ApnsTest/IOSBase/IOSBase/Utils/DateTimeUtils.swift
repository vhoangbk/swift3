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
    
    class func convertTimestampToString(longTime : Int, format : String) -> String{
        let date = NSDate(timeIntervalSince1970: TimeInterval(longTime));
        return convertDateToString(date: date as Date, format: format);
    }
    

    class func convertDateToString(date : Date, format : String) -> String{
        let formatter = DateFormatter();
        formatter.dateFormat = format;
        let someDateTime = formatter.string(from: date);
        return someDateTime;
    }
    
    class func convertStringToDate(strDate : String, formatterDate : String) -> Date{
        let formatter = DateFormatter();
        formatter.dateFormat = formatterDate;
        let someDateTime = formatter.date(from: strDate);
        return someDateTime!;
    }
    
    
    
  
}
