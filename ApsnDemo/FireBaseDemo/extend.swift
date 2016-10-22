//
//  extend.swift
//  FireBaseDemo
//
//  Created by Hoang Nguyen on 10/22/16.
//  Copyright © 2016 Hoang Nguyen. All rights reserved.
//

import Foundation

extension String{
	
	func trim() -> String{
		return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
	}
	
}
