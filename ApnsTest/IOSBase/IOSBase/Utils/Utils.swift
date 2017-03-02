//
//  Utils.swift
//  Uema
//
//  Created by paraline on 5/23/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class Utils: NSObject {
    
    class func corner(_ view : UIView, roundingCorner : UIRectCorner, radius : CGFloat) {
        let maskPath : UIBezierPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners:roundingCorner, cornerRadii: CGSize(width: radius, height: radius));
        let maskLayer : CAShapeLayer = CAShapeLayer();
        maskLayer.path = maskPath.cgPath;
        view.layer.mask = maskLayer;
    }
    
    class func convertDictionaryToJSonString(_ dic : Dictionary<String, AnyObject>) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
            let theJSONText = String(data: jsonData,
                                     encoding: String.Encoding.ascii)
            return theJSONText;
        } catch let error as NSError {
            print(error)
        }
        return nil;
    }
    
    class func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    

    /*
     * check connect network
     */
    class func isInternetAvailable() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

}
