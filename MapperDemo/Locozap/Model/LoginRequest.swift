//
//  LoginRequest.swift
//  Locozap
//
//  Created by Hoang Nguyen on 11/12/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class LoginRequest: NSObject {

	var username : String?;
	
	var password : String?;
	
	var latitude : String?;
	
	var longitude : String?;
	
	override init() {
		
	}
	
//	init(email : String, password : String, latitude : String, longtitude : String) {
//		self.username = email;
//		self.password = password;
//		self.latitude = latitude;
//		self.longitude = longtitude;
//	}
}
