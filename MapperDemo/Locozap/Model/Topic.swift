//
//  Topic.swift
//  Locozap
//
//  Created by MAC on 10/14/16.
//  Copyright © 2016 paraline. All rights reserved.
//

import UIKit

class Topic: NSObject {
    var content : String;
    var distance : String;
    var icon : String;
    var id : String;
    var latitude : String;
    var longitude : String;
    var messageCount : Int;
    var title : String;
    
    init(content : String, distance : String, icon : String, id : String, latitude : String, longitude : String, messageCount : Int, title : String) {
        self.content = content;
        self.distance = distance;
        self.icon = icon;
        self.id = id;
        self.latitude = latitude;
        self.longitude = longitude;
        self.messageCount = messageCount;
        self.title = title;
    }
}
