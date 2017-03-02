//
//  ValidationUtils.swift
//  IOSBase
//
//  Created by paraline on 2/22/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit

class ValidationUtils: NSObject {

    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
