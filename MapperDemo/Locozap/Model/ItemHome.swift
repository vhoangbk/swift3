//
//  ItemHome.swift
//  Locozap
//
//  Created by MAC on 10/13/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import Foundation
class ItemHome: NSObject {
    var user : User;
    var topic : Topic;
    
    init(user : User, topic : Topic) {
        self.user = user;
        self.topic = topic;
    }
}
