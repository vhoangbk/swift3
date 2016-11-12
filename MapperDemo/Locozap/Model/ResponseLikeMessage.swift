//
//  ResponseLikeMessage.swift
//  Locozap
//
//  Created by paraline on 11/1/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class ResponseLikeMessage: NSObject {

    var numberLike : Int?
    var messageId : String?
    var topicId : String?
    
    var user : User?
    
    init(numberLike : Int, messageId : String, topicId : String, user : User) {
        self.numberLike = numberLike;
        self.messageId = messageId;
        self.topicId = topicId;
        self.user = user;
    }

}
