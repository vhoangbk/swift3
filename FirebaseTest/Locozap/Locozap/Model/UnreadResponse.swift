//
//  UnreadResponse.swift
//  Locozap
//
//  Created by Macintosh HD on 1/24/17.
//  Copyright © 2017 paraline. All rights reserved.
//

import UIKit
import ObjectMapper

class UnreadResponse: NSObject, Mappable {
    var topic: Int!
    var notification: Int!
    var total: Int!
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        topic    <- map["topic"]
        notification    <- map["notification"]
        total    <- map["total"]
    }
}
