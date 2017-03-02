/**
 * APIError
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class APIError: NSObject {
    
    let errorCodeMessage : [String : String] = [

        "10001" : StringUtilities.getLocalizedString("error_10001", comment: ""),
        
    ]
    
    func getMessage(errorCode : String) -> String? {
        if hasErrorCode(errorCode: errorCode) {
            return errorCodeMessage[errorCode]!
        }else{
            return "";
        }
    }
    
    func hasErrorCode(errorCode : String) -> Bool {
        return errorCodeMessage.keys.contains(errorCode);
    }
    
}
