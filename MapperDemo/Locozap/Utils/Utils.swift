//
//  Utils.swift
//  Uema
//
//  Created by paraline on 5/23/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON
import SystemConfiguration
import Alamofire

class Utils: NSObject {

    class func corner(_ view : UIView, roundingCorner : UIRectCorner) {
        let maskPath : UIBezierPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners:roundingCorner, cornerRadii: CGSize(width: 5.0, height: 5.0));
        let maskLayer : CAShapeLayer = CAShapeLayer();
        maskLayer.path = maskPath.cgPath;
        view.layer.mask = maskLayer;
    }
    
    @available(iOS 8.0, *)
    class func showAlertWithTitle(_ title: String!, message: String, titleButtonClose : String, titleButtonOk : String, viewController: UIViewController, actionOK: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButtonOk, style: .default, handler: actionOK);
        alert.addAction(action)
        if(!titleButtonClose.isEmpty){
            let actionCancel = UIAlertAction(title: titleButtonClose, style: .cancel, handler: nil);
            alert.addAction(actionCancel);
        }
        
        viewController.present(alert, animated: true, completion: nil)
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

    class func setInfoAccount(infoAccount : AnyObject?){
        UserDefaults.standard.set(infoAccount, forKey: Const.USER_DEFAULT_KEY_INFO_ACCOUNT);
    }
    
    class func getInfoAccount() -> AnyObject? {
        return UserDefaults.standard.object(forKey: Const.USER_DEFAULT_KEY_INFO_ACCOUNT) as AnyObject?;
    }
}
