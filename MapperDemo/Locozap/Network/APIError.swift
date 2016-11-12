//
//  APIError.swift
//  Locozap
//
//  Created by paraline on 11/9/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class APIError: NSObject {

	let errorCodeMessage : [String : String] = [
		
		"10000" : "token required",
		"10001" : "token not exist",
		"10002" : "offest invalid",
		"10003" : "limit invalid",
		
		//login
		"11000" : "login fail",
		"11100" : "email required",
		"11101" : "email not avaialbe",
		"11110" : "password required",
		"11120" : "longitude not avaialbe",
		"11130" : "latitude not avaialbe",
		"11140" : "login_type required",
		"11141" : "login_type invalid",
		
		//add_user
		"12000" : "duplicate email",
		"12001" : "error register",
		"12100" : "first name required",
		"12110" : "last name required"
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
