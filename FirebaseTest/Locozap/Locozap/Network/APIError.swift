/**
 * APIError
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit

class APIError: NSObject {
    
    //remove topic, user
    static let TopicIsDeleted = 15002;
    static let UserIsDeleted = 15001;
    static let YouAreDeleted = 15000;
    static let LoginAgain = 11157;

    let errorCodeMessage : [String : String] = [
        
        //10000 API_KEY_REQUIRED
        "10000" : StringUtilities.getLocalizedString("error_10000", comment: ""),
        //10001 API_KEY_INVALID
        "10001" : StringUtilities.getLocalizedString("error_10001", comment: ""),
        
        
        //11000 LOGIN_FAILED
        "11000" : StringUtilities.getLocalizedString("error_11000", comment: ""),
        //11100 EMAIL_REQUIRED
        "11100" : StringUtilities.getLocalizedString("error_11100", comment: ""),
        //11101 EMAIL_INVALID
        "11101" : StringUtilities.getLocalizedString("error_11101", comment: ""),
        //11102 EMAIL_NOT_EXIST
        "11102" : StringUtilities.getLocalizedString("error_11102", comment: ""),
        //11103 EMAIL_DUPLICATE
        "11103" : StringUtilities.getLocalizedString("error_11103", comment: ""),
        
        
        //11110 PASSWORD_REQUIRED
        "11110" : StringUtilities.getLocalizedString("error_11110", comment: ""),
        //11111 PASSWORD_MIN_LENGTH_INVALID
        "11111" : StringUtilities.getLocalizedString("error_11111", comment: ""),
        
        
        //11120 LONGITUDE_REQUIRED
        "11120" : StringUtilities.getLocalizedString("error_11120", comment: ""),
        //11120 LONGITUDE_INVALID
        "11121" : StringUtilities.getLocalizedString("error_11121", comment: ""),
        
        
        //11130 LATITUDE_REQUIRED
        "11130" : StringUtilities.getLocalizedString("error_11130", comment: ""),
        //11131 LATITUDE_INVALID
        "11131" : StringUtilities.getLocalizedString("error_11131", comment: ""),
        
        
        //11140 LOGIN_TYPE_REQUIRED
        "11140" : StringUtilities.getLocalizedString("error_11140", comment: ""),
        //11141 LOGIN_TYPE_INVALID
        "11141" : StringUtilities.getLocalizedString("error_11141", comment: ""),
        //11142 SET_API_KEY_EXPIRED
        "11142" : StringUtilities.getLocalizedString("error_11142", comment: ""),
        //11143 TIME_EXPIRED_API_KEY
        "11143" : StringUtilities.getLocalizedString("error_11143", comment: ""),

        //11146 TITLE_REQUIRED
        "11146" : StringUtilities.getLocalizedString("error_11146", comment: ""),
        //11147 CONTENT_REQUIRED
        "11147" : StringUtilities.getLocalizedString("error_11147", comment: ""),
        //11148 CATEGORY_REQUIRED
        "11148" : StringUtilities.getLocalizedString("error_11148", comment: ""),
        //11149 CATEGORY_INVALID
        "11149" : StringUtilities.getLocalizedString("error_11149", comment: ""),
        
        //11157 API_KEY_EXPIRED
        "11157" : StringUtilities.getLocalizedString("error_11157", comment: ""),
        "11158" : StringUtilities.getLocalizedString("error_11157", comment: ""),
        
        //12001 ADD_USER_ERROR
        "12001" : StringUtilities.getLocalizedString("error_12001", comment: ""),
        //12100 FIRST_NAME_REQUIRED
        "12100" : StringUtilities.getLocalizedString("error_12100", comment: ""),
        //12110 LAST_NAME_REQUIRED
        "12110" : StringUtilities.getLocalizedString("error_12110", comment: ""),
        
        
        //13001 ADD_TOPIC_ERROR
        "13001" : StringUtilities.getLocalizedString("error_13001", comment: ""),
        
        //12111 WRONG_OLD_PASSWORD
        "12111" : StringUtilities.getLocalizedString("error_12111", comment: ""),
        //12112 CHANGE_PASSWORD_ERROR
        "12112" : StringUtilities.getLocalizedString("error_12112", comment: ""),
        
        //15003 MY_USER_DELETED Login
        "15003" : StringUtilities.getLocalizedString("user_is_deleted", comment: ""),
        
        // 15002 TOPIC_NOT_FOUND
        "15002" : StringUtilities.getLocalizedString("error_15002", comment: ""),

        //1500 MY_USER_DELETED
        "15000" : StringUtilities.getLocalizedString("user_is_deleted", comment: ""),
        
        //15001 USER_DELETED
        "15001" : StringUtilities.getLocalizedString("user_is_deleted", comment: ""),
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
    
    func isLoginFail(errorCode: String) -> Bool {
        if (errorCode == "11158" || errorCode == "11142" || errorCode == "11157" || errorCode == "15000") {
            return true;
        } else {
            return false;
        }
    }
}
