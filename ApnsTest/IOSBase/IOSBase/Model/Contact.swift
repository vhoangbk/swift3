//
//  Contact.swift
//  IOSBase
//
//  Created by paraline on 2/28/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit

class Contact: NSObject {

    let id: Int64?
    var name: String
    var phone: String
    var address: String
    
    init(id: Int64) {
        self.id = id
        name = ""
        phone = ""
        address = ""
    }
    
    init(id: Int64, name: String, phone: String, address: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.address = address
    }
    
}
