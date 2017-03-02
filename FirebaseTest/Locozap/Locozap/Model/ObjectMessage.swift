/**
 * ObjectMessage
 *
 * @author : Archi-Edge
 * @copyright © 2016 LocoBee. All rights reserved.
 */

import UIKit
import ObjectMapper

class ObjectMessage: Mappable {
    
    var id : String?;
    
    var category : Int?;
    
    var title : String?;
    
    var type : Int?;
    
    var isOld : Bool?;
    
    var messageUnread : Int?;
    
    var lastMessage : Message?;
    
    var userCreate : User?;
    
    var userAction : User?;
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id    <- map["id"]
        category    <- map["category"]
        isOld    <- map["is_old"]
        title    <- map["title"]
        type    <- map["type"]
        messageUnread    <- map["message_unread"]
        userCreate    <- map["user_create"]
        userAction    <- map["action_user"]
        lastMessage    <- map["last_message"]
    }
    
    public class func createObject(userAction: User, lastMessage: Message, typeMessage: TypeMessage) -> ObjectMessage {
        let objMessage = ObjectMessage();
        objMessage.userAction = userAction;
        objMessage.lastMessage = lastMessage;
        objMessage.messageUnread = 1;
        objMessage.type = typeMessage.rawValue;
        objMessage.id = lastMessage.topicId;
        
        return objMessage;
    }
}
