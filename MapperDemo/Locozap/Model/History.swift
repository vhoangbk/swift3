//
//  History.swift
//  Locozap
//
//  Created by paraline on 10/13/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class History: NSObject {

    var user : User?;
    
    var message : Message?;
    
    init(user : User, message : Message) {
        self.user = user;
        self.message = message;
    }
    
}
