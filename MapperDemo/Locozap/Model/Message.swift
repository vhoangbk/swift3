//
//  Message.swift
//  Locozap
//
//  Created by paraline on 10/13/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    static let MESSAGE_SERVER_TYPE_TEXT = 1;
    static let MESSAGE_SERVER_TYPE_IMAGE = 2;
    static let MESSAGE_SERVER_TYPE_LOCATION = 3;
    
    var id : String?;
    var toppicId : String?;
    var message : String?;
    var like : Int?;
    var fileName : String?;
    var type : Int?;
    var size : String?;
    var createdTime : String?;
    var latitude : String?;
    var longitude : String?;
    
    var isLike : Bool?;
    
    override init() {
        
    }

    init(id : String, topicId : String, message : String, like : Int, fileName : String, type : Int, size : String, createdTime : String, latitude : String, longitude : String, isLike : Bool) {
        self.id = id;
        self.toppicId = topicId;
        self.message = message;
        self.like = like;
        self.fileName = fileName;
        self.type = type;
        self.size = size;
        self.createdTime = createdTime;
        self.latitude = latitude;
        self.longitude = longitude;
        self.isLike = isLike;
    }
}
