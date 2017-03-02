/**
 * ObjectNotification
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class ObjectNotification: Mappable {
    
    var id : String;
    
    var createdTime : Int?;
    
    var updatedTime : Int?;
    
    var type : Int?;
    
    var content : String?;
    
    var isRead : Bool;
    
    var userAction : User?;
    
    var lastMessage : Message?;
    
    required init?(map: Map) {
        id = "";
        isRead = true;
    }
    
    func mapping(map: Map) {
        id    <- map["id"]
        createdTime    <- map["created_time"]
        updatedTime    <- map["updated_time"]
        type    <- map["type"]
        content    <- map["content"]
        isRead    <- map["is_read"]
        userAction    <- map["action_user"]
        lastMessage <- map["message"];
    }
}
